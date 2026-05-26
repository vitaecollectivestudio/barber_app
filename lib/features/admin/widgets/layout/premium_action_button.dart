import 'package:flutter/material.dart';
import 'package:barber_app/core/responsive/responsive_utils.dart';

class PremiumActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color? color;

  const PremiumActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    final isMobile =
        Responsive.width(context) < 700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
  color: Colors.transparent,

  child: InkWell(
        onTap: onTap,

borderRadius:
    BorderRadius.circular(18),

child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 9 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
  mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
size: isMobile ? 17 : 18,
                color: color ?? Colors.white,
              ),

              if (label != null &&
                  label!.isNotEmpty) ...[
                const SizedBox(width: 6),

Flexible(
  child:
                Text(
                  label!,
                  maxLines: 1,
overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}