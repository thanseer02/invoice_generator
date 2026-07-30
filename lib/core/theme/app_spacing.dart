import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // EdgeInsets
  static const EdgeInsets edgeInsetsAllSm = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsAllMd = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsAllLg = EdgeInsets.all(lg);
  
  static const EdgeInsets edgeInsetsHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets edgeInsetsHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets edgeInsetsHLg = EdgeInsets.symmetric(horizontal: lg);
  
  static const EdgeInsets edgeInsetsVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets edgeInsetsVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets edgeInsetsVLg = EdgeInsets.symmetric(vertical: lg);
}
