import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleService {

  static Future<void> bloccaOrario({
    required DateTime giorno,
    required String operatore,
    required String ora,
  }) async {

    await FirebaseFirestore.instance
        .collection('orari_bloccati')
        .add({

      "data": Timestamp.fromDate(giorno),
      "operatore": operatore,
      "ora": ora,
    });
  }

  static Future<void> sbloccaOrario({
    required DateTime giorno,
    required String operatore,
    required String ora,
  }) async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('orari_bloccati')
            .where(
              'ora',
              isEqualTo: ora,
            )
            .where(
              'operatore',
              isEqualTo: operatore,
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
        await doc.reference.delete();
      }
    }
  }

  static Future<void> chiudiGiorno({
    required DateTime giorno,
    required String operatore,
  }) async {

    await FirebaseFirestore.instance
        .collection('giorni_chiusi')
        .add({

      "data": Timestamp.fromDate(giorno),
      "operatore": operatore,
    });
  }

  static Future<void> riapriGiorno({
    required DateTime giorno,
    required String operatore,
  }) async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('giorni_chiusi')
            .where(
              'operatore',
              isEqualTo: operatore,
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
        await doc.reference.delete();
      }
    }
  }
}