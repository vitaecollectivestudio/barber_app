import 'package:flutter/material.dart';

class PremiumInfoChip extends StatelessWidget {

  final IconData icon;
  final String text;

  const PremiumInfoChip({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return ConstrainedBox(
  constraints: const BoxConstraints(
    maxWidth: 170,
  ),

  child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            icon,
            color: const Color(0xFF00C853),
            size: 15,
          ),

          const SizedBox(width: 6),
Flexible(
  child:
          Text(
            text,
maxLines: 1,
overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
),
        ],
      ),
  ),
    );
  }
}