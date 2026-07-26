import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:barber_app/mie.prenotazioni_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_background.dart';
import '../auth/login_page.dart';
import 'package:flutter/gestures.dart';
import '../../services/slot_service.dart';
import 'widgets/booking_header.dart';
import 'widgets/booking_time_grid.dart';
import 'widgets/day_selector.dart';
import 'package:barber_app/core/responsive/responsive_utils.dart';
import 'package:barber_app/features/booking/services/booking_service.dart';
import 'package:barber_app/features/booking/services/waitlist_service.dart';
import 'package:barber_app/core/dialogs/premium_loading_dialog.dart';
import 'package:barber_app/core/dialogs/premium_success_dialog.dart';
import 'package:barber_app/core/dialogs/premium_alert_dialog.dart';
import 'package:barber_app/core/constants/app_colors.dart';
import 'package:barber_app/core/constants/app_spacing.dart';
import 'package:barber_app/core/constants/app_animations.dart';
import 'package:barber_app/features/schedule/models/operator_schedule_model.dart';
import 'package:barber_app/services/notification_service.dart';
import 'package:barber_app/features/schedule/services/operator_schedule_service.dart';

class BookingPage extends StatefulWidget {
  final String serviceId;
  final String servizio;
  final int durata;

  const BookingPage({
    super.key,
    required this.serviceId,
    required this.servizio,
    required this.durata,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final ScrollController _scrollController = ScrollController();

  final user = FirebaseAuth.instance.currentUser;

  DateTime selectedDay = DateTime.now();
  String? operatore;
  bool giornoSelezionato = false;
  final nome = TextEditingController();
  String? orarioSelezionato;
  List<Map<String, dynamic>> orariOccupati = [];

  List<String> orariBloccati = [];
  Map<String, dynamic> availabilitySlots = {};
  StreamSubscription? blocchiSub;
  StreamSubscription? appuntamentiSub;
  StreamSubscription? scheduleSub;
  StreamSubscription? availabilitySub;
  int? pressedIndex;

  bool isLoading = false;
  bool loadingOrari = false;
  List<DateTime> giorniChiusi = [];

  bool giaInLista = false;
  DaySchedule? currentSchedule;

  bool loadingSchedule = false;

  Future<void> apriRecensioneGoogle() async {
    final url = Uri.parse("https://g.page/r/TUO-LINK-GOOGLE/review");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smooth,
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(selectedDay.day - 1); // puoi cambiare index
    });
    if (operatore != null) {
      caricaGiorniChiusi();
    }
  }

  void _scrollToIndex(int index) {
    const itemWidth = 72.0;

    final screenWidth = MediaQuery.of(context).size.width;
    if (!_scrollController.hasClients) return;
    final offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      offset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),

      duration: const Duration(milliseconds: 300),

      curve: Curves.easeOut,
    );
  }

  /*Future<void> caricaOrariOccupati() async {

  if (operatore == null) return;

  if (!mounted) return;

  setState(() {
    loadingOrari = true;
  });

  try {

    final appuntamentiSnapshot =
        await FirebaseFirestore.instance
            .collection('appuntamenti')
            .where(
  'operatorId',
  isEqualTo: operatore!.toLowerCase(),
)
            .get();

    final occupati =
    appuntamentiSnapshot.docs.where((doc) {

  final start =
      (doc['startAt'] as Timestamp).toDate();

  return start.year == selectedDay.year &&
      start.month == selectedDay.month &&
      start.day == selectedDay.day;

}).map((doc) {

  final start =
    (doc['startAt'] as Timestamp).toDate();

final end =
    (doc['endAt'] as Timestamp).toDate();

  return {
    "ora":
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",

    "durata":
        end.difference(start).inMinutes,
  };

}).toList();

    if (!mounted) return;

    setState(() {
      orariOccupati = occupati;
      loadingOrari = false;
    });

  } catch (e) {


    print(e);

    if (!mounted) return;

    setState(() {
      loadingOrari = false;
    });
  }
}
*/

  void ascoltaOrariBloccati() {
    blocchiSub?.cancel();

    if (operatore == null) return;

    final key = dateKey(selectedDay);

    blocchiSub = FirebaseFirestore.instance
        .collection('orari_bloccati')
        .where('operatore', isEqualTo: operatore!.toLowerCase())
        .where('dateKey', isEqualTo: key)
        .snapshots()
        .listen(
          (snapshot) {
            final lista = snapshot.docs
                .map((doc) => doc['ora'].toString())
                .toList();

            if (!mounted) return;

            setState(() {
              orariBloccati = lista;
            });
          },
          onError: (e) {
            debugPrint("ERRORE orari_bloccati: $e");
          },
        );
  }

  /*
void ascoltaAppuntamentiRealtime() {

  appuntamentiSub?.cancel();

  if (operatore == null) return;

  appuntamentiSub = FirebaseFirestore.instance
      .collection('appuntamenti')
      .where(
  'operatorId',
  isEqualTo: operatore!.toLowerCase(),
)
      .snapshots()
      .listen((snapshot) {

    final occupati =
    snapshot.docs.where((doc) {

  final start =
      (doc['startAt'] as Timestamp).toDate();

  return start.year == selectedDay.year &&
      start.month == selectedDay.month &&
      start.day == selectedDay.day;

}).map((doc) {

final start =
    (doc['startAt'] as Timestamp).toDate();

final end =
    (doc['endAt'] as Timestamp).toDate();


  return {
    "ora":
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",

    "durata":
        end.difference(start).inMinutes,
  };

}).toList();

    if (!mounted) return;

    setState(() {
      orariOccupati = occupati;
    });
  });
}
*/
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

    final dayId = dayMap[selectedDay.weekday]!;

    scheduleSub = FirebaseFirestore.instance
        .collection('operator_schedules')
        .doc(operatore!.toLowerCase())
        .collection('weekly')
        .doc(dayId)
        .snapshots()
        .listen(
          (doc) {
            if (!doc.exists || doc.data() == null) {
              if (!mounted) return;

              setState(() {
                currentSchedule = null;
              });

              return;
            }

            if (!mounted) return;

            setState(() {
              currentSchedule = DaySchedule.fromMap(doc.data()!);
            });
          },
          onError: (e) {
            debugPrint("ERRORE operator_schedules: $e");
          },
        );
  }

  void ascoltaAvailabilityRealtime() {
    availabilitySub?.cancel();

    if (operatore == null) return;

    final month = selectedDay.month.toString().padLeft(2, '0');

    final day = selectedDay.day.toString().padLeft(2, '0');

    final docId = "${operatore!.toLowerCase()}_${selectedDay.year}-$month-$day";

    availabilitySub = FirebaseFirestore.instance
        .collection('availability_public')
        .doc(docId)
        .snapshots()
        .listen(
          (doc) {
            if (!doc.exists) {
              if (!mounted) return;

              setState(() {
                availabilitySlots = {};
              });

              return;
            }

            final data = doc.data();

            if (data == null) return;

            if (!mounted) return;

            setState(() {
              availabilitySlots = Map<String, dynamic>.from(
                data['slots'] ?? {},
              );
            });
          },
          onError: (e) {
            debugPrint("ERRORE availability_public: $e");
          },
        );
  }

  Future<void> caricaGiorniChiusi() async {
    if (operatore == null) return;

    final chiusureSnapshot = await FirebaseFirestore.instance
        .collection('giorni_chiusi')
        .where('operatore', isEqualTo: operatore!.toLowerCase())
        .get();

    final chiusi = chiusureSnapshot.docs.map((doc) {
      return (doc['data'] as Timestamp).toDate();
    }).toList();
    if (!mounted) return;
    setState(() {
      giorniChiusi = chiusi;
    });
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

    final dayId = dayMap[selectedDay.weekday]!;

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

  String formatData(DateTime d) {
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

  String meseAnnoLabel(DateTime d) {
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

    return "${mesi[d.month - 1]} ${d.year}".toUpperCase();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _slotDateTime(String slot) {
    final parts = slot.split(":");

    return DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool _giornataTerminata(List<String> orariBase) {
    final now = DateTime.now();

    if (!_isSameDay(selectedDay, now)) {
      return false;
    }

    if (orariBase.isEmpty) {
      return false;
    }

    return !orariBase.any((slot) => _slotDateTime(slot).isAfter(now));
  }

  String dateKey(DateTime giorno) {
    return "${giorno.year}-"
        "${giorno.month.toString().padLeft(2, '0')}-"
        "${giorno.day.toString().padLeft(2, '0')}";
  }

  /*final operatori = [
  {
    "id": "francesco",
    "nome": "Francesco",
    "img": "assets/images/francesco.jpeg",
  },

  {
    "id": "antonio",
    "nome": "Antonio",
    "img": "assets/images/antonio.jpeg",
  },
];
*/

  bool isClosed(DateTime d) {
    final now = DateTime.now();

    final oggi = DateTime(now.year, now.month, now.day);
    final giorno = DateTime(d.year, d.month, d.day);

    // ❌ blocca SOLO giorni prima di oggi (non oggi)
    if (giorno.isBefore(oggi)) {
      return true;
    }

    // ❌ domenica chiusa
    if (d.weekday == 7) {
      return true;
    }

    // ❌ giorni chiusi da backend
    return giorniChiusi.any(
      (g) => g.year == d.year && g.month == d.month && g.day == d.day,
    );
  }

  bool slotDisponibile(String slot) {
    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(slot.split(":")[0]),
      int.parse(slot.split(":")[1]),
    );

    final end = start.add(Duration(minutes: widget.durata));

    for (var app in orariOccupati) {
      final oraApp = app['ora'];

      final startApp = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(oraApp.split(":")[0]),
        int.parse(oraApp.split(":")[1]),
      );

      final endApp = startApp.add(
        Duration(minutes: int.tryParse(app['durata'].toString()) ?? 30),
      );

      final overlap = start.isBefore(endApp) && end.isAfter(startApp);

      if (overlap) {
        return false;
      }
    }

    return true;
  }

  void showBookingError({
    required String message,
    IconData icon = Icons.error_outline_rounded,
    Color color = Colors.redAccent,
  }) {
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
                color: color.withOpacity(0.14),
              ),
              child: Icon(icon, color: color, size: 19),
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

  Future<void> salva(String ora) async {
    final horizontalPadding = Responsive.horizontalPadding(context);
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

      return;
    }

    // 🔥 CONTROLLO SLOT DINAMICO

    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(ora.split(":")[0]),
      int.parse(ora.split(":")[1]),
    );

    final end = start.add(Duration(minutes: widget.durata));

    /*
final snapshot = await FirebaseFirestore.instance
    .collection('appuntamenti')
    .where(
  'operatorId',
  isEqualTo: operatore!.toLowerCase(),
)
    .where(
      'startAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(
        DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        ),
      ),
    )
    .where(
      'startAt',
      isLessThan: Timestamp.fromDate(
        DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day + 1,
        ),
      ),
    )
    .get();
if (!mounted) return;
final clash = snapshot.docs.any((doc) {
  final startDoc =
    (doc['startAt'] as Timestamp).toDate();

final endDoc =
    (doc['endAt'] as Timestamp).toDate();



  return start.isBefore(endDoc) && end.isAfter(startDoc);
});

if (clash) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Orario occupato")),
  );

  setState(() {
    isLoading = false;
  });

  return;
  }
  */

    // 👇 QUI PARTE IL TUO CODICE NORMALE
    PremiumLoadingDialog.show(
      context: context,

      title: "CONFERMA PRENOTAZIONE",

      subtitle: "Stiamo riservando il tuo appuntamento.",
    );

    // 👇 1. PRENDI DATI UTENTE
    final userDoc = await FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .get();

    final nome = userDoc.data()?['nome'] ?? "";
    final cognome = userDoc.data()?['cognome'] ?? "";
    final telefono = userDoc.data()?['telefono'] ?? "";

    final nomeFinale = (nome + " " + cognome).trim();

    /*final chiusureSnapshot = await FirebaseFirestore.instance
    .collection('giorni_chiusi')
    .where('operatore', isEqualTo: operatore)
    .get();

bool chiuso = false;

for (var doc in chiusureSnapshot.docs) {
  final data = (doc['data'] as Timestamp).toDate();

  if (data.year == selectedDay.year &&
      data.month == selectedDay.month &&
      data.day == selectedDay.day) {
    chiuso = true;
  }
}

if (chiuso) {

  setState(() {
    isLoading = false;
  });

  showBookingError(
  message: "Questa giornata è chiusa per l'operatore selezionato.",
  icon: Icons.event_busy_rounded,
  color: Colors.redAccent,
);
  return;
}
*/

    final bookingDate = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(ora.split(":")[0]),
      int.parse(ora.split(":")[1]),
    );

    final baseId = DateTime.now().millisecondsSinceEpoch.remainder(2147480000);

    final notification2hId = baseId + 1;
    final notification24hId = baseId + 2;

    try {
      await BookingService.createBookingAtomic(
        operatorId: operatore!.toLowerCase(),
        serviceId: widget.serviceId,
        startAt: bookingDate,
        durata: widget.durata,
        servizio: widget.servizio,
        notification2hId: notification2hId,
        notification24hId: notification24hId,
      );
    } on FirebaseFunctionsException catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = "Non siamo riusciti a completare la prenotazione.";

      if (e.code == "already-exists") {
        message =
            "Questo orario è stato appena prenotato. Scegli un altro slot.";
      } else if (e.code == "permission-denied") {
        message = "Non hai i permessi per completare questa prenotazione.";
      } else if (e.code == "invalid-argument") {
        message = "I dati della prenotazione non sono validi.";
      } else if (e.code == "unauthenticated") {
        message = "Accedi di nuovo per completare la prenotazione.";
      }

      showBookingError(
        message: message,
        icon: Icons.info_outline_rounded,
        color: e.code == "already-exists"
            ? Colors.orangeAccent
            : Colors.redAccent,
      );

      return;
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showBookingError(
        message: "Errore imprevisto. Riprova tra qualche secondo.",
      );

      return;
    }

    if (!mounted) return;
    // 🔔 👇 INCOLLA QUI SOTTO 👇

    ascoltaAvailabilityRealtime();

    if (!mounted) return;

    setState(() {});

    final dataPrenotazione = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(ora.split(":")[0]),
      int.parse(ora.split(":")[1]),
    );

    final twoHoursBefore = dataPrenotazione.subtract(const Duration(hours: 2));
    final oneDayBefore = dataPrenotazione.subtract(const Duration(hours: 24));

    // 🔔 1 MINUTO DOPO
    await NotificationService.scheduleNotification(
      id: baseId + 99,
      title: "GRAZIE!",
      body: "Grazie per aver scelto VITÆ Collective Studio",
      scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
    );

    // 🔔 2 ORE PRIMA
    if (twoHoursBefore.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: notification2hId,
        title: "Promemoria appuntamento",
        body: "Hai un appuntamento tra 2 ore.",
        scheduledTime: twoHoursBefore,
      );
    }

    //24 ORE PRIMA
    if (oneDayBefore.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: notification24hId,
        title: "Promemoria appuntamento",
        body: "Hai un appuntamento domani.",
        scheduledTime: oneDayBefore,
      );
    }

    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    HapticFeedback.lightImpact();

    await PremiumSuccessDialog.show(
      context: context,

      title: "Prenotazione confermata",

      subtitle: "${widget.servizio}\n\n${formatData(selectedDay)} • $ora",
    );

    if (!mounted) return;

    if (!mounted) return;

    setState(() {
      orarioSelezionato = null;
      isLoading = false;
    });
  }

  Widget slot(String o) {
    final selezionato = o == orarioSelezionato;

    return GestureDetector(
      onTap: () {
        setState(() {
          orarioSelezionato = o;
        });
      },
      child: AnimatedScale(
        scale: selezionato ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: selezionato ? Colors.green : Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
            boxShadow: selezionato
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Text(
            o,
            style: TextStyle(
              color: selezionato ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool meseSuccessivoSbloccato() {
    final now = DateTime.now();

    final ultimoGiorno = DateTime(now.year, now.month + 1, 0);

    final sblocco = DateTime(
      ultimoGiorno.year,
      ultimoGiorno.month,
      ultimoGiorno.day,
      13,
    );

    return now.isAfter(sblocco);
  }

  List<DateTime> generaGiorni() {
    final now = DateTime.now();

    final firstDay = DateTime(now.year, now.month, now.day);
    final lastDay = meseSuccessivoSbloccato()
        ? DateTime(now.year, now.month + 2, 0)
        : DateTime(now.year, now.month + 1, 0);

    List<DateTime> giorni = [];

    for (int i = 0; i <= lastDay.difference(firstDay).inDays; i++) {
      giorni.add(firstDay.add(Duration(days: i)));
    }

    return giorni;
  }



  Widget _bookingSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 0),
      padding: EdgeInsets.all(
        isDesktop
            ? 26
            : isTablet
            ? 24
            : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isDesktop ? 34 : 30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF101010)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.48),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(color: Colors.white.withOpacity(0.025), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 18 : 15,
              vertical: isDesktop ? 8 : 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.045),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isDesktop ? 12 : 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 18 : 15),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop
                  ? 28
                  : isTablet
                  ? 24
                  : 21,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _sectionDescription(title),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: isMobile ? 12.5 : 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: isDesktop ? 22 : 18),

          Container(
            width: isDesktop ? 86 : 68,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.75),
                  Colors.white.withOpacity(0.08),
                ],
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 26 : 22),

          child,
        ],
      ),
    );
  }

  String _sectionDescription(String title) {
    switch (title.toLowerCase()) {
      case "data":
        return "Consulta i giorni disponibili e scegli quello più comodo.";
      case "professionista":
        return "Seleziona il barber che preferisci per il tuo servizio.";
      case "orario":
        return "Visualizza gli slot liberi e completa la prenotazione.";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final orari = currentSchedule == null
        ? <String>[]
        : SlotService.generateSlotsFromSchedule(
            start: currentSchedule!.start,
            end: currentSchedule!.end,
            pauseStart: currentSchedule!.pauseStart,
            pauseEnd: currentSchedule!.pauseEnd,
            durata: 10,
          );
    final now = DateTime.now();
    final horizontalPadding = Responsive.horizontalPadding(context);

    final maxWidth = Responsive.maxContentWidth(context);

    final isTablet = Responsive.isTablet(context);

    final isDesktop = Responsive.isDesktop(context);
    final giorni = generaGiorni();

    bool availabilityCompatibile(String slot) {
      for (int offset = 0; offset < widget.durata; offset += 10) {
        final slotDate = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          int.parse(slot.split(":")[0]),
          int.parse(slot.split(":")[1]),
        ).add(Duration(minutes: offset));

        final slotKey =
            "${slotDate.hour.toString().padLeft(2, '0')}:${slotDate.minute.toString().padLeft(2, '0')}";

        if (availabilitySlots[slotKey] == false) {
          return false;
        }
      }

      return true;
    }

    final orariFiltrati = orari.where((slot) {
      // ❌ slot bloccato admin
      if (orariBloccati.contains(slot)) {
        return false;
      }

      if (!availabilityCompatibile(slot)) {
        return false;
      }

      //if (!slotDisponibile(slot)) {
      //  return false;
      // }

      // ❌ orari passati oggi
      final now = DateTime.now();

      final slotTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(slot.split(":")[0]),
        int.parse(slot.split(":")[1]),
      );

      final isToday =
          selectedDay.year == now.year &&
          selectedDay.month == now.month &&
          selectedDay.day == now.day;

      if (isToday && slotTime.isBefore(now)) {
        return false;
      }

      return true;
    }).toList()..sort();

    final giornataTerminata = _giornataTerminata(orari);

    final canConfirm =
        operatore != null && orarioSelezionato != null && !isLoading;
    final hasMorning = orariFiltrati.any((o) => o.compareTo("13:00") < 0);

    final hasAfternoon = orariFiltrati.any((o) => o.compareTo("13:00") >= 0);

    final morningSlots = orariFiltrati
        .where((o) => o.compareTo("13:00") < 0)
        .toList();

    final afternoonSlots = orariFiltrati
        .where((o) => o.compareTo("13:00") >= 0)
        .toList();
    return FadeTransition(
      opacity: _animation,
      child: AppBackground(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,

            backgroundColor: Colors.black.withOpacity(0.78),

            surfaceTintColor: Colors.transparent,

            elevation: 0,

            scrolledUnderElevation: 0,

            toolbarHeight: isDesktop
                ? 96
                : isTablet
                ? 86
                : 76,

            centerTitle: true,

            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

                child: Container(color: Colors.black.withOpacity(0.30)),
              ),
            ),

            leadingWidth: isDesktop ? 90 : 74,

            leading: Padding(
              padding: EdgeInsets.only(left: horizontalPadding),

              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),

                    width: isDesktop ? 56 : 48,

                    height: isDesktop ? 56 : 48,

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,

                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(color: Colors.white.withOpacity(0.08)),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),

                          blurRadius: 18,

                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,

                      color: Colors.white,

                      size: isDesktop ? 20 : 18,
                    ),
                  ),
                ),
              ),
            ),

            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 560 : 320),

                  child: Text(
                    widget.servizio,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: isDesktop
                          ? 28
                          : isTablet
                          ? 23
                          : 19,

                      fontWeight: FontWeight.w800,

                      letterSpacing: -0.4,

                      height: 1,
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 10 : 7),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 13,

                    vertical: isDesktop ? 6 : 4,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),

                    borderRadius: BorderRadius.circular(40),

                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.20),
                    ),
                  ),

                  child: Text(
                    "${widget.durata} min",

                    style: TextStyle(
                      color: const Color(0xFF69F0AE),

                      fontSize: isDesktop ? 13 : 11,

                      fontWeight: FontWeight.w700,

                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
  children: [
    const SizedBox(height: 22),


    const SizedBox(height: 10),

    _bookingSection(
      icon: Icons.calendar_month_rounded,
                      title: "Data",
                      subtitle: "Scegli il giorno dell'appuntamento.",
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.045),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),

                        // QUI dentro incolli SOLO il contenuto del vecchio Container,
                        // cioè da child: Center(...) in poi
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.13),
                                    Colors.white.withOpacity(0.045),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.035),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.82),
                                    ),
                                  ),

                                  const SizedBox(width: 9),

                                  Text(
                                    meseAnnoLabel(selectedDay),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.92),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.4,
                                    ),
                                  ),

                                  const SizedBox(width: 9),

                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.82),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Center(
                              child: ShaderMask(
                                shaderCallback: (Rect rect) {
                                  return LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black,
                                      Colors.black,
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.1, 0.9, 1.0],
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.dstIn,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 95,
                                  child: ScrollConfiguration(
                                    behavior: const ScrollBehavior().copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                      },
                                    ),
                                    child: DaySelector(
                                      giorni: giorni,
                                      selectedDay: selectedDay,
                                      controller: _scrollController,
                                      pressedIndex: pressedIndex,
                                      setPressed: (i) {
                                        setState(() {
                                          pressedIndex = i;
                                        });
                                      },
                                      isClosed: isClosed,
                                      onSelect: (day, index) async {
                                        setState(() {
                                          selectedDay = day;
                                          giornoSelezionato = true;
                                          giaInLista = false;
                                          orarioSelezionato = null;
                                          orariOccupati = [];
                                          orariBloccati = [];
                                        });

                                        _scrollToIndex(index);

                                        if (operatore != null) {
                                          ascoltaScheduleRealtime();
                                          ascoltaAvailabilityRealtime();
                                        }

                                        ascoltaOrariBloccati();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _bookingSection(
                      icon: Icons.content_cut_rounded,
                      title: "Professionista",
                      subtitle: "Seleziona chi si occuperà del servizio.",
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('operators')
                            .where('active', isEqualTo: true)
                            .orderBy('publicOrder')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              snapshot.error.toString(),
                              style: const TextStyle(color: Colors.red),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 90,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final operatorDocs = snapshot.data!.docs;

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final operatorsCount = operatorDocs.length;

                              if (operatorsCount == 0) {
                                return const SizedBox.shrink();
                              }

                              final availableWidth =
                                  constraints.maxWidth.isFinite
                                  ? constraints.maxWidth
                                        .clamp(0.0, 520.0)
                                        .toDouble()
                                  : 520.0;
                              final maxAvatarSize = isDesktop
                                  ? 96.0
                                  : isTablet
                                  ? 78.0
                                  : 58.0;
                              final operatorGap =
                                  ((availableWidth / operatorsCount) * 0.08)
                                      .clamp(4.0, isDesktop ? 20.0 : 10.0)
                                      .toDouble();
                              final cardWidth =
                                  (availableWidth -
                                      (operatorGap * (operatorsCount - 1))) /
                                  operatorsCount;
                              final horizontalPadding = (cardWidth * 0.08)
                                  .clamp(3.0, isDesktop ? 12.0 : 8.0)
                                  .toDouble();
                              final verticalPadding = (cardWidth * 0.12)
                                  .clamp(8.0, isDesktop ? 18.0 : 14.0)
                                  .toDouble();
                              final avatarSize =
                                  (cardWidth - (horizontalPadding * 2) - 4)
                                      .clamp(32.0, maxAvatarSize)
                                      .toDouble();
                              final avatarFontSize = (avatarSize * 0.42)
                                  .clamp(14.0, 24.0)
                                  .toDouble();
                              final avatarNameGap = (avatarSize * 0.17)
                                  .clamp(5.0, 10.0)
                                  .toDouble();
                              final operatorNameFontSize = (cardWidth * 0.16)
                                  .clamp(10.0, isDesktop ? 15.0 : 13.0)
                                  .toDouble();

                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 520,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(operatorDocs.length, (
                                      index,
                                    ) {
                                      final doc = operatorDocs[index];
                                      final op =
                                          doc.data() as Map<String, dynamic>;

                                      final operatorId = doc.id;
                                      final nomeOperatore =
                                          op['displayName']?.toString() ??
                                          operatorId;

                                      final imageUrl =
                                          op['imageUrl']?.toString() ?? "";

                                      final sel = operatore == operatorId;

                                      return Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                index == operatorDocs.length - 1
                                                ? 0
                                                : operatorGap,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 150,
                                            ),
                                            curve: AppAnimations.smooth,
                                            constraints: const BoxConstraints(
                                              minHeight: 128,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              color: sel
                                                  ? const Color(0xFF232323)
                                                  : const Color(0xFF1A1A1A),
                                              border: Border.all(
                                                color: sel
                                                    ? AppColors.primary
                                                    : Colors.white.withOpacity(
                                                        0.04,
                                                      ),
                                                width: sel ? 2 : 1,
                                              ),
                                              boxShadow: sel
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.primary
                                                            .withOpacity(0.22),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.35),
                                                        blurRadius: 14,
                                                        offset: const Offset(
                                                          0,
                                                          8,
                                                        ),
                                                      ),
                                                    ]
                                                  : [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.20),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          5,
                                                        ),
                                                      ),
                                                    ],
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              onTap: () async {
                                                HapticFeedback.lightImpact();

                                                setState(() {
                                                  operatore = operatorId;
                                                  orarioSelezionato = null;
                                                  orariOccupati = [];
                                                  orariBloccati = [];
                                                  giaInLista = false;
                                                });

                                                ascoltaScheduleRealtime();
                                                ascoltaAvailabilityRealtime();

                                                await caricaGiorniChiusi();

                                                if (!mounted) return;

                                                ascoltaOrariBloccati();
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: verticalPadding,
                                                  horizontal: horizontalPadding,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: avatarSize,
                                                      height: avatarSize,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: sel
                                                              ? Colors.white
                                                              : Colors.white24,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child:
                                                          imageUrl.startsWith(
                                                            'http',
                                                          )
                                                          ? Image.network(
                                                              imageUrl,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) {
                                                                return Center(
                                                                  child: Text(
                                                                    nomeOperatore
                                                                            .isNotEmpty
                                                                        ? nomeOperatore[0]
                                                                              .toUpperCase()
                                                                        : "?",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      fontSize:
                                                                          avatarFontSize,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : imageUrl.isNotEmpty
                                                          ? Image.asset(
                                                              imageUrl,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Center(
                                                              child: Text(
                                                                nomeOperatore
                                                                        .isNotEmpty
                                                                    ? nomeOperatore[0]
                                                                          .toUpperCase()
                                                                    : "?",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize:
                                                                      avatarFontSize,
                                                                ),
                                                              ),
                                                            ),
                                                    ),

                                                    SizedBox(
                                                      height: avatarNameGap,
                                                    ),

                                                    Text(
                                                      nomeOperatore,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize:
                                                            operatorNameFontSize,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    _bookingSection(
                      icon: Icons.schedule_rounded,
                      title: "Orario",
                      subtitle: "Scegli la fascia oraria disponibile.",
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.045),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),

                        child: operatore == null || !giornoSelezionato
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.05),
                                          border: Border.all(
                                            color: Colors.white10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.schedule,
                                          color: Colors.white54,
                                          size: 26,
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      Text(
                                        operatore == null
                                            ? "Seleziona il giorno e il professionista per consultare gli orari disponibili."
                                            : "Seleziona un giorno dal calendario per visualizzare gli orari disponibili.",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : isClosed(selectedDay)
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.block,
                                      color: Colors.redAccent,
                                      size: 40,
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      "Giornata chiusa",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 2),

                                    Text(
                                      "per questo operatore",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : orariFiltrati.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: giornataTerminata
                                              ? const Color(
                                                  0xFFFFD54F,
                                                ).withOpacity(0.10)
                                              : Colors.redAccent.withOpacity(
                                                  0.10,
                                                ),
                                          border: Border.all(
                                            color: giornataTerminata
                                                ? const Color(
                                                    0xFFFFD54F,
                                                  ).withOpacity(0.28)
                                                : Colors.redAccent.withOpacity(
                                                    0.25,
                                                  ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: giornataTerminata
                                                  ? const Color(
                                                      0xFFFFD54F,
                                                    ).withOpacity(0.10)
                                                  : Colors.redAccent
                                                        .withOpacity(0.08),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          giornataTerminata
                                              ? Icons.schedule_rounded
                                              : Icons.event_busy_rounded,
                                          color: giornataTerminata
                                              ? const Color(0xFFFFD54F)
                                              : Colors.redAccent,
                                          size: 30,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        giornataTerminata
                                            ? "GIORNATA TERMINATA"
                                            : "OPERATORE AL COMPLETO",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        giornataTerminata
                                            ? "Gli orari disponibili per oggi sono terminati. Scegli un altro giorno."
                                            : "Non ci sono più slot disponibili per questo operatore.",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      if (!giornataTerminata) ...[
                                        SizedBox(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.012,
                                        ),

                                        SizedBox(
                                          width: double.infinity,

                                          child: AnimatedOpacity(
                                            duration: AppAnimations.normal,
                                            opacity: giaInLista ? 0.6 : 1,

                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                elevation: 0,

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 18,
                                                    ),

                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),

                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                ),
                                              ),

                                              onPressed: giaInLista
                                                  ? null
                                                  : () async {
                                                      final user = FirebaseAuth
                                                          .instance
                                                          .currentUser;

                                                      if (user == null) return;

                                                      // 🔥 CONTROLLO SE GIÀ PRESENTE
                                                      final esiste =
                                                          await WaitlistService.alreadyInWaitlist(
                                                            userId: user.uid,
                                                            giorno: selectedDay,
                                                            operatore:
                                                                operatore,
                                                            servizio:
                                                                widget.servizio,
                                                          );

                                                      // ❌ GIÀ IN LISTA
                                                      if (esiste) {
                                                        setState(() {
                                                          giaInLista = true;
                                                        });

                                                        PremiumAlertDialog.show(
                                                          context: context,

                                                          title:
                                                              "Sei già in lista d'attesa.",

                                                          subtitle:
                                                              "Hai già richiesto uno slot per questa giornata.",

                                                          icon: Icons
                                                              .info_outline,
                                                        );

                                                        return;
                                                      }

                                                      final userDoc =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                'utenti',
                                                              )
                                                              .doc(user.uid)
                                                              .get();

                                                      // ✅ SALVA
                                                      await WaitlistService.addToWaitlist(
                                                        userId: user.uid,
                                                        operatore: operatore,
                                                        servizio:
                                                            widget.servizio,
                                                        giorno: selectedDay,
                                                        fcmToken: userDoc
                                                            .data()?['fcmToken'],
                                                      );

                                                      setState(() {
                                                        giaInLista = true;
                                                      });

                                                      // ✅ POPUP PREMIUM
                                                      PremiumSuccessDialog.show(
                                                        context: context,

                                                        title:
                                                            "Inserito in lista d'attesa ✨",

                                                        subtitle:
                                                            "Riceverai una notifica non appena sarà disponibile uno slot.",
                                                      );
                                                    },

                                              child: Text(
                                                giaInLista
                                                    ? "GIÀ IN LISTA"
                                                    : "ENTRA IN LISTA D'ATTESA",

                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.2,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🌅 MATTINA
                                  if (hasMorning)
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 6,
                                        bottom: 14,
                                      ),
                                      child: Text(
                                        "MATTINA",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                  if (morningSlots.isNotEmpty)
                                    BookingTimeGrid(
                                      orari: morningSlots,

                                      selected: orarioSelezionato,

                                      onSelect: (ora) {
                                        setState(() {
                                          orarioSelezionato = ora;
                                        });
                                      },
                                    ),

                                  SizedBox(
                                    height: morningSlots.length <= 2
                                        ? 10
                                        : morningSlots.length <= 4
                                        ? 18
                                        : 28,
                                  ),
                                  // 🌙 POMERIGGIO
                                  if (hasAfternoon)
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 6,
                                        bottom: 10,
                                        top: 2,
                                      ),
                                      child: Text(
                                        "POMERIGGIO",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                  if (afternoonSlots.isNotEmpty)
                                    BookingTimeGrid(
                                      orari: afternoonSlots,

                                      selected: orarioSelezionato,

                                      onSelect: (ora) {
                                        setState(() {
                                          orarioSelezionato = ora;
                                        });
                                      },
                                    ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(
                      height: isDesktop
                          ? 120
                          : isTablet
                          ? 100
                          : 85,
                    ),
                  ],
                ),
              ),
            ),
          ),

          bottomNavigationBar: SafeArea(
            top: false,

            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                isDesktop ? 28 : 20,
              ),

              child: SizedBox(
                width: double.infinity,
                height: isDesktop
                    ? 66
                    : isTablet
                    ? 62
                    : 56,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canConfirm
                        ? AppColors.primary
                        : Colors.grey.shade800,

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 22 : 18),
                    ),
                  ),

                  onPressed: canConfirm && !loadingOrari
                      ? () async {
                          HapticFeedback.mediumImpact();
                          await salva(orarioSelezionato!);
                        }
                      : null,

                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,

                          child: Text(
                            "CONFERMA PRENOTAZIONE",
                            style: TextStyle(
                              fontSize: isDesktop
                                  ? 15
                                  : isTablet
                                  ? 14
                                  : 13,

                              fontWeight: FontWeight.w700,

                              letterSpacing: isDesktop ? 1.2 : 0.8,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    blocchiSub?.cancel();
    //appuntamentiSub?.cancel();
    scheduleSub?.cancel();
    availabilitySub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    nome.dispose();
    super.dispose();
  }
}
