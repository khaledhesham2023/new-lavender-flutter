import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/spacers.dart';

/// `clAttachment`: PDF icon, title and download icon; the whole row downloads.
class ReportRow extends StatelessWidget {
  final VoidCallback onTap;

  const ReportRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14).copyWith(left: 10, right: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cE6E6E6),
        ),
        child: Row(
          children: [
            const AppSvg(AppAssets.icPdfAttachment),
            const HorizontalSpacer(10),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 58),
                child: Text(
                  context.l10n.medicalReportPdf,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold(14, AppColors.c10162E),
                ),
              ),
            ),
            const HorizontalSpacer(10),
            const AppSvg(AppAssets.icDownload),
          ],
        ),
      ),
    );
  }
}

/// 56dp-high rounded (16) bar button: primary-filled or primary-outlined. A
/// disabled filled one stays primary like Android's `isEnabled = false`, except
/// the grey edit button (`bg_btn_grey_color_rounded_12`).
class DetailsBarButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool enabled;
  final String? icon;
  final VoidCallback onTap;

  const DetailsBarButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final grey = filled && !enabled && icon == null;
    final background = !filled
        ? AppColors.white
        : (grey ? AppColors.cBEBEBE : AppColors.primary);
    final textColor = filled ? AppColors.white : AppColors.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: AppColors.primary),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                AppSvg(icon!),
                const HorizontalSpacer(7),
              ],
              Text(
                label,
                maxLines: 1,
                style: AppTextStyles.bold(14, textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
