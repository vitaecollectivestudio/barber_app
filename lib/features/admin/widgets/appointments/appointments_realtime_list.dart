import 'package:flutter/material.dart';

class AppointmentsRealtimeList extends StatelessWidget {
  final List<Widget> children;

  const AppointmentsRealtimeList({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(children.length, (index) {
        return _TimelineAppointmentItem(
          isFirst: index == 0,
          isLast: index == children.length - 1,
          child: children[index],
        );
      }),
    );
  }
}

class _TimelineAppointmentItem extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget child;

  const _TimelineAppointmentItem({
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 11.5,
          top: isFirst ? 28 : 0,
          bottom: isLast ? 28 : 0,
          child: Container(
            width: 1,
            color: Colors.white.withOpacity(0.08),
          ),
        ),

        Positioned(
          left: 7,
          top: 34,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD8D8D8),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.16),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: child,
        ),
      ],
    );
  }
}