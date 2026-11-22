import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../app/router/routes.dart';

/// Port of `SuccessFragment`: password changed; the button and system back go to Login.
class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key});

  static const double _gifSize = 140;

  void _backToLogin(BuildContext context) => context.go(Routes.authLogin);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLogin(context);
      },
      child: SystemUi(
        statusBarColor: AppColors.white,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              // layout_constraintVertical_bias=0.3 of the 140dp GIF in the full screen.
              final top = 0.3 * (constraints.maxHeight - _gifSize);
              return Stack(
                children: [
                  Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Image.asset(
                          AppAssets.successGif,
                          width: _gifSize,
                          height: _gifSize,
                        ),
                        const SizedBox(height: 60),
                        Text(
                          l10n.passwordChangedSuccessfullyTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bold(18, AppColors.c251836),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.passwordChangedSuccessfullyBody,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.regular(14, AppColors.c47586E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.paddingOf(context).bottom,
                    child: ProgressButton(
                      text: l10n.passwordChangedSuccessfullyBtn,
                      onPressed: () => _backToLogin(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
