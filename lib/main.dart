// MAIN 100% DEFINITIVO 💈🔥
import 'package:barber_app/app_background.dart';
import 'package:barber_app/mie.prenotazioni_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'clienti_page.dart';
import 'package:barber_app/inserisci_telefono_page.dart';
import 'package:intl/intl.dart';
import 'walkin_page.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/auth/auth_gate.dart';
import 'features/home/home_page.dart';
import 'services/notification_service.dart';




Future<void> saveCurrentFcmToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("FCM: user null, skip");
      return;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken;

      for (int i = 0; i < 20; i++) {
        apnsToken = await messaging.getAPNSToken();

        if (apnsToken != null) {
          debugPrint("APNS TOKEN OK: $apnsToken");
          break;
        }

        debugPrint("APNS TOKEN non disponibile, retry $i");

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      }

      if (apnsToken == null) {
        debugPrint("APNS TOKEN ancora null: non salvo FCM");
        return;
      }
    }

    final token = await messaging.getToken();

    if (token == null) {
      debugPrint("FCM TOKEN null");
      return;
    }

    await FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint("FCM TOKEN SAVED: $token");
  } catch (e) {
    debugPrint("Errore salvataggio FCM token: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
} on FirebaseException catch (e) {
  if (e.code == 'duplicate-app') {
    debugPrint("Firebase già inizializzato, continuo.");
  } else {
    rethrow;
  }
}

 tz.initializeTimeZones();
 tz.setLocalLocation(
  tz.getLocation('Europe/Rome'),
);
await NotificationService.init();

FirebaseMessaging.instance.onTokenRefresh.listen(
  (token) async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .set({
      'fcmToken': token,
    }, SetOptions(merge: true));

    debugPrint(
      "FCM TOKEN UPDATED: $token",
    );
  },
);

  // 👇 METTI QUESTO BLOCCO QUI
  if (!kIsWeb) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
    await saveCurrentFcmToken();
await FirebaseMessaging.instance
    .setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "Notifica";
      final body = message.notification?.body ?? "";
      debugPrint("Notifica ricevuta: $title - $body");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App aperta da notifica");
    });
  }
  
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
]);

SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.edgeToEdge,
);

SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
  ),
);

runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  builder: (context, child) {

  final mediaQuery = MediaQuery.of(context);

  return MediaQuery(
    data: mediaQuery.copyWith(

      textScaler: const TextScaler.linear(1.0),

    ),

    child: GestureDetector(

      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      child: child!,
    ),
  );
},
  debugShowCheckedModeBanner: false,
      theme: ThemeData(

  useMaterial3: true,

  visualDensity: VisualDensity.adaptivePlatformDensity,

  splashFactory: NoSplash.splashFactory,

  fontFamily: 'Montserrat',

  brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C853), // verde premium
          secondary: Color(0xFF00E676),
      ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  cardColor: const Color(0xFF1A1A1A),
  dividerColor: Colors.white12,

  textTheme: const TextTheme(
  bodyMedium: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
  ),

  titleLarge: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 18,
  ),

  titleMedium: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ),
),
),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it', 'IT')],
      home: const AuthGate(),
    );
  }
}






class Logo3D extends StatefulWidget {
  const Logo3D({super.key});

  @override
  State<Logo3D> createState() => _Logo3DState();
}

class _Logo3DState extends State<Logo3D>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 🔥 più lento e fluido
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        final angle = _controller.value * 2 * 3.1416;
        final isFront = _controller.value <= 0.5;

        return Transform(
  alignment: Alignment.center,
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.0025)
    ..rotateY(angle),
  child: Stack(
    children: [

      // 🔥 FRONTE (visibile solo 0 → 90°)
      if (angle <= 1.57 || angle >= 4.71)
        _buildCard(),

      // 🔥 RETRO (visibile solo 90° → 270°)
      if (angle > 1.57 && angle < 4.71)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.1416),
          child: _buildCard(),
        ),
    ],
  ),
);
      },
    );
  }

  Widget _buildCard() {
    return Container(
  width: 140,
  height: 140,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(25),

    // 🔥 bordo sottile = spessore
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1,
    ),

    // 🔥 ombra più profonda
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.9),
        blurRadius: 30,
        offset: Offset(0, 10),
      ),
    ],
  ),
  clipBehavior: Clip.antiAlias,
  child: Stack(
    children: [

      // 🔥 immagine
      Positioned.fill(
        child: Image.asset(
          "assets/images/logo.jpeg",
          fit: BoxFit.cover,
        ),
      ),

      // 🔥 overlay leggero = profondità
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.transparent,
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}




//////////////// ADMIN //////////////////
Future<void> logoutCompleto() async {
  // Google: chiude la sessione locale
  final googleSignIn = GoogleSignIn();

  try {
    await googleSignIn.signOut();
  } catch (_) {}

  // Google: revoca il collegamento, così al prossimo login richiede di nuovo scelta/account
  try {
    await googleSignIn.disconnect();
  } catch (_) {
    // Può fallire se non c'è una sessione Google attiva: normale
  }

  // Facebook
  try {
  } catch (_) {}

  // Firebase per ultimo
  await FirebaseAuth.instance.signOut();
}