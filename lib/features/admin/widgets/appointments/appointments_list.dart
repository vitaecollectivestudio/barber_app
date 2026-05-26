import 'package:flutter/material.dart';

class AppointmentsList extends StatelessWidget {

  final List<Widget> children;

  const AppointmentsList({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}