import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Port of `ParentSheetFragment` + `AppBottomSheetDialogTheme`: modal sheet with a
/// white rounded-top (24) container, dimmed barrier, keyboard-aware padding.
/// [isDismissible] maps to Android `isCancel`; [expanded] to `isFull`.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool expanded = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    barrierColor: const Color(0x4D000000),
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    builder: (ctx) {
      Widget content = Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(top: false, child: builder(ctx)),
      );
      if (expanded) {
        content = FractionallySizedBox(heightFactor: 0.9, child: content);
      }
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: content,
      );
    },
  );
}

/// White as it looks under a sheet's dimmed barrier (`0x4D000000`). The status bar is
/// painted by the system, so the barrier cannot dim it: a screen with a white status
/// bar switches to this colour while a sheet is open.
final Color dimmedWhiteStatusBar = Color.alphaBlend(
  const Color(0x4D000000),
  AppColors.white,
);
