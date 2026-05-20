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
}