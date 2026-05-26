import 'package:flutter/material.dart';

class ScheduleHeader extends StatelessWidget {

  const ScheduleHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(0.16),
                Colors.redAccent.withOpacity(0.06),
              ],
            ),

            border: Border.all(
              color:
                  Colors.redAccent
                      .withOpacity(0.18),
            ),
          ),

          child: const Icon(
            Icons.schedule_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                "GESTIONE ORARI",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "Blocca o riapri gli slot disponibili.",

                style: TextStyle(
                  color: Colors.white
                      .withOpacity(0.5),

                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}