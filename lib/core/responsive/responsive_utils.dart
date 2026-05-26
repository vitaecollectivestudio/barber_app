import 'package:flutter/material.dart';

class Responsive {

  // =========================
  // BREAKPOINTS
  // =========================

  static const double mobile = 600;
  static const double tablet = 1100;
  static const double desktop = 1400;

  // =========================
  // DEVICE TYPES
  // =========================

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  // =========================
  // SCREEN SIZE
  // =========================

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

      static double sectionSpacing(BuildContext context) {

  if (isDesktop(context)) return 32;

  if (isTablet(context)) return 28;

  return 20;
}

  // =========================
  // FULLSCREEN CONTENT WIDTH
  // =========================

  static double maxContentWidth(BuildContext context) {

    final w = width(context);

    // 📱 MOBILE
    if (w < mobile) {
      return w;
    }

    // 📲 TABLET
    if (w < tablet) {
      return w * 0.92;
    }

    // 💻 DESKTOP
    return 1400;
  }

  // =========================
  // HORIZONTAL PADDING
  // =========================

  static double horizontalPadding(BuildContext context) {

    final w = width(context);

    if (w >= desktop) {
      return 40;
    }

    if (w >= tablet) {
      return 32;
    }

    if (w >= mobile) {
      return 24;
    }

    return 16;
  }

  // =========================
  // FONT SIZES
  // =========================

  static double titleSize(BuildContext context) {

    final w = width(context);

    if (w >= desktop) {
      return 34;
    }

    if (w >= tablet) {
      return 28;
    }

    if (w >= mobile) {
      return 24;
    }

    return 20;
  }

  static double bodySize(BuildContext context) {

    final w = width(context);

    if (w >= desktop) {
      return 17;
    }

    if (w >= tablet) {
      return 16;
    }

    return 14;
  }

  // =========================
  // CARD RADIUS
  // =========================

  static double cardRadius(BuildContext context) {

    final w = width(context);

    if (w >= tablet) {
      return 30;
    }

    return 22;
  }

  // =========================
  // SAFE AREA HELPERS
  // =========================

  static double safeTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  // =========================
  // DEVICE HELPERS
  // =========================

  static bool isSmallPhone(BuildContext context) =>
      height(context) < 700;

  static bool isLargeTablet(BuildContext context) =>
      width(context) > 1300;

  static double authWidth(BuildContext context) {
    final w = width(context);

    if (w >= tablet) return 460;
    if (w >= mobile) return 440;

    return w;
  }

  static double dialogWidth(BuildContext context) {
    final w = width(context);

    if (w >= tablet) return 460;
    if (w >= mobile) return 420;

    return w - (horizontalPadding(context) * 2);
  }

  static double compactTitleSize(BuildContext context) {
    final w = width(context);

    if (w >= desktop) return 28;
    if (w >= tablet) return 24;
    if (w >= mobile) return 22;

    return 20;
  }
}
