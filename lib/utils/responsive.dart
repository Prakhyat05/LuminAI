import 'package:flutter/material.dart';

/// Responsive breakpoints and utility extensions for adaptive layouts.
///
/// Mobile: < 600px | Tablet: 600–1024px | Desktop: > 1024px
class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Adaptive horizontal padding based on screen width.
  static double hPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 16;
    if (w < mobileBreakpoint) return 24;
    if (w < tabletBreakpoint) return 40;
    return 64;
  }

  /// Adaptive grid cross-axis count.
  static int gridCount(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Scale factor for fonts on very small screens.
  static double fontScale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 320) return 0.85;
    if (w < 360) return 0.92;
    return 1.0;
  }
}

/// Convenience extensions on BuildContext.
extension ResponsiveContext on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  double get hPad => Responsive.hPadding(this);
  int gridCount({int mobile = 2, int tablet = 3}) =>
      Responsive.gridCount(this, mobile: mobile, tablet: tablet);
}
