import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:barber_app/services/slot_service.dart';
import 'package:barber_app/features/schedule/models/operator_schedule_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:barber_app/features/schedule/services/operator_schedule_service.dart';
import 'dart:async';

class UI {
  static const cardColor = Color(0xFF1E1E1E);
  static const green = Color(0xFF00C853);

  static BoxDecoration card({bool pressed = false}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B1B1B), Color(0xFF111111)],
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF00C853).withOpacity(0.04),

          blurRadius: 50,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: pressed
              ? Colors.white.withOpacity(0.3)
              : Colors.black.withOpacity(0.4),
          blurRadius: pressed ? 16 : 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class WalkInPage extends StatefulWidget {
  const WalkInPage({super.key});

  @override
  State<WalkInPage> createState() => _WalkInPageState();
}

class _WalkInPageState extends State<WalkInPage> {
  final nome = TextEditingController();
  final telefono = TextEditingController();

  Widget premiumAvailabilityEmptyState({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 28,
        vertical: isMobile ? 26 : 34,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 28 : 34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF101010)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.06),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 56 : 64,
            height: isMobile ? 56 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C853).withOpacity(0.10),
              border: Border.all(
                color: const Color(0xFF69F0AE).withOpacity(0.22),
              ),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: Color(0xFF69F0AE),
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "SELEZIONA UN OPERATORE",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Scegli un barbiere per visualizzare gli orari disponibili della giornata.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.54),
              fontSize: isMobile ? 12.5 : 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget premiumSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202020), Color(0xFF111111)],
        ),

        borderRadius: BorderRadius.circular(40),

        border: Border.all(color: Colors.white.withOpacity(0.08)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),

          BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 4),
        ],
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00C853),
            ),
          ),

          const SizedBox(width: 10),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget slotGroupTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),

      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),

          const SizedBox(width: 8),

          Text(
            title,

            style: TextStyle(
              color: Colors.white.withOpacity(.75),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget premiumSlot(String slot, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),

      width: 86,
      height: 52,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A2A2A), Color(0xFF171717)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D1D1D), Color(0xFF121212)],
              ),

        border: Border.all(
          color: selected ? Colors.white : Colors.white.withOpacity(.05),

          width: selected ? 1.5 : 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),

          if (selected)
            BoxShadow(color: Colors.white.withOpacity(.12), blurRadius: 18),
        ],
      ),

      child: Center(
        child: Text(
          slot,

          style: TextStyle(
            color: Colors.white,

            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,

            letterSpacing: 0.5,

            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scheduleSub?.cancel();
    nome.dispose();
    telefono.dispose();
    super.dispose();
  }

  Future<void> caricaScheduleOperatore() async {
    if (operatore == null) return;

    setState(() {
      loadingSchedule = true;
    });

    final dayMap = {
      1: "monday",
      2: "tuesday",
      3: "wednesday",
      4: "thursday",
      5: "friday",
      6: "saturday",
      7: "sunday",
    };

    final dayId = dayMap[data.weekday]!;

    final schedule = await OperatorScheduleService.getDaySchedule(
      operatorId: operatore!.toLowerCase(),
      dayId: dayId,
    );

    if (!mounted) return;

    setState(() {
      currentSchedule = schedule;
      loadingSchedule = false;
    });
  }

  void ascoltaScheduleRealtime() {
    scheduleSub?.cancel();

    if (operatore == null) return;

    final dayMap = {
      1: "monday",
      2: "tuesday",
      3: "wednesday",
      4: "thursday",
      5: "friday",
      6: "saturday",
      7: "sunday",
    };

    final dayId = dayMap[data.weekday]!;

    scheduleSub = FirebaseFirestore.instance
        .collection('operator_schedules')
        .doc(operatore!.toLowerCase())
        .collection('weekly')
        .doc(dayId)
        .snapshots()
        .listen((doc) {
          if (!doc.exists) return;

          final map = doc.data();

          if (map == null) return;

          if (!mounted) return;

          setState(() {
            currentSchedule = DaySchedule.fromMap(map);
          });
        });
  }

  String? servizio;
  String? orario;
  DateTime data = DateTime.now();
  DateTime selectedDay = DateTime.now();
  String? operatore;

  bool giornataChiusaLocal = false;
  bool loading = false;
  DaySchedule? currentSchedule;

  bool loadingSchedule = false;
  bool buttonPressed = false;
  StreamSubscription? scheduleSub;
  Map<String, dynamic>? servizioSelezionato;
  String? userIdSelezionato;

  List<Map<String, dynamic>> servizi = [];

  @override
  void initState() {
    super.initState();

    caricaServizi();
    caricaOperatori();
  }

  Future<void> caricaServizi() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    if (!mounted) return;

    setState(() {
      servizi = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
  "id": doc.id,
  "nome": data["name"],
  "durata": data["durationMinutes"],
  "prezzo": "€${(data["priceCents"] / 100).toStringAsFixed(0)}",
};
      }).toList();
    });
  }

  Future<void> caricaOperatori() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('operators')
        .where('active', isEqualTo: true)
        .orderBy('publicOrder')
        .get();

    if (!mounted) return;

    setState(() {
      operatori = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          "id": doc.id,
          "name": data["displayName"] ?? "",
          "photoUrl": data["imageUrl"],
        };
      }).toList();
    });
  }

  List<Map<String, dynamic>> operatori = [];
  Future<void> salva() async {
    if (loading) return;

    if (telefono.text.trim().isNotEmpty) {
      final telefonoPulito = telefono.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (telefonoPulito.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1E),

            behavior: SnackBarBehavior.floating,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Numero di telefono non valido",

                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return;
      }
    }

    if (giornataChiusaLocal) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Giornata chiusa")));
      return;
    }

    if (nome.text.trim().isEmpty ||
        servizioSelezionato == null ||
        orario == null ||
        operatore == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Compila tutto")));
      return;
    }
    try {
      setState(() => loading = true);

      final callable = FirebaseFunctions.instance.httpsCallable(
        'createWalkInBooking',
      );

      final parts = orario!.split(":");

      final startAt = DateTime(
        data.year,
        data.month,
        data.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final endAt = startAt.add(
        Duration(minutes: servizioSelezionato!["durata"]),
      );

      final dateKey =
          "${data.year}-"
          "${data.month.toString().padLeft(2, '0')}-"
          "${data.day.toString().padLeft(2, '0')}";

      await callable.call({
  "operatorId": operatore!.toLowerCase(),
  "dateKey": dateKey,
  "startAt": startAt.toUtc().toIso8601String(),
  "endAt": endAt.toUtc().toIso8601String(),
  "serviceId": servizioSelezionato!["id"],
  "durata": servizioSelezionato!["durata"],
  "servizio": servizioSelezionato!["nome"],
  "nome": nome.text.trim(),
  "telefono": telefono.text.trim(),
  "userId": userIdSelezionato,
});

      if (!mounted) return;

      setState(() => loading = false);
      setState(() {
        loading = false;
        buttonPressed = false;
      });

      Navigator.pop(context);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        buttonPressed = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Errore prenotazione")),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        buttonPressed = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Errore imprevisto")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;
    final isDesktop = width >= 1100;
    final sidePadding = isMobile ? 12.0 : 20.0;
    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
        ? 28.0
        : 40.0;

    final cardWidth = isDesktop
        ? 920.0
        : isTablet
        ? 760.0
        : width;

    final titleSize = isMobile
        ? 18.0
        : isTablet
        ? 22.0
        : 26.0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          isMobile
              ? 104
              : isTablet
              ? 132
              : 148,
        ),

        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

            child: Container(
              padding: EdgeInsets.only(
                left: isMobile ? 14 : 24,
                right: isMobile ? 14 : 24,
                top: isMobile ? 8 : 16,
                bottom: isMobile ? 8 : 12,
              ),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Colors.black.withOpacity(0.82),

                    const Color(0xFF111111).withOpacity(0.76),

                    Colors.black.withOpacity(0.70),
                  ],
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMobile ? 28 : 34),

                  bottomRight: Radius.circular(isMobile ? 28 : 34),
                ),

                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),

              child: SafeArea(
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,

                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          width: isMobile ? 54 : 72,
                          height: isMobile ? 54 : 72,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withOpacity(0.06),

                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: isMobile ? 14 : 20),

                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,

                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12,
                            vertical: isMobile ? 4 : 6,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.12),

                            borderRadius: BorderRadius.circular(30),

                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.25),
                            ),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: const Color(0xFF69F0AE),
                                size: isMobile ? 11 : 14,
                              ),

                              SizedBox(width: isMobile ? 4 : 6),

                              Text(
                                "REGISTRAZIONE CLIENTE WALK-IN",

                                style: TextStyle(
                                  color: const Color(0xFF69F0AE),
                                  fontSize: isMobile ? 9 : 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: isMobile ? 0.6 : 1.2,
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
        ),
      ),
      body: Stack(
        children: [
          // 🌑 BACKGROUND PREMIUM
          // 🌑 BACKGROUND PREMIUM
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFAFAFA),

                    Color(0xFFF1F1F1),

                    Color(0xFFE8E8E8),

                    Color(0xFFF7F7F7),
                  ],
                ),
              ),
            ),
          ),

          // ✨ GLOW VERDE
          Positioned(
            top: -120,
            left: -80,

            child: Container(
              width: 260,
              height: 260,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C853).withOpacity(0.04),
              ),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),

                child: const SizedBox(),
              ),
            ),
          ),

          // 🔥 GLOW ROSSO
          Positioned(
            bottom: -140,
            right: -100,

            child: Container(
              width: 320,
              height: 320,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.06),
              ),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),

                child: const SizedBox(),
              ),
            ),
          ),

          // 📦 CONTENUTO SCROLLABILE
          SafeArea(
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

              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(horizontalPadding),

                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),

                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 28,
                        vertical: isMobile ? 22 : 34,
                      ),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF323232),
                            Color(0xFF252525),
                            Color(0xFF1B1B1B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isMobile ? 32 : 40),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),

                          BoxShadow(
                            color: Colors.white.withOpacity(0.015),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          Column(
                            children: [
                              // 🔥 BADGE TOP
                              Align(
                                alignment: Alignment.center,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isMobile ? 310 : 520,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 18,
                                      vertical: isMobile ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.18),
                                          const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00C853,
                                        ).withOpacity(0.22),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.10),
                                          blurRadius: 24,
                                        ),
                                      ],
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: isMobile ? 6 : 7,
                                            height: isMobile ? 6 : 7,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF69F0AE),
                                            ),
                                          ),

                                          const SizedBox(width: 9),

                                          Text(
                                            "BENVENUTO/A IN VITÆ COLLECTIVE STUDIO!",
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(
                                              color: const Color(0xFF69F0AE),
                                              fontSize: isMobile ? 10 : 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: isMobile
                                                  ? 1.7
                                                  : 2.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isMobile ? 26 : 34),

                              // 🔥 TITLE
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,

                                    colors: [
                                      Colors.white,

                                      Color(0xFFEAEAEA),

                                      Color(0xFFBDBDBD),
                                    ],
                                  ).createShader(bounds);
                                },

                                child: Text(
                                  "REGISTRA\nCLIENTE",

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    height: 0.95,

                                    color: Colors.white,

                                    fontSize: (width * 0.09).clamp(42.0, 72.0),

                                    fontWeight: FontWeight.w900,

                                    letterSpacing: 3,
                                  ),
                                ),
                              ),

                              SizedBox(height: isMobile ? 18 : 22),

                              // 🔥 SUBTITLE
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),

                                child: Text(
                                  "Gestisci appuntamenti walk-in in modo rapido e professionale.",

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.42),

                                    fontSize: isMobile ? 13 : 15,

                                    height: 1.6,

                                    letterSpacing: 0.6,

                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              SizedBox(height: isMobile ? 42 : 54),
                            ],
                          ),
                          premiumSectionTitle("SELEZIONA BARBIERE"),

                          const SizedBox(height: 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 18,
                            runSpacing: 18,
                            children: operatori.map((op) {
                              final nomeOperatore = op["name"] as String;
                              final operatorId = op["id"] as String;
                              final photoUrl = op["photoUrl"];
                              final selezionato = operatore == operatorId;

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,

                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    setState(() {
                                      operatore = operatorId;
                                      orario = null; // 🔥 RESET
                                    });

                                    await caricaScheduleOperatore();

                                    ascoltaScheduleRealtime();
                                  },
                                  child: AnimatedScale(
                                    scale: selezionato ? 0.96 : 1,
                                    duration: const Duration(milliseconds: 120),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minWidth: isMobile ? 140 : 180,
                                        maxWidth: isMobile ? 170 : 240,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 22 : 28,
                                        vertical: isMobile ? 18 : 22,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: selezionato
                                            ? const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF141414),
                                                  Color(0xFF0D0D0D),
                                                ],
                                              )
                                            : LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF2A2A2A),
                                                  Color(0xFF1B1B1B),
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(30),

                                        border: selezionato
                                            ? Border.all(
                                                color: UI.green,
                                                width: 1.5,
                                              )
                                            : Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.04,
                                                ),
                                              ),

                                        boxShadow: selezionato
                                            ? [
                                                BoxShadow(
                                                  color: UI.green.withOpacity(
                                                    0.5,
                                                  ),
                                                  blurRadius: 20,
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: isMobile ? 18 : 22,
                                            backgroundColor: Colors.black,
                                            backgroundImage:
                                                photoUrl != null &&
                                                    photoUrl
                                                        .toString()
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    photoUrl.toString(),
                                                  )
                                                : null,
                                            child:
                                                photoUrl == null ||
                                                    photoUrl.toString().isEmpty
                                                ? Text(
                                                    nomeOperatore.isNotEmpty
                                                        ? nomeOperatore[0]
                                                              .toUpperCase()
                                                        : "?",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),

                                          const SizedBox(width: 8),

                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                nomeOperatore,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: selezionato
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  fontSize: isMobile ? 13 : 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 42),

                          premiumSectionTitle("SELEZIONA IL GIORNO"),

                          const SizedBox(height: 18),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: isMobile ? 0 : 10,
                            ),

                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 22,
                              vertical: isMobile ? 18 : 26,
                            ),

                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1A1A1A), Color(0xFF101010)],
                              ),

                              borderRadius: BorderRadius.circular(
                                isMobile ? 34 : 40,
                              ),

                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),

                                BoxShadow(
                                  color: Colors.white.withOpacity(0.02),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),

                                BoxShadow(
                                  color: const Color(
                                    0xFF00C853,
                                  ).withOpacity(0.05),
                                  blurRadius: 12,
                                ),
                              ],
                            ),

                            child: TableCalendar(
                              rowHeight: isMobile ? 52 : 64,
                              daysOfWeekHeight: 26,
                              locale: 'it_IT',

                              firstDay: DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),

                              lastDay: DateTime.now().add(
                                const Duration(days: 30),
                              ),

                              focusedDay: selectedDay,

                              selectedDayPredicate: (d) =>
                                  isSameDay(d, selectedDay),

                              availableGestures:
                                  AvailableGestures.horizontalSwipe,

                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,

                                titleCentered: true,
                                titleTextFormatter: (date, locale) {
                                  return DateFormat(
                                    'MMMM yyyy',
                                    'it_IT',
                                  ).format(date).toUpperCase();
                                },

                                headerPadding: EdgeInsets.only(
                                  bottom: isMobile ? 22 : 30,
                                ),

                                titleTextStyle: TextStyle(
                                  color: Colors.white,

                                  fontSize: isMobile ? 16 : 20,

                                  fontWeight: FontWeight.w900,

                                  letterSpacing: 4,

                                  height: 1,
                                ),

                                leftChevronIcon: Container(
                                  padding: const EdgeInsets.all(10),

                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),

                                    borderRadius: BorderRadius.circular(18),
                                  ),

                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                  ),
                                ),

                                rightChevronIcon: Container(
                                  padding: const EdgeInsets.all(10),

                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),

                                    borderRadius: BorderRadius.circular(18),
                                  ),

                                  child: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.55),

                                  fontWeight: FontWeight.w700,

                                  fontSize: 12,

                                  letterSpacing: 1,
                                ),

                                weekendStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),

                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,

                                defaultDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),

                                todayDecoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),

                                selectedDecoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),

                                defaultTextStyle: TextStyle(
                                  color: Colors.white,
                                ),

                                weekendTextStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),

                              onDaySelected: (day, focusedDay) async {
                                final today = DateTime.now();
                                final isToday = isSameDay(day, today);

                                final isPast = day.isBefore(
                                  DateTime(today.year, today.month, today.day),
                                );

                                if (isPast) return;

                                if (day.weekday == 7) return;

                                setState(() {
                                  selectedDay = day;

                                  data = day;

                                  orario = null;
                                });

                                await caricaScheduleOperatore();
                                ascoltaScheduleRealtime();
                              },

                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  final isSelected = isSameDay(
                                    day,
                                    selectedDay,
                                  );

                                  final domenica = day.weekday == 7;

                                  final today = DateTime.now();
                                  final isToday = isSameDay(day, today);

                                  final isPast = day.isBefore(
                                    DateTime(
                                      today.year,
                                      today.month,
                                      today.day,
                                    ),
                                  );

                                  if (domenica || isPast) {
                                    return Container(
                                      margin: const EdgeInsets.all(6),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),

                                        color: Colors.black,
                                      ),

                                      child: Center(
                                        child: Text(
                                          "${day.day}",

                                          style: const TextStyle(
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),

                                    margin: const EdgeInsets.all(6),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),

                                      gradient: isSelected
                                          ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF00C853),
                                                Color(0xFF00A63E),
                                              ],
                                            )
                                          : isToday
                                          ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF3A3A3A),
                                                Color(0xFF2A2A2A),
                                              ],
                                            )
                                          : const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF262626),
                                                Color(0xFF1B1B1B),
                                              ],
                                            ),

                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.95)
                                            : isToday
                                            ? const Color(0xFF00C853)
                                            : Colors.white.withOpacity(0.04),

                                        width: isSelected ? 2 : 1,
                                      ),

                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00C853,
                                            ).withOpacity(0.40),

                                            blurRadius: 22,

                                            offset: const Offset(0, 10),
                                          ),

                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.28),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),

                                    child: Center(
                                      child: Text(
                                        "${day.day}",

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,

                                          fontSize: isMobile ? 14 : 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },

                                todayBuilder: (context, day, focusedDay) {
                                  return Container(
                                    margin: const EdgeInsets.all(6),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),

                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF353535),
                                          Color(0xFF262626),
                                        ],
                                      ),

                                      border: Border.all(
                                        color: const Color(0xFF00C853),
                                        width: 1.4,
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.30),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),

                                    child: Center(
                                      child: Text(
                                        "${day.day}",

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  );
                                },

                                selectedBuilder: (context, day, focusedDay) {
                                  return Container(
                                    margin: const EdgeInsets.all(6),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),

                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF00C853),
                                          Color(0xFF009624),
                                        ],
                                      ),

                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.45),

                                          blurRadius: 22,
                                          offset: const Offset(0, 10),
                                        ),

                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.30),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),

                                    child: Center(
                                      child: Text(
                                        "${day.day}",

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 42),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('utenti')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox();

                              final clienti = snapshot.data!.docs.toList()
                                ..sort((a, b) {
                                  final dataA =
                                      a.data() as Map<String, dynamic>;
                                  final dataB =
                                      b.data() as Map<String, dynamic>;

                                  final nomeA = (dataA['nome'] ?? "")
                                      .toString()
                                      .toLowerCase();
                                  final nomeB = (dataB['nome'] ?? "")
                                      .toString()
                                      .toLowerCase();

                                  return nomeA.compareTo(nomeB);
                                });

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 220),

                                margin: EdgeInsets.symmetric(
                                  horizontal: sidePadding,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    dropdownColor: const Color(0xFF1A1A1A),
                                    hint: const Text(
                                      "Cliente registrato (opzionale)",
                                      style: TextStyle(color: Colors.white38),
                                    ),
                                    value: userIdSelezionato,
                                    isExpanded: true,
                                    items: clienti.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;

                                      return DropdownMenuItem(
                                        value: doc.id,
                                        child: Text(
                                          "${data['nome'] ?? ""} ${data['cognome'] ?? ""}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      final selected = clienti.firstWhere(
                                        (c) => c.id == value,
                                      );
                                      final data =
                                          selected.data()
                                              as Map<String, dynamic>;

                                      setState(() {
                                        userIdSelezionato = value as String;
                                        nome.text =
                                            "${data['nome'] ?? ""} ${data['cognome'] ?? ""}"
                                                .trim();
                                        telefono.text = data['telefono'] ?? "";
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 42),

                          if (userIdSelezionato != null)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: sidePadding,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  // ✅ BADGE
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFF00C853,
                                            ).withOpacity(0.20),
                                            const Color(
                                              0xFF00C853,
                                            ).withOpacity(0.04),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF00C853),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Cliente registrato",
                                          style: TextStyle(
                                            color: Color(0xFF00C853),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // ❌ RIMUOVI
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,

                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          userIdSelezionato = null;
                                          nome.clear();
                                          telefono.clear();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: Colors.redAccent.withOpacity(
                                            0.1,
                                          ),
                                          border: Border.all(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        child: const Text(
                                          "Rimuovi",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 34),

                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: sidePadding,
                              vertical: 8,
                            ),
                            decoration: UI.card(),
                            child: TextField(
                              controller: nome,
                              enabled: userIdSelezionato == null,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,

                                hintText: "INSERIRE NOME E COGNOME ",

                                hintStyle: TextStyle(color: Colors.white),

                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),

                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),

                                  borderSide: const BorderSide(
                                    color: Color(0xFF00C853),
                                    width: 1.4,
                                  ),
                                ),

                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: sidePadding,
                              vertical: 8,
                            ),
                            decoration: UI.card(),
                            child: TextField(
                              controller: telefono,
                              enabled: userIdSelezionato == null,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,

                                hintText: "INSERIRE TELEFONO",

                                hintStyle: TextStyle(color: Colors.white),

                                prefixIcon: Icon(
                                  Icons.phone_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),

                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),

                                  borderSide: const BorderSide(
                                    color: Color(0xFF00C853),
                                    width: 1.4,
                                  ),
                                ),

                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 42),

                          premiumSectionTitle("SELEZIONA IL SERVIZIO"),

                          const SizedBox(height: 18),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: servizi.length,

                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),

                            itemBuilder: (context, i) {
                              final s = servizi[i];

                              final selected = servizioSelezionato == s;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    servizioSelezionato = s;
                                    orario = null;
                                  });
                                },

                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),

                                  padding: const EdgeInsets.all(18),

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),

                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1A1A1A),
                                        Color(0xFF101010),
                                      ],
                                    ),

                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFF00C853)
                                          : Colors.white.withOpacity(.05),
                                      width: selected ? 1.5 : 1,
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),

                                      if (selected)
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00C853,
                                          ).withOpacity(.18),
                                          blurRadius: 24,
                                        ),
                                    ],
                                  ),

                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),

                                        width: 48,
                                        height: 48,

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,

                                          color: selected
                                              ? const Color(
                                                  0xFF00C853,
                                                ).withOpacity(.14)
                                              : Colors.white.withOpacity(.05),
                                        ),

                                        child: Icon(
                                          Icons.content_cut_rounded,
                                          color: selected
                                              ? const Color(0xFF69F0AE)
                                              : Colors.white60,
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              s["nome"],

                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              "${s["durata"]} min",

                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  .45,
                                                ),

                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,

                                        children: [
                                          Text(
                                            s["prezzo"],

                                            style: const TextStyle(
                                              color: Color(0xFF69F0AE),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),

                                            child: selected
                                                ? const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Color(0xFF69F0AE),
                                                    key: ValueKey("selected"),
                                                  )
                                                : const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    key: ValueKey("empty"),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          const SizedBox(height: 20),

                          const SizedBox(height: 20),

                          premiumSectionTitle("DISPONIBILITÀ RIMASTE"),

                          const SizedBox(height: 18),

                          if (operatore == null)
                            premiumAvailabilityEmptyState(isMobile: isMobile)
                          else
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('availability_public')
                                  .doc(
                                    "${operatore?.toLowerCase()}_"
                                    "${data.year}-"
                                    "${data.month.toString().padLeft(2, '0')}-"
                                    "${data.day.toString().padLeft(2, '0')}",
                                  )
                                  .snapshots(),

                              builder: (context, snapshot) {
                                final docId =
                                    "${operatore?.toLowerCase()}_"
                                    "${data.year}-"
                                    "${data.month.toString().padLeft(2, '0')}-"
                                    "${data.day.toString().padLeft(2, '0')}";

                                if (!snapshot.hasData) {
                                  return const SizedBox();
                                }

                                final doc = snapshot.data!;

                                if (!doc.exists) {
                                  if (currentSchedule == null) {
                                    return const SizedBox();
                                  }

                                  final disponibili =
                                      SlotService.generateSlotsFromSchedule(
                                        start: currentSchedule!.start,
                                        end: currentSchedule!.end,
                                        pauseStart: currentSchedule!.pauseStart,
                                        pauseEnd: currentSchedule!.pauseEnd,
                                        durata: 10,
                                      ).where((slot) {
                                        final now = DateTime.now();

                                        final slotTime = DateTime(
                                          data.year,
                                          data.month,
                                          data.day,
                                          int.parse(slot.split(":")[0]),
                                          int.parse(slot.split(":")[1]),
                                        );

                                        final isToday =
                                            data.year == now.year &&
                                            data.month == now.month &&
                                            data.day == now.day;

                                        if (isToday && slotTime.isBefore(now)) {
                                          return false;
                                        }

                                        return true;
                                      });

                                  final mattina = disponibili.where((e) {
                                    return int.parse(e.split(":")[0]) < 13;
                                  }).toList();

                                  final pomeriggio = disponibili.where((e) {
                                    return int.parse(e.split(":")[0]) >= 13;
                                  }).toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      if (mattina.isNotEmpty) ...[
                                        slotGroupTitle(
                                          "MATTINA",
                                          Icons.wb_sunny_outlined,
                                        ),

                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,

                                          children: mattina.map((o) {
                                            final selected = orario == o;

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  orario = o;
                                                });
                                              },

                                              child: premiumSlot(o, selected),
                                            );
                                          }).toList(),
                                        ),
                                      ],

                                      const SizedBox(height: 28),

                                      if (pomeriggio.isNotEmpty) ...[
                                        slotGroupTitle(
                                          "POMERIGGIO",
                                          Icons.nightlight_round,
                                        ),

                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,

                                          children: pomeriggio.map((o) {
                                            final selected = orario == o;

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  orario = o;
                                                });
                                              },

                                              child: premiumSlot(o, selected),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  );
                                }

                                final dataMap =
                                    doc.data() as Map<String, dynamic>;

                                final slots = Map<String, dynamic>.from(
                                  dataMap['slots'] ?? {},
                                );

                                final durata =
                                    servizioSelezionato?["durata"] ?? 30;

                                if (currentSchedule == null) {
                                  return const SizedBox();
                                }

                                final disponibili =
                                    SlotService.generateSlotsFromSchedule(
                                      start: currentSchedule!.start,
                                      end: currentSchedule!.end,
                                      pauseStart: currentSchedule!.pauseStart,
                                      pauseEnd: currentSchedule!.pauseEnd,
                                      durata: 10,
                                    ).where((slot) {
                                      final now = DateTime.now();

                                      final slotTime = DateTime(
                                        data.year,
                                        data.month,
                                        data.day,
                                        int.parse(slot.split(":")[0]),
                                        int.parse(slot.split(":")[1]),
                                      );

                                      final isToday =
                                          data.year == now.year &&
                                          data.month == now.month &&
                                          data.day == now.day;

                                      if (isToday && slotTime.isBefore(now)) {
                                        return false;
                                      }
                                      final start = DateTime(
                                        data.year,
                                        data.month,
                                        data.day,
                                        int.parse(slot.split(":")[0]),
                                        int.parse(slot.split(":")[1]),
                                      );

                                      for (
                                        int offset = 0;
                                        offset < durata;
                                        offset += 10
                                      ) {
                                        final check = start.add(
                                          Duration(minutes: offset),
                                        );

                                        final checkSlot =
                                            "${check.hour.toString().padLeft(2, '0')}:"
                                            "${check.minute.toString().padLeft(2, '0')}";

                                        if (slots[checkSlot] == false) {
                                          return false;
                                        }
                                      }

                                      return true;
                                    }).toList();

                                final mattina = disponibili.where((e) {
                                  return int.parse(e.split(":")[0]) < 13;
                                }).toList();

                                final pomeriggio = disponibili.where((e) {
                                  return int.parse(e.split(":")[0]) >= 13;
                                }).toList();

                                if (disponibili.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(24),

                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.event_busy_rounded,
                                          color: Colors.white24,
                                          size: 42,
                                        ),

                                        SizedBox(height: 14),

                                        Text(
                                          "NESSUNA DISPONIBILITÀ",

                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    if (mattina.isNotEmpty) ...[
                                      slotGroupTitle(
                                        "MATTINA",
                                        Icons.wb_sunny_outlined,
                                      ),

                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,

                                        children: mattina.map((o) {
                                          final selected = orario == o;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                orario = o;
                                              });
                                            },

                                            child: premiumSlot(o, selected),
                                          );
                                        }).toList(),
                                      ),
                                    ],

                                    const SizedBox(height: 28),

                                    if (pomeriggio.isNotEmpty) ...[
                                      slotGroupTitle(
                                        "POMERIGGIO",
                                        Icons.nightlight_round,
                                      ),

                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,

                                        children: pomeriggio.map((o) {
                                          final selected = orario == o;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                orario = o;
                                              });
                                            },

                                            child: premiumSlot(o, selected),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),

                          const SizedBox(height: 20),

                          GestureDetector(
                            onTapDown: (_) {
                              setState(() {
                                buttonPressed = true;
                              });
                            },

                            onTapUp: (_) {
                              setState(() {
                                buttonPressed = false;
                              });
                            },

                            onTapCancel: () {
                              setState(() {
                                buttonPressed = false;
                              });
                            },

                            onTap:
                                (nome.text.isNotEmpty &&
                                    servizioSelezionato != null &&
                                    orario != null &&
                                    operatore != null &&
                                    !giornataChiusaLocal &&
                                    !loading)
                                ? salva
                                : null,
                            child: AnimatedScale(
                              scale: buttonPressed ? 0.97 : 1,
                              duration: const Duration(milliseconds: 120),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                  horizontal: sidePadding,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 16 : 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      (nome.text.isNotEmpty &&
                                          servizioSelezionato != null &&
                                          orario != null &&
                                          operatore != null &&
                                          !giornataChiusaLocal)
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1F1F1F),
                                            Color(0xFF121212),
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.withOpacity(0.25),
                                            Colors.grey.withOpacity(0.18),
                                          ],
                                        ),

                                  borderRadius: BorderRadius.circular(24),

                                  border: Border.all(
                                    color:
                                        (nome.text.isNotEmpty &&
                                            servizioSelezionato != null &&
                                            orario != null &&
                                            operatore != null &&
                                            !giornataChiusaLocal)
                                        ? const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.15)
                                        : Colors.white.withOpacity(0.03),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),

                                    if (nome.text.isNotEmpty &&
                                        servizioSelezionato != null &&
                                        orario != null &&
                                        operatore != null &&
                                        !giornataChiusaLocal)
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00C853,
                                        ).withOpacity(0.10),

                                        blurRadius: 22,
                                      ),
                                  ],
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),

                                  child: loading
                                      ? SizedBox(
                                          key: const ValueKey("loading"),

                                          width: 22,
                                          height: 22,

                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          key: const ValueKey("normal"),

                                          mainAxisAlignment:
                                              MainAxisAlignment.center,

                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),

                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(
                                                  0.06,
                                                ),
                                              ),

                                              child: const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Text(
                                              "CONFERMA WALK-IN",

                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.8,
                                                fontSize: isMobile ? 13 : 14,
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
