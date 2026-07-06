import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nome = TextEditingController();
  final cognome = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final telefono = TextEditingController();

  final nomeFocus = FocusNode();
  final cognomeFocus = FocusNode();
  final emailFocus = FocusNode();
  final telefonoFocus = FocusNode();
  final passwordFocus = FocusNode();

  bool loading = false;

  @override
  void dispose() {
    nome.dispose();
    cognome.dispose();
    email.dispose();
    password.dispose();
    telefono.dispose();

    nomeFocus.dispose();
    cognomeFocus.dispose();
    emailFocus.dispose();
    telefonoFocus.dispose();
    passwordFocus.dispose();

    super.dispose();
  }

  Future<void> register() async {
    if (loading) return;

    if (nome.text.trim().isEmpty ||
        cognome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.trim().isEmpty ||
        telefono.text.trim().isEmpty) {
      _showPremiumMessage(
  message: "Compila tutti i campi.",
  icon: Icons.info_outline_rounded,
  color: Colors.orangeAccent,
);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('utenti')
          .doc(cred.user!.uid)
          .set({
        "nome": nome.text.trim(),
        "cognome": cognome.text.trim(),
        "email": email.text.trim(),
        "telefono": telefono.text.trim(),
        "ruolo": "cliente",
        "uid": cred.user!.uid,
        "creatoIl": Timestamp.now(),
      });

await saveCurrentFcmToken();

      if (!mounted) return;
      _showPremiumMessage(
  message: "Account creato con successo.",
  icon: Icons.check_rounded,
  color: const Color(0xFF00C853),
);

await Future.delayed(
  const Duration(milliseconds: 900),
);
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = "Registrazione non riuscita.";

      switch (e.code) {
        case 'email-already-in-use':
          message = "Questa email è già registrata.";
          break;
        case 'weak-password':
          message = "Password troppo debole.";
          break;
        case 'invalid-email':
          message = "Email non valida.";
          break;
        case 'network-request-failed':
          message = "Controlla la connessione internet.";
          break;
      }

      if (!mounted) return;
      _showPremiumMessage(
  message: message,
  icon: Icons.error_outline_rounded,
  color: Colors.redAccent,
);
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _showPremiumMessage({
  required String message,
  IconData icon = Icons.info_outline_rounded,
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
        side: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
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
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
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
    final width = MediaQuery.of(context).size.width;

    final maxWidth = width >= 900
        ? 580.0
        : width >= 600
            ? 520.0
            : double.infinity;

    final horizontalPadding = width >= 900
        ? 40.0
        : width >= 600
            ? 54.0
            : 22.0;

    final cardPadding = width >= 900
        ? 34.0
        : width >= 600
            ? 28.0
            : 18.0;

    final cardRadius = width >= 900 ? 22.0 : 32.0;

    final titleSize = width >= 900
        ? 38.0
        : width >= 600
            ? 36.0
            : 32.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: TweenAnimationBuilder(
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
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/vitae.jpeg",
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.72),
                ),
              ),

              SafeArea(
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
                              maxWidth: maxWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: width >= 900 ? 36 : 22,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Logo3D(),

SizedBox(
  height: width < 600 ? 14 : 26,
),
                                  Text(
                                    "Crea account",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                    ),
                                  ),

SizedBox(
  height: width < 600 ? 12 : 20,
),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(cardPadding),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(cardRadius),
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
                                          color:
                                              Colors.black.withOpacity(0.55),
                                          blurRadius: 34,
                                          offset: const Offset(0, 18),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "MODULO DI REGISTRAZIONE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          "Registrati e prenota il tuo prossimo appuntamento.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.48),
                                            fontSize: 13,
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 26),

                                        _PremiumInput(
                                          hint: "Nome",
                                          icon: Icons.person_outline_rounded,
                                          controller: nome,
                                          focusNode: nomeFocus,
                                          nextFocus: cognomeFocus,
                                        ),

                                        _PremiumInput(
                                          hint: "Cognome",
                                          icon: Icons.badge_outlined,
                                          controller: cognome,
                                          focusNode: cognomeFocus,
                                          nextFocus: emailFocus,
                                        ),

                                        _PremiumInput(
                                          hint: "Email",
                                          icon:
                                              Icons.alternate_email_rounded,
                                          controller: email,
                                          focusNode: emailFocus,
                                          nextFocus: telefonoFocus,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),

                                        _PremiumInput(
                                          hint: "Telefono",
                                          icon: Icons.phone_rounded,
                                          controller: telefono,
                                          focusNode: telefonoFocus,
                                          nextFocus: passwordFocus,
                                          keyboardType: TextInputType.phone,
                                        ),

                                        _PremiumInput(
                                          hint: "Password",
                                          icon: Icons.lock_outline_rounded,
                                          controller: password,
                                          focusNode: passwordFocus,
                                          obscureText: true,
                                          onDone: register,
                                        ),

                                        const SizedBox(height: 8),

                                        _PrimaryButton(
                                          loading: loading,
                                          onTap: register,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      "Hai già un account? Accedi",
                                      style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.66),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    "Registrandoti accetti la Privacy Policy",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withOpacity(0.32),
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

class _PremiumInput extends StatelessWidget {
  const _PremiumInput({
    required this.hint,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.nextFocus,
    this.keyboardType,
    this.obscureText = false,
    this.onDone,
  });

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            onDone?.call();
          }
        },
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.45),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.38),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: Color(0xFF00C853),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.loading,
    required this.onTap,
  });

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
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
            color: const Color(0xFF00C853).withOpacity(0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: loading ? null : onTap,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: loading
                  ? const SizedBox(
                      key: ValueKey("loading"),
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.black,
                      ),
                    )
                  : const Row(
                      key: ValueKey("register"),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "REGISTRATI",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.7,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}