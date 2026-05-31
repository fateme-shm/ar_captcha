// lib/utils/screen_utils.dart

// Flutter imports:
import 'package:flutter/material.dart';

enum DeviceScreenSizeType { mobile, tablet, desktop }

extension ScreenSizeUtil on BuildContext {
  DeviceScreenSizeType get screenSizeType {
    double width = MediaQuery.of(this).size.width;

    if (width >= ScreenSizeBreakpoints.desktopMinWidth) {
      return DeviceScreenSizeType.desktop;
    }
    if (width >= ScreenSizeBreakpoints.mobileMaxWidth) {
      return DeviceScreenSizeType.tablet;
    }
    return DeviceScreenSizeType.mobile;
  }
}

// Mobile: ≤ 599px (covers most phones in portrait/landscape)
// Tablet: 600–1023px (7"–10" tablets, iPad, small laptops)
// Desktop: ≥ 1024px (desktops, large laptops)

/// Standard breakpoints (Material Design inspired)
class ScreenSizeBreakpoints {
  static const double mobileMaxWidth = 600;
  static const double desktopMinWidth = 1024;
}
