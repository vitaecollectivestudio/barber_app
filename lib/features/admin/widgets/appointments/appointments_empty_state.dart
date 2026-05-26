import 'package:flutter/material.dart';

class AppointmentsEmptyState extends StatelessWidget {

  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const AppointmentsEmptyState({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: isDesktop
          ? 260
          : isTablet
              ? 240
              : 220,

      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(
              width: 72,
              height: 72,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
              ),

              child: Icon(
                Icons.event_busy_rounded,
                color:
                    Colors.white.withOpacity(0.35),
                size: 34,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Nessun appuntamento",

              style: TextStyle(
                color:
                    Colors.white.withOpacity(0.82),

                fontSize:
                    isMobile ? 16 : 18,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Non ci sono prenotazioni per questa giornata.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color:
                    Colors.white.withOpacity(0.42),

                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}