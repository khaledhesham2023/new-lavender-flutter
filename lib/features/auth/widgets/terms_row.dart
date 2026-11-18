import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/spacers.dart';
import 'field_error.dart';

/// `cbTermsAndCondition` + `tvTermsAndCondition` + `tvTermsAndConditionError`:
/// tapping the box or "Agree to the" toggles it, the bold part opens the terms,
/// and [showError] shows the "please accept" line below.
class TermsRow extends StatelessWidget {
  final bool checked;
  final bool showError;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;

  const TermsRow({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.onOpenTerms,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(!checked),
                child: Row(
                  children: [
                    AppSvg(
                      checked ? AppAssets.icCheckTrue : AppAssets.icCheckFalse,
                      width: 24,
                      height: 24,
                    ),
                    const HorizontalSpacer(5),
                    Text(
                      l10n.agreeToThe,
                      style: AppTextStyles.regular(14, AppColors.c7E94B0),
                    ),
                  ],
                ),
              ),
              const HorizontalSpacer(5),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onOpenTerms,
                  child: Text(
                    l10n.termsAndConditions,
                    style: AppTextStyles.bold(14, AppColors.c251836),
                  ),
                ),
              ),
            ],
          ),
          if (showError) FieldErrorText(l10n.pleaseAcceptTheTermsAndConditions),
        ],
      ),
    );
  }
}
