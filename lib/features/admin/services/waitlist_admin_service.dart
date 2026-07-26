import 'package:cloud_firestore/cloud_firestore.dart';

class WaitlistAdminService {
  static String dateKey(DateTime giorno) {
    return "${giorno.year}-"
        "${giorno.month.toString().padLeft(2, '0')}-"
        "${giorno.day.toString().padLeft(2, '0')}";
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> waitlistForDay({
    required DateTime day,
  }) {
    return FirebaseFirestore.instance
        .collection('lista_attesa')
        .where('dateKey', isEqualTo: dateKey(day))
        .snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> userDoc(
    String userId,
  ) {
    return FirebaseFirestore.instance.collection('utenti').doc(userId).get();
  }

  static Future<void> removeFromWaitlist(String waitlistId) async {
    await FirebaseFirestore.instance
        .collection('lista_attesa')
        .doc(waitlistId)
        .delete();
  }
}