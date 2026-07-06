import 'package:cloud_firestore/cloud_firestore.dart';

class WaitlistService {
  static String dateKey(DateTime giorno) {
    return "${giorno.year}-"
        "${giorno.month.toString().padLeft(2, '0')}-"
        "${giorno.day.toString().padLeft(2, '0')}";
  }

  static Future<bool> alreadyInWaitlist({
    required String userId,
    required DateTime giorno,
    required String? operatore,
    required String servizio,
  }) async {
    if (operatore == null) return false;

    final snapshot = await FirebaseFirestore.instance
        .collection('lista_attesa')
        .where('userId', isEqualTo: userId)
        .where('dateKey', isEqualTo: dateKey(giorno))
        .where('operatore', isEqualTo: operatore.toLowerCase())
        .where('servizio', isEqualTo: servizio)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<void> addToWaitlist({
    required String userId,
    required String? operatore,
    required String servizio,
    required DateTime giorno,
    required String? fcmToken,
  }) async {
    if (operatore == null) {
      throw Exception("Operatore mancante");
    }

    await FirebaseFirestore.instance.collection('lista_attesa').add({
      "userId": userId,
      "operatore": operatore.toLowerCase(),
      "servizio": servizio,
      "data": Timestamp.fromDate(giorno),
      "dateKey": dateKey(giorno),
      "fcmToken": fcmToken, // lo teniamo per compatibilità, ma il backend leggerà utenti/{userId}
      "notified": false,
      "creatoIl": FieldValue.serverTimestamp(),
    });
  }
}