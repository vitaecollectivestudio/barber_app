const functions = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notificaListaAttesa = functions.onDocumentDeleted(
  "appuntamenti/{id}",
  async (event) => {

    const appuntamento = event.data.data();

    const data = appuntamento.data;
    const operatore = appuntamento.operatore;

    const lista = await admin.firestore()
      .collection("lista_attesa")
      .where("operatore", "==", operatore)
      .where("data", "==", data)
      .get();

    if (lista.empty) {
      console.log("Nessuno in lista attesa");
      return null;
    }

    const tokens = [];

    lista.forEach(doc => {
      const token = doc.data().fcmToken;

      if (token) {
        tokens.push(token);
      }
    });

    if (tokens.length === 0) {
      console.log("Nessun token");
      return null;
    }

    const message = {
  notification: {
    title: "Nuova disponibilità ✂️",
    body: "È disponibile un nuovo appuntamento per il giorno richiesto.",
  },

  android: {
    priority: "high",

    notification: {
      sound: "default",
      channelId: "high_importance_channel",
      priority: "high",
      defaultSound: true,
      defaultVibrateTimings: true,
    },
  },

  apns: {
    payload: {
      aps: {
        sound: "default",
      },
    },
  },

  tokens: tokens,
};

    await admin.messaging().sendEachForMulticast(message);

    console.log("Notifiche inviate");

    return null;
  }
);