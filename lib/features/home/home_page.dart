import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:marquee/marquee.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../mie.prenotazioni_page.dart';
import '../booking/booking_page.dart';
import '../auth/login_page.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:barber_app/core/responsive/responsive_utils.dart';
import 'dart:ui';

Future<void> logoutCompleto() async {
  await FirebaseAuth.instance.signOut();

  final googleSignIn = GoogleSignIn();
  await googleSignIn.signOut();

  await FacebookAuth.instance.logOut();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget _topAction({

  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required bool isDesktop,

}) {

  return Material(

    color: Colors.transparent,

    child: InkWell(

      borderRadius:
          BorderRadius.circular(16),

      onTap: onTap,

      child: Container(

        padding: EdgeInsets.symmetric(

          horizontal:
              isDesktop ? 18 : 12,

          vertical:
              isDesktop ? 12 : 8,
        ),

        decoration: BoxDecoration(

          color:
              Colors.white.withOpacity(0.05),

          borderRadius:
              BorderRadius.circular(16),

          border: Border.all(
            color:
                Colors.white.withOpacity(0.08),
          ),
        ),

       child: Row(
  mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,
              size:
                  isDesktop ? 18 : 15,
              color: Colors.white,
            ),

            SizedBox(
              width:
                  isDesktop ? 8 : 6,
            ),


Flexible(
  child:
            Text(

              label,
maxLines: 1,
overflow: TextOverflow.ellipsis,
              style: TextStyle(

                color: Colors.white,

                fontWeight:
                    FontWeight.w600,

                fontSize:
                    isDesktop ? 13 : 11,
              ),
            ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomePageState extends State<HomePage> {
Future<void> apriRecensioneGoogle() async {
  final url = Uri.parse(
    "https://g.page/r/TUO-LINK-GOOGLE/review",
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

  int? pressedIndex;
  bool pressedInvite = false;

  final servizi = const [
  {"nome": "Taglio + Shampoo", "prezzo": "€17", "durata": 30},
  {"nome": "Barba rasata a pelle", "prezzo": "€8", "durata": 20},
  {"nome": "Barba modellata", "prezzo": "€10", "durata": 20},
  {"nome": "Taglio + Shampoo + Barba", "prezzo": "€23", "durata": 45},
  {"nome": "Taglio + Shampoo + Barba (Panno caldo)", "prezzo": "€30", "durata": 60},
  {"nome": "Radical Cut (lungo → corto)", "prezzo": "€20", "durata": 40},
];

  Future<void> invitaAmici() async {
    final url = Uri.parse(
      "https://wa.me/?text=🔥 Prova questa app per prenotare dal barbiere! 💈\n\nScaricala qui: https://tuo-link-app",
    );


    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }


  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
    Responsive.horizontalPadding(context);

final maxWidth =
    Responsive.maxContentWidth(context);

final isTablet =
    Responsive.isTablet(context);

final isDesktop =
    Responsive.isDesktop(context);
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
child: SafeArea(  
  child: Scaffold(
      extendBody: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(

  backgroundColor: Colors.black,
  flexibleSpace: ClipRRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 18,
      sigmaY: 18,
    ),

    child: Container(

      decoration: BoxDecoration(

        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),

        gradient: LinearGradient(

          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,

          colors: [

            Colors.white.withOpacity(0.04),

            Colors.black.withOpacity(0.18),
          ],
        ),
      ),
    ),
  ),
),

  surfaceTintColor: Colors.black,

  elevation: 0,

  scrolledUnderElevation: 0,

  toolbarHeight:
      isDesktop
          ? 90
          : isTablet
              ? 82
              : 74,

  centerTitle: false,

  title: SizedBox(

  height: 24,

  width: double.infinity,

    child: Marquee(

      text:
          'VITÆ | COLLECTIVE STUDIO',

      style: TextStyle(

        fontSize:
            isDesktop
                ? 13
                : 11,

        fontWeight:
            FontWeight.w700,

        letterSpacing: 2,

        color: Colors.white,
      ),

      scrollAxis: Axis.horizontal,

      blankSpace: 140,

      velocity: 28,

      pauseAfterRound:
          const Duration(milliseconds: 400),

      startPadding: 10,

      accelerationDuration:
          const Duration(seconds: 1),

      decelerationDuration:
          const Duration(milliseconds: 500),
    ),
  ),

  actions: [

    Padding(

      padding: EdgeInsets.only(
        right: horizontalPadding,
      ),

      child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,

  child: Row(

        children: [

          _topAction(
            icon: Icons.calendar_month,
            label: "Prenotazioni",

            onTap: () {

              Navigator.push(
  context,

  PageRouteBuilder(
    transitionDuration:
        const Duration(milliseconds: 240),

    reverseTransitionDuration:
        const Duration(milliseconds: 200),

    pageBuilder:
        (_, animation, __) {

      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),

        child:
            const MiePrenotazioniPage(),
      );
    },
  ),
);
            },

            isDesktop: isDesktop,
          ),

          SizedBox(
            width:
                isDesktop ? 12 : 8,
          ),

          _topAction(
            icon: Icons.logout,
            label: "Esci",

            onTap: () async {
              await logoutCompleto();
            },

            isDesktop: isDesktop,
          ),
        ],
  ),
      ),
    ),
  ],
),

      // 🔥 NUOVO BODY PREMIUM
      body: Stack(
  children: [

    
Positioned(
  top: -120,
  left: -80,

  child: Container(

    width: 260,
    height: 260,

    decoration: BoxDecoration(

      shape: BoxShape.circle,

      gradient: RadialGradient(

        colors: [

          Colors.white.withOpacity(0.05),

          Colors.transparent,
        ],
      ),
    ),
  ),
),
Positioned(
  right: -100,
  top: 260,

  child: Container(

    width: 240,
    height: 240,

    decoration: BoxDecoration(

      shape: BoxShape.circle,

      gradient: RadialGradient(

        colors: [

          Colors.white.withOpacity(0.03),

          Colors.transparent,
        ],
      ),
    ),
  ),
),

    Center(
  child: ConstrainedBox(

    constraints: BoxConstraints(
      maxWidth: maxWidth,
    ),

    child: SingleChildScrollView(
  physics: const BouncingScrollPhysics(),

  padding: const EdgeInsets.only(bottom: 140),

  child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [

          // 🔥 HEADER PREMIUM
          Padding(

  padding: EdgeInsets.fromLTRB(

    horizontalPadding,

    isDesktop
        ? 42
        : isTablet
            ? 34
            : 26,

    horizontalPadding,

    isDesktop ? 24 : 16,
  ),

  child: Column(

    children: [

      Container(

        padding: EdgeInsets.symmetric(

          horizontal:
              isDesktop ? 18 : 14,

          vertical:
              isDesktop ? 8 : 6,
        ),

        decoration: BoxDecoration(

          color:
              const Color(0xFF00C853)
                  .withOpacity(0.10),

          borderRadius:
              BorderRadius.circular(40),

          border: Border.all(
            color:
                const Color(0xFF00C853)
                    .withOpacity(0.18),
          ),
        ),

        child: Text(

          "BOOKING EXPERIENCE",

          style: TextStyle(

            color:
                const Color(0xFF69F0AE),

            fontSize:
                isDesktop
                    ? 13
                    : 11,

            letterSpacing: 2.5,

            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      SizedBox(
        height:
            isDesktop ? 22 : 18,
      ),

      Text(

        "Scegli il servizio",

        textAlign: TextAlign.center,

        style: TextStyle(

          color: Colors.white,

          fontSize:
              isDesktop
                  ? 42
                  : isTablet
                      ? 34
                      : 28,

          fontWeight:
              FontWeight.w800,

          height: 1,

          letterSpacing: -0.5,
        ),
      ),

      SizedBox(
        height:
            isDesktop ? 10 : 8,
      ),

      ConstrainedBox(

        constraints: BoxConstraints(
          maxWidth:
              isDesktop ? 620 : 420,
        ),

        child: Text(

          "Prenota il tuo appuntamento selezionando uno dei servizi disponibili.",

          textAlign: TextAlign.center,

          style: TextStyle(

            color: Colors.white70,

            fontSize:
                isDesktop
                    ? 17
                    : isTablet
                        ? 16
                        : 14,

            height: 1.6,

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),

      SizedBox(
        height:
            isDesktop ? 26 : 20,
      ),

      Container(

        height: 3,

        width:
            isDesktop ? 70 : 56,

        decoration: BoxDecoration(

          borderRadius:
              BorderRadius.circular(30),

          gradient: LinearGradient(

            colors: [

              const Color(0xFF00C853),

              const Color(0xFF69F0AE)
                  .withOpacity(0.9),
            ],
          ),

          boxShadow: [

            BoxShadow(

              color:
                  const Color(0xFF00C853)
                      .withOpacity(0.45),

              blurRadius: 14,

              spreadRadius: 1,
            ),
          ],
        ),
      ),
    ],
  ),
),

          // 👇 LISTA SERVIZI (IL TUO CODICE IDENTICO)
          ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
              itemCount: servizi.length,
              itemBuilder: (context, i) {
                final s = servizi[i];

                return TweenAnimationBuilder(
  duration: Duration(milliseconds: 400 + (i * 80)),
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - value)),
        child: child,
      ),
    );
  },
  child: Material(
  color: Colors.transparent,

  child: InkWell(
                  onTapDown: (_) => setState(() => pressedIndex = i),
                  onTapUp: (_) => setState(() => pressedIndex = null),
                  onTapCancel: () => setState(() => pressedIndex = null),
                  onTap: () {
                    HapticFeedback.lightImpact();

                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Effettua il login per prenotare")),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                      return;
                    }

                    Navigator.push(
  context,
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => BookingPage(
      servizio: s["nome"] as String,
      durata: s["durata"] as int,
    ),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {

      return FadeTransition(

  opacity: CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  ),

  child: SlideTransition(

    position: Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(

      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
    ),

    child: child,
  ),
);
},
  ),
);
                  },
                  
                  child: AnimatedScale(
                    scale: pressedIndex == i ? 0.96 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
  vertical: isDesktop ? 12 : 10,
),
                      padding: EdgeInsets.all(
  isDesktop ? 24 : 18,
),
                      decoration: BoxDecoration(

  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,

    colors: [
      Color(0xFF232323),
      Color(0xFF161616),
    ],
  ),

  borderRadius: BorderRadius.circular(24),

  border: Border.all(
    color: Colors.white.withOpacity(0.05),
  ),

  boxShadow: [

    BoxShadow(
      color: Colors.black.withOpacity(0.45),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),

    if (pressedIndex == i)
      BoxShadow(
        color: Colors.white.withOpacity(0.08),
        blurRadius: 24,
        spreadRadius: 1,
      ),
  ],
),
                    child: SizedBox(
                      child: Row(
                        children: [
                          Container(

  width: isDesktop ? 62 : 54,
  height: isDesktop ? 62 : 54,

  decoration: BoxDecoration(

    shape: BoxShape.circle,

    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,

      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.02),
      ],
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),

    boxShadow: [

      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  ),

  child: Icon(
    Icons.content_cut_rounded,

    color: Colors.white.withOpacity(0.92),

    size: isDesktop ? 28 : 24,
  ),
),
                          const SizedBox(width: 16),
                          Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        s["nome"] as String,
        maxLines: 2,
overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize:
    isDesktop
        ? 20
        : isTablet
            ? 18
            : 15,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 4),

      Row(
        children: [
          Icon(Icons.schedule, size: 14, color: Colors.white38),
          const SizedBox(width: 4),
          Text(
            "${s["durata"]} min",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),


    ],
  ),
),
SizedBox(
  width: isDesktop ? 72 : 60,

  child:
                          Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [

    Text(
      s["prezzo"] as String,
      style: TextStyle(
        color: const Color(0xFF69F0AE),
        fontWeight: FontWeight.bold,
        fontSize:
    isDesktop
        ? 22
        : isTablet
            ? 20
            : 16,
      ),
    ),

    const SizedBox(height: 4),

    Container(

  width: 28,
  height: 28,

  decoration: BoxDecoration(

    shape: BoxShape.circle,

    color: Colors.white.withOpacity(0.04),

    border: Border.all(
      color: Colors.white.withOpacity(0.05),
    ),
  ),

  child: Icon(
    Icons.arrow_forward_ios_rounded,

    size: 11,

    color: Colors.white.withOpacity(0.65),
  ),
),

  ],
                          ),
),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),
  ),
                );
              },
            ),
            const SizedBox(height: 40),
    ],
          ),
      ),
    ),
    ),


    // 🔥 FADE PREMIUM BOTTOM
    Positioned(
  left: 0,
  right: 0,
  bottom: 0,

  child: SafeArea(
    top: false,

    child: Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        18,
      ),

      child: Wrap(
  spacing: 12,
  runSpacing: 12,
  alignment: WrapAlignment.center,

  children: [

    // 🔥 INVITA
    Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: invitaAmici,

        child: Container(
          height: isDesktop ? 58 : 52,

          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 220,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          decoration: BoxDecoration(

            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [
                Color(0xFF262626),
                Color(0xFF171717),
              ],
            ),

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color:
                  Colors.white.withOpacity(0.06),
            ),

            boxShadow: [

              BoxShadow(
                color:
                    Colors.black.withOpacity(0.45),

                blurRadius: 18,

                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: const [

              Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 18,
              ),

              SizedBox(width: 10),

              Text(
                "INVITA",

                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    ),

    // 🔥 RECENSIONE
    Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: apriRecensioneGoogle,

        child: Container(
          height: isDesktop ? 58 : 52,

          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 220,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          decoration: BoxDecoration(

            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [
                Color(0xFF262626),
                Color(0xFF171717),
              ],
            ),

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color:
                  Colors.white.withOpacity(0.06),
            ),

            boxShadow: [

              BoxShadow(
                color:
                    Colors.black.withOpacity(0.45),

                blurRadius: 18,

                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: const [

              Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 18,
              ),

              SizedBox(width: 10),

              Text(
                "RECENSIONE",

                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),
    ),
  ),
),
  ],
  
),


  ),
),
    );
  }
}