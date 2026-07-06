import 'package:cloud_firestore/cloud_firestore.dart';

class SlotService {

  static List<String> calcolaSlotDisponibili({

    required List<String> orariBase,
    required List<Map<String, dynamic>> occupati,
    required List<String> bloccati,
    required DateTime selectedDay,
    required int durataServizio,

  }) {

    List<String> disponibili = [];

    for (var o in orariBase) {

      final start = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(o.split(":")[0]),
        int.parse(o.split(":")[1]),
      );

      final end =
          start.add(Duration(minutes: durataServizio));

      bool occupato = false;

      for (var doc in occupati) {

        final parts = doc["ora"].split(":");

        final durataDoc = doc["durata"] ?? 30;

        final startDoc = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        final endDoc =
            startDoc.add(Duration(minutes: durataDoc));

        if (start.isBefore(endDoc) &&
            end.isAfter(startDoc)) {

          occupato = true;
          break;
        }
      }

      final now = DateTime.now();

      if (selectedDay.year == now.year &&
          selectedDay.month == now.month &&
          selectedDay.day == now.day) {

        if (!start.isAfter(now)) {
          continue;
        }
      }

      if (selectedDay.weekday == 1) {

        if (o.compareTo("13:00") >= 0) {
          continue;
        }
      }

      if (!occupato && !bloccati.contains(o)) {
        disponibili.add(o);
      }
    }

    return disponibili;
  }

  static List<String> generateSlotsFromSchedule({

  required String start,
  required String end,
  required String pauseStart,
  required String pauseEnd,
  required int durata,

}) {

  final slots = <String>[];

  DateTime parse(String value) {

    final parts = value.split(":");

    return DateTime(
      2024,
      1,
      1,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String format(DateTime d) {

    final h =
        d.hour.toString().padLeft(2, '0');

    final m =
        d.minute.toString().padLeft(2, '0');

    return "$h:$m";
  }

  final startTime = parse(start);

  final endTime = parse(end);

  DateTime? pausaStart;
  DateTime? pausaEnd;

  if (pauseStart.isNotEmpty &&
      pauseEnd.isNotEmpty) {

    pausaStart = parse(pauseStart);
    pausaEnd = parse(pauseEnd);
  }

  var current = startTime;

  while (true) {

    final slotEnd =
        current.add(Duration(minutes: durata));

    if (slotEnd.isAfter(endTime)) {
      break;
    }

    bool overlapsPause = false;

    if (pausaStart != null &&
        pausaEnd != null) {

      overlapsPause =
          current.isBefore(pausaEnd) &&
          slotEnd.isAfter(pausaStart);
    }

    if (!overlapsPause) {
      slots.add(format(current));
    }

    // 🔥 QUI LA FIX
    current = current.add(
      Duration(minutes: durata),
    );
  }

  return slots;
}
static List<String> calcolaSlotDaAvailability({
  required Map<String, dynamic> slots,
  required int durataServizio,
}) {

  final necessari =
      (durataServizio / 10).ceil();

  final disponibili =
      slots.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList()
        ..sort();

  List<String> finali = [];

  for (final slot in disponibili) {

    final parts = slot.split(":");

    final start = DateTime(
      2024,
      1,
      1,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    bool valid = true;

    for (int i = 0; i < necessari; i++) {

      final current =
          start.add(Duration(minutes: i * 10));

      final key =
          "${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}";

      if (slots[key] != true) {

        valid = false;

        break;
      }
    }

    if (valid) {
      finali.add(slot);
    }
  }

  return finali;
}
}