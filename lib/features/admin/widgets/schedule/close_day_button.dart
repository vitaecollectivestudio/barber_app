import 'package:flutter/material.dart';

class CloseDayButton extends StatelessWidget {

  final bool giornataChiusa;

  final VoidCallback onTap;

  const CloseDayButton({
    super.key,
    required this.giornataChiusa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

   return Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      minWidth: 220,
      maxWidth: 320,
    ),

      child: ElevatedButton.icon(

        onPressed: onTap,

        style: ElevatedButton.styleFrom(
  elevation: 0,

  backgroundColor:
      giornataChiusa
          ? const Color(0xFF00C853)
          : const Color(0xFFE53935),

  foregroundColor: Colors.white,

  padding: const EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 18,
  ),

  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(24),
  ),

  shadowColor:
      giornataChiusa
          ? const Color(0xFF00C853)
              .withOpacity(0.25)
          : Colors.redAccent
              .withOpacity(0.25),
),

        icon: Icon(
          giornataChiusa
              ? Icons.lock_open_rounded
              : Icons.block_rounded,
        ),

        label: Text(

          giornataChiusa
              ? "RIAPRI GIORNATA"
              : "CHIUDI GIORNATA",

          style: const TextStyle(
            fontWeight: FontWeight.w700,
letterSpacing: 1.1,          ),
        ),
      ),
  ),
    );
  }
}