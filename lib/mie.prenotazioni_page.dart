import 'package:barber_app/main.dart';
import 'package:flutter/material.dart';
import 'app_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barber_app/core/responsive/responsive_utils.dart';
import 'dart:ui';

class MiePrenotazioniPage extends StatelessWidget {
  const MiePrenotazioniPage({super.key});

  // 🔥 MODIFICA PRENOTAZIONE CON BLOCCO ORARI
  void mostraModifica(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final isDesktop =
    Responsive.isDesktop(context);

final isTablet =
    Responsive.isTablet(context);
    final orari = [
      "08:30","09:00","09:30","10:00","10:30",
      "11:00","11:30","12:00","12:30",
      "15:00","15:30","16:00","16:30",
      "17:00","17:30","18:00","18:30",
    ];

    showGeneralDialog(
      barrierDismissible: true,
barrierLabel: "Modifica",
barrierColor: Colors.black.withOpacity(0.7),
transitionDuration: const Duration(milliseconds: 250),
      context: context,
      pageBuilder: (_, __, ___) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('appuntamenti')
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final dataPren = (data['data'] as Timestamp).toDate();

            // 🔥 ORARI OCCUPATI NELLO STESSO GIORNO
            final oraAttuale = data['ora'];

final occupati = docs.where((doc) {
  final d = (doc['data'] as Timestamp).toDate();

  return d.year == dataPren.year &&
      d.month == dataPren.month &&
      d.day == dataPren.day;
}).map((doc) => doc['ora'] as String).toList();

            return Center(
  child: Material(
    color: Colors.transparent,
    child: Container(
      margin: EdgeInsets.symmetric(
  horizontal:
      isDesktop
          ? 120
          : isTablet
              ? 70
              : 24,
),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Modifica orario prenotato",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


Text(
  "Seleziona un nuovo orario disponibile per questo giorno",
  textAlign: TextAlign.center,
  style: TextStyle(
    color: Colors.white54,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  ),
),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: orari.map((ora) {

                      // 🔥 LUNEDÌ SOLO MATTINA
if (dataPren.weekday == 1 && ora.compareTo("13:00") >= 0) {
  return const SizedBox.shrink();
}

                      final occupato = occupati.contains(ora);
final selezionato = ora == oraAttuale;

                      return GestureDetector(
                        onTap: occupato
    ? null
    : () async {

        final bookingId = docId.hashCode;

        // 🔔 CANCELLA VECCHIE NOTIFICHE
        await flutterLocalNotificationsPlugin.cancel(bookingId + 1);
        await flutterLocalNotificationsPlugin.cancel(bookingId + 2);

        // 🔥 AGGIORNA ORARIO
        await FirebaseFirestore.instance
            .collection('appuntamenti')
            .doc(docId)
            .update({
          "ora": ora,
        });

        // 🔥 RICREA NUOVE NOTIFICHE

        final dataPren = (data['data'] as Timestamp).toDate();

        final nuovaDataCompleta = DateTime(
          dataPren.year,
          dataPren.month,
          dataPren.day,
          int.parse(ora.split(":")[0]),
          int.parse(ora.split(":")[1]),
        );

        final twoHoursBefore =
            nuovaDataCompleta.subtract(const Duration(hours: 2));
        final oneDayBefore =
            nuovaDataCompleta.subtract(const Duration(hours: 24));

        if (twoHoursBefore.isAfter(DateTime.now())) {
          await scheduleNotification(
            bookingId + 1,
            "Promemoria appuntamento",
            "Hai un appuntamento tra 2 ore.",
            twoHoursBefore,
          );
        }

        if (oneDayBefore.isAfter(DateTime.now())) {
          await scheduleNotification(
            bookingId + 2,
            "Promemoria appuntamento",
            "Hai un appuntamento domani.",
            oneDayBefore,
          );
        }

if (context.mounted) {
  Navigator.pop(context);
}
      },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
color: selezionato
    ? const Color(0xFF00C853)
    : occupato
        ? const Color(0xFF1E1E1E)
        : const Color(0xFF111111),
      borderRadius: BorderRadius.circular(10),
  border: Border.all(
color: occupato
    ? Colors.white10
    : const Color.fromARGB(255, 125, 145, 133),
        width: 1.5,
  ),
),
                          child: Text(
                            ora,
                            style: TextStyle(
                              color: selezionato
    ? Colors.black
    : occupato
        ? Colors.white24
        : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
final isMobile =
    Responsive.isMobile(context);

final isTablet =
    Responsive.isTablet(context);

final isDesktop =
    Responsive.isDesktop(context);

final horizontalPadding =
    Responsive.horizontalPadding(context);

final maxWidth =
    Responsive.maxContentWidth(context);
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Non sei loggato"),
        ),
      );
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

  toolbarHeight:
      Responsive.isDesktop(context)
          ? 90
          : Responsive.isTablet(context)
              ? 82
              : 74,

  flexibleSpace: ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 18,
        sigmaY: 18,
      ),

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

          width:
              Responsive.isDesktop(context)
                  ? 52
                  : 46,

          height:
              Responsive.isDesktop(context)
                  ? 52
                  : 46,

          decoration: BoxDecoration(

            color:
                Colors.white.withOpacity(0.06),

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color:
                  Colors.white.withOpacity(0.08),
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
  ),

  title: Column(

    mainAxisAlignment:
        MainAxisAlignment.center,

    children: [

      Container(

        padding: EdgeInsets.symmetric(

          horizontal:
              Responsive.isDesktop(context)
                  ? 14
                  : 12,

          vertical:
              Responsive.isDesktop(context)
                  ? 5
                  : 4,
        ),

        decoration: BoxDecoration(

          color:
              const Color(0xFF00C853)
                  .withOpacity(0.12),

          borderRadius:
              BorderRadius.circular(30),

          border: Border.all(
            color:
                const Color(0xFF00C853)
                    .withOpacity(0.25),
          ),
        ),

        child: Text(

          "AREA CLIENTE",

          style: TextStyle(

            color:
                const Color(0xFF69F0AE),

            fontSize:
                Responsive.isDesktop(context)
                    ? 13
                    : 11,

            fontWeight:
                FontWeight.w700,

            letterSpacing: 1.8,
          ),
        ),
      ),

      SizedBox(
        height:
            Responsive.isDesktop(context)
                ? 6
                : 4,
      ),

      Text(

        "Le tue prenotazioni",

        style: TextStyle(

          color: Colors.white,

          fontSize:
              Responsive.isDesktop(context)
                  ? 22
                  : Responsive.isTablet(context)
                      ? 20
                      : 17,

          fontWeight:
              FontWeight.w700,
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

  final data = (doc['data'] as Timestamp).toDate();
  final ora = doc['ora'];

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

  final da = (a['data'] as Timestamp).toDate();
  final db = (b['data'] as Timestamp).toDate();

  final oraA = a['ora'];
  final oraB = b['ora'];

  final partsA = oraA.split(":");
  final partsB = oraB.split(":");

  final dataA = DateTime(
    da.year,
    da.month,
    da.day,
    int.parse(partsA[0]),
    int.parse(partsA[1]),
  );

  final dataB = DateTime(
    db.year,
    db.month,
    db.day,
    int.parse(partsB[0]),
    int.parse(partsB[1]),
  );

  return dataA.compareTo(dataB);
});

          if (docs.isEmpty) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),

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
physics:
    const BouncingScrollPhysics(),
 padding: EdgeInsets.fromLTRB(
  horizontalPadding,
  14,
  horizontalPadding,
  MediaQuery.of(context)
          .padding
          .bottom +
      30,
),
  itemCount: docs.length,

  itemBuilder: (context, index) {

    final doc = docs[index];

    final data =
        doc.data() as Map<String, dynamic>;

    final dataPren =
        (data['data'] as Timestamp).toDate();

    const giorni = [
      "Lunedì","Martedì","Mercoledì",
      "Giovedì","Venerdì","Sabato","Domenica"
    ];

    const mesi = [
      "Gennaio","Febbraio","Marzo","Aprile",
      "Maggio","Giugno","Luglio","Agosto",
      "Settembre","Ottobre","Novembre","Dicembre"
    ];

    final giorno =
        giorni[dataPren.weekday - 1];

    final mese =
        mesi[dataPren.month - 1];

    return Container(
      margin: EdgeInsets.symmetric(
  vertical: 10,
),
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
    colors: [
      Color(0xFF232323),
      Color(0xFF161616),
    ],
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
      color: const Color(0xFF00C853)
          .withOpacity(0.05),
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
        color: const Color(0xFF00C853)
            .withOpacity(0.08),
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

              Container(

  margin: const EdgeInsets.only(top: 6),

  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 7,
  ),

  decoration: BoxDecoration(

    color: Colors.white.withOpacity(0.04),

    borderRadius: BorderRadius.circular(10),

    border: Border.all(
      color: Colors.white.withOpacity(0.04),
    ),
  ),

  child: Text(

    "$giorno ${dataPren.day} $mese • ${data['ora']}",

    style: const TextStyle(
      color: Colors.white70,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
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
              mostraModifica(context, doc.id, data);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00C853).withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Cancella prenotazione",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Questa operazione eliminerà definitivamente l’appuntamento.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [

                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Annulla",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {

                                  final bookingId = doc.id.hashCode;

                                  await flutterLocalNotificationsPlugin.cancel(bookingId + 1);
                                  await flutterLocalNotificationsPlugin.cancel(bookingId + 2);

                                  await FirebaseFirestore.instance
                                      .collection('appuntamenti')
                                      .doc(doc.id)
                                      .delete();
if (dialogContext.mounted) {
  Navigator.of(dialogContext).pop();
}
                                },
                                child: const Text(
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
                mainAxisAlignment: MainAxisAlignment.center,
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