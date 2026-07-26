import 'package:barber_app/main.dart';
import 'package:flutter/material.dart';
import 'app_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barber_app/core/responsive/responsive_utils.dart';
import 'dart:ui';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:barber_app/services/notification_service.dart';

class MiePrenotazioniPage extends StatefulWidget {
  const MiePrenotazioniPage({super.key});

  @override
  State<MiePrenotazioniPage> createState() => _MiePrenotazioniPageState();
}

class _MiePrenotazioniPageState extends State<MiePrenotazioniPage> {
  final Set<String> _cancellingBookingIds = <String>{};

  void _showCancelError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 28),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.14),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
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

Future<void> _cancelLocalReminderIfValid(dynamic rawId) async {
  final int? id = rawId is int
      ? rawId
      : rawId is num
          ? rawId.toInt()
          : null;

  if (id == null) return;

  const minAndroidId = -2147483648;
  const maxAndroidId = 2147483647;

  if (id < minAndroidId || id > maxAndroidId) {
    debugPrint("Skip cancel local notification: invalid id $id");
    return;
  }

  try {
    await NotificationService.cancelNotification(id);
  } catch (e) {
    debugPrint("Errore cancellazione notifica locale $id: $e");
  }
}

  String _capitalizeWord(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _operatorNameFromBooking(Map<String, dynamic> data) {
    final directName =
        data['operatorName'] ??
        data['operatorDisplayName'] ??
        data['nomeOperatore'] ??
        data['barberName'];

    if (directName != null && directName.toString().trim().isNotEmpty) {
      return directName.toString().trim();
    }

    final rawOperator =
        data['operatorId'] ??
        data['operatore'] ??
        data['barberId'] ??
        data['barber'];

    if (rawOperator == null || rawOperator.toString().trim().isEmpty) {
      return "Operatore";
    }

    final cleaned = rawOperator
        .toString()
        .trim()
        .replaceAll("_", " ")
        .replaceAll("-", " ");

    return cleaned
        .split(" ")
        .where((word) => word.trim().isNotEmpty)
        .map((word) => _capitalizeWord(word.trim()))
        .join(" ");
  }

  Widget _bookingDetailChip({
  required IconData icon,
  required String label,
  required String value,
  bool accent = false,
  double? width,
  bool multiline = false,
}) {
  final isMobile = Responsive.isMobile(context);
  final isTablet = Responsive.isTablet(context);
  final isDesktop = Responsive.isDesktop(context);

  final maxTextWidth = isDesktop
      ? 260.0
      : isTablet
          ? 230.0
          : MediaQuery.of(context).size.width * 0.42;

  final valueStyle = TextStyle(
    color: accent ? Colors.white.withOpacity(0.92) : Colors.white70,
    fontSize: isDesktop ? 12.5 : 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
  );

  return Container(
    width: width,
    padding: EdgeInsets.symmetric(
      horizontal: isDesktop ? 13 : 12,
      vertical: isDesktop ? 8 : 7,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(accent ? 0.055 : 0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: accent
            ? const Color(0xFF00C853).withOpacity(0.16)
            : Colors.white.withOpacity(0.05),
      ),
      boxShadow: accent
          ? [
              BoxShadow(
                color: const Color(0xFF00C853).withOpacity(0.045),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ]
          : [],
    ),
    child: Row(
  mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
  crossAxisAlignment:
      multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
  children: [
        Icon(
          icon,
          color: accent
              ? const Color(0xFF69F0AE).withOpacity(0.9)
              : Colors.white60,
          size: isDesktop ? 15 : 14,
        ),
        const SizedBox(width: 7),
        Text(
          "${label.toUpperCase()}:",
          style: TextStyle(
            color: Colors.white.withOpacity(0.42),
            fontSize: isMobile ? 9.5 : 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 5),
        width == null
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTextWidth),
                child: Text(
                  value,
                  maxLines: multiline ? 2 : 1,
overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
softWrap: multiline,
                  style: valueStyle,
                ),
              )
            : Expanded(
                child: Text(
                  value,
                  maxLines: multiline ? 2 : 1,
overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
softWrap: multiline,
                  style: valueStyle,
                ),
              ),
      ],
    ),
  );
}

  Widget _responsiveDialogShell({
    required BuildContext dialogContext,
    required Widget child,
    double maxWidth = 420,
  }) {
    final media = MediaQuery.of(dialogContext);

    final availableHeight =
        media.size.height - media.padding.top - media.padding.bottom - 48;

    final dialogMaxHeight = availableHeight.clamp(280.0, 720.0).toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: dialogMaxHeight,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isMobile = Responsive.isMobile(context);

    final isTablet = Responsive.isTablet(context);

    final isDesktop = Responsive.isDesktop(context);

    final horizontalPadding = Responsive.horizontalPadding(context);

    final maxWidth = Responsive.maxContentWidth(context);
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Non sei loggato")));
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,

          centerTitle: true,

          toolbarHeight: Responsive.isDesktop(context)
              ? 90
              : Responsive.isTablet(context)
              ? 82
              : 74,

          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.black,

                      const Color(0xFF111111),

                      Colors.black.withOpacity(0.96),
                    ],
                  ),
                ),
              ),
            ),
          ),

          leadingWidth: 70,

          leading: Padding(
            padding: EdgeInsets.only(
              left: Responsive.horizontalPadding(context),
            ),

            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },

                child: Container(
                  width: Responsive.isDesktop(context) ? 52 : 46,

                  height: Responsive.isDesktop(context) ? 52 : 46,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),

                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.isDesktop(context) ? 14 : 12,

                  vertical: Responsive.isDesktop(context) ? 5 : 4,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),

                  borderRadius: BorderRadius.circular(30),

                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.25),
                  ),
                ),

                child: Text(
                  "AREA CLIENTE",

                  style: TextStyle(
                    color: const Color(0xFF69F0AE),

                    fontSize: Responsive.isDesktop(context) ? 13 : 11,

                    fontWeight: FontWeight.w700,

                    letterSpacing: 1.8,
                  ),
                ),
              ),

              SizedBox(height: Responsive.isDesktop(context) ? 6 : 4),

              Text(
                "Le tue prenotazioni",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: Responsive.isDesktop(context)
                      ? 22
                      : Responsive.isTablet(context)
                      ? 20
                      : 17,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),

            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('appuntamenti')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Nessun dato"));
                }

                final now = DateTime.now();

                final docs = snapshot.data!.docs.where((doc) {
                  final data = (doc['startAt'] as Timestamp).toDate();
                  final start = (doc['startAt'] as Timestamp).toDate();

                  final ora =
                      "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";

                  final parts = ora.split(":");

                  final prenotazioneDateTime = DateTime(
                    data.year,
                    data.month,
                    data.day,
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                  );

                  return prenotazioneDateTime.isAfter(now);
                }).toList();

                docs.sort((a, b) {
                  final dataA = (a['startAt'] as Timestamp).toDate();

                  final dataB = (b['startAt'] as Timestamp).toDate();

                  return dataA.compareTo(dataB);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),

                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90,
                              height: 90,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                color: Colors.white.withOpacity(0.05),

                                border: Border.all(
                                  color: Colors.white.withOpacity(0.10),
                                ),
                              ),

                              child: const Icon(
                                Icons.event_busy,
                                color: Colors.white70,
                                size: 34,
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              "Non sono presenti prenotazioni.",

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Una volta effettuata, la prenotazione sarà visibile in questa sezione.",

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    MediaQuery.of(context).padding.bottom + 30,
                  ),
                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final doc = docs[index];

                    final data = doc.data() as Map<String, dynamic>;
                    final bookingId = doc.id;
                    final isCancelling = _cancellingBookingIds.contains(
                      bookingId,
                    );
                    final dataPren = (data['startAt'] as Timestamp).toDate();

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

                    final giorno = giorni[dataPren.weekday - 1];

                    final mese = mesi[dataPren.month - 1];

                    final appointmentLabel =
                        "$giorno ${dataPren.day} $mese • ${dataPren.hour.toString().padLeft(2, '0')}:${dataPren.minute.toString().padLeft(2, '0')}";

                    final operatorName = _operatorNameFromBooking(data);

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(
                        Responsive.isDesktop(context)
                            ? 24
                            : Responsive.isTablet(context)
                            ? 20
                            : 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF232323), Color(0xFF161616)],
                        ),

                        borderRadius: BorderRadius.circular(
                          isDesktop ? 32 : 26,
                        ),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.75),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),

                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.05),
                            blurRadius: 24,
                            spreadRadius: 1,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔥 ICONA
                              Container(
                                width: 54,
                                height: 54,

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2B2B2B),
                                      Color(0xFF171717),
                                    ],
                                  ),

                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.06),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),

                                    BoxShadow(
                                      color: const Color(
                                        0xFF00C853,
                                      ).withOpacity(0.08),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),

                                child: const Icon(
                                  Icons.content_cut_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 14),

                              // 🔥 TESTI
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['servizio'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                        height: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: LayoutBuilder(
  builder: (context, constraints) {
    final chipWidth = Responsive.isMobile(context)
        ? constraints.maxWidth
        : null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _bookingDetailChip(
  icon: Icons.calendar_month_rounded,
  label: "Quando",
  value: appointmentLabel,
  width: chipWidth,
  multiline: Responsive.isMobile(context),
),
        _bookingDetailChip(
          icon: Icons.person_rounded,
          label: "Operatore",
          value: operatorName,
          accent: true,
          width: chipWidth,
        ),
      ],
    );
  },
),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 🔥 BOTTONI RESPONSIVE
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,

                                        builder: (dialogContext) {
                                          return _responsiveDialogShell(
                                            dialogContext: dialogContext,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(36),

                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 24,
                                                  sigmaY: 24,
                                                ),

                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    28,
                                                  ),

                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          36,
                                                        ),

                                                    gradient:
                                                        const LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,

                                                          colors: [
                                                            Color(0xFF1B1B1B),
                                                            Color(0xFF111111),
                                                          ],
                                                        ),

                                                    border: Border.all(
                                                      color: Colors.white10,
                                                    ),

                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.55),
                                                        blurRadius: 40,
                                                        offset: const Offset(
                                                          0,
                                                          20,
                                                        ),
                                                      ),

                                                      BoxShadow(
                                                        color: Colors.white
                                                            .withOpacity(0.02),
                                                        blurRadius: 10,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),

                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,

                                                    children: [
                                                      Container(
                                                        width: 56,
                                                        height: 56,

                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,

                                                          gradient:
                                                              LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,

                                                                colors: [
                                                                  const Color(
                                                                    0xFF00C853,
                                                                  ).withOpacity(
                                                                    0.22,
                                                                  ),

                                                                  const Color(
                                                                    0xFF69F0AE,
                                                                  ).withOpacity(
                                                                    0.08,
                                                                  ),
                                                                ],
                                                              ),

                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF69F0AE,
                                                            ).withOpacity(0.20),
                                                          ),
                                                        ),

                                                        child: const Icon(
                                                          Icons
                                                              .info_outline_rounded,
                                                          color: Colors.white70,
                                                          size: 34,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 24,
                                                      ),

                                                      const Text(
                                                        "Come modificare una prenotazione?",

                                                        textAlign:
                                                            TextAlign.center,

                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          letterSpacing: 1.5,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 12,
                                                      ),

                                                      Text(
                                                        "Per modificare una prenotazione è necessario cancellare quella attuale e crearne una nuova dalla sezione principale.",

                                                        textAlign:
                                                            TextAlign.center,

                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                0.68,
                                                              ),
                                                          fontSize: 14,
                                                          height: 1.6,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 30,
                                                      ),

                                                      Center(
                                                        child: SizedBox(
                                                          width: 160,
                                                          height: 58,

                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFF00C853,
                                                                  ),

                                                              elevation: 0,

                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      18,
                                                                    ),
                                                              ),
                                                            ),

                                                            onPressed: () {
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop();
                                                            },

                                                            child: const Text(
                                                              "CHIUDI",

                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                letterSpacing:
                                                                    1.2,
                                                                fontSize: 13,
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
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF00C853,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF00C853,
                                          ).withOpacity(0.25),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.edit,
                                            color: Color(0xFF00C853),
                                            size: 14,
                                          ),

                                          SizedBox(width: 6),

                                          Flexible(
                                            child: Text(
                                              "Modifica",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: Color(0xFF00C853),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: GestureDetector(
                                  onTap: isCancelling
                                      ? null
                                      : () {
                                          bool dialogCancelling = false;

                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (dialogContext) {
                                              return StatefulBuilder(
                                                builder: (dialogContext, setDialogState) {
                                                  return PopScope(
                                                    canPop: !dialogCancelling,
                                                    child: _responsiveDialogShell(
                                                      dialogContext:
                                                          dialogContext,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 28,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF181818,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.7,
                                                                  ),
                                                              blurRadius: 30,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    12,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    14,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .red
                                                                    .withOpacity(
                                                                      0.12,
                                                                    ),
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .withOpacity(
                                                                        0.25,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                color: Colors
                                                                    .redAccent,
                                                                size: 28,
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 10,
                                                            ),

                                                            const Text(
                                                              "Cancella prenotazione",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 10,
                                                            ),

                                                            const Text(
                                                              "Questa operazione eliminerà definitivamente l’appuntamento.",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white54,
                                                                fontSize: 14,
                                                                height: 1.5,
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 28,
                                                            ),

                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: OutlinedButton(
                                                                    style: OutlinedButton.styleFrom(
                                                                      side: BorderSide(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.08,
                                                                            ),
                                                                      ),
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            16,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              14,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        dialogCancelling
                                                                        ? null
                                                                        : () {
                                                                            Navigator.of(
                                                                              dialogContext,
                                                                            ).pop();
                                                                          },
                                                                    child: const Text(
                                                                      "Annulla",
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .white70,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),

                                                                const SizedBox(
                                                                  width: 14,
                                                                ),

                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          const Color(
                                                                            0xFFE53935,
                                                                          ),
                                                                      elevation:
                                                                          0,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            16,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              14,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        dialogCancelling
                                                                        ? null
                                                                        : () async {
                                                                            if (_cancellingBookingIds.contains(
                                                                              bookingId,
                                                                            )) {
                                                                              return;
                                                                            }

                                                                            setDialogState(() {
                                                                              dialogCancelling = true;
                                                                            });

                                                                            if (mounted) {
                                                                              setState(
                                                                                () {
                                                                                  _cancellingBookingIds.add(
                                                                                    bookingId,
                                                                                  );
                                                                                },
                                                                              );
                                                                            }

                                                                            try {
                                                                              await FirebaseFunctions.instance
    .httpsCallable('cancelBooking')
    .call(
      {
        "bookingId": bookingId,
      },
    );

await _cancelLocalReminderIfValid(data['notification2hId']);
await _cancelLocalReminderIfValid(data['notification24hId']);

                                                                              if (dialogContext.mounted) {
                                                                                Navigator.of(
                                                                                  dialogContext,
                                                                                ).pop();
                                                                              }
                                                                            } on FirebaseFunctionsException catch (
                                                                              e
                                                                            ) {
                                                                              String
                                                                              message = "Non siamo riusciti a cancellare la prenotazione.";

                                                                              if (e.code ==
                                                                                  "not-found") {
                                                                                message = "Questa prenotazione risulta già cancellata.";
                                                                              } else if (e.code ==
                                                                                  "permission-denied") {
                                                                                message = "Non hai i permessi per cancellare questa prenotazione.";
                                                                              } else if (e.code ==
                                                                                  "unauthenticated") {
                                                                                message = "Accedi di nuovo per cancellare la prenotazione.";
                                                                              }

                                                                              if (dialogContext.mounted) {
                                                                                Navigator.of(
                                                                                  dialogContext,
                                                                                ).pop();
                                                                              }

                                                                              _showCancelError(
                                                                                message,
                                                                              );
                                                                            } catch (
                                                                              _
                                                                            ) {
                                                                              if (dialogContext.mounted) {
                                                                                Navigator.of(
                                                                                  dialogContext,
                                                                                ).pop();
                                                                              }

                                                                              _showCancelError(
                                                                                "Errore imprevisto. Riprova tra qualche secondo.",
                                                                              );
                                                                            } finally {
                                                                              if (mounted) {
                                                                                setState(
                                                                                  () {
                                                                                    _cancellingBookingIds.remove(
                                                                                      bookingId,
                                                                                    );
                                                                                  },
                                                                                );
                                                                              }
                                                                            }
                                                                          },
                                                                    child:
                                                                        dialogCancelling
                                                                        ? const SizedBox(
                                                                            width:
                                                                                18,
                                                                            height:
                                                                                18,
                                                                            child: CircularProgressIndicator(
                                                                              strokeWidth: 2.2,
                                                                              color: Colors.white,
                                                                            ),
                                                                          )
                                                                        : const Text(
                                                                            "Elimina",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                  child: Opacity(
                                    opacity: isCancelling ? 0.45 : 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white10,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.delete_outline,
                                            color: Colors.white70,
                                            size: 14,
                                          ),

                                          SizedBox(width: 6),

                                          Flexible(
                                            child: Text(
                                              "Cancella",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
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
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
