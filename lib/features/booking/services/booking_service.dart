import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BookingService {

  /*static Stream<QuerySnapshot> appointmentsStream() {

    return FirebaseFirestore.instance
        .collection('appuntamenti')
        .snapshots();
  }*/

  static Future<void> createAppointment({
  required Map<String, dynamic> data,
}) async {

  final functions =
      FirebaseFunctions.instance;

  final callable =
      functions.httpsCallable(
    'createBooking',
  );

  final startAt =
      (data['data'] as Timestamp)
          .toDate();

  final endAt = startAt.add(
    Duration(
      minutes: data['durata'] ?? 30,
    ),
  );

  final dateKey =
      "${startAt.year}-"
      "${startAt.month.toString().padLeft(2, '0')}-"
      "${startAt.day.toString().padLeft(2, '0')}";

  await callable.call({

    "operatorId":
        data['operatore'],

    "dateKey":
        dateKey,
  "startAt": startAt.toUtc().toIso8601String(),

  "endAt": endAt.toUtc().toIso8601String(),

    "servizio":
        data['servizio'],

    "durata":
        data['durata'],
  });
}

static Future<void> createBookingAtomic({
  required String operatorId,
  required String serviceId,
  required DateTime startAt,
  required int durata,
  required String servizio,
  int? notification2hId,
  int? notification24hId,
}) async {

  final endAt =
      startAt.add(Duration(minutes: durata));

  final dateKey =
      "${startAt.year}-"
      "${startAt.month.toString().padLeft(2, '0')}-"
      "${startAt.day.toString().padLeft(2, '0')}";


  final callable =
      FirebaseFunctions.instance
          .httpsCallable('createBooking');

await callable.call({
  "operatorId": operatorId,
  "serviceId": serviceId,
  "dateKey": dateKey,
  "startAt": startAt.toUtc().toIso8601String(),
  "endAt": endAt.toUtc().toIso8601String(),
  "durata": durata,
  "servizio": servizio,
  "notification2hId": notification2hId,
  "notification24hId": notification24hId,
});
}

  /*static Future<bool> hasConflict({
    required DateTime giorno,
    required String ora,
    required String operatore,
  }) async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('appuntamenti')
            .where(
              'operatore',
              isEqualTo: operatore,
            )
            .where(
              'ora',
              isEqualTo: ora,
            )
            .get();

    for (var doc in snapshot.docs) {

      final d =
          (doc['data'] as Timestamp)
              .toDate();

      final stessoGiorno =
          d.year == giorno.year &&
          d.month == giorno.month &&
          d.day == giorno.day;

      if (stessoGiorno) {
        return true;
      }
    }

    return false;
  }*/
}