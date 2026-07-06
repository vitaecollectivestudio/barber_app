import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsDialog
    extends StatelessWidget {

  final bool isMobile;

  final Map<String, dynamic> data;

  final String formattedDate;

  const AppointmentDetailsDialog({
    super.key,
    required this.isMobile,
    required this.data,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {

final start =
    data['startAt'] != null
        ? data['startAt'].toDate()
        : null;

final ora = start != null
    ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}"
    : "--:--";

final operatore =
    data['operatorId'] ?? "-";
    return Stack(
      children: [

        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6,
            sigmaY: 6,
          ),

          child: Container(
            color: Colors.black.withOpacity(0.2),
          ),
        ),

        SafeArea(
  child: Center(
          child: Container(
           constraints: BoxConstraints(
  maxWidth: isMobile ? 320 : 420,
),

           padding: EdgeInsets.all(
  isMobile ? 18 : 24,
),

            decoration: BoxDecoration(

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF101010),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [

                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.6),

                  blurRadius: 30,
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                Container(
                  width: 58,
                  height: 58,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF202020),
                        Color(0xFF121212),
                      ],
                    ),
                  ),

                  child: const Icon(
                    Icons.person_outline_rounded,

                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  data['nome'] ?? "Cliente",
maxLines: 1,
overflow: TextOverflow.ellipsis,
textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  formattedDate,

                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.65),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "${data['servizio']}",
maxLines: 1,
overflow: TextOverflow.ellipsis,
textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.88),

                    fontSize: 17,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                

                GestureDetector(
                  onTap: () async {

                    final url = Uri.parse(
                      "tel:${data['telefono']}",
                    );

                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },

                  child: Text(
                    data['telefono'] ?? "-",
maxLines: 1,
overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          Colors.white.withOpacity(0.9),

                      fontWeight: FontWeight.w600,

                      fontSize:
                          isMobile ? 15 : 17,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    decoration: BoxDecoration(

                      borderRadius:
                          BorderRadius.circular(18),

                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF1C1C1C),
                          Color(0xFF111111),
                        ],
                      ),
                    ),

                    child:  Center(
                      child: Text(
                        "CHIUDI",

                        style: TextStyle(
                          color: Colors.white,

                          fontWeight:
                              FontWeight.w700,

                          letterSpacing:
    isMobile ? 1.1 : 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
  ),
        ),
      ],
    );
  }
}