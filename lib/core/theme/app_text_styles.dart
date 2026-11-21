import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Ports of the Android text styles (`bold_font`, `medium_font`, `regular_font`,
/// `semi_bold`, `messiri_bold_font`, `discount_font`). `height: 1.0` mimics
/// `includeFontPadding=false`. [size] is the Android `sp` value.
abstract final class AppTextStyles {
  static const String urw = 'UrwDinArabic';
  static const String messiri = 'Messiri';
  static const String comicSans = 'ComicSans';

  static TextStyle _style(String family, FontWeight weight, double size, Color color) =>
      TextStyle(fontFamily: family, fontWeight: weight, fontSize: size, color: color, height: 1.3);

  static TextStyle bold(double size, [Color color = AppColors.c251836]) =>
      _style(urw, FontWeight.w700, size, color);

  static TextStyle semiBold(double size, [Color color = AppColors.c251836]) =>
      _style(urw, FontWeight.w600, size, color);

  static TextStyle medium(double size, [Color color = AppColors.c251836]) =>
      _style(urw, FontWeight.w500, size, color);

  static TextStyle regular(double size, [Color color = AppColors.c251836]) =>
      _style(urw, FontWeight.w400, size, color);

  static TextStyle messiriBold(double size, [Color color = AppColors.c251836]) =>
      _style(messiri, FontWeight.w700, size, color);

  static TextStyle messiriSemiBold(double size, [Color color = AppColors.c251836]) =>
      _style(messiri, FontWeight.w600, size, color);

  static TextStyle discount(double size, [Color color = AppColors.c251836]) =>
      _style(comicSans, FontWeight.w700, size, color);
}
