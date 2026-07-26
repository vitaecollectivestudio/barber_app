import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:barber_app/features/admin/widgets/waitlist/waitlist_admin_section.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:barber_app/services/slot_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:barber_app/features/schedule/services/operator_schedule_service.dart';
import 'package:barber_app/features/schedule/models/operator_schedule_model.dart';
import '../../../clienti_page.dart';
import '../../../walkin_page.dart';
import 'package:barber_app/core/responsive/responsive_utils.dart';
import '../utils/constants.dart';
import 'package:barber_app/features/admin/widgets/premium_popup.dart';
import 'package:barber_app/features/admin/widgets/layout/premium_action_button.dart';
import 'package:barber_app/features/admin/widgets/layout/admin_topbar.dart';
import 'package:barber_app/features/admin/widgets/operators/operator_selector.dart';
import 'package:barber_app/features/admin/widgets/calendar/premium_calendar.dart';
import 'package:barber_app/features/admin/widgets/appointments/appointments_section.dart';
import 'package:barber_app/features/admin/widgets/appointments/appointment_card.dart';
import 'package:barber_app/features/admin/widgets/appointments/appointments_list.dart';
import 'package:barber_app/features/admin/widgets/appointments/appointments_empty_state.dart';
import 'package:barber_app/features/admin/widgets/appointments/appointments_header.dart';
import 'package:barber_app/features/admin/widgets/appointments/appointments_realtime_list.dart';
import 'package:barber_app/features/admin/widgets/common/premium_info_chip.dart';
import 'package:barber_app/features/admin/widgets/schedule/schedule_management_section.dart';
import 'package:barber_app/features/admin/widgets/schedule/schedule_slot_card.dart';
import 'package:barber_app/features/admin/widgets/schedule/schedule_header.dart';
import 'package:barber_app/features/admin/widgets/schedule/close_day_button.dart';
import 'package:barber_app/core/constants/schedule_constants.dart';
import 'package:barber_app/features/admin/services/admin_auth_service.dart';
import 'package:barber_app/features/admin/services/schedule_service.dart';
import 'package:barber_app/features/admin/services/appointments_service.dart';
import 'package:barber_app/features/admin/widgets/schedule/schedule_editor_dialog.dart';
import 'package:barber_app/features/availability/services/availability_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class BarberPanelPage extends StatefulWidget {
  const BarberPanelPage({super.key});

  @override
  State<BarberPanelPage> createState() => _BarberPanelPageState();
}

class _BarberPanelPageState extends State<BarberPanelPage> {
  Future<void> uploadOperatorImage(String operatorId) async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child("operators")
        .child("$operatorId.jpg");

    await ref.putFile(File(file.path));

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('operators')
        .doc(operatorId)
        .update({"imageUrl": url});
  }

  Future<void> eliminaOperatore(String operatorId, String name) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final isSmallPhone = mediaQuery.size.width <= 380;
        final dialogPadding = isSmallPhone ? 22.0 : 28.0;

        final maxDialogHeight =
            (mediaQuery.size.height -
                    mediaQuery.padding.top -
                    mediaQuery.padding.bottom -
                    mediaQuery.viewInsets.bottom -
                    48)
                .clamp(280.0, 720.0)
                .toDouble();

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: maxDialogHeight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(dialogPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1B1B1B), Color(0xFF101010)],
                        ),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 36,
                            offset: const Offset(0, 18),
                          ),
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.08),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isSmallPhone ? 58 : 64,
                            height: isSmallPhone ? 58 : 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent.withOpacity(0.12),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.24),
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 34,
                            ),
                          ),

                          SizedBox(height: isSmallPhone ? 16 : 18),

                          Text(
                            "ELIMINARE OPERATORE?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallPhone ? 19 : 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "$name verrà rimosso dal sistema.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.58),
                              fontSize: isSmallPhone ? 13 : 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: isSmallPhone ? 22 : 26),

                          LayoutBuilder(
                            builder: (buttonContext, constraints) {
                              final stackButtons = constraints.maxWidth < 330;

                              final cancelButton = OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  "ANNULLA",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    fontSize: 12,
                                  ),
                                ),
                              );

                              final deleteButton = ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('operators')
                                      .doc(operatorId)
                                      .delete();

                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                                child: const Text(
                                  "ELIMINA",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    fontSize: 12,
                                  ),
                                ),
                              );

                              if (stackButtons) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: cancelButton,
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: deleteButton,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: cancelButton),
                                  const SizedBox(width: 14),
                                  Expanded(child: deleteButton),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> aggiungiOperatore() async {
    final nomeController = TextEditingController();
    final ordineController = TextEditingController();

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final isSmallPhone = mediaQuery.size.width <= 380;
        final dialogPadding = isSmallPhone ? 22.0 : 28.0;
        final maxDialogHeight =
            (mediaQuery.size.height - mediaQuery.viewInsets.bottom - 48)
                .clamp(120.0, mediaQuery.size.height)
                .toDouble();

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: maxDialogHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(dialogPadding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B1B1B), Color(0xFF101010)],
                      ),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.55),
                          blurRadius: 36,
                          offset: const Offset(0, 18),
                        ),
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.08),
                          blurRadius: 26,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00C853).withOpacity(0.14),
                            border: Border.all(
                              color: const Color(0xFF69F0AE).withOpacity(0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Color(0xFF69F0AE),
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          "NUOVO OPERATORE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Aggiungi un professionista visibile nella sezione prenotazioni.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.58),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 26),

                        _PremiumAdminInput(
                          controller: nomeController,
                          hint: "Nome operatore",
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 14),

                        _PremiumAdminInput(
                          controller: ordineController,
                          hint: "Ordine visualizzazione",
                          icon: Icons.format_list_numbered_rounded,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "ANNULLA",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () async {
                                  final nome = nomeController.text.trim();

                                  if (nome.isEmpty) return;

                                  final id = nome.toLowerCase().replaceAll(
                                    " ",
                                    "_",
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('operators')
                                      .doc(id)
                                      .set({
                                        "displayName": nome,
                                        "active": true,
                                        "publicOrder":
                                            int.tryParse(
                                              ordineController.text.trim(),
                                            ) ??
                                            999,
                                        "imageUrl": "",
                                      });

                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  "SALVA",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    fontSize: 12,
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
              ),
            ),
          ),
        );
      },
    );

    nomeController.dispose();
    ordineController.dispose();
  }

  /*
final List<Map<String, String>> operatori = [

  {
    "nome": "Francesco",
    "img": "assets/images/francesco.jpeg",
  },

  {
    "nome": "Antonio",
    "img": "assets/images/antonio.jpeg",
  },
  
];
*/

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String filtro = "Tutti";

  String? orarioSelezionato;
  DaySchedule? currentSchedule;

  bool loadingSchedule = false;

  List<String> orariBloccati = [];

  bool slotOccupato(String ora, List<QueryDocumentSnapshot> docs) {
    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(ora.split(":")[0]),
      int.parse(ora.split(":")[1]),
    );

    final end = start.add(const Duration(minutes: 10));

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (filtro != "Tutti" &&
          data['operatorId'].toString().toLowerCase() != filtro.toLowerCase()) {
        continue;
      }

      final d = (data['startAt'] as Timestamp).toDate();

      final stessoGiorno =
          d.year == selectedDay.year &&
          d.month == selectedDay.month &&
          d.day == selectedDay.day;

      if (!stessoGiorno) continue;

      final startDoc = (data['startAt'] as Timestamp).toDate();

      final endDoc = (data['endAt'] as Timestamp).toDate();

      final overlap = start.isBefore(endDoc) && end.isAfter(startDoc);

      if (overlap) return true;
    }

    return false;
  }

  String getKey(DateTime giorno, String operatore) {
    return "${giorno.year}-${giorno.month}-${giorno.day}-$operatore";
  }

  String formatDataBella(DateTime d) {
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

    return "${giorni[d.weekday - 1]} ${d.day} ${mesi[d.month - 1]}";
  }

  Future<void> caricaScheduleOperatore() async {
    if (filtro == "Tutti") return;

    setState(() {
      loadingSchedule = true;
    });

    final dayId = DateFormat('EEEE', 'en_US').format(selectedDay).toLowerCase();

    final schedule = await OperatorScheduleService.getDaySchedule(
      operatorId: filtro.toLowerCase(),
      dayId: dayId,
    );

    if (!mounted) return;

    setState(() {
      currentSchedule = schedule;

      loadingSchedule = false;
    });
  }

bool _isCalendarDayClosed(
  DateTime day,
  List<QueryDocumentSnapshot> chiusiDocs,
) {
  if (filtro == "Tutti") return false;

  final dayKey = DateFormat('yyyy-MM-dd').format(day);

  return chiusiDocs.any((doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawDate = data['data'];
    final dateKey = data['dateKey']?.toString();

    final sameDayFromTimestamp = rawDate is Timestamp &&
        rawDate.toDate().year == day.year &&
        rawDate.toDate().month == day.month &&
        rawDate.toDate().day == day.day;

    final sameDayFromKey = dateKey == dayKey;

    final operatore = (data['operatore'] ?? data['operatorId'] ?? "")
        .toString()
        .toLowerCase();

    return (sameDayFromTimestamp || sameDayFromKey) &&
        operatore == filtro.toLowerCase();
  });
}

Color _calendarStatusColor({
  required int count,
  required int totaleSlot,
  required bool isClosed,
}) {
  if (isClosed) {
    return const Color(0xFFD4AF37);
  }

  if (filtro == "Tutti") {
    return count == 0
        ? const Color(0xFF00C853)
        : const Color(0xFFD8D8D8);
  }

  if (count >= totaleSlot) {
    return Colors.redAccent;
  }

  if (count <= (totaleSlot * 0.35)) {
    return const Color(0xFF00C853);
  }

  return const Color(0xFFD8D8D8);
}

Widget _calendarStatusStrip({
  required int count,
  required int totaleSlot,
  required bool isClosed,
  required bool isMobile,
}) {
  final color = _calendarStatusColor(
    count: count,
    totaleSlot: totaleSlot,
    isClosed: isClosed,
  );

  return Positioned(
  top: isMobile ? 6 : 7,
  right: isMobile ? 6 : 7,
  child: Container(
    width: isMobile ? 7 : 8,
    height: isMobile ? 7 : 8,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFF101010),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.45),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    ),
  ),
);
}

  @override
  Widget build(BuildContext context) {
    final width = Responsive.width(context);
    final isMobile = Responsive.isMobile(context);

    final isTablet = Responsive.isTablet(context);

    final isDesktop = Responsive.isDesktop(context);

    final orari = currentSchedule == null
        ? <String>[]
        : SlotService.generateSlotsFromSchedule(
            start: currentSchedule!.start,
            end: currentSchedule!.end,
            pauseStart: currentSchedule!.pauseStart,
            pauseEnd: currentSchedule!.pauseEnd,
            durata: 10,
          );
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

      child: Stack(
        children: [
          // 🌑 BACKGROUND PREMIUM
          // 🌑 BACKGROUND PREMIUM
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  const Color(0xFFFAFAFA),

                  const Color(0xFFF1F1F1),

                  const Color(0xFFE8E8E8),

                  const Color(0xFFF7F7F7),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,

                  colors: [Colors.white.withOpacity(0.85), Colors.transparent],
                ),
              ),
            ),
          ),
          // ✨ GLOW ALTO
          Positioned(
            top: -40,
            right: -60,

            child: Container(
              width: 320,
              height: 320,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withOpacity(0.07),
              ),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 180, sigmaY: 180),

                child: const SizedBox(),
              ),
            ),
          ),

          // 🔥 GLOW BASSO
          Positioned(
            bottom: -120,
            left: -80,

            child: Container(
              width: 280,
              height: 280,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withOpacity(0.05),
              ),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 160, sigmaY: 160),

                child: const SizedBox(),
              ),
            ),
          ),

          // 📱 CONTENUTO
          Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AdminTopBar(
              isMobile: isMobile,
              isTablet: isTablet,

              currentDate: formatDataBella(selectedDay),

              onClientsTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 260),

                    reverseTransitionDuration: const Duration(
                      milliseconds: 220,
                    ),

                    pageBuilder: (_, animation, __) {
                      return FadeTransition(
                        opacity: animation,

                        child: const ClientiPage(),
                      );
                    },
                  ),
                );
              },

              onWalkInTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 260),

                    reverseTransitionDuration: const Duration(
                      milliseconds: 220,
                    ),

                    pageBuilder: (_, animation, __) {
                      return FadeTransition(
                        opacity: animation,

                        child: WalkInPage(),
                      );
                    },
                  ),
                );
              },

              onLogoutTap: () async {
                await AdminAuthService.logoutCompleto();
              },
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? 1320
                        : isTablet
                        ? 1000
                        : double.infinity,
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: isDesktop
                            ? 230
                            : isTablet
                            ? 190
                            : 165,
                      ),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('operators')
                            .where('active', isEqualTo: true)
                            .orderBy('publicOrder')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                snapshot.error.toString(),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 92,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final operatoriFirestore = snapshot.data!.docs.map((
                            doc,
                          ) {
                            final data = doc.data() as Map<String, dynamic>;

                            return {
                              "id": doc.id,
                              "nome": data['displayName']?.toString() ?? doc.id,
                              "img": data['imageUrl']?.toString() ?? "",
                            };
                          }).toList();

                          return OperatorSelector(
                            isMobile: isMobile,
                            isTablet: isTablet,
                            operators: operatoriFirestore,
                            selectedOperator: filtro,
                            onAddOperator: aggiungiOperatore,
                            onSelected: (value) async {
                              setState(() {
                                filtro = value;
                              });

                              await caricaScheduleOperatore();
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('operators')
                            .orderBy('publicOrder')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1F1F1F), Color(0xFF101010)],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF00C853,
                                  ).withOpacity(0.08),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(11),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(
                                          0xFF00C853,
                                        ).withOpacity(0.12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF69F0AE,
                                          ).withOpacity(0.22),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: Color(0xFF69F0AE),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "GESTIONE OPERATORI",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "Gestisci la visibilità dei professionisti.",
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                ...snapshot.data!.docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final active = data['active'] ?? true;
                                  final name = data['displayName'] ?? doc.id;
                                  final imageUrl =
                                      data['imageUrl']?.toString() ?? "";

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.045),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.06),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await uploadOperatorImage(doc.id);
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 54,
                                                height: 54,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: active
                                                        ? const Color(
                                                            0xFF69F0AE,
                                                          ).withOpacity(0.55)
                                                        : Colors.white24,
                                                    width: 1.4,
                                                  ),
                                                ),
                                                child: imageUrl.isEmpty
                                                    ? const Icon(
                                                        Icons
                                                            .person_outline_rounded,
                                                        color: Colors.white54,
                                                      )
                                                    : imageUrl.startsWith(
                                                        "http",
                                                      )
                                                    ? Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.asset(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),

                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color(
                                                      0xFF00C853,
                                                    ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFF101010,
                                                      ),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.camera_alt_rounded,
                                                    color: Colors.black,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                active
                                                    ? "Visibile ai clienti"
                                                    : "Nascosto dalla prenotazione",
                                                style: TextStyle(
                                                  color: active
                                                      ? const Color(0xFF69F0AE)
                                                      : Colors.white38,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              GestureDetector(
                                                onTap: () async {
                                                  await uploadOperatorImage(
                                                    doc.id,
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 7,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF00C853,
                                                    ).withOpacity(0.10),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFF00C853,
                                                      ).withOpacity(0.20),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "CAMBIA FOTO",
                                                    style: TextStyle(
                                                      color: Color(0xFF69F0AE),
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: 1.1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Switch(
                                              value: active,
                                              activeColor: const Color(
                                                0xFF00C853,
                                              ),
                                              onChanged: (value) async {
                                                await FirebaseFirestore.instance
                                                    .collection('operators')
                                                    .doc(doc.id)
                                                    .update({"active": value});
                                              },
                                            ),

                                            const SizedBox(width: 4),

                                            GestureDetector(
                                              onTap: () async {
                                                await eliminaOperatore(
                                                  doc.id,
                                                  name.toString(),
                                                );
                                              },
                                              child: Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.redAccent
                                                      .withOpacity(0.12),
                                                  border: Border.all(
                                                    color: Colors.redAccent
                                                        .withOpacity(0.22),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.redAccent,
                                                  size: 19,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: isDesktop
                            ? 42
                            : isTablet
                            ? 34
                            : 28,
                      ),

                      // 👇 STREAM BUILDER (QUI METTIAMO CALENDARIO)
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('giorni_chiusi')
                            .snapshots(),
                        builder: (context, snapshotChiusi) {
                          if (!snapshotChiusi.hasData) return const SizedBox();

                          final chiusiDocs = snapshotChiusi.data!.docs;

                          return StreamBuilder(
                            stream: AppointmentsService.appointmentsStream(
                              visibleMonth: focusedDay,
                              operatorId: filtro == "Tutti" ? null : filtro,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox();

                              final docs = snapshot.data!.docs;

                              final giornataChiusa = chiusiDocs.any((doc) {
                                final d = (doc['data'] as Timestamp).toDate();

                                final stessoGiorno =
                                    d.year == selectedDay.year &&
                                    d.month == selectedDay.month &&
                                    d.day == selectedDay.day;

                                final stessoOperatore =
                                    doc['operatore'].toString().toLowerCase() ==
                                    filtro.toLowerCase();
                                return stessoGiorno && stessoOperatore;
                              });
                              final ordinati = docs.toList()
                                ..sort((a, b) {
                                  final dataA = (a['startAt'] as Timestamp)
                                      .toDate();

                                  final dataB = (b['startAt'] as Timestamp)
                                      .toDate();

                                  return dataA.compareTo(dataB);
                                });

                              final filteredAppointments = ordinati.where((
                                doc,
                              ) {
                                final data = doc.data() as Map<String, dynamic>;

                                if (!data.containsKey('startAt')) {
                                  return false;
                                }

                                final d = (doc['startAt'] as Timestamp)
                                    .toDate();

                                final sameDay =
                                    d.year == selectedDay.year &&
                                    d.month == selectedDay.month &&
                                    d.day == selectedDay.day;

                                if (!sameDay) return false;

                                if (filtro == "Tutti") {
                                  return true;
                                }

                                return doc['operatorId']
                                        .toString()
                                        .toLowerCase() ==
                                    filtro.toLowerCase();
                              }).toList();

                              return Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: isDesktop
          ? 1180
          : isTablet
              ? 940
              : double.infinity,
    ),
    child: SizedBox(
      width: double.infinity,
      child: Column(
      children: [
        const SizedBox(height: 20),

        // 🔥 CALENDARIO PREMIUM
        PremiumCalendar(
                                        child: TableCalendar(
                                          locale: 'it_IT',

                                          firstDay: DateTime.now(),
                                          lastDay: DateTime(
                                            DateTime.now().year + 1,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                          ),
                                          focusedDay: focusedDay,

                                          enabledDayPredicate: (day) {
                                            final today = DateTime.now();

                                            final isPast = day.isBefore(
                                              DateTime(
                                                today.year,
                                                today.month,
                                                today.day,
                                              ),
                                            );

                                            // ❌ giorni passati
                                            if (isPast) return false;

                                            // ❌ domenica
                                            if (day.weekday == 7) return false;

                                            return true;
                                          },

                                          headerStyle: HeaderStyle(
                                            formatButtonVisible: false,
                                            titleCentered: true,

                                            headerPadding: EdgeInsets.only(
                                              top: isMobile ? 6 : 10,
                                              bottom: isMobile ? 18 : 24,
                                            ),

                                            titleTextFormatter: (date, locale) {
                                              return DateFormat(
                                                'MMMM yyyy',
                                                locale,
                                              ).format(date).toUpperCase();
                                            },

                                            titleTextStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: isMobile
                                                  ? 15
                                                  : isTablet
                                                  ? 22
                                                  : 28,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: isMobile ? 1.2 : 3,
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.45),
                                            ),

                                            leftChevronIcon: Container(
                                              padding: const EdgeInsets.all(12),

                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.45,
                                                ),

                                                borderRadius:
                                                    BorderRadius.circular(18),

                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.04),
                                                ),

                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.35),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),

                                              child: const Icon(
                                                Icons.chevron_left,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),

                                            rightChevronIcon: Container(
                                              padding: const EdgeInsets.all(12),

                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.45,
                                                ),

                                                borderRadius:
                                                    BorderRadius.circular(18),

                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.04),
                                                ),

                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.35),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),

                                              child: const Icon(
                                                Icons.chevron_right,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),

                                          daysOfWeekStyle: DaysOfWeekStyle(
                                            weekdayStyle: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.55,
                                              ),

                                              fontWeight: FontWeight.w700,

                                              fontSize: isMobile ? 11 : 13,

                                              letterSpacing: 1,
                                            ),
                                            weekendStyle: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),

                                          calendarStyle: const CalendarStyle(
                                            defaultTextStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                            weekendTextStyle: TextStyle(
                                              color: Colors.white,
                                            ),

                                            selectedDecoration: BoxDecoration(
                                              color: Color.fromARGB(0, 0, 0, 0),
                                            ),

                                            todayDecoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                0,
                                                119,
                                                119,
                                                119,
                                              ),
                                            ),

                                            outsideDaysVisible: false,
                                          ),

                                          selectedDayPredicate: (d) =>
                                              isSameDay(d, selectedDay),

                                          onDaySelected: (day, _) async {
                                            final today = DateTime.now();

                                            final isPast = day.isBefore(
                                              DateTime(
                                                today.year,
                                                today.month,
                                                today.day,
                                              ),
                                            );

                                            if (isPast) return;

                                            if (!mounted) return;

                                            setState(() {
                                              selectedDay = day;
                                              focusedDay = day;
                                            });

                                            await caricaScheduleOperatore();
                                          },

                                          onPageChanged: (day) {
                                            setState(() {
                                              focusedDay = day;
                                            });
                                          },

                                          calendarBuilders: CalendarBuilders(
                                            headerTitleBuilder: (context, day) {
                                              final text = DateFormat(
                                                'MMMM yyyy',
                                                'it_IT',
                                              ).format(day).toUpperCase();

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 26,
                                                ),
                                                child: Center(
                                                  child: premiumSectionTitle(
                                                    text,
                                                  ),
                                                ),
                                              );
                                            },

                                            selectedBuilder: (context, day, focusedDay) {
                                              final today = DateTime.now();

                                              final isPast = day.isBefore(
                                                DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                ),
                                              );

                                              if (isPast) {
                                                return Container(
                                                  margin: EdgeInsets.all(
                                                    isMobile ? 4 : 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.black
                                                        .withOpacity(0.2),
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

                                              final filtered = docs.where((
                                                doc,
                                              ) {
                                                if (doc['startAt'] == null)
                                                  return false;
                                                final d =
                                                    (doc['startAt']
                                                            as Timestamp)
                                                        .toDate();
                                                final sameDay =
                                                    d.year == day.year &&
                                                    d.month == day.month &&
                                                    d.day == day.day;

                                                if (!sameDay) return false;

                                                if (filtro == "Tutti")
                                                  return true;

                                                return doc['operatorId']
                                                        .toString()
                                                        .toLowerCase() ==
                                                    filtro.toLowerCase();
                                              }).toList();

                                              final count = filtered.length;
                                              final totaleSlot = 17;
                                              final isSelected = true;
                                              final dayClosed = _isCalendarDayClosed(day, chiusiDocs);

                                              Color bgColor =
                                                  const Color.fromARGB(
                                                    255,
                                                    35,
                                                    35,
                                                    35,
                                                  );

                                              return GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();

                                                  if (!mounted) return;

                                                  setState(() {
                                                    selectedDay = day;
                                                  });
                                                },
                                                child: AnimatedScale(
                                                  scale: 1.15,
                                                  duration: const Duration(
                                                    milliseconds: 150,
                                                  ),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 250,
                                                    ),
                                                    margin: EdgeInsets.all(
                                                      isDesktop
                                                          ? 10
                                                          : isTablet
                                                          ? 8
                                                          : 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),
                                                      color: bgColor,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: bgColor
                                                              .withOpacity(0.9),
                                                          blurRadius: 20,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Stack(
  children: [
    Center(
      child: Text(
        "${day.day}",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isDesktop
              ? 18
              : isTablet
              ? 16
              : 14,
        ),
      ),
    ),
    _calendarStatusStrip(
      count: count,
      totaleSlot: totaleSlot,
      isClosed: dayClosed,
      isMobile: isMobile,
    ),
  ],
),
                                                  ),
                                                ),
                                              );
                                            },

                                            defaultBuilder: (context, day, focusedDay) {
                                              final filtered = docs.where((
                                                doc,
                                              ) {
                                                if (doc['startAt'] == null)
                                                  return false;
                                                final d =
                                                    (doc['startAt']
                                                            as Timestamp)
                                                        .toDate();

                                                final sameDay =
                                                    d.year == day.year &&
                                                    d.month == day.month &&
                                                    d.day == day.day;

                                                if (!sameDay) return false;

                                                if (filtro == "Tutti")
                                                  return true;

                                                return doc['operatorId']
                                                        .toString()
                                                        .toLowerCase() ==
                                                    filtro.toLowerCase();
                                              }).toList();

                                              final count = filtered.length;
                                              final totaleSlot = 17;
                                              final isSelected = isSameDay(
                                                day,
                                                selectedDay,
                                              );
                                              final domenica = day.weekday == 7;
                                              final dayClosed = _isCalendarDayClosed(day, chiusiDocs);

                                              Color bgColor;
                                              List<BoxShadow> glow = [];

                                             if (domenica) {
  bgColor = Colors.black;
} else if (dayClosed) {
  bgColor = const Color(0xFF171717);
  glow = [
    BoxShadow(
      color: const Color(0xFFD4AF37).withOpacity(0.16),
      blurRadius: 16,
    ),
  ];
} else if (count == 0) {
                                                bgColor = const Color.fromARGB(
                                                  255,
                                                  137,
                                                  151,
                                                  138,
                                                );
                                              } else if (count < totaleSlot) {
                                                bgColor = const Color.fromARGB(
                                                  255,
                                                  37,
                                                  37,
                                                  37,
                                                );
                                                glow = [
                                                  BoxShadow(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      36,
                                                      36,
                                                      36,
                                                    ).withOpacity(0.6),
                                                    blurRadius: 16,
                                                  ),
                                                ];
                                              } else {
                                                bgColor = const Color.fromARGB(
                                                  255,
                                                  23,
                                                  23,
                                                  23,
                                                );
                                                glow = [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFE53935,
                                                    ).withOpacity(0.6),
                                                    blurRadius: 16,
                                                  ),
                                                ];
                                              }

                                              if (isSelected) {
                                                bgColor = const Color(
                                                  0xFF00C853,
                                                ); // 💚 verde neon
                                                glow = [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF00C853,
                                                    ).withOpacity(0.9),
                                                    blurRadius: 20,
                                                  ),
                                                ];
                                              }

                                              return GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();

                                                  if (!mounted) return;

                                                  setState(() {
                                                    selectedDay = day;
                                                  });
                                                },
                                                child: AnimatedScale(
                                                  scale: isSelected
                                                      ? 1.08
                                                      : 0.96,
                                                  duration: Duration(
                                                    milliseconds: 180,
                                                  ),
                                                  curve: Curves.easeOutBack,
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 250,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),

                                                      gradient: isSelected
                                                          ? LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              colors: [
                                                                const Color(
                                                                  0xFF1F1F1F,
                                                                ),
                                                                const Color(
                                                                  0xFF121212,
                                                                ),
                                                              ],
                                                            )
                                                          : LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              colors: [
                                                                const Color(
                                                                  0xFF262626,
                                                                ),
                                                                const Color(
                                                                  0xFF1D1D1D,
                                                                ),
                                                              ],
                                                            ),

                                                      border: Border.all(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF00C853,
                                                              )
                                                            : Colors.white
                                                                  .withOpacity(
                                                                    0.04,
                                                                  ),
                                                        width: isSelected
                                                            ? 1.8
                                                            : 1,
                                                      ),

                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.35,
                                                              ),
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                        ),

                                                        if (isSelected) ...[
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFF00C853,
                                                            ).withOpacity(0.22),

                                                            blurRadius: 18,
                                                            spreadRadius: 2,
                                                          ),

                                                          BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.03,
                                                                ),
                                                            blurRadius: 4,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Center(
                                                          child: Text(
                                                            "${day.day}",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: isTablet
                                                                  ? 18
                                                                  : 14,
                                                            ),
                                                          ),
                                                        ),

                                                      _calendarStatusStrip(
  count: count,
  totaleSlot: totaleSlot,
  isClosed: dayClosed,
  isMobile: isMobile,
),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 25),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: CloseDayButton(
                                          giornataChiusa: giornataChiusa,

                                          onTap: () async {
                                            if (filtro == "Tutti") {
                                              premiumPopup(
                                                context: context,
                                                title: "SELEZIONA OPERATORE",
                                                subtitle:
                                                    "Devi selezionare un operatore.",
                                                icon: Icons
                                                    .person_outline_rounded,
                                                color: const Color(0xFFD4AF37),
                                              );

                                              return;
                                            }

                                            if (!giornataChiusa) {
                                              await ScheduleService.chiudiGiorno(
                                                giorno: selectedDay,
                                                operatore: filtro,
                                              );
                                            } else {
                                              await ScheduleService.riapriGiorno(
                                                giorno: selectedDay,
                                                operatore: filtro,
                                              );
                                            }

                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      SizedBox(height: isMobile ? 18 : isTablet ? 22 : 24),

AppointmentsSection(
                                        child: Column(
                                          children: [
                                            AppointmentsHeader(
                                              selectedDay: selectedDay,
                                              formatDataBella: formatDataBella,
                                            ),

                                            SizedBox(
                                              height: isMobile ? 22 : 30,
                                            ),

                                            AppointmentsList(
                                              children:
                                                  filteredAppointments.isEmpty
                                                  ? [
                                                      AppointmentsEmptyState(
                                                        isMobile: isMobile,
                                                        isTablet: isTablet,
                                                        isDesktop: isDesktop,
                                                      ),
                                                    ]
                                                  : [
                                                      AppointmentsRealtimeList(
                                                        children: filteredAppointments.map((
                                                          d,
                                                        ) {
                                                          final data =
                                                              d.data()
                                                                  as Map<
                                                                    String,
                                                                    dynamic
                                                                  >;

                                                          return AppointmentCard(
                                                            isMobile: isMobile,

                                                            data: data,

                                                            index:
                                                                ordinati
                                                                    .where((
                                                                      doc,
                                                                    ) {
                                                                      if (doc['startAt'] ==
                                                                          null) {
                                                                        return false;
                                                                      }

                                                                      final dd =
                                                                          (doc['startAt']
                                                                                  as Timestamp)
                                                                              .toDate();

                                                                      final sameDay =
                                                                          dd.year ==
                                                                              selectedDay.year &&
                                                                          dd.month ==
                                                                              selectedDay.month &&
                                                                          dd.day ==
                                                                              selectedDay.day;

                                                                      if (!sameDay)
                                                                        return false;

                                                                      if (filtro ==
                                                                          "Tutti") {
                                                                        return true;
                                                                      }

                                                                      return doc['operatorId']
                                                                              .toString()
                                                                              .toLowerCase() ==
                                                                          filtro
                                                                              .toLowerCase();
                                                                    })
                                                                    .toList()
                                                                    .indexOf(
                                                                      d,
                                                                    ) +
                                                                1,

                                                            onTap: () {},

                                                            onDelete: () async {
                                                              await AppointmentsService.deleteAppointment(
                                                                d.id,
                                                              );
                                                            },

                                                            infoChips: Wrap(
  spacing: isMobile ? 8 : 10,
  runSpacing: 8,
  children: [
    PremiumInfoChip(
      icon: Icons.access_time_rounded,
      text: DateFormat('HH:mm').format(
        (data['startAt'] as Timestamp).toDate(),
      ),
    ),

    if (!isMobile)
      PremiumInfoChip(
        icon: Icons.person_outline,
        text: "${data['operatorId']}",
      ),

    PremiumInfoChip(
      icon: Icons.timelapse,
      text: "${data['durata'] ?? 30} min",
    ),
  ],
),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ],
                                            ),
                                          ],
                                        ),
                                      ),

SizedBox(height: isMobile ? 16 : isTablet ? 20 : 22),

WaitlistAdminSection(
  selectedDay: selectedDay,
  selectedOperator: filtro,
  isMobile: isMobile,
),


                                      SizedBox(height: isMobile ? 16 : isTablet ? 20 : 22),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          16,
                                          isMobile ? 10 : 14,
                                          16,
                                          isMobile ? 18 : 24,
                                        ),
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: isDesktop
                                                  ? 520
                                                  : isTablet
                                                  ? 460
                                                  : double.infinity,
                                            ),
                                            child: GestureDetector(
                                              onTapDown: filtro == "Tutti"
                                                  ? null
                                                  : (_) {
                                                      HapticFeedback.selectionClick();
                                                    },
                                              onTap: filtro == "Tutti"
                                                  ? null
                                                  : () async {
                                                      try {
                                                        HapticFeedback.lightImpact();

                                                        final dayId =
                                                            DateFormat(
                                                                  'EEEE',
                                                                  'en_US',
                                                                )
                                                                .format(
                                                                  selectedDay,
                                                                )
                                                                .toLowerCase();

                                                        final doc = await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                              'operator_schedules',
                                                            )
                                                            .doc(
                                                              filtro
                                                                  .toLowerCase(),
                                                            )
                                                            .collection(
                                                              'weekly',
                                                            )
                                                            .doc(dayId)
                                                            .get();

                                                        if (!mounted) return;

                                                        await showDialog(
                                                          context: context,
                                                          barrierColor:
                                                              Colors.black54,
                                                          builder: (_) =>
                                                              ScheduleEditorDialog(
                                                                operatorId: filtro
                                                                    .toLowerCase(),
                                                                dayId: dayId,
                                                                current: doc
                                                                    .data(),
                                                              ),
                                                        );

                                                        await caricaScheduleOperatore();

                                                        if (!mounted) return;

                                                        setState(() {});
                                                      } catch (e) {
                                                        debugPrint(
                                                          e.toString(),
                                                        );

                                                        if (!mounted) return;

                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Errore apertura schedule: $e",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                opacity: filtro == "Tutti"
                                                    ? 0.55
                                                    : 1,
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: isDesktop
                                                        ? 22
                                                        : isTablet
                                                        ? 20
                                                        : 18,
                                                    horizontal: isMobile
                                                        ? 18
                                                        : 24,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          isDesktop ? 30 : 26,
                                                        ),
                                                    gradient: filtro == "Tutti"
                                                        ? LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Colors
                                                                  .grey
                                                                  .shade700
                                                                  .withOpacity(
                                                                    0.55,
                                                                  ),
                                                              Colors
                                                                  .grey
                                                                  .shade900
                                                                  .withOpacity(
                                                                    0.65,
                                                                  ),
                                                            ],
                                                          )
                                                        : const LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Color(0xFF1F1F1F),
                                                              Color(0xFF111111),
                                                              Color(0xFF090909),
                                                            ],
                                                          ),
                                                    border: Border.all(
                                                      color: filtro == "Tutti"
                                                          ? Colors.white
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                          : const Color(
                                                              0xFF00C853,
                                                            ).withOpacity(0.30),
                                                      width: 1.2,
                                                    ),
                                                    boxShadow: filtro == "Tutti"
                                                        ? [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.18,
                                                                  ),
                                                              blurRadius: 14,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    8,
                                                                  ),
                                                            ),
                                                          ]
                                                        : [
                                                            BoxShadow(
                                                              color:
                                                                  const Color(
                                                                    0xFF00C853,
                                                                  ).withOpacity(
                                                                    0.18,
                                                                  ),
                                                              blurRadius: 30,
                                                              spreadRadius: 1,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    12,
                                                                  ),
                                                            ),
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.42,
                                                                  ),
                                                              blurRadius: 22,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    12,
                                                                  ),
                                                            ),
                                                          ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: isDesktop
                                                            ? 48
                                                            : 44,
                                                        height: isDesktop
                                                            ? 48
                                                            : 44,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              filtro == "Tutti"
                                                              ? LinearGradient(
                                                                  colors: [
                                                                    Colors.white
                                                                        .withOpacity(
                                                                          0.08,
                                                                        ),
                                                                    Colors.white
                                                                        .withOpacity(
                                                                          0.03,
                                                                        ),
                                                                  ],
                                                                )
                                                              : LinearGradient(
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
                                                            color:
                                                                filtro ==
                                                                    "Tutti"
                                                                ? Colors.white
                                                                      .withOpacity(
                                                                        0.08,
                                                                      )
                                                                : const Color(
                                                                    0xFF69F0AE,
                                                                  ).withOpacity(
                                                                    0.28,
                                                                  ),
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .auto_awesome_motion_rounded,
                                                          color:
                                                              filtro == "Tutti"
                                                              ? Colors.white54
                                                              : const Color(
                                                                  0xFF69F0AE,
                                                                ),
                                                          size: isDesktop
                                                              ? 22
                                                              : 20,
                                                        ),
                                                      ),

                                                      SizedBox(
                                                        width: isMobile
                                                            ? 12
                                                            : 16,
                                                      ),

                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "AGGIUNGI / RIMUOVI EXTRAORARI",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                letterSpacing:
                                                                    isMobile
                                                                    ? 0.9
                                                                    : 1.4,
                                                                fontSize:
                                                                    isDesktop
                                                                    ? 15
                                                                    : isTablet
                                                                    ? 14
                                                                    : 12.5,
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 4,
                                                            ),

                                                            Text(
                                                              filtro == "Tutti"
                                                                  ? "Seleziona un operatore per continuare"
                                                                  : "Gestisci disponibilità extra per ${filtro.toUpperCase()}",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color:
                                                                    filtro ==
                                                                        "Tutti"
                                                                    ? Colors
                                                                          .white38
                                                                    : const Color(
                                                                        0xFF69F0AE,
                                                                      ).withOpacity(
                                                                        0.72,
                                                                      ),
                                                                fontSize:
                                                                    isMobile
                                                                    ? 10.5
                                                                    : 11.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    0.2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      SizedBox(
                                                        width: isMobile
                                                            ? 10
                                                            : 14,
                                                      ),

                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        color: filtro == "Tutti"
                                                            ? Colors.white30
                                                            : const Color(
                                                                0xFF69F0AE,
                                                              ),
                                                        size: isMobile
                                                            ? 14
                                                            : 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      ScheduleManagementSection(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const ScheduleHeader(),

                                            SizedBox(
                                              height: isMobile ? 22 : 30,
                                            ),

                                            if (filtro == "Tutti")
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  color: Colors.white
                                                      .withOpacity(0.04),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.06),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .person_search_rounded,
                                                      color: Color(0xFF69F0AE),
                                                      size: 36,
                                                    ),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      "SELEZIONA UN OPERATORE",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      "Seleziona un operatore per visualizzare e gestire gli orari disponibili.",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              SingleChildScrollView(
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  runAlignment:
                                                      WrapAlignment.center,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing: isMobile ? 10 : 14,
                                                  runSpacing: isMobile
                                                      ? 10
                                                      : 14,
                                                  children: [
                                                    StreamBuilder<
                                                      QuerySnapshot
                                                    >(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                            'orari_bloccati',
                                                          )
                                                          .snapshots(),
                                                      builder: (context, snapshot) {
                                                        if (!snapshot.hasData)
                                                          return const SizedBox();

                                                        final lista = snapshot
                                                            .data!
                                                            .docs
                                                            .where((doc) {
                                                              final data =
                                                                  (doc['data']
                                                                          as Timestamp)
                                                                      .toDate();

                                                              final stessoGiorno =
                                                                  data.year ==
                                                                      selectedDay
                                                                          .year &&
                                                                  data.month ==
                                                                      selectedDay
                                                                          .month &&
                                                                  data.day ==
                                                                      selectedDay
                                                                          .day;

                                                              if (!stessoGiorno) {
                                                                return false;
                                                              }

                                                              if (filtro ==
                                                                  "Tutti") {
                                                                return true;
                                                              }

                                                              return doc['operatore']
                                                                      .toString()
                                                                      .toLowerCase() ==
                                                                  filtro
                                                                      .toLowerCase();
                                                            })
                                                            .map((doc) {
                                                              return doc['ora']
                                                                  .toString()
                                                                  .trim();
                                                            })
                                                            .toList();

                                                        final orariBloccati =
                                                            lista;

                                                        return Wrap(
                                                          alignment:
                                                              WrapAlignment
                                                                  .center,
                                                          spacing: isMobile
                                                              ? 10
                                                              : 14,
                                                          runSpacing: isMobile
                                                              ? 10
                                                              : 14,
                                                          children: orari.map((
                                                            ora,
                                                          ) {
                                                            final now =
                                                                DateTime.now();

                                                            final slotHour =
                                                                int.parse(
                                                                  ora.split(
                                                                    ":",
                                                                  )[0],
                                                                );

                                                            final slotMinute =
                                                                int.parse(
                                                                  ora.split(
                                                                    ":",
                                                                  )[1],
                                                                );

                                                            final slotDateTime =
                                                                DateTime(
                                                                  selectedDay
                                                                      .year,
                                                                  selectedDay
                                                                      .month,
                                                                  selectedDay
                                                                      .day,
                                                                  slotHour,
                                                                  slotMinute,
                                                                );

                                                            final isToday =
                                                                selectedDay
                                                                        .year ==
                                                                    now.year &&
                                                                selectedDay
                                                                        .month ==
                                                                    now.month &&
                                                                selectedDay
                                                                        .day ==
                                                                    now.day;

                                                            // ❌ NASCONDI ORARI PASSATI
                                                            if (isToday &&
                                                                slotDateTime
                                                                    .isBefore(
                                                                      now,
                                                                    )) {
                                                              return const SizedBox.shrink();
                                                            }

                                                            final isBloccato =
                                                                orariBloccati.any(
                                                                  (e) =>
                                                                      e.trim() ==
                                                                      ora.trim(),
                                                                );

                                                            final occupato =
                                                                slotOccupato(
                                                                  ora,
                                                                  docs,
                                                                );

                                                            if (currentSchedule ==
                                                                    null ||
                                                                currentSchedule!
                                                                        .enabled ==
                                                                    false) {
                                                              return const SizedBox.shrink();
                                                            }

                                                            return ScheduleSlotCard(
                                                              isMobile:
                                                                  isMobile,

                                                              occupato:
                                                                  occupato,

                                                              isBloccato:
                                                                  isBloccato,

                                                              ora: ora,

                                                              onTap: () async {
                                                                if (occupato) {
                                                                  premiumPopup(
                                                                    context:
                                                                        context,
                                                                    title:
                                                                        "ORARIO OCCUPATO",
                                                                    subtitle:
                                                                        "Questo orario ha già un appuntamento.",
                                                                    icon: Icons
                                                                        .lock_clock_rounded,
                                                                    color: const Color(
                                                                      0xFFE53935,
                                                                    ),
                                                                  );

                                                                  return;
                                                                }

                                                                if (filtro ==
                                                                    "Tutti") {
                                                                  premiumPopup(
                                                                    context:
                                                                        context,
                                                                    title:
                                                                        "SELEZIONA OPERATORE",
                                                                    subtitle:
                                                                        "Devi selezionare un operatore prima di bloccare un orario.",
                                                                    icon: Icons
                                                                        .person_outline_rounded,
                                                                    color: const Color(
                                                                      0xFFD4AF37,
                                                                    ),
                                                                  );

                                                                  return;
                                                                }

                                                                if (isBloccato) {
                                                                  await ScheduleService.sbloccaOrario(
                                                                    giorno:
                                                                        selectedDay,
                                                                    operatore:
                                                                        filtro,
                                                                    ora: ora,
                                                                  );

                                                                  premiumPopup(
                                                                    context:
                                                                        context,
                                                                    title:
                                                                        "ORARIO SBLOCCATO",
                                                                    subtitle:
                                                                        "$ora nuovamente disponibile.",
                                                                    icon: Icons
                                                                        .lock_open_rounded,
                                                                    color: const Color(
                                                                      0xFF00C853,
                                                                    ),
                                                                  );
                                                                } else {
                                                                  await ScheduleService.bloccaOrario(
                                                                    giorno:
                                                                        selectedDay,
                                                                    operatore:
                                                                        filtro,
                                                                    ora: ora,
                                                                  );
                                                                }
                                                              },
                                                            );
                                                          }).toList(),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        height:
                                            MediaQuery.of(
                                              context,
                                            ).padding.bottom +
                                            36,
                                      ),

                                      // 👇 LISTA
                                    ],
                                  ),
                                ),
  ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _PremiumAdminInput extends StatelessWidget {
  const _PremiumAdminInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.42), size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF00C853), width: 1.4),
        ),
      ),
    );
  }
}

Widget premiumSectionTitle(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),

    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.045),
      backgroundBlendMode: BlendMode.overlay,

      borderRadius: BorderRadius.circular(22),

      border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: Text(
      text,

      textAlign: TextAlign.center,

      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
        fontSize: 16,
      ),
    ),
  );
}

Widget _infoRow(String titolo, String valore) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titolo, style: const TextStyle(color: Colors.white38)),
        Text(
          valore,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
