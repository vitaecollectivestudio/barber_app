import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'register_page.dart';

import '../../main.dart';
//////////////// LOGIN //////////////////

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late VideoPlayerController _controller;
  final user = TextEditingController();
  final pass = TextEditingController();
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  @override
void initState() {
  super.initState();

  _controller = VideoPlayerController.asset('assets/video/barber.mp4')
    ..initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
      _controller.setVolume(0);
    });
}

@override
void dispose() {

  user.dispose();
  pass.dispose();

  emailFocus.dispose();
  passFocus.dispose();

  _controller.dispose();

  super.dispose();
}

  void login() async {

  try {

    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: user.text.trim(),
      password: pass.text.trim(),
    );


    if (!mounted) return;


    await salvaUtente(cred.user!);



    await FirebaseMessaging.instance.requestPermission();

// 👇 ASPETTA APNS TOKEN (QUESTO È IL FIX)
String? apnsToken;
for (int i = 0; i < 10; i++) {
  apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) break;
  await Future.delayed(const Duration(milliseconds: 500));
}


// serve Apple Developer
final token = await FirebaseMessaging.instance.getToken();


    if (token != null) {

      await FirebaseFirestore.instance
          .collection('utenti')
          .doc(cred.user!.uid)
          .set({
            'fcmToken': token,
          }, SetOptions(merge: true));

    } else {
    }

  } on FirebaseAuthException catch (e) {

  if (!mounted) return;

  String messaggio = "Accesso non riuscito.";

  switch (e.code) {

    case 'invalid-credential':
      messaggio =
          "Email o password non corretti.";
      break;

    case 'wrong-password':
      messaggio =
          "Password non corretta.";
      break;

    case 'user-not-found':
      messaggio =
          "Nessun account trovato con questa email.";
      break;

    case 'invalid-email':
      messaggio =
          "Inserisci un indirizzo email valido.";
      break;

    case 'too-many-requests':
      messaggio =
          "Troppi tentativi. Riprova più tardi.";
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(

      behavior: SnackBarBehavior.floating,

      backgroundColor: const Color(0xFF181818),

      elevation: 0,

      margin: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        26,
      ),

      duration: const Duration(seconds: 3),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: BorderSide(
          color: Colors.white.withOpacity(0.06),
        ),
      ),

      content: Row(
        children: [

          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.12),
            ),

            child: const Icon(
              Icons.close_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              messaggio,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
Future<void> loginGoogle() async {
  try {

    UserCredential userCred;

    if (kIsWeb) {
      // 🌐 WEB
      final provider = GoogleAuthProvider();
      userCred = await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      // 📱 MOBILE
      final googleSignIn = GoogleSignIn();

      // await googleSignIn.disconnect();
      // await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCred = await FirebaseAuth.instance
          .signInWithCredential(credential);
    }

    // 👇 QUI UGUALE PER ENTRAMBI
    await salvaUtente(userCred.user!);
    final token = await FirebaseMessaging.instance.getToken();

if (token != null) {
  await FirebaseFirestore.instance
    .collection('utenti')
    .doc(userCred.user!.uid)
    .update({
  'fcmToken': token,
});
}

if (mounted) {
}

  } catch (_) {

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,

      backgroundColor: const Color(0xFF181818),

      elevation: 0,

      margin: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        26,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      content: const Text(
        "Accesso Google non disponibile.",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
}
Future<void> loginFacebook() async {
  try {
    final result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      final userCred = await FirebaseAuth.instance
          .signInWithCredential(credential);

      await salvaUtente(userCred.user!);
      final token = await FirebaseMessaging.instance.getToken();

if (token != null) {
  await FirebaseFirestore.instance
    .collection('utenti')
    .doc(userCred.user!.uid)
    .update({
  'fcmToken': token,
});
}

if (mounted) {
}

    }
  } catch (_) {

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,

      backgroundColor: const Color(0xFF181818),

      elevation: 0,

      margin: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        26,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      content: const Text(
        "Accesso Facebook non disponibile.",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
}
Future<void> salvaUtente(User user) async {
  final ref = FirebaseFirestore.instance
      .collection('utenti')
      .doc(user.uid);

  final doc = await ref.get();

  if (!doc.exists) {
    await ref.set({
      "email": user.email,
      "uid": user.uid,
      "nome": user.displayName ?? user?.email ?? "Cliente",
      "creatoIl": Timestamp.now(),


      "ruolo": "cliente",
    });
  }
}

  @override
Widget build(BuildContext context) {
return TweenAnimationBuilder(
  duration: const Duration(milliseconds: 400),
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    );
  },
  child: Scaffold(    resizeToAvoidBottomInset: true,
    body: Stack(
  children: [

    // 🎥 VIDEO SFONDO
    if (_controller.value.isInitialized)
      SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),

    // 🌑 OVERLAY SCURO
    Container(
      color: Colors.black.withOpacity(0.72),
    ),

    // 👇 IL TUO CONTENUTO (IDENTICO)
    SafeArea(
  child: SizedBox.expand(

    child: SingleChildScrollView(

      child: ConstrainedBox(

        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height,
        ),

        child: Padding(

          padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width * 0.06,
          ),

          child: IntrinsicHeight(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.center,

              children: [

                SizedBox(
                  height:
                      MediaQuery.of(context)
                              .size
                              .height *
                          0.08,
                ),

                // 🔥 LOGO
                const Logo3D(),

                const SizedBox(height: 20),

                const Text(
                  "BENVENUTO/A!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Accedi per prenotare il tuo taglio o registrati",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 40),

                // 📧 EMAIL
                TextField(
                  controller: user,
                  focusNode: emailFocus,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email
                  ],

                  onSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(passFocus);
                  },

                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor:
                        Colors.black.withOpacity(0.6),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔒 PASSWORD
                TextField(
                  controller: pass,
                  focusNode: passFocus,
                  obscureText: true,

                  textInputAction:
                      TextInputAction.done,

                  autofillHints: const [
                    AutofillHints.password
                  ],

                  onSubmitted: (_) {
                    login();
                  },

                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor:
                        Colors.black.withOpacity(0.6),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔥 LOGIN BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF00C853),

                      foregroundColor:
                          Colors.black,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),
                    ),

                    onPressed: () {
                      login();
                    },

                    child: const Text(
                      "Accedi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔵 GOOGLE
                SizedBox(
                  width: double.infinity,

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                              14),

                      color: Colors.white,
                    ),

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(
                              14),

                      onTap: () {
                        loginGoogle();
                      },

                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [

                            Image.network(
                              "https://cdn-icons-png.flaticon.com/512/2991/2991148.png",
                              width: 22,
                            ),

                            const SizedBox(
                                width: 10),

                            const Text(
                              "Continua con Google",

                              style: TextStyle(
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔵 FACEBOOK
                SizedBox(
                  width: double.infinity,

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                              14),

                      color:
                          const Color(0xFF1877F2),
                    ),

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(
                              14),

                      onTap: loginFacebook,

                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: const [

                            Icon(
                              Icons.facebook,
                              color: Colors.white,
                            ),

                            SizedBox(width: 10),

                            Text(
                              "Continua con Facebook",

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 📝 REGISTRAZIONE
                TextButton(
                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const RegisterPage(),
                      ),
                    );
                  },

                  child: const Text(
                    "Non hai un account? Registrati",

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                Text(
                  "Registrandoti accetti la Privacy Policy",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height:
                      MediaQuery.of(context)
                              .padding
                              .bottom +
                          24,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
),

     ],
    ),
  ),
  );
  }
}