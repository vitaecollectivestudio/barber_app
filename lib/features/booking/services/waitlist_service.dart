import 'package:cloud_firestore/cloud_firestore.dart';

class WaitlistService {

  static Future<bool> alreadyInWaitlist({
    required String userId,
    required DateTime giorno,
  }) async {

    final snapshot =
        await FirebaseFirestore.instance
            .collection('lista_attesa')
            .where(
              'userId',
              isEqualTo: userId,
            )
            .where(
              'data',
              isEqualTo: Timestamp.fromDate(giorno),
            )
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

    await FirebaseFirestore.instance
        .collection('lista_attesa')
        .add({

      "userId": userId,

      "operatore": operatore,

      "servizio": servizio,

      "data": Timestamp.fromDate(giorno),

      "fcmToken": fcmToken,

      "creatoIl": Timestamp.now(),
    });
  }
}