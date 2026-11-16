import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Port of `SuccessDialog` / `dialog_success.xml`: non-dismissible card with the
/// success gif and [title]; closes itself after 2 s. What happens next (Android type
/// "auth" -> go home) is the caller's job, after the returned future completes.
Future<void> showSuccessDialog(BuildContext context, String title) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SuccessDialog(title: title),
  );
}

class _SuccessDialog extends StatefulWidget {
  final String title;
  const _SuccessDialog({required this.title});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
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
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.successGif, width: 120, height: 120),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(16, AppColors.c101010),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
