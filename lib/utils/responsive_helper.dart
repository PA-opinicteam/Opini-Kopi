import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  const ResponsiveHelper._();

  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMaxWidth) return DeviceType.mobile;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  static double pagePadding(BuildContext context) =>
      isMobile(context) ? 16 : 32;

  static int menuGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 520) return 2;
    if (width < 900) return 2;
    if (width < 1280) return 3;
    return 4;
  }
}
