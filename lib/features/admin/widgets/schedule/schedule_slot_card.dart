import 'package:flutter/material.dart';

class ScheduleSlotCard extends StatelessWidget {

  final bool isMobile;

  final bool occupato;
  final bool isBloccato;

  final String ora;

  final VoidCallback? onTap;

  const ScheduleSlotCard({
    super.key,
    required this.isMobile,
    required this.occupato,
    required this.isBloccato,
    required this.ora,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Material(
  color: Colors.transparent,

  child: InkWell(
      onTap: onTap,

      child: AnimatedScale(
        scale: occupato ? 0.98 : 1,

        duration: const Duration(milliseconds: 180),

        child: AnimatedContainer(
          constraints: BoxConstraints(
  minWidth: isMobile ? 120 : 145,
),
          curve: Curves.easeOutCubic,

          duration: const Duration(milliseconds: 200),

          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 18,
            vertical: 10,
          ),

          decoration: BoxDecoration(

            borderRadius:
                BorderRadius.circular(
              isMobile ? 18 : 22,
            ),

            gradient: occupato

                ? const LinearGradient(
                    colors: [
                      Color(0xFF2B2B2B),
                      Color(0xFF1A1A1A),
                    ],
                  )

                : isBloccato

                    ? const LinearGradient(
                        colors: [
                          Color(0xFFFF5A5A),
                          Color(0xFFD32F2F),
                        ],
                      )

                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,

                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),

            border: Border.all(
              color: occupato

                  ? Colors.white.withOpacity(0.04)

                  : isBloccato
                      ? Colors.redAccent.withOpacity(0.25)
                      : Colors.white.withOpacity(0.08),
            ),

            boxShadow: [

              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),

              if (!occupato && !isBloccato)
                BoxShadow(
                  color: Colors.white.withOpacity(0.015),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),

              if (isBloccato)
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.25),
                  blurRadius: 16,
                ),
            ],
          ),

          child: Center(
            child: Text(
maxLines: 1,
overflow: TextOverflow.ellipsis,
              occupato
                  ? "$ora • OCCUPATO"
                  : isBloccato
                      ? "$ora • BLOCCATO"
                      : ora,

              textAlign: TextAlign.center,

              style: TextStyle(
                color: occupato
                    ? Colors.white30
                    : Colors.white,

                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ),
      ),
  ),
    );
  }
}