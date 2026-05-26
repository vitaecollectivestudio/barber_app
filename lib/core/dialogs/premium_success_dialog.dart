import 'package:flutter/material.dart';

class PremiumSuccessDialog {

  static Future<void> show({
    required BuildContext context,

    required String title,

    required String subtitle,

    IconData icon = Icons.check,

    Duration duration =
        const Duration(seconds: 2),
  }) async {

    final width =
        MediaQuery.of(context).size.width;

    showGeneralDialog(
      context: context,

      barrierDismissible: false,

      barrierLabel: "success",

      barrierColor:
          Colors.black.withOpacity(0.6),

      transitionDuration:
          const Duration(milliseconds: 250),

      pageBuilder: (_, __, ___) {

        return Center(
          child: Material(
            color: Colors.transparent,

            child: Container(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 30,
              ),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFF181818),

                borderRadius:
                    BorderRadius.circular(20),

                border: Border.all(
                  color:
                      Colors.white.withOpacity(0.05),
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.8),

                    blurRadius: 30,

                    offset:
                        const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    title,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,

                      fontSize:
                          width * 0.048,

                      fontWeight:
                          FontWeight.w700,

                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    subtitle,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white70,

                      fontSize: 14,

                      height: 1.5,

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      transitionBuilder:
          (_, animation, __, child) {

        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );

    await Future.delayed(duration);

    if (Navigator.canPop(context)) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();
    }
  }
}