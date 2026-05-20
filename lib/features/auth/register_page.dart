import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {


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

  late AnimationController _controller;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    if (nome.text.isEmpty ||
        cognome.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty ||
        telefono.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compila tutti i campi")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('utenti')
          .doc(cred.user!.uid)
          .set({
        "nome": nome.text,
        "cognome": cognome.text,
        "email": email.text,
        "telefono": telefono.text,
        "uid": cred.user!.uid,
        "creatoIl": Timestamp.now(),
      });

      if (mounted) {
  Navigator.pop(context);
}

    } catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}

    if (mounted) {
  setState(() => loading = false);
}
  }

  Widget buildInput(
  String hint,
  IconData icon,
  TextEditingController controller, {

  FocusNode? focusNode,
  FocusNode? nextFocus,

  bool obscure = false,

  TextInputType type = TextInputType.text,

}) {

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),

    child: TextField(

      controller: controller,

      focusNode: focusNode,

      obscureText: obscure,

      keyboardType: type,

      textInputAction:
          nextFocus != null
              ? TextInputAction.next
              : TextInputAction.done,

      autofillHints: [

        if (hint == "Nome")
          AutofillHints.name,

        if (hint == "Cognome")
          AutofillHints.familyName,

        if (hint == "Email")
          AutofillHints.email,

        if (hint == "Telefono")
          AutofillHints.telephoneNumber,

        if (hint == "Password")
          AutofillHints.password,
      ],

      onSubmitted: (_) {

        if (nextFocus != null) {

          FocusScope.of(context)
              .requestFocus(nextFocus);

        } else {

          register();
        }
      },

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),

        prefixIcon: Icon(
          icon,
          color: Colors.white54,
        ),

        hintText: hint,

        hintStyle: const TextStyle(
          color: Colors.white54,
        ),

        filled: true,

        fillColor:
            Colors.black.withOpacity(0.6),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),

          borderSide: const BorderSide(
            color: Color(0xFF00C853),
            width: 1.5,
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

  onTap: () {
    FocusScope.of(context).unfocus();
  },

  child: Scaffold(
  backgroundColor: Colors.black,
  body: Stack(
    children: [

      // 🔥 SFONDO
      Positioned.fill(
        child: Image.asset(
          "assets/images/mike.jpeg",
          fit: BoxFit.cover,
        ),
      ),

      // 🔥 OVERLAY SCURO
      Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.25),
        ),
      ),

      SafeArea(
        child: Center(
          child: SingleChildScrollView(
  keyboardDismissBehavior:
      ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(
  MediaQuery.of(context).size.width * 0.05,
),
            child: Container(
              padding: EdgeInsets.all(
  MediaQuery.of(context).size.width * 0.055,
),
              decoration: BoxDecoration(
  color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                children: [

                  // 🔥 LOGO 3D LOOP
                  AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    final angle = _controller.value * 2 * 3.1416;

    final isFront =
        angle <= 3.1416 / 2 || angle >= 3 * 3.1416 / 2;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0025)
        ..rotateY(angle),
      child: isFront
          ? _buildLogoCard()
          : Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1416),
              child: _buildLogoCard(),
            ),
    );
  },
),

                  const SizedBox(height: 15),

                  Text(
                    "CREA ACCOUNT",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  Text(
                    "Inserisci i tuoi dati ed entra in VITÆ",
                    style: TextStyle(
  color: Colors.white54,
  fontSize: MediaQuery.of(context).size.width * 0.032,
),
                  ),

                  const SizedBox(height: 20),

                  buildInput(
  "Nome",
  Icons.person,
  nome,

  focusNode: nomeFocus,
  nextFocus: cognomeFocus,
),
                  buildInput(
  "Cognome",
  Icons.person_outline,
  cognome,

  focusNode: cognomeFocus,
  nextFocus: emailFocus,
),
                  buildInput(
  "Email",
  Icons.email,
  email,

  focusNode: emailFocus,
  nextFocus: telefonoFocus,

  type: TextInputType.emailAddress,
),
                  buildInput(
  "Telefono",
  Icons.phone,
  telefono,

  focusNode: telefonoFocus,
  nextFocus: passwordFocus,

  type: TextInputType.phone,
),
                  buildInput(
  "Password",
  Icons.lock,
  password,

  focusNode: passwordFocus,

  obscure: true,
),

                  const SizedBox(height: 20),

                  SizedBox(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    onPressed: loading ? null : register,

    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF111111),

      elevation: 12,

      shadowColor: Colors.black,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      side: BorderSide(
        color: Colors.white.withOpacity(0.08),
      ),
    ),

    child: loading
        ? const CircularProgressIndicator(
            color: Colors.white,
          )
        : const Text(
            "REGISTRATI",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
  ),
),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Hai già un account? Accedi",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ],
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

  // 🔥 LOGO CARD PREMIUM
  Widget _buildLogoCard() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
            blurRadius: 25,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          "assets/images/logo.jpeg",
          width: 120,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}