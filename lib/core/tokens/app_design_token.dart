import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDesignToken {
  AppDesignToken._();

  // Card inner padding for container/section cards (was 20.r)
  static EdgeInsets get cardPadding => EdgeInsets.all(16.r);

  // Gaps
  static double get cardTitleGap => 12.h;
  static double get infoRowGap => 8.h;
  static double get sectionGap => 12.h;
  static double get itemGap => 8.h;
  static double get subtitleContentGap => 12.h;
  static double get buttonGap => 8.h;
  static double get buttonSectionGap => 12.h;
  static double get movementGroupGap => 16.h;
  static double get tileGap => 8.h;
  static double get formFieldGap => 10.h;
}