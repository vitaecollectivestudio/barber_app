import 'package:flutter/material.dart';

class AppAnimations {

  // DURATIONS

  static const fast =
      Duration(milliseconds: 180);

  static const normal =
      Duration(milliseconds: 250);

  static const slow =
      Duration(milliseconds: 400);

  // CURVES

  static const smooth =
      Curves.easeOutCubic;

  static const fade =
      Curves.easeInOut;

  static const button =
      Curves.easeOut;
}