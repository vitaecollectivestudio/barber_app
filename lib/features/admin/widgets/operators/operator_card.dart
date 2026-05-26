import 'package:flutter/material.dart';

Future<void> premiumPopup({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
}) async {

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),

    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,

      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 250),
        tween: Tween(begin: 0.8, end: 1.0),

        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },

        child: Container(
          width: 320,
          padding: const EdgeInsets.all(26),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),

            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0F0F0F),
              ],
            ),

            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),

            boxShadow: [

              BoxShadow(
                color: Colors.black.withOpacity(0.65),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),

              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 72,
                height: 72,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.25),
                      color.withOpacity(0.12),
                    ],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 25,
                    ),
                  ],
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 34,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  await Future.delayed(
  const Duration(seconds: 2),
);

if (context.mounted) {
  Navigator.of(context, rootNavigator: true).maybePop();
}
}