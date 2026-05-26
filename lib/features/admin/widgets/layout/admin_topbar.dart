import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:barber_app/features/admin/widgets/layout/premium_action_button.dart';

class AdminTopBar extends StatelessWidget
    implements PreferredSizeWidget {

  final bool isMobile;
  final bool isTablet;

  final String currentDate;

  final VoidCallback onClientsTap;
  final VoidCallback onWalkInTap;
  final VoidCallback onLogoutTap;

  const AdminTopBar({
    super.key,
    required this.isMobile,
    required this.isTablet,
    required this.currentDate,
    required this.onClientsTap,
    required this.onWalkInTap,
    required this.onLogoutTap,
  });

  @override
 Size get preferredSize => Size.fromHeight(
      isMobile ? 118 : isTablet ? 150 : 170,
    );

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),

        child: Container(
          margin: EdgeInsets.zero,

          padding: EdgeInsets.only(
            left: isMobile ? 14 : 24,
            right: isMobile ? 14 : 24,
            top: isMobile ? 8 : 16,
            bottom: isMobile ? 8 : 12,
          ),

          decoration: BoxDecoration(
            gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,

  colors: [

    Colors.black.withOpacity(0.82),

    const Color(0xFF111111)
        .withOpacity(0.76),

    Colors.black.withOpacity(0.70),
  ],
),

            borderRadius: BorderRadius.only(

  bottomLeft: Radius.circular(
    isMobile ? 28 : 34,
  ),

  bottomRight: Radius.circular(
    isMobile ? 28 : 34,
  ),
),

            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
            
          ),

          child: SafeArea(
            child: Row(
              children: [

                Expanded(
                  child: Row(
                    children: [

                      Container(
                        width: isMobile ? 54 : 72,
                        height: isMobile ? 54 : 72,

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20),

                          child: Image.asset(
                            "assets/images/logo.jpeg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(width: isMobile ? 10 : 14),

                      if (!isMobile || isTablet)
                        Flexible(
  child: Column(
  mainAxisSize: MainAxisSize.min,

  mainAxisAlignment:
      MainAxisAlignment.start,

  crossAxisAlignment:
      CrossAxisAlignment.start,
                            children: [

SizedBox(
  height: isMobile ? 2 : 10,
),
Container(
  padding: EdgeInsets.symmetric(
  horizontal: isMobile ? 8 : 12,
  vertical: isMobile ? 4 : 6,
),

  decoration: BoxDecoration(
    color: const Color(0xFF00C853)
        .withOpacity(0.12),

    borderRadius: BorderRadius.circular(30),

    border: Border.all(
      color: const Color(0xFF00E676)
          .withOpacity(0.25),
    ),
  ),

  child: FittedBox(
  fit: BoxFit.scaleDown,

  child: Row(
    mainAxisSize: MainAxisSize.min,

    children: [

      Icon(
        Icons.verified_rounded,
        color: const Color(0xFF69F0AE),
        size: isMobile ? 11 : 14,
      ),

      SizedBox(width: isMobile ? 4 : 6),

      Text(
        "BARBER ADMIN",

        overflow: TextOverflow.ellipsis,

        style: TextStyle(
          color: const Color(0xFF69F0AE),

          fontSize: isMobile ? 9 : 11,

          fontWeight: FontWeight.w700,

          letterSpacing:
              isMobile ? 0.6 : 1.2,
        ),
      ),
    ],
  ),
),
),

                              Text(
  "Dashboard Operativa",

  maxLines: 1,
  overflow: TextOverflow.ellipsis,

  style: TextStyle(
    color: Colors.white,

    fontSize:
        isMobile ? 14 : 20,

    fontWeight: FontWeight.w800,
  ),
),

                            SizedBox(
  height: isMobile ? 2 : 4,
),

                          
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    PremiumActionButton(
                      icon:
                          Icons.people_alt_outlined,

                      label:
                          isMobile ? "" : "Clienti",

                      onTap: onClientsTap,
                    ),

                    const SizedBox(width: 8),

                    PremiumActionButton(
                      icon:
                          Icons.flash_on_rounded,

                      label:
                          isMobile ? "" : "Walk-In",

                      color: const Color(0xFFD4AF37),

                      onTap: onWalkInTap,
                    ),

                    const SizedBox(width: 8),

                    PremiumActionButton(
                      icon:
                          Icons.logout_rounded,

                      label:
                          isMobile ? "" : "Logout",

                      color: Colors.redAccent,

                      onTap: onLogoutTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}