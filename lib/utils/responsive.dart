import 'package:flutter/material.dart';

class Responsive {

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double horizontalPadding(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (width >= 1100) {
      return 40;
    }

    if (width >= 600) {
      return 28;
    }

    return 16;
  }

  static double maxContentWidth(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (width >= 1400) {
      return 1200;
    }

    if (width >= 1100) {
      return 1000;
    }

    if (width >= 600) {
      return 700;
    }

    return width;
  }

  static double title(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (width >= 1100) {
      return 28;
    }

    if (width >= 600) {
      return 24;
    }

    return 20;
  }

  static double body(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (width >= 1100) {
      return 16;
    }

    if (width >= 600) {
      return 15;
    }

    return 14;
  }

  static double radius(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    if (width >= 600) {
      return 24;
    }

    return 18;
  }
static double screenHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;

static double screenWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;

}