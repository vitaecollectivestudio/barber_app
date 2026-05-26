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
import 'package:barber_app/features/admin/widgets/dialogs/appointment_details_dialog.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();



class BarberPanelPage extends StatefulWidget {
  const BarberPanelPage({super.key});

  @override
  State<BarberPanelPage> createState() => _BarberPanelPageState();
}

class _BarberPanelPageState extends State<BarberPanelPage> {

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





  @override
  Widget build(BuildContext context) {
    final width = Responsive.width(context);
final isMobile = Responsive.isMobile(context);

final isTablet = Responsive.isTablet(context);

final isDesktop = Responsive.isDesktop(context);

final orari = selectedDay.weekday == 1
    ? ScheduleConstants.mondaySlots
    : ScheduleConstants.standardSlots;
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

        colors: [

          Colors.white.withOpacity(0.85),

          Colors.transparent,
        ],
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

      color:
          Colors.white.withOpacity(0.07),
    ),

    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 180,
        sigmaY: 180,
      ),

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

      color:
          Colors.white.withOpacity(0.05),
    ),

    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 160,
        sigmaY: 160,
      ),

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

  currentDate:
      formatDataBella(selectedDay),

  onClientsTap: () {
    Navigator.of(context).push(

  PageRouteBuilder(

    transitionDuration:
        const Duration(milliseconds: 260),

    reverseTransitionDuration:
        const Duration(milliseconds: 220),

    pageBuilder:
        (_, animation, __) {

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

    transitionDuration:
        const Duration(milliseconds: 260),

    reverseTransitionDuration:
        const Duration(milliseconds: 220),

    pageBuilder:
        (_, animation, __) {

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
  physics:
      const BouncingScrollPhysics(),
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
  height:
      isDesktop
          ? 230
          : isTablet
              ? 190
              : 165,
),

        
OperatorSelector(
  isMobile: isMobile,
  isTablet: isTablet,

  operators: operatori,

  selectedOperator: filtro,

  onSelected: (value) {
    setState(() {
      filtro = value;
    });
  },
),


SizedBox(
  height:
      isDesktop
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
        stream: AppointmentsService
    .appointmentsStream(),
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

       final filteredAppointments =
    ordinati.where((doc) {

  if (doc['data'] == null) {
    return false;
  }

  final d =
      (doc['data'] as Timestamp)
          .toDate();

  final sameDay =
      d.year == selectedDay.year &&
      d.month == selectedDay.month &&
      d.day == selectedDay.day;

  if (!sameDay) return false;

  if (filtro == "Tutti") {
    return true;
  }

  return doc['operatore'] == filtro;

}).toList();        

                
    return SizedBox(
      width: double.infinity,

      child: ConstrainedBox(
  constraints: const BoxConstraints(),

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
                    PremiumCalendar(
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
    fontSize: isMobile
    ? 15
    : isTablet
        ? 22
        : 28,
    fontWeight: FontWeight.w900,
    letterSpacing:
    isMobile ? 1.2 : 3,
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
        margin: EdgeInsets.all(
  isDesktop ? 10 : isTablet ? 8 : 6,
),
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
              fontSize: isDesktop
    ? 18
    : isTablet
        ? 16
        : 14,
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

    blurRadius: 18,
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
  child: CloseDayButton(

  giornataChiusa: giornataChiusa,

  onTap: () async {

    if (filtro == "Tutti") {

      premiumPopup(
        context: context,
        title: "SELEZIONA OPERATORE",
        subtitle:
            "Devi selezionare un operatore.",
        icon: Icons.person_outline_rounded,
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

SizedBox(
  height: isMobile ? 20 : 26,
),

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
  children: filteredAppointments.isEmpty
    ? [
        AppointmentsEmptyState(
  isMobile: isMobile,
  isTablet: isTablet,
  isDesktop: isDesktop,
),
      ]
  : [
    AppointmentsRealtimeList(
    children: filteredAppointments.map((d) {

 final data =
    d.data() as Map<String, dynamic>;

      return AppointmentCard(

        isMobile: isMobile,

        data: data,

        index:
            ordinati.where((doc) {

          if (doc['data'] == null) {
            return false;
          }

          final dd =
              (doc['data'] as Timestamp)
                  .toDate();

          final sameDay =
              dd.year == selectedDay.year &&
              dd.month == selectedDay.month &&
              dd.day == selectedDay.day;

          if (!sameDay) return false;

          if (filtro == "Tutti") {
            return true;
          }

          return doc['operatore']
              == filtro;

        }).toList().indexOf(d) + 1,

        onTap: () {

          showDialog(
            context: context,

            barrierColor: Colors.transparent,

            builder: (_) =>
                AppointmentDetailsDialog(

              isMobile: isMobile,

              data: data,

              formattedDate:
                  formatDataBella(
                (data['data'] as Timestamp)
                    .toDate(),
              ),
            ),
          );
        },

        onDelete: () async {

          await AppointmentsService
    .deleteAppointment(d.id);
        },

        infoChips:

    isMobile

        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: [

                PremiumInfoChip(
                  icon: Icons.access_time_rounded,
                  text: "${data['ora']}",
                ),

                const SizedBox(width: 8),

                PremiumInfoChip(
                  icon: Icons.person_outline,
                  text: "${data['operatore']}",
                ),

                const SizedBox(width: 8),

                PremiumInfoChip(
                  icon: Icons.timelapse,
                  text:
                      "${data['durata'] ?? 30} min",
                ),
              ],
            ),
          )

        : Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [

              PremiumInfoChip(
                icon: Icons.access_time_rounded,
                text: "${data['ora']}",
              ),

              PremiumInfoChip(
                icon: Icons.person_outline,
                text:
                    "${data['operatore']}",
              ),

              PremiumInfoChip(
                icon: Icons.timelapse,
                text:
                    "${data['durata'] ?? 30} min",
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
     
SizedBox(
  height: isMobile ? 20 : 26,
),



SizedBox(
  height: isMobile ? 20 : 26,
),




ScheduleManagementSection(
  child: Column(
    
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
const ScheduleHeader(),

SizedBox(
  height: isMobile ? 22 : 30,
),



      SingleChildScrollView(
  child: Wrap(
  alignment: WrapAlignment.center,
  runAlignment: WrapAlignment.center,
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: isMobile ? 10 : 14,
  runSpacing: isMobile ? 10 : 14,
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

    final orariBloccati = lista;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isMobile ? 10 : 14,
runSpacing: isMobile ? 10 : 14,
      children: orari.map((ora) {
        final now = DateTime.now();

final slotHour =
    int.parse(ora.split(":")[0]);

final slotMinute =
    int.parse(ora.split(":")[1]);

final slotDateTime = DateTime(
  selectedDay.year,
  selectedDay.month,
  selectedDay.day,
  slotHour,
  slotMinute,
);

final isToday =
    selectedDay.year == now.year &&
    selectedDay.month == now.month &&
    selectedDay.day == now.day;

// ❌ NASCONDI ORARI PASSATI
if (isToday &&
    slotDateTime.isBefore(now)) {

  return const SizedBox.shrink();
}

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

        return ScheduleSlotCard(

  isMobile: isMobile,

  occupato: occupato,

  isBloccato: isBloccato,

  ora: ora,

  onTap: occupato
      ? null
      : () async {

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

            await ScheduleService.sbloccaOrario(
  giorno: selectedDay,
  operatore: filtro,
  ora: ora,
);

            premiumPopup(
              context: context,
              title: "ORARIO SBLOCCATO",
              subtitle:
                  "$ora nuovamente disponibile.",
              icon: Icons.lock_open_rounded,
              color: const Color(0xFF00C853),
            );

          } else {

            await ScheduleService.bloccaOrario(
  giorno: selectedDay,
  operatore: filtro,
  ora: ora,
);
          }
        },
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
      MediaQuery.of(context)
              .padding
              .bottom +
          36,
),




                    // 👇 LISTA
                    
              ],
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