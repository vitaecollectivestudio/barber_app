import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsService {

  static Stream<QuerySnapshot> appointmentsStream() {

    return FirebaseFirestore.instance
        .collection('appuntamenti')
        .snapshots();
  }

  static Future<void> deleteAppointment(
    String id,
  ) async {

    await FirebaseFirestore.instance
        .collection('appuntamenti')
        .doc(id)
        .delete();
  }
}