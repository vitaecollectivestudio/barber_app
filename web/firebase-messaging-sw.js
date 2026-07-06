importScripts("https://www.gstatic.com/firebasejs/11.9.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/11.9.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "TUA_API_KEY",
  authDomain: "vitae-3ee57.firebaseapp.com",
  projectId: "vitae-3ee57",
  messagingSenderId: "54159583135",
  appId: "1:54159583135:web:69be211c59956c9384bfaa",
});

const messaging = firebase.messaging();