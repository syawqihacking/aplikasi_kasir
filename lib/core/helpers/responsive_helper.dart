import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getResponsiveWidth(
    BuildContext context, {
    required double mobileWidth,
    required double tabletWidth,
    required double desktopWidth,
  }) {
    if (isMobile(context)) return mobileWidth;
    if (isTablet(context)) return tabletWidth;
    return desktopWidth;
  }

  static int getResponsiveFlex(
    BuildContext context, {
    required int mobileFlex,
    required int tabletFlex,
    required int desktopFlex,
  }) {
    if (isMobile(context)) return mobileFlex;
    if (isTablet(context)) return tabletFlex;
    return desktopFlex;
  }

  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) return 0;
    if (isTablet(context)) return 200;
    return 240;
  }
}
