import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../clienti_page.dart';
import '../../walkin_page.dart';
import '../../core/responsive.dart';
import 'utils/constants.dart';
import 'widgets/premium_popup.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> logoutCompleto() async {
  await FirebaseAuth.instance.signOut();

  final googleSignIn = GoogleSignIn();
  await googleSignIn.signOut();

  await FacebookAuth.instance.logOut();
}

class BarberPanelPage extends StatefulWidget {
  const BarberPanelPage({super.key});

  @override
  State<BarberPanelPage> createState() => _BarberPanelPageState();
}

class _BarberPanelPageState extends State<BarberPanelPage> {

  DateTime selectedDay = DateTime.now();
  String filtro = "Tutti";

  String? orarioSelezionato;

  List<String> orariBloccati = [];

bool slotOccupato(
  String ora,
  List<QueryDocumentSnapshot> docs,
) {

  final start = DateTime(
    selectedDay.year,
    selectedDay.month,
    selectedDay.day,
    int.parse(ora.split(":")[0]),
    int.parse(ora.split(":")[1]),
  );

  final end = start.add(const Duration(minutes: 30));

  for (var doc in docs) {

    final data = doc.data() as Map<String, dynamic>;

    if (filtro != "Tutti" &&
        data['operatore'] != filtro) {
      continue;
    }

    final d = (data['data'] as Timestamp).toDate();

    final stessoGiorno =
        d.year == selectedDay.year &&
        d.month == selectedDay.month &&
        d.day == selectedDay.day;

    if (!stessoGiorno) continue;

    final oraDoc = data['ora'];

    final startDoc = DateTime(
      d.year,
      d.month,
      d.day,
      int.parse(oraDoc.split(":")[0]),
      int.parse(oraDoc.split(":")[1]),
    );

    final durata = data['durata'] ?? 30;

    final endDoc = startDoc.add(
      Duration(minutes: durata),
    );

    final overlap =
        start.isBefore(endDoc) &&
        end.isAfter(startDoc);

    if (overlap) return true;
  }

  return false;
}

String getKey(DateTime giorno, String operatore) {
  return "${giorno.year}-${giorno.month}-${giorno.day}-$operatore";
}

  Future<void> chiudiGiorno(DateTime giorno, String operatore) async {
  await FirebaseFirestore.instance.collection('giorni_chiusi').add({
    "data": Timestamp.fromDate(giorno),
    "operatore": operatore,
  });
}

bool initialized = false;
int lastCount = 0;

String formatDataBella(DateTime d) {
  const giorni = [
    "Lunedì","Martedì","Mercoledì",
    "Giovedì","Venerdì","Sabato","Domenica"
  ];

  const mesi = [
    "Gennaio","Febbraio","Marzo","Aprile",
    "Maggio","Giugno","Luglio","Agosto",
    "Settembre","Ottobre","Novembre","Dicembre"
  ];

  return "${giorni[d.weekday - 1]} ${d.day} ${mesi[d.month - 1]}";
}

Future<void> bloccaOrario(DateTime giorno, String operatore, String ora) async {
  await FirebaseFirestore.instance.collection('orari_bloccati').add({
    "data": Timestamp.fromDate(giorno),
    "operatore": operatore,
    "ora": ora,
  });

  premiumPopup(
    context: context,
  title: "ORARIO BLOCCATO",
  subtitle: "$ora bloccato per $filtro.",
  icon: Icons.lock_rounded,
  color: Colors.redAccent,
);
}

Widget _premiumAction({
  required IconData icon,
  String? label,
  required VoidCallback onTap,
  Color? color,
}) {

final isMobile =
    MediaQuery.of(context).size.width < 700;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
  horizontal: isMobile ? 10 : 14,
  vertical: isMobile ? 10 : 12,
),
        decoration: BoxDecoration(

  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.07),
      Colors.white.withOpacity(0.03),
    ],
  ),

  borderRadius: BorderRadius.circular(18),

  border: Border.all(
    color: Colors.white.withOpacity(0.06),
  ),

  boxShadow: [

    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ],
),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.white),
            if (label != null && label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white)),
            ]
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
final isMobile = width < 700;
final isTablet = width > 700;

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
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
  Color(0xFF1A1A1A),
  Color(0xFF252525),
  Color(0xFF2F2F2F),
],
        ),
      ),
    ),

    // ✨ GLOW ALTO
    Positioned(
      top: -120,
      left: -80,

      child: Container(
        width: 260,
        height: 260,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00C853)
              .withOpacity(0.08),
        ),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 120,
            sigmaY: 120,
          ),

          child: const SizedBox(),
        ),
      ),
    ),

    // 🔥 GLOW BASSO
    Positioned(
      bottom: -140,
      right: -100,

      child: Container(
        width: 320,
        height: 320,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent
              .withOpacity(0.06),
        ),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 140,
            sigmaY: 140,
          ),

          child: const SizedBox(),
        ),
      ),
    ),

    // 📱 CONTENUTO
    SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
          appBar: PreferredSize(
  preferredSize: Size.fromHeight(
  isMobile ? 128 : 142,
),

  child: ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

      child: Container(
        margin: EdgeInsets.fromLTRB(
  isMobile ? 12 : 20,
  isMobile ? 8 : 12,
  isMobile ? 12 : 20,
  0,
),
        padding: EdgeInsets.only(
  left: isMobile ? 14 : 24,
  right: isMobile ? 14 : 24,
  top: isMobile ? 8 : 16,
  bottom: isMobile ? 8 : 12,
),

        decoration: BoxDecoration(

  color: Colors.white.withOpacity(0.08),

  borderRadius: BorderRadius.circular(
    isMobile ? 28 : 34,
  ),

  border: Border.all(
    color: Colors.white.withOpacity(0.10),
    width: 1,
  ),

  boxShadow: [

    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),

    BoxShadow(
      color: Colors.white.withOpacity(0.03),
      blurRadius: 4,
      spreadRadius: 1,
    ),
  ],
),

        child: SafeArea(
          child: LayoutBuilder(
  builder: (context, constraints) {

  final isMobile = constraints.maxWidth < 700;

  return Row(
    children: [

      Expanded(
        child: Row(
          children: [

            Container(
              width: isMobile ? 54 : 72,
              height: isMobile ? 54 : 72,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1C1C1C),
    Color(0xFF111111),
  ],
),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: Image.asset(
                  "assets/images/logo.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 14),

            if (!isMobile)
  Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),

              decoration: BoxDecoration(

                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00C853)
                        .withOpacity(0.18),

                    const Color(0xFF00E676)
                        .withOpacity(0.08),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(30),

                border: Border.all(
                  color: const Color(0xFF00E676)
                      .withOpacity(0.18),
                ),
              ),

              child: const Text(
                "BARBER ADMIN",

                style: TextStyle(
                  color: Color(0xFF69F0AE),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 8,
              height: 8,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C853),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853)
                        .withOpacity(0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          "Dashboard Operativa",

          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: Colors.white,

            fontSize:
                isTablet ? 24 : 21,

            fontWeight: FontWeight.w800,

            letterSpacing: 0.2,

            height: 1,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [

            Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: Colors.white.withOpacity(0.45),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                formatDataBella(selectedDay),

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),

                  fontSize: 12,

                  fontWeight: FontWeight.w500,

                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
          ],
        ),
      ),

      const SizedBox(width: 10),

      Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          _premiumAction(
            icon: Icons.people_alt_outlined,
            label: isMobile ? "" : "Clienti",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ClientiPage(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          _premiumAction(
            icon: Icons.flash_on_rounded,
            label: isMobile ? "" : "Walk-In",
            color: const Color(0xFFD4AF37),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalkInPage(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          _premiumAction(
            icon: Icons.logout_rounded,
            label: isMobile ? "" : "Logout",
            color: Colors.redAccent,
            onTap: () async {
              await logoutCompleto();
            },
          ),
        ],
      ),
    ],
  );
},
          ),
        ),
      ),
    ),
  ),
),
      body: SingleChildScrollView(
  child: Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: Responsive.maxContentWidth(context),
    ),

    child: Column(
        children: [

SizedBox(height: MediaQuery.of(context).size.height * 0.03),

          // 👇 FILTRO OPERATORI (rimane sopra)
          SizedBox(
            height: isMobile ? 138 : 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: operatori.length,
              itemBuilder: (context, index) {
                final op = operatori[index];
                final selezionato = filtro == op["nome"]!;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      filtro = op["nome"]!;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(
  horizontal: isMobile ? 12 : 16,
  vertical: isMobile ? 14 : 18,
),
                    width: isMobile
    ? 118
    : isTablet
        ? 170
        : 150,
                    decoration: BoxDecoration(
  gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,

  colors: selezionato
      ? [
          const Color(0xFF1F1F1F),
          const Color(0xFF111111),
        ]
      : [
          const Color(0xFF1A1A1A),
          const Color(0xFF101010),
        ],
),

borderRadius: BorderRadius.circular(30),

border: Border.all(
  color: selezionato
      ? const Color(0xFF00C853)
          .withOpacity(0.25)
      : Colors.white.withOpacity(0.04),

  width: 1,
),

boxShadow: [

  BoxShadow(
    color: Colors.black.withOpacity(0.40),
    blurRadius: 24,
    offset: const Offset(0, 10),
  ),

  if (selezionato)
    BoxShadow(
      color: const Color(0xFF00C853)
          .withOpacity(0.10),

      blurRadius: 20,
    ),
],
),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
  padding: const EdgeInsets.all(3),

  decoration: BoxDecoration(
    shape: BoxShape.circle,

    border: Border.all(
      color: selezionato
          ? const Color(0xFF00C853)
          : Colors.white.withOpacity(0.08),
    ),

    boxShadow: [

      if (selezionato)
        BoxShadow(
          color: const Color(0xFF00C853)
              .withOpacity(0.18),
          blurRadius: 16,
        ),
    ],
  ),

  child: CircleAvatar(
    radius: isMobile ? 26 : 34,

    backgroundColor: Colors.white,

    backgroundImage: op["img"] != ""
        ? AssetImage(op["img"]!)
        : null,
  ),
),
                        SizedBox(
  height: isMobile ? 10 : 14,
),
                        Text(
  op["nome"]!,
  style: TextStyle(
    fontSize: isMobile ? 12 : 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: selezionato
    ? Colors.white
    : Colors.white60,
  ),
),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),


const SizedBox(height: 40),

          // 👇 STREAM BUILDER (QUI METTIAMO CALENDARIO)
          StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('giorni_chiusi')
        .snapshots(),
    builder: (context, snapshotChiusi) {

      if (!snapshotChiusi.hasData) return const SizedBox();

      final chiusiDocs = snapshotChiusi.data!.docs;

      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('appuntamenti')
            .snapshots(),
        builder: (context, snapshot) {

                if (!snapshot.hasData) return const SizedBox();

                final docs = snapshot.data!.docs;
                


                final giornataChiusa = chiusiDocs.any((doc) {
  final d = (doc['data'] as Timestamp).toDate();

  final stessoGiorno =
      d.year == selectedDay.year &&
      d.month == selectedDay.month &&
      d.day == selectedDay.day;

  final stessoOperatore = doc['operatore'] == filtro;

  return stessoGiorno && stessoOperatore;
});
                final ordinati = docs.toList()
  ..sort((a, b) {

    
    final dataA = (a['data'] as Timestamp).toDate();
    final dataB = (b['data'] as Timestamp).toDate();

    final oraA = a['ora'];
    final oraB = b['ora'];

    final dateTimeA = DateTime(
      dataA.year,
      dataA.month,
      dataA.day,
      int.parse(oraA.split(":")[0]),
      int.parse(oraA.split(":")[1]),
    );

    final dateTimeB = DateTime(
      dataB.year,
      dataB.month,
      dataB.day,
      int.parse(oraB.split(":")[0]),
      int.parse(oraB.split(":")[1]),
    );

    return dateTimeA.compareTo(dateTimeB);
  });

                // 🔔 NOTIFICA
                if (initialized && docs.length > lastCount) {
  final newDoc = docs.last.data();

  final dataPren = (newDoc['data'] as Timestamp).toDate();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
  width: 58,
  height: 58,

  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF111111),
      ],
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),

  child: const Icon(
    Icons.notifications_none_rounded,
    color: Colors.white,
    size: 28,
  ),
),

              const SizedBox(height: 10),

              const Text(
  "NUOVA PRENOTAZIONE",

  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    letterSpacing: 2.2,
  ),
),

              const SizedBox(height: 15),

              Text(
                newDoc['nome'] ?? "Cliente",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                formatDataBella(dataPren),
                style: TextStyle(
  color: Colors.white.withOpacity(0.65),
  fontWeight: FontWeight.w500,
  letterSpacing: 0.4,
),
              ),

              const SizedBox(height: 5),

              Text(
                "${newDoc['ora']} • ${newDoc['operatore']}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 5),

              Text(
                newDoc['servizio'],
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              GestureDetector(
  onTap: () {
    Navigator.pop(context);
  },

  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14),

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),

      gradient: const LinearGradient(
        colors: [
          Color(0xFF1B1B1B),
          Color(0xFF111111),
        ],
      ),

      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: const Center(
      child: Text(
        "CHIUDI",

        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  });
}
if (!initialized) {
  initialized = true;
}
                lastCount = docs.length;

                return SingleChildScrollView(
    child: SizedBox(
      width: double.infinity,

      child: ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: MediaQuery.of(context).size.width,
  ),

  child: Column(
    children: [

const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const SizedBox(height: 20),

    ],
  ),
),

                    // 🔥 CALENDARIO PREMIUM
                    Container(

  margin: EdgeInsets.symmetric(
    horizontal:
        isMobile ? 16 : 24,
  ),

  padding: EdgeInsets.symmetric(
    horizontal:
        isMobile ? 14 : 22,
    vertical:
        isMobile ? 18 : 26,
  ),

  decoration: BoxDecoration(

    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF101010),
      ],
    ),

    borderRadius: BorderRadius.circular(
  isMobile ? 28 : 34,
),

    border: Border.all(
      color: Colors.white.withOpacity(0.04),
    ),

    boxShadow: [

  // OMBRA PROFONDA
  BoxShadow(
    color: Colors.black.withOpacity(0.40),
    blurRadius: 40,
    offset: const Offset(0, 22),
  ),

  // GLOW PREMIUM
  BoxShadow(
    color: Colors.white.withOpacity(0.025),
    blurRadius: 6,
    spreadRadius: 1,
  ),

  // RIFLESSO VERDE BARBER
  BoxShadow(
    color: const Color(0xFF00C853)
        .withOpacity(0.05),

    blurRadius: 28,
    spreadRadius: 1,
  ),
],
  ),

  child: TableCalendar(
  locale: 'it_IT',

  firstDay: DateTime.now(),
  lastDay: DateTime.now().add(const Duration(days: 30)),
  focusedDay: selectedDay,

  enabledDayPredicate: (day) {

  final today = DateTime.now();

  final isPast = day.isBefore(
    DateTime(today.year, today.month, today.day),
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
    fontSize: width < 500
    ? 16
    : width < 900
        ? 22
        : 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 3,
    backgroundColor: Colors.black.withOpacity(0.45),
  ),

  leftChevronIcon: Container(
    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.45),

      borderRadius: BorderRadius.circular(18),

      border: Border.all(
        color: Colors.white.withOpacity(0.04),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
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
      color: Colors.black.withOpacity(0.45),

      borderRadius: BorderRadius.circular(18),

      border: Border.all(
        color: Colors.white.withOpacity(0.04),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
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
  color: Colors.white.withOpacity(0.55),

  fontWeight: FontWeight.w700,

  fontSize:
      isMobile ? 11 : 13,

  letterSpacing: 1,
),
  weekendStyle: TextStyle(
    color: Colors.white.withOpacity(0.3),
    fontSize: 12,
  ),
),

  calendarStyle: const CalendarStyle(
    defaultTextStyle: TextStyle(color: Colors.white),
    weekendTextStyle: TextStyle(color: Colors.white),

    selectedDecoration: BoxDecoration(
      color: Color.fromARGB(0, 0, 0, 0),
    ),

    todayDecoration: BoxDecoration(
      color: Color.fromARGB(0, 119, 119, 119),
    ),

    outsideDaysVisible: false,
  ),

  selectedDayPredicate: (d) => isSameDay(d, selectedDay),

  onDaySelected: (day, _) {
  final today = DateTime.now();

  final isPast = day.isBefore(
    DateTime(today.year, today.month, today.day),
  );

  if (isPast) return;

  if (!mounted) return;

  setState(() {
    selectedDay = day;
  });
},

  calendarBuilders: CalendarBuilders(
  headerTitleBuilder: (context, day) {

    final text = DateFormat(
      'MMMM yyyy',
      'it_IT',
    ).format(day).toUpperCase();

    return Padding(
  padding: const EdgeInsets.only(bottom: 26),
  child: Center(
    child: premiumSectionTitle(text),
  ),
);
  },


    selectedBuilder: (context, day, focusedDay) {

      final today = DateTime.now();

final isPast = day.isBefore(
  DateTime(today.year, today.month, today.day),
);

if (isPast) {
  return Container(
    margin: EdgeInsets.all(
  isMobile ? 4 : 6,
),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withOpacity(0.2),
    ),
    child: Center(
      child: Text(
        "${day.day}",
        style: const TextStyle(color: Colors.white24),
      ),
    ),
  );
}

  final filtered = docs.where((doc) {
    if (doc['data'] == null) return false;
    final d = (doc['data'] as Timestamp).toDate();

    final sameDay = d.year == day.year &&
        d.month == day.month &&
        d.day == day.day;

    if (!sameDay) return false;

    if (filtro == "Tutti") return true;

    return doc['operatore'] == filtro;
  }).toList();

  final count = filtered.length;
  final totaleSlot = 17;
  final isSelected = true;

  Color bgColor = const Color.fromARGB(255, 35, 35, 35);

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
      duration: const Duration(milliseconds: 150),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.9),
              blurRadius: 20,
            )
          ],
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 18 : 14,
            ),
          ),
        ),
      ),
    ),
  );
},

    defaultBuilder: (context, day, focusedDay) {

      final filtered = docs.where((doc) {
        if (doc['data'] == null) return false;
        final d = (doc['data'] as Timestamp).toDate();

        final sameDay = d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;

        if (!sameDay) return false;

        if (filtro == "Tutti") return true;

        return doc['operatore'] == filtro;
      }).toList();

      final count = filtered.length;
      final totaleSlot = 17;
      final isSelected = isSameDay(day, selectedDay);
      final domenica = day.weekday == 7;

      Color bgColor;
      List<BoxShadow> glow = [];


    

      if (domenica) {

  bgColor = Colors.black;

} else if (count == 0) {

  bgColor = const Color.fromARGB(255, 137, 151, 138);

} else if (count < totaleSlot) {
        bgColor = const Color.fromARGB(255, 37, 37, 37);
        glow = [
          BoxShadow(
            color: const Color.fromARGB(255, 36, 36, 36).withOpacity(0.6),
            blurRadius: 16,
          )
        ];
      } else {
        bgColor = const Color.fromARGB(255, 23, 23, 23);
        glow = [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.6),
            blurRadius: 16,
          )
        ];
      }

      if (isSelected) {
  bgColor = const Color(0xFF00C853); // 💚 verde neon
  glow = [
    BoxShadow(
      color: const Color(0xFF00C853).withOpacity(0.9),
      blurRadius: 20,
    )
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
          scale: isSelected ? 1.08 : 0.96,
duration: Duration(milliseconds: 180),
curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(18),

  gradient: isSelected
    ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1F1F1F),
          const Color(0xFF121212),
        ],
      )
    : LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF262626),
          const Color(0xFF1D1D1D),
        ],
      ),

  border: Border.all(
    color: isSelected
        ? const Color(0xFF00C853)
        : Colors.white.withOpacity(0.04),
    width: isSelected ? 1.8 : 1,
  ),

  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),

    if (isSelected) ...[

  BoxShadow(
    color: const Color(0xFF00C853)
        .withOpacity(0.22),

    blurRadius: 26,
    spreadRadius: 2,
  ),

  BoxShadow(
    color: Colors.white.withOpacity(0.03),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
fontSize: isTablet ? 18 : 14,
                    ),
                  ),
                ),

                if (count > 0)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 7, 7, 7),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$count",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (count >= totaleSlot)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.white38,
                        size: 18,
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
  ),
),



const SizedBox(height: 25),

Padding(
  padding: const EdgeInsets.symmetric(vertical: 20),
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
  backgroundColor: giornataChiusa
      ? const Color(0xFF00C853).withOpacity(0.15)
      : Colors.redAccent.withOpacity(0.15),

  foregroundColor: giornataChiusa
      ? const Color(0xFF00E676)
      : Colors.redAccent,

  elevation: 0,

  side: BorderSide(
    color: giornataChiusa
        ? const Color(0xFF00E676)
        : Colors.redAccent,
    width: 1.2,
  ),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),

  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
),

    onPressed: () async {
  

      

      if (filtro == "Tutti") {
  
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
  content: const Text(
    "Seleziona un operatore",
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: Colors.redAccent,
),
    );
    return;
  }

  final conferma = await showGeneralDialog(
  context: context,

  barrierDismissible: true,
  barrierLabel: "",

  barrierColor: Colors.black.withOpacity(0.75),

  transitionDuration: const Duration(milliseconds: 220),

  pageBuilder: (_, __, ___) {

    return Center(
      child: Material(
        color: Colors.transparent,

        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),

            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF181818),
                Color(0xFF0E0E0E),
              ],
            ),

            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 35,
                offset: const Offset(0, 18),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ICONA
              Container(
                width: 82,
                height: 82,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: giornataChiusa
                        ? [
                            const Color(0xFF00E676),
                            const Color(0xFF00C853),
                          ]
                        : [
                            const Color(0xFFFF5252),
                            const Color(0xFFFF1744),
                          ],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: (giornataChiusa
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFF1744))
                          .withOpacity(0.45),

                      blurRadius: 26,
                    ),
                  ],
                ),

                child: Icon(
                  giornataChiusa
                      ? Icons.lock_open_rounded
                      : Icons.lock_rounded,

                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(height: 26),

              // TITOLO
              Text(
                giornataChiusa
                    ? "RIAPRI GIORNATA"
                    : "CHIUDI GIORNATA",

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 12),

              // DESCRIZIONE
              Text(
                giornataChiusa
                    ? "Vuoi riaprire la giornata per $filtro?"
                    : "Vuoi chiudere la giornata per $filtro?",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // BOTTONI
              Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                      },

                      child: Container(
                        height: 54,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          color: Colors.white.withOpacity(0.06),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),

                        child: const Center(
                          child: Text(
                            "ANNULLA",

                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },

                      child: Container(
                        height: 54,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          gradient: LinearGradient(
                            colors: giornataChiusa
                                ? [
                                    const Color(0xFF00E676),
                                    const Color(0xFF00C853),
                                  ]
                                : [
                                    const Color(0xFFFF5252),
                                    const Color(0xFFFF1744),
                                  ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: (giornataChiusa
                                      ? const Color(0xFF00E676)
                                      : const Color(0xFFFF1744))
                                  .withOpacity(0.35),

                              blurRadius: 20,
                            ),
                          ],
                        ),

                        child: Center(
                          child: Text(
                            giornataChiusa
                                ? "RIAPRI"
                                : "CHIUDI",

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              fontSize: 13,
                            ),
                          ),
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

  transitionBuilder: (_, animation, __, child) {

    return Transform.scale(
      scale: Curves.easeOutBack.transform(animation.value),

      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  },
);

  if (conferma == true) {



    if (!giornataChiusa) {
  await chiudiGiorno(selectedDay, filtro);
} else {
  final snapshot = await FirebaseFirestore.instance
    .collection('giorni_chiusi')
    .where('operatore', isEqualTo: filtro)
    .get();

for (var doc in snapshot.docs) {
  final d = (doc['data'] as Timestamp).toDate();

  final stessoGiorno =
      d.year == selectedDay.year &&
      d.month == selectedDay.month &&
      d.day == selectedDay.day;

  if (stessoGiorno) {
    await doc.reference.delete();
  }
}
}

setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    backgroundColor: giornataChiusa
        ? const Color(0xFF00C853)
        : Colors.redAccent,
        

    content: Row(
      children: [

        Icon(
          giornataChiusa ? Icons.lock_open : Icons.lock,
          color: Colors.white,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            giornataChiusa
                ? "Giornata riaperta per $filtro"
                : "Giornata chiusa per $filtro",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
},

    icon: Icon(
  giornataChiusa ? Icons.lock_open : Icons.lock,
  size: 18,
),

    label: Text(
  giornataChiusa ? "Riapri giornata" : "Chiudi giornata",
  style: const TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  ),
),
  ),
),

const SizedBox(height: 30),


Container(
  margin: EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : 24,
  ),

  padding: EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : 24,
    vertical: isMobile ? 20 : 28,
  ),

  decoration: BoxDecoration(

    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF101010),
      ],
    ),

    borderRadius: BorderRadius.circular(
      isMobile ? 30 : 36,
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.05),
    ),

    boxShadow: [

      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: 30,
        offset: const Offset(0, 14),
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

      Row(
        children: [

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C853)
                      .withOpacity(0.18),

                  const Color(0xFF00E676)
                      .withOpacity(0.08),
                ],
              ),

              border: Border.all(
                color: const Color(0xFF00E676)
                    .withOpacity(0.16),
              ),
            ),

            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF69F0AE),
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "APPUNTAMENTI",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  formatDataBella(selectedDay),

                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.5),

                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      SizedBox(
        height: isMobile ? 22 : 30,
      ),

      ListView(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
                        children: ordinati.where((doc) {

  if (doc['data'] == null) return false;

  final d = (doc['data'] as Timestamp).toDate();

  final sameDay =
      d.year == selectedDay.year &&
      d.month == selectedDay.month &&
      d.day == selectedDay.day;

  if (!sameDay) return false;

  if (filtro == "Tutti") return true;

  return doc['operatore'] == filtro;

}).isEmpty
    ? [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 40,
          ),

          child: Column(
            children: [

              Container(
                width: 72,
                height: 72,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),

                child: Icon(
                  Icons.event_busy_rounded,
                  color: Colors.white.withOpacity(0.35),
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Nessun appuntamento",

                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Non ci sono prenotazioni per questa giornata.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ]
    : ordinati.where((doc) {

    if (doc['data'] == null) return false;

    final d = (doc['data'] as Timestamp).toDate();

    final sameDay =
        d.year == selectedDay.year &&
        d.month == selectedDay.month &&
        d.day == selectedDay.day;

    if (!sameDay) return false;

    if (filtro == "Tutti") return true;

    return doc['operatore'] == filtro;

}).map((d) {
                          final data = d.data();

                          bool pressed = false;

return StatefulBuilder(
  builder: (context, setInnerState) {

    return GestureDetector(
      onTapDown: (_) {
        setInnerState(() {
          pressed = true;
        });
      },

      onTapUp: (_) {
        setInnerState(() {
          pressed = false;
        });
      },

      onTapCancel: () {
        setInnerState(() {
          pressed = false;
        });
      },

      onTap: () {
    showDialog(
  context: context,
  barrierColor: Colors.transparent,
  builder: (_) => Stack(
  children: [

    // 🌫 BLUR DIETRO (COME QUELLO CHE HAI)
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withOpacity(0.2),
      ),
    ),

    // 💎 POPUP CENTRALE
    Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A1A1A),
    Color(0xFF101010),
  ],
),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
            )
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

    gradient: const LinearGradient(
      colors: [
        Color(0xFF202020),
        Color(0xFF121212),
      ],
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),

    boxShadow: [

  BoxShadow(
    color: Colors.black.withOpacity(0.40),
    blurRadius: 24,
    offset: const Offset(0, 12),
  ),

  BoxShadow(
    color: Colors.white.withOpacity(0.015),
    blurRadius: 2,
    spreadRadius: 1,
  ),
],
  ),

  child: const Icon(
    Icons.person_outline_rounded,
    color: Colors.white,
    size: 28,
  ),
),

            const SizedBox(height: 10),

            Text(
              data['nome'] ?? "Cliente",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 15),

            Text(
  formatDataBella((data['data'] as Timestamp).toDate()),
  style: TextStyle(
  color: Colors.white.withOpacity(0.65),
  fontWeight: FontWeight.w500,
  letterSpacing: 0.4,
),
),
const SizedBox(height: 5),
            Text(
  "${data['servizio']}",

  style: TextStyle(
    color: Colors.white.withOpacity(0.88),
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  ),
),
            Text(
  "${data['ora']} • ${data['operatore']}",

  style: TextStyle(
    color: Colors.white.withOpacity(0.45),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
),
            GestureDetector(
  onTap: () async {
    final url = Uri.parse("tel:${data['telefono']}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  },
  child: Text(
    data['telefono'] ?? "-",
    style: TextStyle(
  color: Colors.white.withOpacity(0.9),
  fontWeight: FontWeight.w600,
  fontSize: isMobile ? 15 : 17,
  letterSpacing: 0.5,
),
  ),
),

const SizedBox(height: 20),

GestureDetector(
  onTap: () => Navigator.pop(context),

  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),

      gradient: const LinearGradient(
        colors: [
          Color(0xFF1C1C1C),
          Color(0xFF111111),
        ],
      ),

      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: const Center(
      child: Text(
        "CHIUDI",

        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
      ),
    ),
  ),
),
          ],
        ),
      ),
    ),
  ],
),
    );
  },

  child: AnimatedScale(
  scale: pressed ? 0.985 : 1,
  duration: const Duration(milliseconds: 140),

  child: ClipRRect(
  borderRadius: BorderRadius.circular(
    isMobile ? 34 : 42,
  ),

  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 12,
      sigmaY: 12,
    ),

    child: AnimatedContainer(
  duration: const Duration(milliseconds: 250),

  margin: EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 24,
    vertical: 6,
  ),

  padding: EdgeInsets.all(
  isMobile ? 14 : 18,
),

  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(
  isMobile ? 34 : 42,
),

    gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    const Color(0xFF1B1B1B),
    const Color(0xFF101010),
  ],
),

    border: Border.all(
      color: Colors.white.withOpacity(0.05),
    ),

    boxShadow: [

  BoxShadow(
  color: Colors.black.withOpacity(0.40),
  blurRadius: 24,
  offset: const Offset(0, 12),
),

  BoxShadow(
    color: Colors.white.withOpacity(0.015),
    blurRadius: 2,
    spreadRadius: 1,
  ),
],
  ),

  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // AVATAR PREMIUM
      Container(
  width: isMobile ? 48 : 56,
height: isMobile ? 48 : 56,

  decoration: BoxDecoration(
    shape: BoxShape.circle,

    gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF222222),
    Color(0xFF111111),
  ],
),

    border: Border.all(
      color: Colors.white.withOpacity(0.04),
    ),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  ),

  child: Center(
    child: Text(
      "${ordinati.where((doc) {
        if (doc['data'] == null) return false;

        final dd = (doc['data'] as Timestamp).toDate();

        final sameDay =
            dd.year == selectedDay.year &&
            dd.month == selectedDay.month &&
            dd.day == selectedDay.day;

        if (!sameDay) return false;

        if (filtro == "Tutti") return true;

        return doc['operatore'] == filtro;

      }).toList().indexOf(d) + 1}",

      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: isMobile ? 15 : 17,
      ),
    ),
  ),
),

      SizedBox(
  width: isMobile ? 14 : 20,
),

      // INFO
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // NOME + BADGE
            Row(
              children: [

                Expanded(
                  child: Text(
                    data['nome'] ?? "Cliente",

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize:
    isMobile ? 16 : 19,
    letterSpacing: 0.2,
                  ),
                ),
                ),

                if (data['walkin'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),

                    child: const Text(
                      "WALK-IN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // SERVIZIO
            Text(
              data['servizio'],

              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                // ORARIO
                _premiumInfoChip(
                  Icons.access_time_rounded,
                  data['ora'],
                ),

                // OPERATORE
                _premiumInfoChip(
                  Icons.person_outline,
                  data['operatore'],
                ),

                // DURATA
                _premiumInfoChip(
                  Icons.timelapse,
                  "${data['durata'] ?? 30} min",
                ),
              ],
            ),

            if ((data['telefono'] ?? "").toString().isNotEmpty) ...[
              const SizedBox(height: 14),

              GestureDetector(
                onTap: () async {
                  final url =
                      Uri.parse("tel:${data['telefono']}");

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },

                child: Row(
                  children: [

                    const Icon(
                      Icons.phone,
                      color: Color(0xFF00C853),
                      size: 16,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      data['telefono'],

                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),

      const SizedBox(width: 10),

      // DELETE
      GestureDetector(
        onTap: () async {

          final bookingId = d.id.hashCode;

          await flutterLocalNotificationsPlugin
              .cancel(bookingId + 1);

          await flutterLocalNotificationsPlugin
              .cancel(bookingId + 2);

          await FirebaseFirestore.instance
              .collection('appuntamenti')
              .doc(d.id)
              .delete();
        },

        child: Container(
          padding: EdgeInsets.symmetric(
  horizontal: isMobile ? 14 : 16,
  vertical: isMobile ? 14 : 16,
),

decoration: BoxDecoration(
  color: Colors.redAccent.withOpacity(0.12),

  borderRadius: BorderRadius.circular(18),

  border: Border.all(
    color: Colors.redAccent.withOpacity(0.18),
  ),

  boxShadow: [
    BoxShadow(
      color: Colors.redAccent.withOpacity(0.10),
      blurRadius: 12,
    ),
  ],
),

          child: const Icon(
  Icons.delete_outline,
  color: Colors.redAccent,
  size: 20,
),
        ),
      ),
    ],
  ),
),
  ),
  ),
      ),
    );
  },
);
                        }).toList(),
                      ),

    ],
  ),
),
     
const SizedBox(height: 30),




const SizedBox(height: 30),





Container(
  margin: EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : 24,
  ),

  padding: EdgeInsets.symmetric(
    horizontal: isMobile ? 18 : 26,
    vertical: isMobile ? 22 : 30,
  ),

  decoration: BoxDecoration(

    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF101010),
      ],
    ),

    borderRadius: BorderRadius.circular(
      isMobile ? 30 : 36,
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.05),
    ),

    boxShadow: [

      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),

      BoxShadow(
        color: Colors.white.withOpacity(0.015),
        blurRadius: 2,
        spreadRadius: 1,
      ),
    ],
  ),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
  children: [

    Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: LinearGradient(
          colors: [
            Colors.redAccent.withOpacity(0.16),
            Colors.redAccent.withOpacity(0.06),
          ],
        ),

        border: Border.all(
          color: Colors.redAccent.withOpacity(0.18),
        ),
      ),

      child: const Icon(
        Icons.schedule_rounded,
        color: Colors.redAccent,
        size: 20,
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            "GESTIONE ORARI",

            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            "Blocca o riapri gli slot disponibili",

            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.5),

              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  ],
),

SizedBox(
  height: isMobile ? 22 : 30,
),

      SingleChildScrollView(
  child: Wrap(
          children: [
            StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('orari_bloccati')
      .snapshots(),
  builder: (context, snapshot) {

    if (!snapshot.hasData) return const SizedBox();

    final lista = snapshot.data!.docs.where((doc) {
      final data = (doc['data'] as Timestamp).toDate();

      return data.year == selectedDay.year &&
          data.month == selectedDay.month &&
          data.day == selectedDay.day &&
          (filtro == "Tutti" || doc['operatore'] == filtro);
    }).map((doc) => doc['ora'] as String).toList();

    orariBloccati = lista;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isMobile ? 10 : 14,
runSpacing: isMobile ? 10 : 14,
      children: orari.map((ora) {

        if (selectedDay.weekday == 7) {
  return const SizedBox.shrink();
}

// 🔒 LUNEDÌ SOLO MATTINA
if (selectedDay.weekday == 1 &&
    ora.compareTo("13:00") >= 0) {
  return const SizedBox.shrink();
}


        final isBloccato = orariBloccati.contains(ora);
        final occupato = slotOccupato(
  ora,
  docs,
);

        return GestureDetector(
          onTap: occupato ? null : () async {

            if (filtro == "Tutti") {

  premiumPopup(
    context: context,
    title: "SELEZIONA OPERATORE",
    subtitle:
        "Devi selezionare un operatore prima di bloccare un orario.",
    icon: Icons.person_outline_rounded,
    color: const Color(0xFFD4AF37),
  );

  return;
}

            if (isBloccato) {
              final snapshot = await FirebaseFirestore.instance
                  .collection('orari_bloccati')
                  .where('ora', isEqualTo: ora)
                  .where('operatore', isEqualTo: filtro)
                  .get();

              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }

              premiumPopup(
                context: context,
  title: "ORARIO SBLOCCATO",
  subtitle: "$ora nuovamente disponibile.",
  icon: Icons.lock_open_rounded,
  color: const Color(0xFF00C853),
);
            } else {
              await bloccaOrario(selectedDay, filtro, ora);
            }
          },

          child: AnimatedScale(
  scale: occupato ? 0.98 : 1,

  duration: const Duration(milliseconds: 180),

  child: AnimatedContainer(
    curve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
  horizontal: isTablet ? 22 : 16,
  vertical: isTablet ? 14 : 10,
),
            decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(
  isMobile ? 18 : 22,
),

  gradient: occupato
      ? const LinearGradient(
          colors: [
            Color(0xFF2B2B2B),
            Color(0xFF1A1A1A),
          ],
        )
      : isBloccato
          ? const LinearGradient(
              colors: [
                Color(0xFFFF5A5A),
                Color(0xFFD32F2F),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),

  border: Border.all(
    color: occupato
        ? Colors.white.withOpacity(0.04)
        : isBloccato
            ? Colors.redAccent.withOpacity(0.25)
            : Colors.white.withOpacity(0.08),
    width: 1,
  ),

  boxShadow: [

    BoxShadow(
  color: Colors.black.withOpacity(0.40),
  blurRadius: 18,
  offset: const Offset(0, 8),
),

    if (!occupato && !isBloccato)
      BoxShadow(
        color: Colors.white.withOpacity(0.015),
        blurRadius: 6,
        spreadRadius: 1,
      ),

    if (isBloccato)
      BoxShadow(
        color: Colors.redAccent.withOpacity(0.25),
        blurRadius: 16,
      ),
  ],
),
            child: Text(
  occupato
      ? "$ora • OCCUPATO"
      : isBloccato
          ? "$ora • BLOCCATO"
          : ora,
              style: TextStyle(
  color: occupato
      ? Colors.white30
      : Colors.white,

  fontWeight: FontWeight.w700,
  letterSpacing: 0.4,
  fontSize: isMobile ? 12 : 14,
),
            ),
          ),
          ),
        );
      }).toList(),
    );
  },
)
          ],
        ),
      ),
    ],
  ),
),

SizedBox(
  height:
      MediaQuery.of(context).padding.bottom + 30,
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


Widget premiumSectionTitle(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 26,
      vertical: 14,
    ),

    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.045),
      backgroundBlendMode: BlendMode.overlay,

      borderRadius: BorderRadius.circular(22),

      border: Border.all(
  color: Colors.white.withOpacity(0.04),
  width: 1,
),

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


Widget _premiumInfoChip(
  IconData icon,
  String text,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),

    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),
    ),

    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          color: const Color(0xFF00C853),
          size: 15,
        ),

        const SizedBox(width: 6),

        Text(
          text,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _infoRow(String titolo, String valore) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titolo,
          style: const TextStyle(color: Colors.white38),
        ),
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
