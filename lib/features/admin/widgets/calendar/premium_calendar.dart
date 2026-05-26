import 'package:flutter/material.dart';

class PremiumCalendar extends StatelessWidget {

  final Widget child;

  const PremiumCalendar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF101010),
          ],
        ),

        borderRadius:
            BorderRadius.circular(34),

        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),

          BoxShadow(
            color: Colors.white.withOpacity(0.025),
            blurRadius: 6,
            spreadRadius: 1,
          ),

          BoxShadow(
            color:
                const Color(0xFF00C853)
                    .withOpacity(0.05),

            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),

      child: child,
    );
  }
}