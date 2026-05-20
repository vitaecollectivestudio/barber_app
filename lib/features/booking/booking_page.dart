import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../app_background.dart';
import '../auth/login_page.dart';
import 'package:flutter/gestures.dart';
import '../../services/slot_service.dart';
import 'widgets/booking_header.dart';
import 'widgets/booking_time_grid.dart';
import 'widgets/day_selector.dart';
import '../../utils/responsive.dart';

Future<void> scheduleNotification(
  int id,
  String title,
  String body,
  DateTime scheduledTime,
) async {}

class BookingPage extends StatefulWidget {
  final String servizio;
  final int durata;

  const BookingPage({
    super.key,
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
  StreamSubscription? blocchiSub;
  StreamSubscription? appuntamentiSub;
  int? pressedIndex;

  bool isLoading = false;
  bool loadingOrari = false;
  List<DateTime> giorniChiusi = [];

  bool giaInLista = false;
  
  Future<void> apriRecensioneGoogle() async {
  final url = Uri.parse(
    "https://g.page/r/TUO-LINK-GOOGLE/review",
  );

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
  curve: Curves.easeOutCubic,
);

_controller.forward();


  WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollToIndex(selectedDay.day - 1); // puoi cambiare index
});
caricaOrariOccupati();
  if (operatore != null) {
  caricaGiorniChiusi();
}
}

void _scrollToIndex(int index) {

  const itemWidth = 72.0;

  final screenWidth =
      MediaQuery.of(context).size.width;

  final offset =
      (index * itemWidth) -
      (screenWidth / 2) +
      (itemWidth / 2);

  _scrollController.animateTo(
    offset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    ),

    duration: const Duration(milliseconds: 300),

    curve: Curves.easeOut,
  );
}


Future<void> caricaOrariOccupati() async {

  if (operatore == null) return;
if (!mounted) return;
  setState(() {
    loadingOrari = true;
  });

  final appuntamentiSnapshot = await FirebaseFirestore.instance
      .collection('appuntamenti')
      .where('operatore', isEqualTo: operatore)
      .get();

  final walkinSnapshot = await FirebaseFirestore.instance
      .collection('walkin')
      .where('operatore', isEqualTo: operatore)
      .get();

  final tuttiDocs = [
    ...appuntamentiSnapshot.docs,
    ...walkinSnapshot.docs,
  ];

  final occupati = tuttiDocs.where((doc) {

    final d = (doc['data'] as Timestamp).toDate();

    return d.year == selectedDay.year &&
        d.month == selectedDay.month &&
        d.day == selectedDay.day;

  }).map((doc) => {

    "ora": doc['ora'],
    "durata": doc['durata'] ?? 30,

  }).toList();

  if (!mounted) return;

  setState(() {
    orariOccupati = occupati;
    loadingOrari = false;
  });
}

void ascoltaOrariBloccati() {

  blocchiSub?.cancel();
  if (operatore == null) return;

  blocchiSub = FirebaseFirestore.instance
      .collection('orari_bloccati')
      .snapshots()
      .listen((snapshot) {

    final lista = snapshot.docs.where((doc) {
      final d = (doc['data'] as Timestamp).toDate();

      return d.year == selectedDay.year &&
          d.month == selectedDay.month &&
          d.day == selectedDay.day &&
          doc['operatore'] == operatore;
    }).map((doc) => doc['ora'] as String).toList();
if (!mounted) return;
    setState(() {
      orariBloccati = lista;
    });
  });
}

void ascoltaAppuntamentiRealtime() {

  appuntamentiSub?.cancel();

  if (operatore == null) return;

  appuntamentiSub = FirebaseFirestore.instance
      .collection('appuntamenti')
      .where('operatore', isEqualTo: operatore)
      .snapshots()
      .listen((snapshot) {

    final occupati = snapshot.docs.where((doc) {

      final d = (doc['data'] as Timestamp).toDate();

      return d.year == selectedDay.year &&
          d.month == selectedDay.month &&
          d.day == selectedDay.day;

    }).map((doc) => {

      "ora": doc['ora'],
      "durata": doc['durata'] ?? 30,

    }).toList();

    if (!mounted) return;

    setState(() {
      orariOccupati = occupati;
    });
  });
}

Future<void> caricaGiorniChiusi() async {

  if (operatore == null) return;

  final chiusureSnapshot = await FirebaseFirestore.instance
      .collection('giorni_chiusi')
      .where('operatore', isEqualTo: operatore)
      .get();

  final chiusi = chiusureSnapshot.docs.map((doc) {

    return (doc['data'] as Timestamp).toDate();

  }).toList();
if (!mounted) return;
  setState(() {
    giorniChiusi = chiusi;
  });
}
  
  String formatData(DateTime d) {
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
  final operatori = [
    {"nome": "Francesco", "img": "assets/images/francesco.jpeg"},
    {"nome": "Antonio", "img": "assets/images/antonio.jpeg"},
  ];

  final orari = [
    "08:30","09:00","09:30","10:00","10:30",
    "11:00","11:30","12:00","12:30",
    "15:00","15:30","16:00","16:30",
    "17:00","17:30","18:00","18:30",
  ];

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
  return giorniChiusi.any((g) =>
      g.year == d.year &&
      g.month == d.month &&
      g.day == d.day);
}

  Future<void> salva(String ora) async {
final horizontalPadding =
    Responsive.horizontalPadding(context);
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
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
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

final snapshot = await FirebaseFirestore.instance
    .collection('appuntamenti')
    .where('operatore', isEqualTo: operatore)
    .get();
if (!mounted) return;
final clash = snapshot.docs.any((doc) {
  final d = (doc['data'] as Timestamp).toDate();
  final oraDoc = doc['ora'];

  final startDoc = DateTime(
    d.year,
    d.month,
    d.day,
    int.parse(oraDoc.split(":")[0]),
    int.parse(oraDoc.split(":")[1]),
  );

 final durataDoc = doc['durata'] ?? 30;
final endDoc = startDoc.add(Duration(minutes: durataDoc));

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

  // 👇 QUI PARTE IL TUO CODICE NORMALE
  showGeneralDialog(
  context: context,

  barrierDismissible: false,

  barrierLabel: "loading",

  barrierColor: Colors.black.withOpacity(0.75),

  transitionDuration: const Duration(milliseconds: 250),

  pageBuilder: (_, __, ___) {

    return Center(
      child: Material(
        color: Colors.transparent,

        child: Container(
          margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
),

          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 28,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFF181818),

            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
  width: 140,
  height: 5,

  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.06),
    borderRadius: BorderRadius.circular(30),
  ),

  child: TweenAnimationBuilder<double>(

    tween: Tween(begin: 0, end: 1),

    duration: const Duration(seconds: 2),

    curve: Curves.easeInOut,

    builder: (context, value, child) {

      return Align(
        alignment: Alignment(-1 + (value * 2), 0),

        child: Container(
          width: 70,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),

            gradient: const LinearGradient(
  colors: [
    Colors.white,
    Color(0xFFEAEAEA),
  ],
),

boxShadow: [
  BoxShadow(
    color: Colors.white24,
    blurRadius: 16,
    spreadRadius: 1,
  ),
],
          ),
        ),
      );
    },
  ),
),

              const SizedBox(height: 22),

              const Text(
                "CONFERMA PRENOTAZIONE",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

           

              const Text(
                "Stiamo riservando il tuo appuntamento.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },

  transitionBuilder: (_, animation, __, child) {

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
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

final chiusureSnapshot = await FirebaseFirestore.instance
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

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Giornata chiusa"),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

// 👇 2. SALVI APPUNTAMENTO CON ID
final docRef = await FirebaseFirestore.instance.collection('appuntamenti').add({
  "nome": nomeFinale.isNotEmpty ? nomeFinale : user.email,
  "servizio": widget.servizio,
  "ora": ora,
  "operatore": operatore,
  "data": Timestamp.fromDate(selectedDay),
  "userId": user.uid,
  "telefono": telefono,
  "durata": widget.durata,
});
if (!mounted) return;
// 🔔 👇 INCOLLA QUI SOTTO 👇

final dataPrenotazione = DateTime(
  selectedDay.year,
  selectedDay.month,
  selectedDay.day,
  int.parse(ora.split(":")[0]),
  int.parse(ora.split(":")[1]),
);

final twoHoursBefore = dataPrenotazione.subtract(const Duration(hours: 2));
final oneDayBefore = dataPrenotazione.subtract(const Duration(hours: 24));

// 🔔 1 ORA PRIMA
final baseId = docRef.id.hashCode;

// 🔔 2 ORE PRIMA
if (twoHoursBefore.isAfter(DateTime.now())) {
  await scheduleNotification(
    baseId + 1,
    "Promemoria appuntamento",
    "Hai un appuntamento tra 2 ore.",
    twoHoursBefore,
  );
}

// 🔔 24 ORE PRIMA
if (oneDayBefore.isAfter(DateTime.now())) {
  await scheduleNotification(
    baseId + 2,
    "Promemoria appuntamento",
    "Hai un appuntamento domani.",
    oneDayBefore,
  );
}

  if (mounted) {
  Navigator.pop(context);
}

HapticFeedback.lightImpact();

showGeneralDialog(
  context: context,
  barrierDismissible: false,
  barrierLabel: "success",
  barrierColor: Colors.black.withOpacity(0.6),
  transitionDuration: const Duration(milliseconds: 250),

  pageBuilder: (_, __, ___) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
  ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
  color: const Color(0xFF181818),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: Colors.white.withOpacity(0.05),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.8), // 🔥 ombra nera
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ],
),
          child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [

    const Icon(
      Icons.check,
      color: Colors.white,
      size: 32,
    ),

    const SizedBox(height: 12),

    Text(
      "Prenotazione confermata",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: MediaQuery.of(context).size.width * 0.048,
        fontWeight: FontWeight.w700, // 🔥 più professionale
        letterSpacing: 0.3,
      ),
    ),

    const SizedBox(height: 10),

    // 🔥 SERVIZIO (più elegante)
    Text(
      widget.servizio,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),

    const SizedBox(height: 16),

    // 🔥 DATA + ORA
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${formatData(selectedDay)} • $ora",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600, // 🔥 più leggibile
        ),
      ),
    ),

  ],
)
        ),
      ),
    );
  },

  transitionBuilder: (_, animation, __, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
);

await Future.delayed(const Duration(seconds: 2));

if (mounted) {
  Navigator.pop(context); // chiude popup successo

}


await caricaOrariOccupati();

if (!mounted) return;

setState(() {
  orarioSelezionato = null;
  isLoading = false;
});

  setState(() {
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
              )
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
    )
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
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final horizontalPadding =
    Responsive.horizontalPadding(context);

final maxWidth =
    Responsive.maxContentWidth(context);

final isTablet =
    Responsive.isTablet(context);

final isDesktop =
    Responsive.isDesktop(context);
  final giorni = generaGiorni();


final orariFiltrati = SlotService.calcolaSlotDisponibili(
  orariBase: orari,
  occupati: orariOccupati,
  bloccati: orariBloccati,
  selectedDay: selectedDay,
  durataServizio: widget.durata,
  );

final canConfirm =
    operatore != null &&
    orarioSelezionato != null &&
    !isLoading;

    return FadeTransition(
  opacity: _animation,
  child: SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_animation),
    child: AppBackground(
    child: Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(

  automaticallyImplyLeading: false,

  backgroundColor: Colors.black.withOpacity(0.78),

  surfaceTintColor: Colors.transparent,

  elevation: 0,

  scrolledUnderElevation: 0,

  toolbarHeight:
      isDesktop
          ? 96
          : isTablet
              ? 86
              : 76,

  centerTitle: true,

  flexibleSpace: ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 18,
        sigmaY: 18,
      ),

      child: Container(
        color: Colors.black.withOpacity(0.30),
      ),
    ),
  ),

  leadingWidth:
      isDesktop ? 90 : 74,

  leading: Padding(

    padding: EdgeInsets.only(
      left: horizontalPadding,
    ),

    child: Center(

      child: GestureDetector(

        onTap: () {
          Navigator.pop(context);
        },

        child: AnimatedContainer(

          duration:
              const Duration(milliseconds: 180),

          width:
              isDesktop ? 56 : 48,

          height:
              isDesktop ? 56 : 48,

          decoration: BoxDecoration(

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color:
                  Colors.white.withOpacity(0.08),
            ),

            boxShadow: [

              BoxShadow(
                color:
                    Colors.black.withOpacity(0.45),

                blurRadius: 18,

                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Icon(
            Icons.arrow_back_ios_new_rounded,

            color: Colors.white,

            size:
                isDesktop ? 20 : 18,
          ),
        ),
      ),
    ),
  ),

  title: Column(

    mainAxisAlignment:
        MainAxisAlignment.center,

    children: [

      ConstrainedBox(

        constraints: BoxConstraints(
          maxWidth:
              isDesktop ? 560 : 320,
        ),

        child: Text(

          widget.servizio,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          textAlign: TextAlign.center,

          style: TextStyle(

            color: Colors.white,

            fontSize:
                isDesktop
                    ? 28
                    : isTablet
                        ? 23
                        : 19,

            fontWeight:
                FontWeight.w800,

            letterSpacing: -0.4,

            height: 1,
          ),
        ),
      ),

      SizedBox(
        height:
            isDesktop ? 10 : 7,
      ),

      Container(

        padding: EdgeInsets.symmetric(

          horizontal:
              isDesktop ? 16 : 13,

          vertical:
              isDesktop ? 6 : 4,
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
                    .withOpacity(0.20),
          ),
        ),

        child: Text(

          "${widget.durata} min",

          style: TextStyle(

            color:
                const Color(0xFF69F0AE),

            fontSize:
                isDesktop ? 13 : 11,

            fontWeight:
                FontWeight.w700,

            letterSpacing: 1.4,
          ),
        ),
      ),
    ],
  ),
),
      body: Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: maxWidth,
    ),

    child: SingleChildScrollView(
      child: Column(
    children: [

      

     BookingHeader(
  title: "DATA",
  subtitle: "Seleziona il giorno",
),

const SizedBox(height:20),


      Container(
  margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
),
  padding: const EdgeInsets.symmetric(vertical: 10),
  decoration: BoxDecoration(
  color: const Color(0xFF1A1A1A),
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: Colors.white10),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.6),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: const Color(0xFF00C853).withOpacity(0.08),
      blurRadius: 20,
    ),
  ],
),
child: Center(
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
    width: MediaQuery.of(context).size.width,
    height: 95,
        child: ScrollConfiguration(
  behavior: const ScrollBehavior().copyWith(
    dragDevices: {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse, // 👈 QUESTA È LA CHIAVE
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

    await caricaOrariOccupati();

    ascoltaOrariBloccati();
    ascoltaAppuntamentiRealtime();
  },
),
      ),
      ),
      ),
      ),
      ),

 const SizedBox(height: 4),

     BookingHeader(
  title: "PROFESSIONISTA",
  subtitle: "Seleziona il professionista",
),

const SizedBox(height: 22),

      Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: isDesktop ? 20 : 12,
runSpacing: isDesktop ? 20 : 12,
          children: operatori.map((op) {
            final sel = operatore == op["nome"];

            return AnimatedContainer(
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeOutCubic,
 width: isDesktop
    ? 240
    : isTablet
        ? 210
        : (MediaQuery.of(context).size.width / 2.45),
  margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
),

  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),

    color: sel
    ? const Color(0xFF232323)
    : const Color(0xFF1A1A1A),


    border: Border.all(
  color: sel
      ? const Color(0xFF00C853)
      : Colors.transparent,
  width: 2,
),

    boxShadow: sel
    ? [
        BoxShadow(
          color: const Color(0xFF00C853).withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ]
    : [],
  ),

  child: InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () async {
      HapticFeedback.lightImpact();

      setState(() {
        operatore = op["nome"];
        orarioSelezionato = null;
        orariOccupati = [];
        orariBloccati = [];
        giaInLista = false;
      });

      await caricaGiorniChiusi();
if (!mounted) return;
      ascoltaOrariBloccati();
      ascoltaAppuntamentiRealtime();

      await caricaOrariOccupati();
    },

    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: isDesktop ? 96 : 74,
height: isDesktop ? 96 : 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(op["img"]!),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: sel ? Colors.white : Colors.white24,
                width: 2,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            op["nome"]!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ),
);
          }).toList(),
        ),
      ),

      const SizedBox(height: 28),

BookingHeader(
  title: "ORARIO",
  subtitle: "Seleziona l'orario",
),

const SizedBox(height: 20),

      Container(
  margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF232323),
    Color(0xFF161616),
  ],
),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white12),
  ),
child: operatore == null || !giornoSelezionato
    ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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

              const SizedBox(height: 12),

              Text(
  operatore == null
      ? "Seleziona il giorno e il professionista per consultare gli orari disponibili."
      : "Seleziona un giorno dal calendario per visualizzare gli orari disponibili.",
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
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
                  color: Colors.red.withOpacity(0.10),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.25),
                  ),
                ),
                child: const Icon(
                  Icons.event_busy,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Operatore al completo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                "Non sono disponibili ulteriori orari per questa giornata.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

SizedBox(
  height:
      MediaQuery.of(context).size.height * 0.012,
),

SizedBox(
  width: double.infinity,

  child: AnimatedOpacity(
    duration: const Duration(milliseconds: 250),
    opacity: giaInLista ? 0.6 : 1,

    child: ElevatedButton(

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        padding: const EdgeInsets.symmetric(vertical: 18),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        side: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
      ),

      onPressed: giaInLista
          ? null
          : () async {

              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              // 🔥 CONTROLLO SE GIÀ PRESENTE
              final esiste = await FirebaseFirestore.instance
                  .collection('lista_attesa')
                  .where('userId', isEqualTo: user.uid)
                  .where(
                    'data',
                    isEqualTo: Timestamp.fromDate(selectedDay),
                  )
                  .get();

              // ❌ GIÀ IN LISTA
              if (esiste.docs.isNotEmpty) {

                setState(() {
                  giaInLista = true;
                });

                showGeneralDialog(
                  context: context,

                  barrierDismissible: true,
                  barrierLabel: "",

                  barrierColor: Colors.black.withOpacity(0.7),

                  transitionDuration:
                      const Duration(milliseconds: 250),

                  pageBuilder: (_, __, ___) {

                    return Center(
                      child: Material(
                        color: Colors.transparent,

                        child: Container(
                          margin: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
),

                          padding: const EdgeInsets.all(26),

                          decoration: BoxDecoration(
                            color: const Color(0xFF181818),

                            borderRadius:
                                BorderRadius.circular(24),

                            border: Border.all(
                              color: Colors.white12,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 30,
                              ),
                            ],
                          ),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [

                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 34,
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Sei già in lista d'attesa.",
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Hai già richiesto uno slot per questa giornata.",
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },

                  transitionBuilder:
                      (_, animation, __, child) {

                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );

                return;
              }

              final userDoc = await FirebaseFirestore.instance
                  .collection('utenti')
                  .doc(user.uid)
                  .get();

              // ✅ SALVA
              await FirebaseFirestore.instance
                  .collection('lista_attesa')
                  .add({

                "userId": user.uid,

                "operatore": operatore,

                "servizio": widget.servizio,

                "data": Timestamp.fromDate(selectedDay),

                "fcmToken": userDoc.data()?['fcmToken'],

                "creatoIl": Timestamp.now(),
              });

              setState(() {
                giaInLista = true;
              });

              // ✅ POPUP PREMIUM
              showGeneralDialog(
                context: context,

                barrierDismissible: true,
                barrierLabel: "",

                barrierColor: Colors.black.withOpacity(0.7),

                transitionDuration:
                    const Duration(milliseconds: 250),

                pageBuilder: (_, __, ___) {

                  return Center(
                    child: Material(
                      color: Colors.transparent,

                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 30),

                        padding: const EdgeInsets.all(26),

                        decoration: BoxDecoration(
                          color: const Color(0xFF181818),

                          borderRadius:
                              BorderRadius.circular(24),

                          border: Border.all(
                            color: Colors.white12,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 30,
                            ),
                          ],
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [

                            Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 34,
                            ),

                            SizedBox(height: 18),

                            Text(
                              "Inserito in lista d'attesa per questo giorno.✨",
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "Riceverai una notifica non appena sarà disponibile uno slot.",
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },

                transitionBuilder:
                    (_, animation, __, child) {

                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
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
          ),
        ),
      )
    : Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    // 🌅 MATTINA
    if (orariFiltrati.any((o) => o.compareTo("13:00") < 0))
      const Padding(
        padding: EdgeInsets.only(left: 6, bottom: 14),
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

    if (orariFiltrati.any((o) => o.compareTo("13:00") < 0))
      BookingTimeGrid(
  orari: orariFiltrati
      .where((o) => o.compareTo("13:00") < 0)
      .toList(),

  selected: orarioSelezionato,

  onSelect: (ora) {
    setState(() {
      orarioSelezionato = ora;
    });
  },
),

    // 🌙 POMERIGGIO
    if (orariFiltrati.any((o) => o.compareTo("13:00") >= 0))
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

    if (orariFiltrati.any((o) => o.compareTo("13:00") >= 0))
      BookingTimeGrid(
  orari: orariFiltrati
      .where((o) => o.compareTo("13:00") >= 0)
      .toList(),

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
              ? const Color(0xFF00C853)
              : Colors.grey.shade800,

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
  isDesktop ? 22 : 18,
),
          ),
        ),

        onPressed: canConfirm
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
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "CONFERMA PRENOTAZIONE",
                style: TextStyle(
  fontSize: isDesktop
      ? 15
      : isTablet
          ? 14
          : 13,

  fontWeight: FontWeight.w700,

  letterSpacing:
      isDesktop ? 1.2 : 0.3,
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
  appuntamentiSub?.cancel();
  _controller.dispose();
  _scrollController.dispose();

  super.dispose();
}

}
