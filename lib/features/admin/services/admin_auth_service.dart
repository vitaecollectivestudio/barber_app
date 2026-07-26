import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminAuthService {
  static Future<void> logoutCompleto() async {
    if (!kIsWeb) {
      final googleSignIn = GoogleSignIn();

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      try {
        await googleSignIn.disconnect();
      } catch (_) {}
    }

    await FirebaseAuth.instance.signOut();
  }
}