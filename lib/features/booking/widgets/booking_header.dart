import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class BookingHeader extends StatelessWidget {

  final String title;
  final String subtitle;

  const BookingHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    final isTablet =
        Responsive.isTablet(context);

    final isDesktop =
        Responsive.isDesktop(context);

    return Padding(

      padding: EdgeInsets.only(
        top: isDesktop ? 34 : 24,
        bottom: isDesktop ? 18 : 12,
      ),

      child: Column(

        children: [

          // 🔥 LABEL PREMIUM
          Container(

            padding: EdgeInsets.symmetric(

              horizontal:
                  isDesktop ? 18 : 14,

              vertical:
                  isDesktop ? 8 : 6,
            ),

            decoration: BoxDecoration(

              gradient: LinearGradient(

  colors: [

    Colors.white.withOpacity(0.10),

    Colors.white.withOpacity(0.04),
  ],
),

              borderRadius:
                  BorderRadius.circular(40),

              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),

              boxShadow: [

                BoxShadow(
                  color: Colors.white.withOpacity(0.05),

                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),

            child: Text(

              title,

              style: TextStyle(

                color: Colors.white,

                fontSize:
                    isDesktop
                        ? 13
                        : 11,

                letterSpacing: 3,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          SizedBox(
            height:
                isDesktop ? 24 : 18,
          ),

          // 🔥 TITLE
          Text(

            subtitle,

            textAlign: TextAlign.center,

            style: TextStyle(

              color: Colors.white,

              fontSize:
                  isDesktop
                      ? 46
                      : isTablet
                          ? 36
                          : 30,

              fontWeight:
                  FontWeight.w800,

              height: 1,

              letterSpacing: -1,
            ),
          ),

          SizedBox(
            height:
                isDesktop ? 18 : 14,
          ),

          // 🔥 PREMIUM LINE
          Container(

            width:
                isDesktop ? 82 : 64,

            height: 4,

            decoration: BoxDecoration(

              borderRadius:
                  BorderRadius.circular(30),

              gradient: LinearGradient(

                begin: Alignment.centerLeft,
                end: Alignment.centerRight,

                colors: [

                  const Color(0xFF00C853),

                  const Color(0xFF69F0AE),

                  Colors.white.withOpacity(0.9),
                ],
              ),

              boxShadow: [

                BoxShadow(

                  color:
                      const Color(0xFF00C853)
                          .withOpacity(0.45),

                  blurRadius: 18,

                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}