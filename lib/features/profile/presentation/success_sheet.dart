import 'dart:async';

import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';

/// Which message the sheet shows (Android `SuccessChangePhoneSheet` args.type).
enum ProfileSuccessType { changePhone, changePassword, forgetPasswordForEdit }

/// Port of `SuccessChangePhoneSheet`: non-dismissible sheet with the success gif and a
/// message; closes itself after 2 s. The future completes when it is gone.
Future<void> showProfileSuccessSheet(
  BuildContext context,
  ProfileSuccessType type,
) {
  return showAppBottomSheet<void>(
    context,
    isDismissible: false,
    builder: (_) => _SuccessSheet(type: type),
  );
}

class _SuccessSheet extends StatefulWidget {
  final ProfileSuccessType type;
  const _SuccessSheet({required this.type});

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = widget.type == ProfileSuccessType.changePhone
        ? l10n.phoneChangedSuccessfully
        : l10n.passwordChangedSuccessfully;
    return PopScope(
      canPop: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.successGif,
              width: 120,
              height: 120,
              errorBuilder: (_, _, _) =>
                  const SizedBox(width: 120, height: 120),
            ),
            const VerticalSpacer(16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bold(16, AppColors.c101010),
            ),
          ],
        ),
      ),
    );
  }
}
