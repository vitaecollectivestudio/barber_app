import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleEditorDialog extends StatefulWidget {

  final String operatorId;
  final String dayId;

  final Map<String, dynamic>? current;

  const ScheduleEditorDialog({
    super.key,
    required this.operatorId,
    required this.dayId,
    required this.current,
  });

  @override
  State<ScheduleEditorDialog> createState() =>
      _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState
    extends State<ScheduleEditorDialog> {

  late TextEditingController start;

  late TextEditingController end;

  late TextEditingController pauseStart;

  late TextEditingController pauseEnd;

  bool enabled = true;

  @override
  void initState() {
    super.initState();

    final data = widget.current;

    start = TextEditingController(
      text: data?['start'] ?? '08:30',
    );

    end = TextEditingController(
      text: data?['end'] ?? '19:00',
    );

    pauseStart = TextEditingController(
      text: data?['pauseStart'] ?? '13:00',
    );

    pauseEnd = TextEditingController(
      text: data?['pauseEnd'] ?? '15:00',
    );

    enabled = data?['enabled'] ?? true;
  }

  Future<void> salva() async {

  try {

  
    final data = {

      "enabled": enabled,

      "start": start.text.trim(),

      "end": end.text.trim(),

      "pauseStart": pauseStart.text.trim(),

      "pauseEnd": pauseEnd.text.trim(),
    };


    print(data);

    await FirebaseFirestore.instance
        .collection('operator_schedules')
        .doc(widget.operatorId)
        .collection('weekly')
        .doc(widget.dayId)
        .set(data);

    print("✅ SALVATO FIRESTORE");

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Schedule salvata"),
      ),
    );

  } catch (e) {

    print("❌ ERRORE:");
    print(e);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(
          "Errore: $e",
        ),
      ),
    );
  }
}

  Widget field(
  String label,
  TextEditingController c,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: c,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,

        labelStyle: TextStyle(
          color: Colors.white.withOpacity(.55),
        ),

        filled: true,
        fillColor: Colors.black.withOpacity(.28),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.05),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.05),
          ),
        ),

        focusedBorder: const OutlineInputBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(18),
          ),
          borderSide: BorderSide(
            color: Color(0xFF00C853),
            width: 1.4,
          ),
        ),
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {

  final width = MediaQuery.of(context).size.width;
  final isMobile = width < 700;

  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.symmetric(
      horizontal: isMobile ? 18 : 28,
      vertical: 24,
    ),
    child: Container(
      constraints: const BoxConstraints(
        maxWidth: 520,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B1B1B),
            Color(0xFF101010),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF00C853)
                .withOpacity(0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C853)
                    .withOpacity(0.12),
                border: Border.all(
                  color: const Color(0xFF69F0AE)
                      .withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.edit_calendar_rounded,
                color: Color(0xFF69F0AE),
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "MODIFICA SCHEDULE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.operatorId.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(.45),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.04),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(.05),
                ),
              ),
              child: Row(
                children: [

                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: enabled
                          ? const Color(0xFF00C853)
                              .withOpacity(.15)
                          : Colors.white10,
                    ),
                    child: Icon(
                      enabled
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: enabled
                          ? const Color(0xFF69F0AE)
                          : Colors.white38,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Giorno attivo",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Abilita prenotazioni per questo giorno",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: enabled,
                    activeColor:
                        const Color(0xFF00C853),
                    onChanged: (v) {
                      setState(() {
                        enabled = v;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            field("Orario apertura", start),

            field("Orario chiusura", end),

            field("Inizio pausa", pauseStart),

            field("Fine pausa", pauseEnd),

            const SizedBox(height: 28),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      side: BorderSide(
                        color: Colors.white
                            .withOpacity(.08),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "ANNULLA",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: salva,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          const Color(0xFF00C853),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "SALVA",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}