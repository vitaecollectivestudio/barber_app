import 'package:flutter/material.dart';

class PremiumAlertDialog {
  static Future<void> show({
    required BuildContext context,

    required String title,

    required String subtitle,

    IconData icon = Icons.info_outline,

    bool barrierDismissible = true,
  }) async {
    final size = MediaQuery.of(context).size;

    final titleFontSize = (size.width * 0.050).clamp(18.0, 24.0).toDouble();

    showGeneralDialog(
      context: context,

      barrierDismissible: barrierDismissible,

      barrierLabel: "alert",

      barrierColor: Colors.black.withOpacity(0.7),

      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  maxHeight: size.height - 48,
                ),
                child: SingleChildScrollView(
                  child: Material(
                    color: Colors.transparent,

                    child: Container(
                      padding: const EdgeInsets.all(26),

                      decoration: BoxDecoration(
                        color: const Color(0xFF181818),

                        borderRadius: BorderRadius.circular(24),

                        border: Border.all(color: Colors.white12),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),

                            blurRadius: 30,
                          ),
                        ],
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(icon, color: Colors.white, size: 34),

                          const SizedBox(height: 14),

                          Text(
                            title,

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: titleFontSize,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            subtitle,

                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              color: Colors.white70,

                              fontSize: 14,

                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },

      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
