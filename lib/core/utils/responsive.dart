import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? tabletPortrait;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    this.tabletPortrait,
  });

  // Define screen width breakpoints
  static const int mobileMaxWidth = 767;
  static const int tabletMinWidth = 768;
  static const int tabletMaxWidth = 1024;

  // Check if the current device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  // Check if the current device is tablet in portrait mode
  static bool isTabletPortrait(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    return width >= tabletMinWidth &&
        width <= tabletMaxWidth &&
        orientation == Orientation.portrait;
  }

  // Check if the current device is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMinWidth;

  @override
  Widget build(BuildContext context) {
    return isTabletPortrait(context) && tabletPortrait != null
        ? tabletPortrait!
        : isTablet(context)
            ? tablet
            : mobile;
  }
}
