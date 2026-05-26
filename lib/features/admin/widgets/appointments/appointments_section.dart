import 'package:flutter/material.dart';

class AppointmentsSection extends StatelessWidget {

  final Widget child;

  const AppointmentsSection({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      padding: const EdgeInsets.all(24),

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
            BorderRadius.circular(36),

        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),

          BoxShadow(
            color: Colors.white.withOpacity(0.015),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),

      child: child,
    );
  }
}