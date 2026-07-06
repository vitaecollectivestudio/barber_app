import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleService {
  static String dateKey(DateTime giorno) {
    return "${giorno.year}-"
        "${giorno.month.toString().padLeft(2, '0')}-"
        "${giorno.day.toString().padLeft(2, '0')}";
  }

  static Future<void> bloccaOrario({
    required DateTime giorno,
    required String operatore,
    required String ora,
  }) async {
    final operatorId = operatore.toLowerCase();
    final key = dateKey(giorno);

    await FirebaseFirestore.instance
        .collection('orari_bloccati')
        .add({
      "data": Timestamp.fromDate(giorno),
      "dateKey": key,
      "operatore": operatorId,
      "ora": ora,
    });
  }

  static Future<void> sbloccaOrario({
    required DateTime giorno,
    required String operatore,
    required String ora,
  }) async {
    final operatorId = operatore.toLowerCase();
    final key = dateKey(giorno);

    final snapshot = await FirebaseFirestore.instance
        .collection('orari_bloccati')
        .where('operatore', isEqualTo: operatorId)
        .where('dateKey', isEqualTo: key)
        .where('ora', isEqualTo: ora)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> chiudiGiorno({
    required DateTime giorno,
    required String operatore,
  }) async {
    final operatorId = operatore.toLowerCase();
    final key = dateKey(giorno);

    await FirebaseFirestore.instance
        .collection('giorni_chiusi')
        .add({
      "data": Timestamp.fromDate(giorno),
      "dateKey": key,
      "operatore": operatorId,
    });
  }

  static Future<void> riapriGiorno({
    required DateTime giorno,
    required String operatore,
  }) async {
    final operatorId = operatore.toLowerCase();
    final key = dateKey(giorno);

    final snapshot = await FirebaseFirestore.instance
        .collection('giorni_chiusi')
        .where('operatore', isEqualTo: operatorId)
        .where('dateKey', isEqualTo: key)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}