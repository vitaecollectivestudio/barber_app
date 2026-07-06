import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:marquee/marquee.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../mie.prenotazioni_page.dart';
import '../booking/booking_page.dart';
import '../auth/login_page.dart';

// import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/core/responsive/responsive_utils.dart';
import 'dart:ui';
import 'package:barber_app/features/services/models/service_model.dart';
import 'package:barber_app/features/services/services/services_service.dart';

Future<void> logoutCompleto() async {
  await FirebaseAuth.instance.signOut();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget _legalTextAction({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = MediaQuery.of(context).size.width;
      final isSmall = width < 390;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 6 : 8,
              vertical: isSmall ? 5 : 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isSmall ? 12.5 : 13.5,
                  color: const Color(0xFF69F0AE).withOpacity(0.72),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: isSmall ? 10.3 : 11.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                    decorationColor: Colors.white.withOpacity(0.22),
                    decorationThickness: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _iconAction({
  required IconData icon,
  required VoidCallback onTap,
  Color iconColor = Colors.white70,
  Color glowColor = Colors.transparent,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.32),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withOpacity(0.24)),
          boxShadow: [
            if (glowColor != Colors.transparent)
              BoxShadow(
                color: glowColor.withOpacity(0.22),
                blurRadius: 14,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
    ),
  );
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
      borderRadius: BorderRadius.circular(16),

      onTap: onTap,

      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 18 : 12,

          vertical: isDesktop ? 12 : 8,
        ),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, size: isDesktop ? 18 : 15, color: Colors.white),

            SizedBox(width: isDesktop ? 8 : 6),

            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.w600,

                  fontSize: isDesktop ? 13 : 11,
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
  Widget _miniAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.035),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white.withOpacity(0.72)),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> apriRecensioneGoogle() async {
    final url = Uri.parse("https://g.page/r/TUO-LINK-GOOGLE/review");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> apriPrivacyPolicy() async {
    final url = Uri.parse("https://vitae-3ee57.web.app/privacy-policy.html");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> apriEliminazioneAccount() async {
    final url = Uri.parse(
      "https://vitae-3ee57.web.app/eliminazione-account.html",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  int? pressedIndex;
  bool pressedInvite = false;
  late final Stream<List<ServiceModel>> _servicesStream;

  Future<void> invitaAmici() async {
    final url = Uri.parse(
      "https://wa.me/?text=🔥 Scarica l'applicazione di VITÆ | Collective Studio. Sarà utile per prenotare dal barbiere. 💈\n\nScaricala qui: https://tuo-link-app",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void initState() {
    super.initState();

    _servicesStream = ServicesService.activeServicesStream();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.horizontalPadding(context);

    final maxWidth = Responsive.maxContentWidth(context);

    final isTablet = Responsive.isTablet(context);

    final user = FirebaseAuth.instance.currentUser;

    final isDesktop = Responsive.isDesktop(context);
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
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
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

            toolbarHeight: isDesktop
                ? 90
                : isTablet
                ? 82
                : 74,

            centerTitle: false,

            title: SizedBox(
              height: 24,

              width: double.infinity,

              child: Marquee(
                text: 'VITÆ | COLLECTIVE STUDIO',

                style: TextStyle(
                  fontSize: isDesktop ? 13 : 11,

                  fontWeight: FontWeight.w700,

                  letterSpacing: 2,

                  color: Colors.white,
                ),

                scrollAxis: Axis.horizontal,

                blankSpace: 140,

                velocity: 28,

                pauseAfterRound: const Duration(milliseconds: 400),

                startPadding: 10,

                accelerationDuration: const Duration(seconds: 1),

                decelerationDuration: const Duration(milliseconds: 500),
              ),
            ),

            actions: [
              Padding(
                padding: EdgeInsets.only(right: horizontalPadding),

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
                              transitionDuration: const Duration(
                                milliseconds: 240,
                              ),

                              reverseTransitionDuration: const Duration(
                                milliseconds: 200,
                              ),

                              pageBuilder: (_, animation, __) {
                                return FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ),

                                  child: const MiePrenotazioniPage(),
                                );
                              },
                            ),
                          );
                        },

                        isDesktop: isDesktop,
                      ),

                      SizedBox(width: isDesktop ? 12 : 8),

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
                  constraints: BoxConstraints(maxWidth: maxWidth),

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
                                  horizontal: isDesktop ? 18 : 14,

                                  vertical: isDesktop ? 8 : 6,
                                ),

                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00C853,
                                  ).withOpacity(0.10),

                                  borderRadius: BorderRadius.circular(40),

                                  border: Border.all(
                                    color: const Color(
                                      0xFF00C853,
                                    ).withOpacity(0.18),
                                  ),
                                ),

                                child: Text(
                                  "BOOKING EXPERIENCE",

                                  style: TextStyle(
                                    color: const Color(0xFF69F0AE),

                                    fontSize: isDesktop ? 13 : 11,

                                    letterSpacing: 2.5,

                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              SizedBox(height: isDesktop ? 22 : 18),

                              Text(
                                "Scegli il servizio",

                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: isDesktop
                                      ? 42
                                      : isTablet
                                      ? 34
                                      : 28,

                                  fontWeight: FontWeight.w800,

                                  height: 1,

                                  letterSpacing: -0.5,
                                ),
                              ),

                              SizedBox(height: isDesktop ? 10 : 8),

                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 620 : 420,
                                ),

                                child: Text(
                                  "Prenota il tuo appuntamento selezionando uno dei servizi disponibili.",

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.white70,

                                    fontSize: isDesktop
                                        ? 17
                                        : isTablet
                                        ? 16
                                        : 14,

                                    height: 1.6,

                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              Container(
                                height: 3,

                                width: isDesktop ? 70 : 56,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),

                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00C853),

                                      const Color(0xFF69F0AE).withOpacity(0.9),
                                    ],
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00C853,
                                      ).withOpacity(0.45),

                                      blurRadius: 14,

                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (user != null)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('appuntamenti')
                                .where('userId', isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final now = DateTime.now();

                              final docs = snapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                final startAt = data['startAt'];

                                if (startAt is! Timestamp) {
                                  return false;
                                }

                                return startAt.toDate().isAfter(now);
                              }).toList();

                              docs.sort((a, b) {
                                final dataA = a.data() as Map<String, dynamic>;

                                final dataB = b.data() as Map<String, dynamic>;

                                final startA = (dataA['startAt'] as Timestamp)
                                    .toDate();

                                final startB = (dataB['startAt'] as Timestamp)
                                    .toDate();

                                return startA.compareTo(startB);
                              });

                              if (docs.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final next =
                                  docs.first.data() as Map<String, dynamic>;

                              final start = (next['startAt'] as Timestamp)
                                  .toDate();

                              final servizio =
                                  next['servizio']?.toString() ??
                                  "Appuntamento";

                              final operatorId =
                                  next['operatorId']?.toString() ?? "";

                              const giorni = [
                                "Lunedì",
                                "Martedì",
                                "Mercoledì",
                                "Giovedì",
                                "Venerdì",
                                "Sabato",
                                "Domenica",
                              ];

                              const mesi = [
                                "Gennaio",
                                "Febbraio",
                                "Marzo",
                                "Aprile",
                                "Maggio",
                                "Giugno",
                                "Luglio",
                                "Agosto",
                                "Settembre",
                                "Ottobre",
                                "Novembre",
                                "Dicembre",
                              ];

                              final dataLabel =
                                  "${giorni[start.weekday - 1]} ${start.day} ${mesi[start.month - 1]}";

                              final oraLabel =
                                  "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";

                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  22,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 240,
                                        ),
                                        reverseTransitionDuration:
                                            const Duration(milliseconds: 200),
                                        pageBuilder: (_, animation, __) {
                                          return FadeTransition(
                                            opacity: CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOut,
                                            ),
                                            child: const MiePrenotazioniPage(),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      isDesktop
                                          ? 22
                                          : isTablet
                                          ? 20
                                          : 18,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF202020),
                                          Color(0xFF121212),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        isDesktop ? 30 : 24,
                                      ),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00C853,
                                        ).withOpacity(0.18),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.50),
                                          blurRadius: 26,
                                          offset: const Offset(0, 14),
                                        ),
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.08),
                                          blurRadius: 28,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: isDesktop ? 58 : 52,
                                          height: isDesktop ? 58 : 52,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(
                                              0xFF00C853,
                                            ).withOpacity(0.12),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF00C853,
                                              ).withOpacity(0.25),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.event_available_rounded,
                                            color: Color(0xFF69F0AE),
                                            size: 24,
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "PROSSIMO APPUNTAMENTO",
                                                style: TextStyle(
                                                  color: const Color(
                                                    0xFF69F0AE,
                                                  ),
                                                  fontSize: isDesktop
                                                      ? 12
                                                      : 10.5,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.4,
                                                ),
                                              ),

                                              const SizedBox(height: 7),

                                              Text(
                                                servizio,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isDesktop
                                                      ? 18
                                                      : isTablet
                                                      ? 16
                                                      : 14.5,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.15,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Text(
                                                "$dataLabel • $oraLabel${operatorId.isNotEmpty ? " • $operatorId" : ""}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.58),
                                                  fontSize: isDesktop
                                                      ? 13
                                                      : isTablet
                                                      ? 12.5
                                                      : 11.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(
                                              0.05,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.06,
                                              ),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 12,
                                            color: Colors.white.withOpacity(
                                              0.70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // 👇 LISTA SERVIZI (IL TUO CODICE IDENTICO)
                        StreamBuilder<List<ServiceModel>>(
                          stream: _servicesStream,

                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final servizi = snapshot.data!;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: servizi.length,
                              itemBuilder: (context, i) {
                                final service = servizi[i];

                                return TweenAnimationBuilder(
                                  duration: Duration(
                                    milliseconds: 400 + (i * 80),
                                  ),
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
                                      onTapDown: (_) =>
                                          setState(() => pressedIndex = i),
                                      onTapUp: (_) =>
                                          setState(() => pressedIndex = null),
                                      onTapCancel: () =>
                                          setState(() => pressedIndex = null),
                                      onTap: () {
                                        HapticFeedback.lightImpact();

                                        final user =
                                            FirebaseAuth.instance.currentUser;

                                        if (user == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Effettua il login per prenotare",
                                              ),
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const LoginPage(),
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            reverseTransitionDuration:
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                            pageBuilder: (_, __, ___) =>
                                                BookingPage(
                                                  serviceId: service.id,
                                                  servizio: service.name,
                                                  durata:
                                                      service.durationMinutes,
                                                ),
                                            transitionsBuilder:
                                                (
                                                  _,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  return FadeTransition(
                                                    opacity: CurvedAnimation(
                                                      parent: animation,
                                                      curve: Curves.easeOut,
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                          ),
                                        );
                                      },

                                      child: AnimatedScale(
                                        scale: pressedIndex == i ? 0.96 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
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

                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),

                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.05,
                                              ),
                                            ),

                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.45,
                                                ),
                                                blurRadius: 18,
                                                offset: const Offset(0, 10),
                                              ),

                                              if (pressedIndex == i)
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
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
                                                      end:
                                                          Alignment.bottomRight,

                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.08),
                                                        Colors.white
                                                            .withOpacity(0.02),
                                                      ],
                                                    ),

                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.06),
                                                    ),

                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.45),
                                                        blurRadius: 18,
                                                        offset: const Offset(
                                                          0,
                                                          8,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  child: Icon(
                                                    Icons.content_cut_rounded,

                                                    color: Colors.white
                                                        .withOpacity(0.92),

                                                    size: isDesktop ? 28 : 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        service.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: isDesktop
                                                              ? 20
                                                              : isTablet
                                                              ? 18
                                                              : 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),

                                                      if (service
                                                          .description
                                                          .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 6,
                                                        ),

                                                        Text(
                                                          service.description,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.55,
                                                                ),
                                                            fontSize: 12,
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],

                                                      const SizedBox(height: 6),

                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.schedule,
                                                            size: 14,
                                                            color:
                                                                Colors.white38,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            "${service.durationMinutes} min",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white38,
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

                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        service.priceLabel,
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF69F0AE,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: isDesktop
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
                                                          shape:
                                                              BoxShape.circle,

                                                          color: Colors.white
                                                              .withOpacity(
                                                                0.04,
                                                              ),

                                                          border: Border.all(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                          ),
                                                        ),

                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,

                                                          size: 11,

                                                          color: Colors.white
                                                              .withOpacity(
                                                                0.65,
                                                              ),
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
                            );
                          },
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isDesktop ? 36 : 28,
                            horizontalPadding,
                            0,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: isDesktop ? 56 : 44,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.24),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                "© ${DateTime.now().year} VITÆ COLLECTIVE STUDIO",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.42),
                                  fontSize: isDesktop ? 11.5 : 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),

                              Text(
                                "Eleganza, cura e precisione. Tutti i diritti riservati.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.28),
                                  fontSize: isDesktop ? 11 : 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.25,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  _legalTextAction(
                                    icon: Icons.privacy_tip_outlined,
                                    label: "Privacy Policy",
                                    onTap: apriPrivacyPolicy,
                                  ),
                                  _legalTextAction(
                                    icon: Icons.person_remove_alt_1_outlined,
                                    label: "Eliminazione account",
                                    onTap: apriEliminazioneAccount,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 14,
                right: horizontalPadding,
                child: _iconAction(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFD54F),
                  glowColor: const Color(0xFF000000),
                  onTap: apriRecensioneGoogle,
                ),
              ),

              // 🔥 FADE PREMIUM BOTTOM
            ],
          ),
        ),
      ),
    );
  }
}
