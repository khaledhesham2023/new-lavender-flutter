import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_svg.dart';

/// Guest replacement of the next-reservation card (`clGuest`): the body line is
/// the tappable "log in" call.
class GuestCard extends StatelessWidget {
  final VoidCallback onLogin;

  const GuestCard({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cF8F6FA,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cE9EBF8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 16,
                end: 28,
                top: 24,
                bottom: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.tvGuestTitle,
                    style: AppTextStyles.semiBold(14, AppColors.c251836),
                  ),
                  const SizedBox(height: 11),
                  AppLink(
                    text: l10n.tvGuestBody,
                    size: 12,
                    weight: FontWeight.w600,
                    onTap: onLogin,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 6, bottom: 6, end: 6),
            child: AppSvg(AppAssets.icGuestHome, width: 80, height: 80),
          ),
        ],
      ),
    );
  }
}
