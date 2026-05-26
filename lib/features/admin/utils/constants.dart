import 'package:flutter/material.dart';

import 'package:barber_app/app_background.dart';
import 'package:barber_app/inserisci_telefono_page.dart';

import 'package:barber_app/features/home/home_page.dart';
import 'package:barber_app/features/auth/login_page.dart';
import 'package:barber_app/features/admin/pages/barber_panel_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
  backgroundColor: Color(0xFF0F0F0F),

  body: Center(
    child: SizedBox(
      height: 26,
      width: 26,

      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: Color(0xFF00C853),
      ),
    ),
  ),
);
        }

        if (snapshot.hasData) {

          final user = snapshot.data!;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('utenti')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snap) {

              if (!snap.hasData) {
                return const Scaffold(
  backgroundColor: Color(0xFF0F0F0F),

  body: Center(
    child: SizedBox(
      height: 26,
      width: 26,

      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: Color(0xFF00C853),
      ),
    ),
  ),
);
              }

              final raw = snap.data?.data();

final data = raw is Map<String, dynamic>
    ? raw
    : null;

              final telefono = data?['telefono'];

              if (telefono == null ||
                  telefono.toString().isEmpty) {
                return InserisciTelefonoPage();
              }

              final ruolo = data?['ruolo'];

              if (ruolo == 'barber') {
                return AppBackground(
                  child: BarberPanelPage(),
                );
              }

              return AppBackground(
                child: HomePage(),
              );
            },
          );
        }

        return LoginPage();
      },
    );
  }
}