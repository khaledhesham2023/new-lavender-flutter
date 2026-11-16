import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import 'bottom_sheet_frame.dart';
import 'state_view.dart';

/// Port of `MustLoginSheetFragment`: asks a guest to log in. The Login button closes
/// the sheet, then opens the auth flow on top (Android `AuthActivity.start`).
Future<void> showMustLoginSheet(BuildContext context) {
  final l10n = context.l10n;
  return showAppBottomSheet<void>(
    context,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 5,
          margin: const EdgeInsets.only(top: 21),
          decoration: BoxDecoration(
            color: AppColors.cDCDCE4,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StateView.empty(
            icon: AppAssets.icMustLogin,
            title: l10n.youMustLoginTitle,
            body: l10n.youMustLoginBody,
            buttonTitle: l10n.login,
            onButton: () {
              Navigator.of(sheetContext).pop();
              // TODO(T10): route constant
              context.push('/auth/start');
            },
          ),
        ),
      ],
    ),
  );
}
