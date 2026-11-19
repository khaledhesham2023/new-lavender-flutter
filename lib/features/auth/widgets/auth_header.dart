import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/spacers.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_svg.dart';

/// Shared top of the auth screens: hexagon background, centered logo, back arrow
/// at the start, bold title and regular body (`ivHeader`, `ivLogo`, `ivBack`, `tvTitle`, `tvBody`).
class AuthHeader extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onBack;

  /// Rich replacement for [body] (the OTP screen embeds the phone number in it).
  final InlineSpan? bodySpan;

  const AuthHeader({
    super.key,
    required this.title,
    required this.body,
    required this.onBack,
    this.bodySpan,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            AppAssets.icAuthHeaderBg,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        // Full width, otherwise the Stack shrinks to the text and the title is not centered.
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 32,
            bottom: 36,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                // Full width, otherwise this Stack shrinks to the logo and the
                // back button lands on top of it instead of the screen edge.
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const AppSvg(AppAssets.icLogo, width: 65, height: 50),
                      // 36x36 tap area, vertically centered on the logo.
                      PositionedDirectional(
                        start: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: AppBackButton(
                            onTap: onBack,
                            size: 36,
                            boxSize: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalSpacer(50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold(18, AppColors.c251836),
                  ),
                ),
                const VerticalSpacer(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    bodySpan ?? TextSpan(text: body),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regular(
                      14,
                      AppColors.c47586E,
                    ).copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
