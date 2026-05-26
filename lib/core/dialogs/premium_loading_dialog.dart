import 'package:flutter/material.dart';

class PremiumLoadingDialog {

  static void show({
    required BuildContext context,
    String title = "CARICAMENTO",
    String subtitle = "Attendi un momento...",
  }) {

    showGeneralDialog(
      context: context,

      barrierDismissible: false,

      barrierLabel: "loading",

      barrierColor: Colors.black.withOpacity(0.75),

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
                horizontal: 30,
                vertical: 28,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFF181818),

                borderRadius:
                    BorderRadius.circular(24),

                border: Border.all(
                  color:
                      Colors.white.withOpacity(0.06),
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

                  Container(
                    width: 140,
                    height: 5,

                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(
                              0.06),

                      borderRadius:
                          BorderRadius.circular(30),
                    ),

                    child:
                        TweenAnimationBuilder<double>(

                      tween:
                          Tween(begin: 0, end: 1),

                      duration:
                          const Duration(seconds: 2),

                      curve: Curves.easeInOut,

                      builder:
                          (context, value, child) {

                        return Align(
                          alignment:
                              Alignment(
                            -1 + (value * 2),
                            0,
                          ),

                          child: Container(
                            width: 70,

                            decoration:
                                BoxDecoration(
                              borderRadius:
                                  BorderRadius
                                      .circular(30),

                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(
                                      0xFFEAEAEA),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    title,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 18,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    subtitle,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white54,

                      fontSize: 13,

                      height: 1.5,
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
  }
}