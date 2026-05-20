import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../../../utils/responsive.dart';

class DaySelector extends StatelessWidget {

  final List<DateTime> giorni;
  final DateTime selectedDay;
  final Function(DateTime, int) onSelect;
  final bool Function(DateTime) isClosed;
  final ScrollController controller;
  final int? pressedIndex;
  final Function(int?) setPressed;

  const DaySelector({
    super.key,
    required this.giorni,
    required this.selectedDay,
    required this.onSelect,
    required this.isClosed,
    required this.controller,
    required this.pressedIndex,
    required this.setPressed,
  });

  @override
  Widget build(BuildContext context) {

    final isTablet =
        Responsive.isTablet(context);

    final isDesktop =
        Responsive.isDesktop(context);

    final itemWidth =
        isDesktop
            ? 82.0
            : isTablet
                ? 72.0
                : 60.0;

    final itemHeight =
        isDesktop
            ? 110.0
            : 95.0;

    return SizedBox(

      width: double.infinity,

      height: itemHeight,

      child: ScrollConfiguration(

        behavior:
            const ScrollBehavior().copyWith(

          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),

        child: ListView.builder(

          controller: controller,

          padding: EdgeInsets.symmetric(
            horizontal:
                Responsive.horizontalPadding(context),
          ),

          scrollDirection: Axis.horizontal,

          itemCount: giorni.length,

          itemBuilder: (context, index) {

            final day = giorni[index];

            final chiuso =
                isClosed(day);

            final sel =
                selectedDay.day == day.day &&
                selectedDay.month == day.month;

            final isToday =
                day.day == DateTime.now().day &&
                day.month == DateTime.now().month;

            return GestureDetector(

              onTapDown: (_) =>
                  setPressed(index),

              onTapUp: (_) =>
                  setPressed(null),

              onTapCancel: () =>
                  setPressed(null),

              onTap: chiuso
                  ? null
                  : () {

                      HapticFeedback.lightImpact();

                      onSelect(day, index);
                    },

              child: AnimatedScale(

                scale:
                    pressedIndex == index
                        ? 0.96
                        : 1,

                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                curve: Curves.easeOutCubic,

                child: AnimatedContainer(

                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),

                  width: itemWidth,

                  margin: EdgeInsets.symmetric(
                    horizontal:
                        isDesktop ? 8 : 6,
                  ),

                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(
                      Responsive.radius(context),
                    ),

                    color: chiuso
                        ? const Color(0xFF111111)
                        : sel
                            ? const Color(0xFF00C853)
                                .withOpacity(0.14)
                            : Colors.white.withOpacity(0.06),

                    border: Border.all(

                      color: chiuso
                          ? Colors.transparent
                          : sel
                              ? const Color(0xFF00C853)
                              : Colors.white.withOpacity(0.12),

                      width:
                          sel ? 1.8 : 1,
                    ),

                    boxShadow: sel
                        ? [

                            BoxShadow(

                              color:
                                  const Color(0xFF00C853)
                                      .withOpacity(0.18),

                              blurRadius: 18,

                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),

                  child: Column(

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      if (isToday)

                        Container(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),

                          decoration: BoxDecoration(

                            color:
                                const Color(0xFF00C853)
                                    .withOpacity(0.12),

                            borderRadius:
                                BorderRadius.circular(30),
                          ),

                          child: const Text(

                            "OGGI",

                            style: TextStyle(

                              fontSize: 8,

                              color:
                                  Color(0xFF00C853),

                              fontWeight:
                                  FontWeight.w700,

                              letterSpacing: 1,
                            ),
                          ),
                        ),

                      if (isToday)
                        const SizedBox(height: 8),

                      Text(

                        "${day.day}",

                        style: TextStyle(

                          fontSize:
                              isDesktop
                                  ? 24
                                  : sel
                                      ? 21
                                      : 18,

                          fontWeight:
                              FontWeight.w800,

                          color: chiuso
                              ? Colors.grey.shade700
                              : Colors.white,
                        ),
                      ),

                      SizedBox(
                        height:
                            isDesktop ? 6 : 4,
                      ),

                      Text(

                        [
                          "Lun",
                          "Mar",
                          "Mer",
                          "Gio",
                          "Ven",
                          "Sab",
                          "Dom"
                        ][day.weekday - 1],

                        style: TextStyle(

                          fontSize:
                              isDesktop
                                  ? 12
                                  : 11,

                          letterSpacing: 1.2,

                          fontWeight:
                              FontWeight.w600,

                          color: chiuso
                              ? Colors.grey.shade600
                              : sel
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}