import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AppointmentsService {
  static Stream<QuerySnapshot> appointmentsStream({
    required DateTime visibleMonth,
    String? operatorId,
  }) {
    final start = DateTime(
      visibleMonth.year,
      visibleMonth.month,
      1,
    );

    final end = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      1,
    );

    Query query = FirebaseFirestore.instance
        .collection('appuntamenti')
        .where(
          'startAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'startAt',
          isLessThan: Timestamp.fromDate(end),
        )
        .orderBy('startAt');

    if (operatorId != null && operatorId != "Tutti") {
      query = query.where(
        'operatorId',
        isEqualTo: operatorId.toLowerCase(),
      );
    }

    return query.snapshots();
  }

  static Future<void> deleteAppointment(String id) async {
    await FirebaseFunctions.instance
        .httpsCallable('cancelBooking')
        .call({
      'bookingId': id,
    });
  }
}