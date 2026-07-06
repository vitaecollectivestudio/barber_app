import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';


class AdminAuthService {

  static Future<void> logoutCompleto() async {

    await FirebaseAuth.instance.signOut();

    final googleSignIn = GoogleSignIn();

    await googleSignIn.signOut();

  }
}