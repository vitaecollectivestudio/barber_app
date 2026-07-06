import * as admin from "firebase-admin";
import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";

admin.initializeApp();

const db = admin.firestore();

/**
 * Converts HH:mm time to total minutes.
 *
 * @param {string} time Time in HH:mm format.
 * @return {number} Total minutes.
 */
function timeToMinutes(time: string): number {
  const [h, m] = time.split(":").map(Number);
  return h * 60 + m;
}

/**
 * Returns total minutes for a Date in Europe/Rome timezone.
 *
 * @param {Date} date Date to convert.
 * @return {number} Total minutes in the day.
 */
function minutesInRome(date: Date): number {
  const parts = new Intl.DateTimeFormat("it-IT", {
    timeZone: "Europe/Rome",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).formatToParts(date);

  const hour = Number(
    parts.find((p) => p.type === "hour")?.value ?? 0
  );

  const minute = Number(
    parts.find((p) => p.type === "minute")?.value ?? 0
  );

  return hour * 60 + minute;
}

/**
 * Returns weekday id in Europe/Rome timezone.
 *
 * @param {Date} date Date to read.
 * @return {string} Lowercase weekday id.
 */
function dayIdInRome(date: Date): string {
  return new Intl.DateTimeFormat("en-US", {
    timeZone: "Europe/Rome",
    weekday: "long",
  }).format(date).toLowerCase();
}

/**
 * Validates that a booking is inside operator schedule.
 *
 * @param {{
 *   operatorId: string,
 *   startAt: Date,
 *   endAt: Date,
 * }} params Booking schedule parameters.
 * @return {Promise<void>} Resolves if schedule is valid.
 */
async function validateOperatorSchedule(params: {
  operatorId: string;
  startAt: Date;
  endAt: Date;
}) {
  const toleranceMinutes = 10;

  const dayId = dayIdInRome(params.startAt);

  const scheduleDoc = await db
    .collection("operator_schedules")
    .doc(params.operatorId)
    .collection("weekly")
    .doc(dayId)
    .get();

  if (!scheduleDoc.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Schedule operatore non configurata"
    );
  }

  const schedule = scheduleDoc.data();

  if (schedule?.enabled !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Operatore non disponibile in questo giorno"
    );
  }

  const startMin = minutesInRome(params.startAt);
  const endMin = minutesInRome(params.endAt);

  const openMin = timeToMinutes(schedule.start);
  const closeMin = timeToMinutes(schedule.end);

  const pauseStartMin = timeToMinutes(schedule.pauseStart);
  const pauseEndMin = timeToMinutes(schedule.pauseEnd);

  if (endMin <= startMin) {
    throw new HttpsError(
      "invalid-argument",
      "Orario non valido"
    );
  }

  if (
    startMin < openMin ||
    endMin > closeMin + toleranceMinutes
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Prenotazione fuori orario"
    );
  }

  const overlapsPause =
    startMin < pauseEndMin &&
    endMin > pauseStartMin + toleranceMinutes;

  if (overlapsPause) {
    throw new HttpsError(
      "failed-precondition",
      "Prenotazione durante la pausa"
    );
  }
}

/**
 * Notifies waitlist users when slots become available.
 *
 * @param {string} operatorId Operator id.
 * @param {string} dateKey Date key in yyyy-mm-dd format.
 * @return {Promise<void>} Resolves when notifications are sent.
 */
async function notifyWaitlist(
  operatorId: string,
  dateKey: string
): Promise<void> {
  const waitlistSnap = await db
    .collection("lista_attesa")
    .where("operatore", "==", operatorId)
    .where("dateKey", "==", dateKey)
    .where("notified", "==", false)
    .limit(10)
    .get();

  if (waitlistSnap.empty) {
    return;
  }

  const batch = db.batch();

  for (const doc of waitlistSnap.docs) {
    const wait = doc.data();
    const userId = wait.userId;

    if (!userId || typeof userId !== "string") {
      batch.update(doc.ref, {
        notified: true,
        notifyError: "userId mancante",
        notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      continue;
    }

    const userDoc = await db
      .collection("utenti")
      .doc(userId)
      .get();

    const token = userDoc.data()?.fcmToken;

    if (!token || typeof token !== "string") {
      batch.update(doc.ref, {
        notified: true,
        notifyError: "fcmToken mancante",
        notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      continue;
    }

    try {
      await admin.messaging().send({
  token,
  notification: {
    title: "Buone Notizie!💈",
    body: "Si è liberato un orario per il giorno richiesto.",
  },
  data: {
    type: "waitlist_slot_available",
    operatorId,
    dateKey,
  },
  apns: {
    payload: {
      aps: {
        sound: "default",
      },
    },
  },
});

      batch.update(doc.ref, {
        notified: true,
        notifyError: null,
        notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      console.log("Errore invio waitlist notification", e);

      batch.update(doc.ref, {
        notified: false,
        notifyError: "invio fallito",
        retryCount: admin.firestore.FieldValue.increment(1),
        lastNotifyAttemptAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  await batch.commit();
}

/**
 * Sends push notifications to all admin users.
 *
 * @param {{
 *   title: string,
 *   nome: string,
 *   servizio: string,
 *   startAt: Date,
 * }} params Notification data.
 * @return {Promise<void>} Resolves when notifications are sent.
 */
async function notifyAdmins(params: {
  title: string;
  nome: string;
  servizio: string;
  startAt: Date;
}): Promise<void> {
  const adminsSnap = await db
    .collection("utenti")
    .where("ruolo", "==", "admin")
    .get();

  if (adminsSnap.empty) {
    return;
  }

  const tokens = adminsSnap.docs
    .map((doc) => doc.data().fcmToken)
    .filter((token) => typeof token === "string");

  if (tokens.length === 0) {
    return;
  }

  const dataLabel = params.startAt.toLocaleDateString("it-IT", {
    timeZone: "Europe/Rome",
    day: "2-digit",
    month: "long",
  });

  const oraLabel = params.startAt.toLocaleTimeString("it-IT", {
    timeZone: "Europe/Rome",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  });

  console.log("ADMIN TOKENS:", tokens.length);

  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title: params.title,
      body:
      `${params.nome}\n` +
      `${params.servizio}\n` +
      `${dataLabel} • ${oraLabel}`,
    },

    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },

    android: {
      notification: {
        sound: "default",
      },
    },

    data: {
      type: "admin_booking_notification",
    },
  });
  response.responses.forEach((r, i) => {
    console.log(
      `TOKEN ${i}:`,
      r.success,
      r.error?.code,
      r.error?.message
    );
  });
}

export const releaseBookingSlots = onDocumentDeleted(
  "appuntamenti/{id}",
  async (event) => {
    const booking = event.data?.data();

    if (!booking) {
      return;
    }

    const bookingId =
      booking.bookingId ?? event.params.id;

    const operatorId = booking.operatorId;
    const dateKey = booking.dateKey;
    const durata = booking.durata ?? 30;

    const startAt = booking.startAt?.toDate();

    if (
      !bookingId ||
      !operatorId ||
      !dateKey ||
      !startAt
    ) {
      console.log(
        "releaseBookingSlots: dati booking incompleti"
      );
      return;
    }

    const batch = db.batch();

    const slots: Record<string, boolean> = {};

    for (let i = 0; i < durata; i += 10) {
      const slotDate =
        new Date(startAt.getTime() + i * 60000);

      const slotKey =
        slotDate.toLocaleTimeString("it-IT", {
          timeZone: "Europe/Rome",
          hour: "2-digit",
          minute: "2-digit",
          hour12: false,
        });

      const lockId =
        `${operatorId}_${dateKey}_${slotKey}`;

      const lockRef =
        db.collection("booking_locks").doc(lockId);

      const lockSnap = await lockRef.get();

      if (
        lockSnap.exists &&
        lockSnap.data()?.bookingId === bookingId
      ) {
        batch.delete(lockRef);
        slots[slotKey] = true;
      }
    }

    if (Object.keys(slots).length === 0) {
      console.log(
        "releaseBookingSlots: nessun lock da liberare",
        bookingId
      );
      return;
    }

    const availabilityDocId =
      `${operatorId}_${dateKey}`;

    const availabilityRef =
      db.collection("availability_public")
        .doc(availabilityDocId);

    batch.set(
      availabilityRef,
      {
        operatorId,
        dateKey,
        slots,
      },
      {merge: true}
    );

    await batch.commit();

    console.log(
      "Slot liberati in sicurezza:",
      availabilityDocId,
      bookingId
    );
  }
);

export const createBooking = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Utente non autenticato"
      );
    }

    const data = request.data;

    const operatorId =
  String(data.operatorId ?? "").trim().toLowerCase();

    const serviceId =
  String(data.serviceId ?? "").trim();

    const startAt =
  new Date(data.startAt);

    if (!serviceId) {
      throw new HttpsError(
        "invalid-argument",
        "Servizio non valido"
      );
    }

    const serviceDoc = await db
      .collection("services")
      .doc(serviceId)
      .get();

    if (!serviceDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Servizio inesistente"
      );
    }

    const serviceData = serviceDoc.data();

    if (serviceData?.active !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Servizio non disponibile"
      );
    }

    const servizio =
  String(serviceData?.name ?? "").trim();

    const durata =
  Number(serviceData?.durationMinutes);

    const endAt =
  new Date(startAt.getTime() + durata * 60000);

    const dateKey =
  startAt.toLocaleDateString("en-CA", {
    timeZone: "Europe/Rome",
  });

    if (!operatorId) {
      throw new HttpsError(
        "invalid-argument",
        "Operatore non valido"
      );
    }

    const operatorDoc = await db
      .collection("operators")
      .doc(operatorId)
      .get();

    if (!operatorDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Operatore inesistente"
      );
    }

    if (operatorDoc.data()?.active !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Operatore non disponibile"
      );
    }

    const giornoChiusoSnap = await db
      .collection("giorni_chiusi")
      .where("operatore", "==", operatorId)
      .where("dateKey", "==", dateKey)
      .limit(1)
      .get();

    const isGiornoChiuso = !giornoChiusoSnap.empty;

    if (isGiornoChiuso) {
      throw new HttpsError(
        "failed-precondition",
        "Giornata chiusa"
      );
    }

    if (
      !dateKey ||
      typeof dateKey !== "string"
    ) {
      throw new HttpsError(
        "invalid-argument",
        "dateKey non valida"
      );
    }

    if (
      !Number.isFinite(durata) ||
  durata <= 0 ||
  durata > 240 ||
  durata % 5 !== 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Durata non valida"
      );
    }

    if (
      isNaN(startAt.getTime()) ||
      isNaN(endAt.getTime())
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Data non valida"
      );
    }

    if (startAt.getTime() < Date.now()) {
      throw new HttpsError(
        "invalid-argument",
        "Data nel passato"
      );
    }

    await validateOperatorSchedule({
      operatorId,
      startAt,
      endAt,
    });

    const userDoc = await db
      .collection("utenti")
      .doc(request.auth.uid)
      .get();

    const userData = userDoc.data() || {};

    const nome =
  `${userData.nome ?? ""} ${userData.cognome ?? ""}`
    .trim();

    const telefono =
      userData.telefono ?? "";

    const appointmentsRef =
      db.collection("appuntamenti");

    const bookingRef =
      appointmentsRef.doc();

    const now =
      admin.firestore.FieldValue.serverTimestamp();

    const slotKeys: string[] = [];

    for (
      let offset = 0;
      offset < durata;
      offset += 10
    ) {
      const slotDate =
        new Date(startAt.getTime() + offset * 60000);

      const slotKey =
        slotDate.toLocaleTimeString("it-IT", {
          timeZone: "Europe/Rome",
          hour: "2-digit",
          minute: "2-digit",
          hour12: false,
        });

      slotKeys.push(slotKey);
    }

    const orariBloccatiSnap = await db
      .collection("orari_bloccati")
      .where("operatore", "==", operatorId)
      .where("dateKey", "==", dateKey)
      .get();

    const hasBlockedSlot =
  orariBloccatiSnap.docs.some((doc) => {
    const blockedOra = doc.data().ora;

    return (
      typeof blockedOra === "string" &&
      slotKeys.includes(blockedOra)
    );
  });

    if (hasBlockedSlot) {
      throw new HttpsError(
        "failed-precondition",
        "Orario bloccato"
      );
    }

    const lockRefs = slotKeys.map((slotKey) => {
      const lockId =
  `${operatorId}_${dateKey}_${slotKey}`;

      return db
        .collection("booking_locks")
        .doc(lockId);
    });

    await db.runTransaction(async (transaction) => {
      const lockSnapshots = await Promise.all(
        lockRefs.map((lockRef) =>
          transaction.get(lockRef)
        )
      );

      const hasLockedSlot =
        lockSnapshots.some((snapshot) => snapshot.exists);

      if (hasLockedSlot) {
        throw new HttpsError(
          "already-exists",
          "Slot occupato"
        );
      }

      lockRefs.forEach((lockRef, index) => {
        transaction.set(lockRef, {
          operatorId,
          serviceId,
          dateKey,
          slotKey: slotKeys[index],
          bookingId: bookingRef.id,
          userId: request.auth!.uid,
          servizio: servizio,
          durata: durata,
          startAt:
            admin.firestore.Timestamp.fromDate(startAt),
          endAt:
            admin.firestore.Timestamp.fromDate(endAt),
          createdAt: now,
          status: "booked",
        });
      });

      transaction.set(bookingRef, {
        bookingId: bookingRef.id,
        operatorId,
        serviceId,
        dateKey,

        startAt:
          admin.firestore.Timestamp.fromDate(startAt),

        endAt:
          admin.firestore.Timestamp.fromDate(endAt),

        createdAt: now,
        updatedAt: now,

        status: "booked",

        userId: request.auth!.uid,

        nome,
        telefono,
        servizio: servizio,

        durata: durata,

        notification2hId:
          typeof data.notification2hId === "number" ?
            data.notification2hId :
            null,

        notification24hId:
          typeof data.notification24hId === "number" ?
            data.notification24hId :
            null,
      });

      const availabilityDocId =
  `${operatorId}_${dateKey}`;

      const availabilityRef =
  db.collection("availability_public")
    .doc(availabilityDocId);

      const slots: Record<string, boolean> = {};

      slotKeys.forEach((slotKey) => {
        slots[slotKey] = false;
      });

      transaction.set(
        availabilityRef,
        {
          operatorId,
          dateKey,
          slots,
        },
        {merge: true}
      );
    });

    try {
      await notifyAdmins({
        title: "🟢NUOVA PRENOTAZIONE🟢",
        nome,
        servizio,
        startAt,
      });
    } catch (e) {
      console.error("Errore notifica admin nuova prenotazione", e);
    }
    return {
      success: true,
      bookingId: bookingRef.id,
    };
  }
);


export const createWalkInBooking = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Utente non autenticato"
      );
    }

    const userDoc = await db
      .collection("utenti")
      .doc(request.auth.uid)
      .get();

    const role =
  userDoc.data()?.ruolo ?? "cliente";

    const isStaff =
  role === "admin" ||
  role === "barber";

    if (!isStaff) {
      throw new HttpsError(
        "permission-denied",
        "Permesso negato"
      );
    }

    const data = request.data;

    const operatorId =
  String(data.operatorId ?? "").trim().toLowerCase();

    const startAt =
  new Date(data.startAt);

    const durata =
  Number(data.durata);

    const endAt =
  new Date(startAt.getTime() + durata * 60000);

    const dateKey =
  startAt.toLocaleDateString("en-CA", {
    timeZone: "Europe/Rome",
  });

    if (!operatorId) {
      throw new HttpsError(
        "invalid-argument",
        "Operatore non valido"
      );
    }

    const operatorDoc = await db
      .collection("operators")
      .doc(operatorId)
      .get();

    if (!operatorDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Operatore inesistente"
      );
    }

    if (operatorDoc.data()?.active !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Operatore non disponibile"
      );
    }

    const giornoChiusoSnap = await db
      .collection("giorni_chiusi")
      .where("operatore", "==", operatorId)
      .where("dateKey", "==", dateKey)
      .limit(1)
      .get();

    const isGiornoChiuso = !giornoChiusoSnap.empty;

    if (isGiornoChiuso) {
      throw new HttpsError(
        "failed-precondition",
        "Giornata chiusa"
      );
    }
    // VALIDAZIONI

    if (
      !Number.isFinite(durata) ||
durata <= 0 ||
durata > 240 ||
durata % 5 !== 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Durata non valida"
      );
    }

    if (
      !data.servizio ||
  typeof data.servizio !== "string"
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Servizio non valido"
      );
    }

    if (
      isNaN(startAt.getTime()) ||
  isNaN(endAt.getTime())
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Data non valida"
      );
    }

    await validateOperatorSchedule({
      operatorId,
      startAt,
      endAt,
    });

    const appointmentsRef =
  db.collection("appuntamenti");

    const bookingRef =
  appointmentsRef.doc();

    const now =
  admin.firestore.FieldValue.serverTimestamp();

    const slotKeys: string[] = [];

    for (
      let offset = 0;
      offset < durata;
      offset += 10
    ) {
      const slotDate =
    new Date(startAt.getTime() + offset * 60000);

      const slotKey =
    slotDate.toLocaleTimeString("it-IT", {
      timeZone: "Europe/Rome",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    });

      slotKeys.push(slotKey);
    }

    const orariBloccatiSnap = await db
      .collection("orari_bloccati")
      .where("operatore", "==", operatorId)
      .where("dateKey", "==", dateKey)
      .get();

    const hasBlockedSlot =
  orariBloccatiSnap.docs.some((doc) => {
    const blockedOra = doc.data().ora;

    return (
      typeof blockedOra === "string" &&
      slotKeys.includes(blockedOra)
    );
  });

    if (hasBlockedSlot) {
      throw new HttpsError(
        "failed-precondition",
        "Orario bloccato"
      );
    }

    const lockRefs = slotKeys.map((slotKey) => {
      const lockId =
    `${operatorId}_${dateKey}_${slotKey}`;

      return db
        .collection("booking_locks")
        .doc(lockId);
    });

    await db.runTransaction(async (transaction) => {
      const lockSnapshots = await Promise.all(
        lockRefs.map((lockRef) =>
          transaction.get(lockRef)
        )
      );

      const hasLockedSlot =
    lockSnapshots.some(
      (snapshot) => snapshot.exists
    );

      if (hasLockedSlot) {
        throw new HttpsError(
          "already-exists",
          "Slot occupato"
        );
      }

      lockRefs.forEach((lockRef, index) => {
        transaction.set(lockRef, {
          operatorId,
          dateKey,
          slotKey: slotKeys[index],
          bookingId: bookingRef.id,

          userId: data.userId ?? null,

          servizio: data.servizio,
          durata: durata,

          startAt:
        admin.firestore.Timestamp.fromDate(startAt),

          endAt:
        admin.firestore.Timestamp.fromDate(endAt),

          createdAt: now,

          status: "booked",
        });
      });

      transaction.set(bookingRef, {
        bookingId: bookingRef.id,

        operatorId,
        dateKey,

        startAt:
      admin.firestore.Timestamp.fromDate(startAt),

        endAt:
      admin.firestore.Timestamp.fromDate(endAt),

        createdAt: now,
        updatedAt: now,

        status: "booked",

        userId: data.userId ?? null,

        nome: data.nome ?? "",
        telefono: data.telefono ?? "",

        servizio: data.servizio,
        durata: durata,

        walkin: true,
      });

      const availabilityDocId =
    `${operatorId}_${dateKey}`;

      const availabilityRef =
    db.collection("availability_public")
      .doc(availabilityDocId);

      const slots: Record<string, boolean> = {};

      slotKeys.forEach((slotKey) => {
        slots[slotKey] = false;
      });

      transaction.set(
        availabilityRef,
        {
          operatorId,
          dateKey,
          slots,
        },
        {merge: true}
      );
    });

    return {
      success: true,
      bookingId: bookingRef.id,
    };
  }
);
export const cancelBooking = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Utente non autenticato"
      );
    }

    const bookingId = request.data.bookingId;

    if (!bookingId) {
      throw new HttpsError(
        "invalid-argument",
        "bookingId mancante"
      );
    }

    const bookingRef =
      db.collection("appuntamenti")
        .doc(bookingId);

    const bookingDoc =
      await bookingRef.get();

    if (!bookingDoc.exists) {
      throw new HttpsError(
        "not-found",
        "Prenotazione non trovata"
      );
    }

    const booking =
      bookingDoc.data();

    const isOwner =
      booking?.userId === request.auth.uid;

    const userDoc = await db
      .collection("utenti")
      .doc(request.auth.uid)
      .get();

    const role =
      userDoc.data()?.ruolo ?? "cliente";

    const isStaff =
      role === "admin" ||
      role === "barber";

    if (!isOwner && !isStaff) {
      throw new HttpsError(
        "permission-denied",
        "Permesso negato"
      );
    }

    const operatorId = booking?.operatorId;
    const dateKey = booking?.dateKey;
    const durata = booking?.durata ?? 30;

    const startAt =
  booking?.startAt?.toDate();

    if (!startAt) {
      throw new HttpsError(
        "internal",
        "startAt mancante"
      );
    }

    await db.runTransaction(async (transaction) => {
      transaction.delete(bookingRef);

      for (
        let offset = 0;
        offset < durata;
        offset += 10
      ) {
        const slotDate =
      new Date(
        startAt.getTime() + offset * 60000
      );

        const slotKey =
      slotDate.toLocaleTimeString("it-IT", {
        timeZone: "Europe/Rome",
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
      });

        const lockId =
      `${operatorId}_${dateKey}_${slotKey}`;

        const lockRef =
      db.collection("booking_locks")
        .doc(lockId);

        transaction.delete(lockRef);
      }

      const availabilityDocId =
  `${operatorId}_${dateKey}`;

      const availabilityRef =
  db.collection("availability_public")
    .doc(availabilityDocId);

      const slots: Record<string, boolean> = {};

      for (
        let offset = 0;
        offset < durata;
        offset += 10
      ) {
        const slotDate =
    new Date(startAt.getTime() + offset * 60000);

        const slotKey =
    slotDate.toLocaleTimeString("it-IT", {
      timeZone: "Europe/Rome",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    });

        slots[slotKey] = true;
      }

      transaction.set(
        availabilityRef,
        {
          operatorId,
          dateKey,
          slots,
        },
        {merge: true}
      );
    });

    try {
      await notifyAdmins({
        title: "❌CANCELLAZIONE PRENOTAZIONE❌",
        nome: booking?.nome ?? "Cliente",
        servizio: booking?.servizio ?? "Servizio",
        startAt,
      });
    } catch (e) {
      console.error("Errore notifica admin cancellazione", e);
    }

    if (operatorId && dateKey) {
      try {
        await notifyWaitlist(
          String(operatorId).toLowerCase(),
          String(dateKey)
        );
      } catch (e) {
        console.error("Errore notifyWaitlist", e);
      }
    }

    return {
      success: true,
    };
  }
);
export const deleteClientAccount = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Non autenticato");
    }

    const adminDoc = await db
      .collection("utenti")
      .doc(request.auth.uid)
      .get();

    const role = adminDoc.data()?.ruolo ?? "cliente";

    if (role !== "admin" && role !== "barber") {
      throw new HttpsError("permission-denied", "Permesso negato");
    }

    const uid = String(request.data.uid ?? "").trim();

    if (!uid) {
      throw new HttpsError("invalid-argument", "UID mancante");
    }

    const batch = db.batch();

    batch.delete(
      db.collection("utenti").doc(uid)
    );

    const waitlistSnap = await db
      .collection("lista_attesa")
      .where("userId", "==", uid)
      .get();

    waitlistSnap.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    const bookingsSnap = await db
      .collection("appuntamenti")
      .where("userId", "==", uid)
      .get();

    bookingsSnap.docs.forEach((doc) => {
      batch.update(doc.ref, {
        userId: null,
        nome: "Cliente eliminato",
        telefono: "",
      });
    });

    await batch.commit();

    try {
      await admin.auth().deleteUser(uid);
    } catch (e) {
      console.log("Auth user già eliminato o non trovato", e);
    }

    return {
      success: true,
    };
  }
);
