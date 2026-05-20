import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class InserisciTelefonoPage extends StatefulWidget {
  const InserisciTelefonoPage({super.key});

  @override
  State<InserisciTelefonoPage> createState() =>
      _InserisciTelefonoPageState();
}

class _InserisciTelefonoPageState
    extends State<InserisciTelefonoPage> {

  final controller = TextEditingController();
  bool loading = false;

@override
void dispose() {
  controller.dispose();
  super.dispose();
}

  Future<void> salva() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final telefono = controller.text.trim();

if (telefono.isEmpty || telefono.length < 8) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Numero non valido")),
  );
  return;
}

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .set({
      "telefono": telefono,
    }, SetOptions(merge: true));

  if (!mounted) return;
    // 🔥 VAI ALLA HOME
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SafeArea(
  child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(
  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.phone_iphone,
                color: Color(0xFF00C853),
                size: 60,
              ),

              const SizedBox(height: 20),

              Text(
                "Inserisci il tuo numero",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Serve per contattarti per la prenotazione",
                textAlign: TextAlign.center,
                style: TextStyle(
  color: Colors.white54,
  fontSize: MediaQuery.of(context).size.width * 0.034,
),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Es. 3331234567",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  contentPadding: const EdgeInsets.symmetric(
  horizontal: 18,
  vertical: 18,
),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : salva,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    elevation: 10,
shadowColor: Colors.black,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text(
                          "CONTINUA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
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