import 'package:flutter/material.dart';

class AppointmentsHeader extends StatelessWidget {

  final DateTime selectedDay;

  final String Function(DateTime)
      formatDataBella;

  const AppointmentsHeader({
    super.key,
    required this.selectedDay,
    required this.formatDataBella,
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
                const Color(0xFF00C853)
                    .withOpacity(0.18),

                const Color(0xFF00E676)
                    .withOpacity(0.08),
              ],
            ),

            border: Border.all(
              color: const Color(0xFF00E676)
                  .withOpacity(0.16),
            ),
          ),

          child: const Icon(
            Icons.calendar_month_rounded,
            color: Color(0xFF69F0AE),
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
                "APPUNTAMENTI",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                formatDataBella(selectedDay),

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