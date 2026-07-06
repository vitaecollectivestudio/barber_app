import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/operator_schedule_model.dart';

class OperatorScheduleService {

  static Future<DaySchedule?> getDaySchedule({

    required String operatorId,
    required String dayId,

  }) async {

    final doc = await FirebaseFirestore.instance
        .collection('operator_schedules')
        .doc(operatorId)
        .collection('weekly')
        .doc(dayId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return DaySchedule.fromMap(doc.data()!);
  }
}