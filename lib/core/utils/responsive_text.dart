import 'package:flutter/material.dart';

extension ResponsiveTextX on BuildContext {
  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1024;

  bool get isTablet => MediaQuery.sizeOf(this).width >= _tabletBreakpoint;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= _desktopBreakpoint;

  /// Responsive size based on screen width (for spacing,
  /// icons, images — things that are NOT text).
  /// For text use [responsiveTextStyle] instead.
  double responsiveSize(
    double mobileSize, {
    double? tabletSize,
    double? desktopSize,
  }) {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= _desktopBreakpoint) {
      return desktopSize ?? tabletSize ?? mobileSize;
    }
    if (width >= _tabletBreakpoint) {
      return tabletSize ?? (mobileSize * 1.15);
    }
    return mobileSize;
  }

  /// Responsive font size that respects the user's system font preference
  /// (accessibility). Always use this for text.
  ///
  /// Flutter applies the system text scaler automatically to this fontSize,
  /// but we also adjust for screen breakpoints here.
  TextStyle responsiveTextStyle({
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      // Flutter applies the system text scaler to this fontSize
      // automatically — no manual scaling required.
      fontSize: responsiveSize(
        mobileSize,
        tabletSize: tabletSize,
        desktopSize: desktopSize,
      ),
      color: color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Responsive symmetric vertical padding. Useful for containers that
  /// wrap text and cannot have a fixed height (e.g., search bars, chips).
  EdgeInsets responsiveVerticalPadding({
    required double mobile,
    double? tablet,
  }) {
    return EdgeInsets.symmetric(
      vertical: responsiveSize(mobile, tabletSize: tablet),
    );
  }
}
