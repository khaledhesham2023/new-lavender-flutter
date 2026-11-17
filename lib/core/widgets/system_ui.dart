import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// Sets the status bar and bottom navigation bar look for the screen it wraps.
/// Each screen picks its own colors; the default is a white navigation bar with
/// dark icons (matches `main.dart`).
class SystemUi extends StatelessWidget {
  const SystemUi({
    super.key,
    required this.child,
    this.statusBarColor = AppColors.transparent,
    this.statusBarIconsDark = true,
    this.navigationBarColor = AppColors.white,
    this.navigationBarIconsDark = true,
  });

  final Widget child;
  final Color statusBarColor;
  final bool statusBarIconsDark;
  final Color navigationBarColor;
  final bool navigationBarIconsDark;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness:
            statusBarIconsDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarDividerColor: AppColors.transparent,
        systemNavigationBarIconBrightness:
            navigationBarIconsDark ? Brightness.dark : Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
