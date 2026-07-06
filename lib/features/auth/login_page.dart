import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'register_page.dart';
import 'package:barber_app/services/notification_service.dart';
import 'package:barber_app/core/dialogs/premium_alert_dialog.dart';
import '../../main.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
  bool isLoading = false;

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
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.text.trim(),
        password: pass.text.trim(),
      );

      if (!mounted) return;

      await salvaUtente(cred.user!);

      await saveCurrentFcmToken();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      String messaggio = "Accesso non riuscito.";

      switch (e.code) {
        case 'invalid-credential':
          messaggio = "Email o password non corretti.";
          break;
        case 'wrong-password':
          messaggio = "Password non corretta.";
          break;
        case 'user-not-found':
          messaggio = "Nessun account trovato con questa email.";
          break;
        case 'invalid-email':
          messaggio = "Inserisci un indirizzo email valido.";
          break;
        case 'too-many-requests':
          messaggio = "Troppi tentativi. Riprova più tardi.";
          break;
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF181818),
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 26),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withOpacity(0.06)),
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

        provider.setCustomParameters({'prompt': 'select_account'});

        userCred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn();

        // Evita il rientro automatico con l'account precedente
        try {
          await googleSignIn.signOut();
        } catch (_) {}

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // 👇 QUI UGUALE PER ENTRAMBI
      await salvaUtente(userCred.user!);
      await saveCurrentFcmToken();

      if (mounted) {}
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          backgroundColor: const Color(0xFF181818),

          elevation: 0,

          margin: const EdgeInsets.fromLTRB(18, 0, 18, 26),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          content: const Text(
            "Accesso Google non disponibile.",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();

    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> loginApple() async {
  try {
    HapticFeedback.lightImpact();

    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final identityToken = appleCredential.identityToken;

    if (identityToken == null) {
      throw FirebaseAuthException(
        code: "missing-identity-token",
        message: "Apple non ha restituito un identity token valido.",
      );
    }

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    final userCred = await FirebaseAuth.instance.signInWithCredential(
      oauthCredential,
    );

    await salvaUtente(userCred.user!);
    await saveCurrentFcmToken();
  } catch (_) {
  

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        content: const Text(
          "Accesso Apple non disponibile.",
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
    final ref = FirebaseFirestore.instance.collection('utenti').doc(user.uid);

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

  bool get isDesktop => MediaQuery.of(context).size.width >= 900;

  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  double get maxContentWidth {
    if (isDesktop) return 460;
    if (isTablet) return 520;
    return double.infinity;
  }

  EdgeInsets get pagePadding {
    if (isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 36);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 54, vertical: 30);
    }
    return const EdgeInsets.symmetric(horizontal: 22, vertical: 22);
  }

  double get titleSize {
    if (isDesktop) return 38;
    if (isTablet) return 36;
    return 32;
  }

  void showPremiumMessage({
    required String message,
    IconData icon = Icons.check_rounded,
    Color color = const Color(0xFF00C853),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 28),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🎥 VIDEO SFONDO
              if (_controller.value.isInitialized)
                Positioned.fill(
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
              Container(color: Colors.black.withOpacity(0.72)),

              // 👇 IL TUO CONTENUTO (IDENTICO)
              // 👇 CONTENUTO RESPONSIVE
              TweenAnimationBuilder(
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width >= 900
                                  ? 580
                                  : MediaQuery.of(context).size.width >= 600
                                  ? 520
                                  : double.infinity,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width >= 900
                                    ? 40
                                    : MediaQuery.of(context).size.width >= 600
                                    ? 54
                                    : 22,
                                vertical:
                                    MediaQuery.of(context).size.width >= 900
                                    ? 36
                                    : 22,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 26),

                                  const Logo3D(),

                                  const SizedBox(height: 26),

                                  Text(
                                    "Benvenuto/a!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width >=
                                              900
                                          ? 38
                                          : MediaQuery.of(context).size.width >=
                                                600
                                          ? 36
                                          : 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width >= 600
                                          ? 28
                                          : 24,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width >= 900
                                            ? 22
                                            : 32,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.10),
                                          Colors.white.withOpacity(0.035),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.55),
                                          blurRadius: 34,
                                          offset: const Offset(0, 18),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Accedi al tuo profilo",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          "Prenota, gestisci e controlla i tuoi appuntamenti.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.48,
                                            ),
                                            fontSize: 13,
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 26),

                                        TextField(
                                          controller: user,
                                          focusNode: emailFocus,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          onSubmitted: (_) {
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(passFocus);
                                          },
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Email",
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.35,
                                              ),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.alternate_email_rounded,
                                              color: Colors.white.withOpacity(
                                                0.45,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(
                                              0.38,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 18,
                                                  vertical: 18,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF00C853),
                                                width: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        TextField(
                                          controller: pass,
                                          focusNode: passFocus,
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          onSubmitted: (_) => login(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Password",
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.35,
                                              ),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.white.withOpacity(
                                                0.45,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(
                                              0.38,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 18,
                                                  vertical: 18,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF00C853),
                                                width: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () async {
                                              final email = user.text.trim();

                                              if (email.isEmpty) {
                                                showPremiumMessage(
                                                  message:
                                                      "Inserisci prima la tua email.",
                                                  icon: Icons
                                                      .info_outline_rounded,
                                                  color: Colors.orangeAccent,
                                                );
                                                return;
                                              }

                                              try {
                                                await FirebaseAuth.instance
                                                    .sendPasswordResetEmail(
                                                      email: email,
                                                    );

                                                if (!mounted) return;

                                                showPremiumMessage(
                                                  message:
                                                      "Email di recupero inviata. Controlla la tua casella di posta.",
                                                  icon: Icons
                                                      .mark_email_read_rounded,
                                                  color: const Color(
                                                    0xFF00C853,
                                                  ),
                                                );
                                              } catch (e) {
                                                if (!mounted) return;

                                                showPremiumMessage(
                                                  message:
                                                      "Impossibile inviare l'email di recupero. Riprova.",
                                                  icon: Icons
                                                      .error_outline_rounded,
                                                  color: Colors.redAccent,
                                                );
                                              }
                                            },
                                            child: Text(
                                              "Password dimenticata?",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.48,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Container(
                                          width: double.infinity,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF69F0AE),
                                                Color(0xFF00C853),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF00C853,
                                                ).withOpacity(0.38),
                                                blurRadius: 24,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              onTap: isLoading ? null : login,
                                              child: Center(
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  child: isLoading
                                                      ? const SizedBox(
                                                          key: ValueKey(
                                                            "loading",
                                                          ),
                                                          width: 23,
                                                          height: 23,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.4,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                        )
                                                      : const Row(
                                                          key: ValueKey(
                                                            "login",
                                                          ),
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "ACCEDI",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                letterSpacing:
                                                                    1.7,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_rounded,
                                                              color:
                                                                  Colors.black,
                                                              size: 20,
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 22),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.white.withOpacity(
                                                  0.08,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              child: Text(
                                                "accesso rapido",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.36),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.white.withOpacity(
                                                  0.08,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 18),

                                        LayoutBuilder(
                                          builder: (context, buttonConstraints) {
                                            final googleButton = OutlinedButton(
                                              onPressed: loginGoogle,
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                    ),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.34),
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.g_mobiledata_rounded,
                                                    color: Color(0xFFEA4335),
                                                    size: 30,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    "Google",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            final showAppleButton =
                                                kIsWeb ||
                                                defaultTargetPlatform ==
                                                    TargetPlatform.iOS;

                                            final appleButton = OutlinedButton(
                                              onPressed: loginApple,
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                    ),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.34),
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.apple,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Apple",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (!showAppleButton) {
                                              return SizedBox(
                                                width: double.infinity,
                                                child: googleButton,
                                              );
                                            }

                                            return Row(
                                              children: [
                                                Expanded(child: googleButton),
                                                const SizedBox(width: 12),
                                                Expanded(child: appleButton),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          reverseTransitionDuration:
                                              const Duration(milliseconds: 250),
                                          pageBuilder: (_, animation, __) =>
                                              const RegisterPage(),
                                          transitionsBuilder:
                                              (_, animation, __, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Non hai un account? Registrati",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.66),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    "Registrandoti accetti la Privacy Policy",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.32),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
