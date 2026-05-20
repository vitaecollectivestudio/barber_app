const {onDocumentDeleted} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notificaListaAttesa = onDocumentDeleted(
  "appuntamenti/{appId}",

  async (event) => {

    const snap = event.data;

    if (!snap) return;

    const appuntamento = snap.data();

    const data = appuntamento.data.toDate();

    const operatore = appuntamento.operatore;

    const servizio = appuntamento.servizio;

    // cerca utenti lista attesa
    const waitlistSnapshot = await admin
      .firestore()
      .collection("lista_attesa")
      .get();

    const utentiInteressati = waitlistSnapshot.docs.filter((doc) => {

      const d = doc.data();

      const dataLista = d.data.toDate();

      return (
        dataLista.getDate() === data.getDate() &&
        dataLista.getMonth() === data.getMonth() &&
        dataLista.getFullYear() === data.getFullYear() &&
        d.operatore === operatore
      );
    });

    // invia notifiche
    const notifications = utentiInteressati.map(async (doc) => {

      const d = doc.data();

      if (!d.fcmToken) return null;

      return admin.messaging().send({
        token: d.fcmToken,

        notification: {
          title: "Slot disponibile ✂️",
          body: `${operatore} ha di nuovo disponibilità il ${data.getDate()}/${data.getMonth() + 1}`,
        },

        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          servizio: servizio || "",
        },
      });
    });

    await Promise.all(notifications);

    return null;
  }
);