import 'package:flutter/material.dart';

class AppSizes {
  const AppSizes._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pagePadding = 32;
  static const double mobilePadding = 16;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusDialog = 24;

  static const double title = 24;
  static const double subtitle = 16;
  static const double body = 14;

  static double adaptivePagePadding(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 48.0;
    if (width > 600) return 24.0;  
    return 12.0;                  
  }

  static double adaptiveTitle(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 32.0; 
    if (width > 600) return 26.0;  
    return 20.0;                 
  }

  static double adaptiveSubtitle(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width > 600) return 16.0; 
    return 14.0;                  
  }

  static double adaptiveBody(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width > 600) return 14.0; 
    return 12.0;                   
  }
}