import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/services/slot_service.dart';

import 'package:barber_app/features/schedule/models/operator_schedule_model.dart';

import 'package:barber_app/features/schedule/services/operator_schedule_service.dart';

class AvailabilityService {

  static FirebaseFirestore db =
      FirebaseFirestore.instance;

  static String buildDocId({
    required String operatorId,
    required DateTime date,
  }) {

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return "${operatorId}_${date.year}-$month-$day";
  }

  static Future<void> saveAvailability({

    required String operatorId,

    required DateTime date,

    required Map<String, bool> slots,

  }) async {

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    final dateKey =
        "${date.year}-$month-$day";

    final docId = buildDocId(
      operatorId: operatorId,
      date: date,
    );

    await db
        .collection('availability_public')
        .doc(docId)
        .set({

      "operatorId": operatorId,

      "dateKey": dateKey,

      "slots": slots,

      "updatedAt":
          FieldValue.serverTimestamp(),

    });
  }

  static Future<void> rebuildAvailability({

    required String operatorId,

    required DateTime date,

  }) async {

print("REBUILD AVAILABILITY START");
print(operatorId);
print(date);

    final dayMap = {

      1: "monday",
      2: "tuesday",
      3: "wednesday",
      4: "thursday",
      5: "friday",
      6: "saturday",
      7: "sunday",
    };

    final dayId =
        dayMap[date.weekday]!;

    final DaySchedule? schedule =
        await OperatorScheduleService
            .getDaySchedule(

      operatorId: operatorId,
      dayId: dayId,
    );

    if (schedule == null ||
        schedule.enabled == false) {

      await saveAvailability(

        operatorId: operatorId,

        date: date,

        slots: {},
      );

      return;
    }

    final baseSlots =
        SlotService.generateSlotsFromSchedule(

      start: schedule.start,

      end: schedule.end,

      pauseStart: schedule.pauseStart,

      pauseEnd: schedule.pauseEnd,

      durata: 10,
    );

    final appointments =
        await FirebaseFirestore.instance
            .collection('appuntamenti')
            .where(
              'operatorId',
              isEqualTo: operatorId,
            )
            .get();

    final blocked =
        await FirebaseFirestore.instance
            .collection('orari_bloccati')
            .where(
              'operatore',
              isEqualTo: operatorId,
            )
            .get();

    final closed =
        await FirebaseFirestore.instance
            .collection('giorni_chiusi')
            .where(
              'operatore',
              isEqualTo: operatorId,
            )
            .get();

    bool isClosed = closed.docs.any((doc) {

      final d =
          (doc['data'] as Timestamp)
              .toDate();

      return d.year == date.year &&
          d.month == date.month &&
          d.day == date.day;
    });

    if (isClosed) {

      await saveAvailability(

        operatorId: operatorId,

        date: date,

        slots: {},
      );

      return;
    }

    final Map<String, bool> slots = {};

    for (final slot in baseSlots) {

      bool available = true;

      final slotStart = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(slot.split(":")[0]),
        int.parse(slot.split(":")[1]),
      );

      final slotEnd =
          slotStart.add(
        const Duration(minutes: 10),
      );

      final blockedSlot =
          blocked.docs.any((doc) {

        final d =
            (doc['data'] as Timestamp)
                .toDate();

        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day &&
            doc['ora'] == slot;
      });

      if (blockedSlot) {
        available = false;
      }

      for (final doc in appointments.docs) {

  final appStart =
      (doc['startAt'] as Timestamp)
          .toDate();

  final appEnd =
      (doc['endAt'] as Timestamp)
          .toDate();

  if (appStart.year != date.year ||
      appStart.month != date.month ||
      appStart.day != date.day) {
    continue;
  }

  final overlap =
      slotStart.isBefore(appEnd) &&
      slotEnd.isAfter(appStart);

  if (overlap) {
    available = false;
    break;
  }
}

      slots[slot] = available;
    }

    await saveAvailability(

      operatorId: operatorId,

      date: date,

      slots: slots,
    );
  }
}