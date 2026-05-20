import 'package:flutter/material.dart';

class Responsive {

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double maxContentWidth(BuildContext context) {

    if (isDesktop(context)) {
      return 900;
    }

    if (isTablet(context)) {
      return 700;
    }

    return width(context);
  }

  static double horizontalPadding(BuildContext context) {

    if (isDesktop(context)) {
      return 40;
    }

    if (isTablet(context)) {
      return 28;
    }

    return 16;
  }

  static double titleSize(BuildContext context) {

    if (isDesktop(context)) {
      return 30;
    }

    if (isTablet(context)) {
      return 26;
    }

    return 22;
  }

  static double cardRadius(BuildContext context) {

    if (isDesktop(context)) {
      return 28;
    }

    return 20;
  }
}