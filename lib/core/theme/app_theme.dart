import 'package:material_ui/material_ui.dart';

import '../widgets/capsule_transition.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'UrwDinArabic',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(primary: AppColors.primary),
      scaffoldBackgroundColor: AppColors.white,
      // Capsule-opening transition for every pushed page.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CapsulePageTransitionsBuilder(),
          TargetPlatform.iOS: CapsulePageTransitionsBuilder(),
          TargetPlatform.macOS: CapsulePageTransitionsBuilder(),
          TargetPlatform.windows: CapsulePageTransitionsBuilder(),
          TargetPlatform.linux: CapsulePageTransitionsBuilder(),
          TargetPlatform.fuchsia: CapsulePageTransitionsBuilder(),
        },
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        modalBackgroundColor: AppColors.transparent,
      ),
    );
    // Android theme default font is urw_din_arabic_medium.
    return base.copyWith(
      textTheme: base.textTheme
          .apply(fontFamily: 'UrwDinArabic')
          .copyWith(
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: base.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            bodySmall: base.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }
}
