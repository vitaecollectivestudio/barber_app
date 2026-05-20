import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class UI {
  static const cardColor = Color(0xFF1E1E1E);
  static const green = Color(0xFF00C853);

  static BoxDecoration card({bool pressed = false}) {
    return BoxDecoration(
      gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1B1B1B),
    Color(0xFF111111),
  ],
),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
  color: const Color(0xFF00C853)
      .withOpacity(0.04),

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

@override
void dispose() {
  nome.dispose();
  telefono.dispose();
  super.dispose();
}

  String? servizio;
  String? orario;
  DateTime data = DateTime.now();
  DateTime selectedDay = DateTime.now();
  String? operatore;

  bool giornataChiusaLocal = false;
  bool loading = false;

  Map<String, dynamic>? servizioSelezionato;
  String? userIdSelezionato;



  final servizi = const [
  {"nome": "Taglio + Shampoo", "prezzo": "€17", "durata": 30},
  {"nome": "Barba rasata a pelle", "prezzo": "€8", "durata": 20},
  {"nome": "Barba modellata", "prezzo": "€10", "durata": 20},
  {"nome": "Taglio + Shampoo + Barba", "prezzo": "€23", "durata": 45},
  {"nome": "Taglio + Shampoo + Barba (Panno caldo)", "prezzo": "€30", "durata": 60},
  {"nome": "Radical Cut (lungo → corto)", "prezzo": "€20", "durata": 40},
];

  final orari = [
    "08:30","09:00","09:30","10:00","10:30",
    "11:00","11:30","12:00","12:30",
    "15:00","15:30","16:00","16:30",
    "17:00","17:30","18:00","18:30",
  ];

  final operatori = ["Francesco", "Antonio"];

  Future<void> salva() async {

    if (loading) return;

    if (giornataChiusaLocal) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Giornata chiusa")),
  );
  return;
}

    if (nome.text.isEmpty || servizioSelezionato == null || orario == null || operatore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compila tutto")),
      );
      return;
    }

  setState(() => loading = true);

    final durata = servizioSelezionato!["durata"];

    await FirebaseFirestore.instance.collection('appuntamenti').add({
      "nome": nome.text,
      "telefono": telefono.text,
      "userId": userIdSelezionato,
      "servizio": servizioSelezionato! ["nome"],
      "ora": orario,
      "operatore": operatore,
      "data": Timestamp.fromDate(data),
      "durata": servizioSelezionato!["durata"],
      "walkin": true, // 🔥 IMPORTANTISSIMO
    });

    if (!mounted) return;

    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

final isMobile = width < 600;
final isTablet = width >= 600 && width < 1100;
final isDesktop = width >= 1100;

final horizontalPadding =
    isMobile ? 16.0 : isTablet ? 28.0 : 40.0;

final cardWidth =
    isDesktop ? 700.0 : isTablet ? 600.0 : width;

final titleSize =
    isMobile ? 18.0 : isTablet ? 22.0 : 26.0;
    return Scaffold(
      extendBodyBehindAppBar: true,
  backgroundColor: Colors.transparent,
  appBar: PreferredSize(
  preferredSize: Size.fromHeight(
    isMobile ? 128 : 142,
  ),

  child: ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 20,
        sigmaY: 20,
      ),

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

          color: Colors.black.withOpacity(0.38),

          borderRadius: BorderRadius.circular(
            isMobile ? 28 : 34,
          ),

          border: Border.all(
  color: Colors.white.withOpacity(0.05),
  width: 1,
),

          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 40,
              offset: const Offset(0, 14),
            ),

            BoxShadow(
              color: Colors.white.withOpacity(0.03),
              blurRadius: 4,
              spreadRadius: 1,
            ),

            BoxShadow(
  color: const Color(0xFF00C853)
      .withOpacity(0.05),

  blurRadius: 26,
),
          ],
        ),

        child: SafeArea(
          top: false,
          child: Row(
            children: [

              // 🔙 BACK
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },

                child: Container(
                  width: isMobile ? 52 : 60,
                  height: isMobile ? 52 : 60,

                  decoration: BoxDecoration(

                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1C1C1C),
                        Color(0xFF111111),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),

                    boxShadow: [

                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),

                      BoxShadow(
                        color: Colors.white.withOpacity(0.015),
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 🧠 TITLE
              Expanded(
                child: AnimatedContainer(

  duration: const Duration(milliseconds: 350),

  curve: Curves.easeOutCubic,

  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(

                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37)
                                .withOpacity(0.18),

                            const Color(0xFFFFD54F)
                                .withOpacity(0.08),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(30),

                        border: Border.all(
                          color: const Color(0xFFFFD54F)
                              .withOpacity(0.18),
                        ),
                      ),

                      child: const Text(
                        "WALK-IN",

                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Nuova Prenotazione",

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Inserisci prenotazione manuale",

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
  Color(0xFF111111),
  Color(0xFF181818),
  Color(0xFF222222),
  Color(0xFF2A2A2A),
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

// 🔥 GLOW ROSSO
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
    padding: EdgeInsets.all(horizontalPadding),

    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: cardWidth,
        ),

        child: Container(
  padding: EdgeInsets.symmetric(
    horizontal: isMobile ? 18 : 28,
    vertical: isMobile ? 22 : 34,
  ),

  decoration: BoxDecoration(

gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(0.03),
    Colors.white.withOpacity(0.015),
  ],
),
    borderRadius: BorderRadius.circular(
      isMobile ? 32 : 40,
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



const SizedBox(height: 20),
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),

  decoration: BoxDecoration(

    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.03),
      ],
    ),

    borderRadius: BorderRadius.circular(30),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),
  ),

  child: Text(
    "SELEZIONA DATA",

    style: TextStyle(
      color: Colors.white,
      fontSize: isMobile ? 12 : 14,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  ),
),

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
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF101010),
      ],
    ),

    borderRadius: BorderRadius.circular(
      isMobile ? 34 : 40,
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.04),
    ),

    boxShadow: [

      BoxShadow(
        color: Colors.black.withOpacity(0.40),
        blurRadius: 45,
        offset: const Offset(0, 24),
      ),

      BoxShadow(
        color: Colors.white.withOpacity(0.02),
        blurRadius: 4,
        spreadRadius: 1,
      ),

      BoxShadow(
        color: const Color(0xFF00C853)
            .withOpacity(0.05),
        blurRadius: 32,
      ),
    ],
  ),

  child: TableCalendar(

    locale: 'it_IT',

    firstDay: DateTime.now(),

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

      headerPadding: EdgeInsets.only(
        bottom: isMobile ? 22 : 30,
      ),

      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: isMobile ? 18 : 24,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),

      leftChevronIcon: Container(
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),

          borderRadius:
              BorderRadius.circular(18),
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

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: const Icon(
          Icons.chevron_right,
          color: Colors.white,
        ),
      ),
    ),

    daysOfWeekStyle: DaysOfWeekStyle(

      weekdayStyle: TextStyle(
        color:
            Colors.white.withOpacity(0.55),

        fontWeight: FontWeight.w700,

        fontSize: 12,

        letterSpacing: 1,
      ),

      weekendStyle: TextStyle(
        color:
            Colors.white.withOpacity(0.25),
      ),
    ),

    calendarStyle: const CalendarStyle(

      outsideDaysVisible: false,

      defaultDecoration:
          BoxDecoration(
        color: Colors.transparent,
      ),

      todayDecoration:
          BoxDecoration(
        color: Colors.transparent,
      ),

      selectedDecoration:
          BoxDecoration(
        color: Colors.transparent,
      ),

      defaultTextStyle:
          TextStyle(color: Colors.white),

      weekendTextStyle:
          TextStyle(color: Colors.white),
    ),

    onDaySelected: (day, focusedDay) {

      final today = DateTime.now();

      final isPast = day.isBefore(
        DateTime(
          today.year,
          today.month,
          today.day,
        ),
      );

      if (isPast) return;

      if (day.weekday == 7) return;

      setState(() {

        selectedDay = day;

        data = day;

        orario = null;
      });
    },

    calendarBuilders: CalendarBuilders(

      defaultBuilder:
          (context, day, focusedDay) {

        final isSelected =
            isSameDay(day, selectedDay);

        final domenica =
            day.weekday == 7;

        final today = DateTime.now();

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
              borderRadius:
                  BorderRadius.circular(18),

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

          duration:
              const Duration(milliseconds: 220),

          margin: const EdgeInsets.all(6),

          decoration: BoxDecoration(

            borderRadius:
                BorderRadius.circular(20),

            gradient: isSelected

                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      Color(0xFF00C853),
                      Color(0xFF009624),
                    ],
                  )

                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      Color(0xFF262626),
                      Color(0xFF1A1A1A),
                    ],
                  ),

            border: Border.all(
              color: isSelected
                  ? Colors.white
                      .withOpacity(0.18)
                  : Colors.white
                      .withOpacity(0.04),
            ),

            boxShadow: [

              BoxShadow(
                color: Colors.black
                    .withOpacity(0.35),

                blurRadius: 12,

                offset:
                    const Offset(0, 6),
              ),

              if (isSelected)

                BoxShadow(
                  color:
                      const Color(0xFF00C853)
                          .withOpacity(0.45),

                  blurRadius: 26,
                ),
            ],
          ),

          child: Center(
            child: Text(
              "${day.day}",

              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w800,

                fontSize:
                    isMobile ? 14 : 16,
              ),
            ),
          ),
        );
      },
    ),
  ),
),

const SizedBox(height: 20),


StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('utenti').snapshots(),
  builder: (context, snapshot) {

    if (!snapshot.hasData) return const SizedBox();

final clienti = snapshot.data!.docs.toList()
  ..sort((a, b) {
    final dataA = a.data() as Map<String, dynamic>;
    final dataB = b.data() as Map<String, dynamic>;

    final nomeA = (dataA['nome'] ?? "").toString().toLowerCase();
    final nomeB = (dataB['nome'] ?? "").toString().toLowerCase();

    return nomeA.compareTo(nomeB);
  });


    return AnimatedContainer(

  duration: const Duration(milliseconds: 220),

  margin: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 8,
  ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
            final data = doc.data() as Map<String, dynamic>;

            return DropdownMenuItem(
              value: doc.id,
              child: Text(
  "${data['nome'] ?? ""} ${data['cognome'] ?? ""}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            final selected = clienti.firstWhere((c) => c.id == value);
            final data = selected.data() as Map<String, dynamic>;

            setState(() {
              userIdSelezionato = value as String;
              nome.text = "${data['nome'] ?? ""} ${data['cognome'] ?? ""}".trim();
              telefono.text = data['telefono'] ?? "";
            });
          },
        ),
      ),
    );
  },
),

const SizedBox(height: 20),

if (userIdSelezionato != null)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    child: Row(
      children: [

        // ✅ BADGE
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
  colors: [
    const Color(0xFF00C853).withOpacity(0.20),
    const Color(0xFF00C853).withOpacity(0.08),
  ],
),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00C853)),
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
        GestureDetector(
          onTap: () {
            setState(() {
              userIdSelezionato = null;
              nome.clear();
              telefono.clear();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.redAccent.withOpacity(0.1),
              border: Border.all(color: Colors.redAccent),
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
      ],
    ),
  ),

const SizedBox(height: 20),


            Container(
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  decoration: UI.card(),
  child: TextField(
    controller: nome,
    enabled: userIdSelezionato == null,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(

  filled: true,
  fillColor: Colors.transparent,

  hintText: "Nome cliente",

  hintStyle: TextStyle(
    color: Colors.white.withOpacity(0.35),
  ),

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
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  decoration: UI.card(),
  child: TextField(
    controller: telefono,
    enabled: userIdSelezionato == null,
    keyboardType: TextInputType.phone,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(

  filled: true,
  fillColor: Colors.transparent,

  hintText: "Telefono",

  hintStyle: TextStyle(
    color: Colors.white.withOpacity(0.35),
  ),

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

const SizedBox(height: 18),

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),

  decoration: BoxDecoration(

    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.03),
      ],
    ),

    borderRadius: BorderRadius.circular(30),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),
  ),

  child: Text(
    "SERVIZI",

    style: TextStyle(
      color: Colors.white,
      fontSize: isMobile ? 12 : 14,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  ),
),
const SizedBox(height: 18),
            ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: servizi.length,
    itemBuilder: (context, i) {
      final s = servizi[i];
      final selezionato = servizioSelezionato == s;

      return GestureDetector(
        onTap: () {
  setState(() {
    servizioSelezionato = s;
    orario = null; // 🔥 RESET
  });
},
        child: AnimatedScale(
  scale: selezionato ? 0.97 : 1,
  duration: const Duration(milliseconds: 140),

  child: Container(
          margin: EdgeInsets.all(
  isMobile ? 8 : 12,
),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(

  gradient: selezionato
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1F1F),
            Color(0xFF121212),
          ],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),

  borderRadius: BorderRadius.circular(24),

  border: Border.all(
    color: selezionato
        ? const Color(0xFF00C853)
            .withOpacity(0.18)
        : Colors.white.withOpacity(0.04),
  ),

  boxShadow: [

    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),

    if (selezionato)
      BoxShadow(
        color: const Color(0xFF00C853)
            .withOpacity(0.12),

        blurRadius: 24,
      ),
  ],
),


          child: Row(
            children: [
              Container(
  padding: const EdgeInsets.all(10),

  decoration: BoxDecoration(

    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.03),
      ],
    ),

    borderRadius: BorderRadius.circular(14),

    border: Border.all(
      color: Colors.white.withOpacity(0.05),
    ),
  ),

  child: const Icon(
    Icons.content_cut_rounded,
    color: Colors.white,
    size: 18,
  ),
),
              const SizedBox(width: 16),

              Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      Text(
        s["nome"] as String,

        style: TextStyle(
          color: Colors.white,

          fontWeight: FontWeight.w700,

          fontSize:
              isMobile ? 14 : 16,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        "${s["durata"]} MIN",

        style: TextStyle(
          color:
              Colors.white.withOpacity(0.38),

          fontSize: 11,

          letterSpacing: 1.2,

          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
),

              Text(
                s["prezzo"] as String,
                style: TextStyle(
  color: const Color(0xFF00C853),

  fontWeight: FontWeight.w800,

  fontSize: isMobile ? 16 : 18,

  letterSpacing: 0.4,
),
              ),
            ],
          ),
        ),
        ),
      );
    },
  ),


const SizedBox(height: 20),


            const SizedBox(height: 20),
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),

  decoration: BoxDecoration(

    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.03),
      ],
    ),

    borderRadius: BorderRadius.circular(30),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),
  ),

  child: Text(
    "BARBER",

    style: TextStyle(
      color: Colors.white,
      fontSize: isMobile ? 12 : 14,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  ),
),

const SizedBox(height: 18),
Wrap(
  alignment: WrapAlignment.center,
  spacing: 10,
  runSpacing: 10,
  children: operatori.map((o) {

    final selezionato = operatore == o;

    return GestureDetector(
      onTap: () {
  setState(() {
    operatore = o;
    orario = null; // 🔥 RESET
  });
},
      child: AnimatedScale(
        scale: selezionato ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: selezionato
    ? const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1F1F1F),
          Color(0xFF121212),
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
            borderRadius: BorderRadius.circular(18),

            border: selezionato
                ? Border.all(color: UI.green, width: 1.5)
                : Border.all(color: Colors.white.withOpacity(0.08)),

            boxShadow: selezionato
                ? [
                    BoxShadow(
                      color: UI.green.withOpacity(0.5),
                      blurRadius: 20,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                o,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selezionato ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }).toList(),
),

const SizedBox(height: 20),

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  ),

  decoration: BoxDecoration(

    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.03),
      ],
    ),

    borderRadius: BorderRadius.circular(30),

    border: Border.all(
      color: Colors.white.withOpacity(0.06),
    ),
  ),

  child: Text(
    "ORARI DISPONIBILI",

    style: TextStyle(
      color: Colors.white,
      fontSize: isMobile ? 12 : 14,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  ),
),

const SizedBox(height: 18),

            StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('giorni_chiusi')
      .snapshots(),
  builder: (context, snapshot) {

    if (!snapshot.hasData) return const SizedBox();

    final chiusiDocs = snapshot.data!.docs;

    final giornataChiusaLocal = chiusiDocs.any((doc) {
  final d = (doc['data'] as Timestamp).toDate();

  return d.year == data.year &&
      d.month == data.month &&
      d.day == data.day &&
      doc['operatore'] == operatore;
});

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orari_bloccati')
          .snapshots(),
      builder: (context, snapshotBlocchi) {

        if (!snapshotBlocchi.hasData) return const SizedBox();

        final bloccatiDocs = snapshotBlocchi.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appuntamenti')
              .snapshots(),
          builder: (context, snapshot2) {

            if (!snapshot2.hasData) return const SizedBox();

            final docs = snapshot2.data!.docs;

        
            final orariDisponibili = orari.where((o) {

    // ❌ Domenica chiuso
if (data.weekday == 7) {
  return false;
}
              // ❌ Lunedì pomeriggio chiuso
if (data.weekday == 1 &&
    o.compareTo("13:00") >= 0) {
  return false;
}
              final isBloccato = bloccatiDocs.any((doc) {
                final d = (doc['data'] as Timestamp).toDate();

                return d.year == data.year &&
                    d.month == data.month &&
                    d.day == data.day &&
                    doc['operatore'] == operatore &&
                    doc['ora'] == o;
              });

              if (isBloccato) return false;
              if (giornataChiusaLocal) return false;

              final durata = servizioSelezionato?["durata"] ?? 30;

              final parts = o.split(":");

              final startNuovo = DateTime(
                data.year,
                data.month,
                data.day,
                int.parse(parts[0]),
                int.parse(parts[1]),
              );

              final endNuovo = startNuovo.add(Duration(minutes: durata));

              for (var doc in docs) {
                final d = (doc['data'] as Timestamp).toDate();

                if (d.year != data.year ||
                    d.month != data.month ||
                    d.day != data.day ||
                    doc['operatore'] != operatore) continue;

                final partsEs = doc['ora'].split(":");

                final startEsistente = DateTime(
                  d.year,
                  d.month,
                  d.day,
                  int.parse(partsEs[0]),
                  int.parse(partsEs[1]),
                );

                final endEsistente =
                    startEsistente.add(Duration(minutes: doc['durata'] ?? 30));

                final overlap =
                    startNuovo.isBefore(endEsistente) &&
                    endNuovo.isAfter(startEsistente);

                if (overlap) return false;
              }

              final now = DateTime.now();

              final oggi =
                  data.year == now.year &&
                  data.month == now.month &&
                  data.day == now.day;

              if (oggi) {
                if (!startNuovo.isAfter(now.add(const Duration(minutes: 5)))) {
                  return false;
                }
              }

              return true;

            }).toList();

            if (operatore == null) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Seleziona un operatore",
                  style: TextStyle(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (servizioSelezionato == null) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Seleziona un servizio",
                  style: TextStyle(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              );
            }



            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: orariDisponibili.map((o) {

                final selezionato = orario == o;

                return GestureDetector(
                  onTap: () {
                    if (giornataChiusaLocal) return;

                    setState(() {
                      orario = o;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
  horizontal: isMobile ? 12 : 18,
  vertical: isMobile ? 10 : 14,
),
                    decoration: BoxDecoration(

  gradient: selezionato
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1F1F),
            Color(0xFF121212),
          ],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),

  borderRadius: BorderRadius.circular(20),

  border: Border.all(
    color: selezionato
        ? const Color(0xFF00C853)
            .withOpacity(0.25)
        : Colors.white.withOpacity(0.05),
  ),

  boxShadow: [

    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),

    if (selezionato)
      BoxShadow(
        color: const Color(0xFF00C853)
            .withOpacity(0.16),

        blurRadius: 18,
      ),
  ],
),
                    child: Text(
                      o,
                      style: TextStyle(
  color: Colors.white,
  fontSize: isMobile ? 13 : 15,
),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  },
),

            const SizedBox(height: 20),

            GestureDetector(
  onTap: (nome.text.isNotEmpty &&
        servizioSelezionato != null &&
        orario != null &&
        operatore != null &&
        !giornataChiusaLocal &&
        !loading)
    ? salva
    : null,
  child: AnimatedScale(
  scale: 1,
  duration: const Duration(milliseconds: 120),
  child: Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.symmetric(
  vertical: isMobile ? 16 : 20,
),
    decoration: BoxDecoration(

  gradient: (nome.text.isNotEmpty &&
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
    color: (nome.text.isNotEmpty &&
            servizioSelezionato != null &&
            orario != null &&
            operatore != null &&
            !giornataChiusaLocal)
        ? const Color(0xFF00C853)
            .withOpacity(0.15)
        : Colors.white.withOpacity(0.03),
  ),

  boxShadow: [

    BoxShadow(
      color: Colors.black.withOpacity(0.45),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),

    if (nome.text.isNotEmpty &&
        servizioSelezionato != null &&
        orario != null &&
        operatore != null &&
        !giornataChiusaLocal)
      BoxShadow(
        color: const Color(0xFF00C853)
            .withOpacity(0.10),

        blurRadius: 22,
      ),
  ],
),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
  padding: const EdgeInsets.all(8),

  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white.withOpacity(0.06),
  ),

  child: const Icon(
    Icons.check_rounded,
    color: Colors.white,
    size: 18,
  ),
),
        SizedBox(width: 10),
        Text(
          "SALVA PRENOTAZIONE",
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