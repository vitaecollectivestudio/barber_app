import 'package:flutter/material.dart';

class AppointmentsRealtimeList extends StatelessWidget {

  final List<Widget> children;

  const AppointmentsRealtimeList({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}