import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {

  static Stream<QuerySnapshot> appointmentsStream() {

    return FirebaseFirestore.instance
        .collection('appuntamenti')
        .snapshots();
  }

  static Future<DocumentReference>
    createAppointment({
    required Map<String, dynamic> data,
  }) async {

   return await FirebaseFirestore.instance
        .collection('appuntamenti')
        .add(data);
  }

  static Future<bool> hasConflict({
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
  }
}