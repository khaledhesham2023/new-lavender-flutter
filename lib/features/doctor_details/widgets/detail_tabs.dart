import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// The three custom tab buttons (`tabLayoutHolder`): selected = primary fill
/// with white text (`bg_selected_tab`), others transparent with `c3D4C5E` text.
class DetailTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const DetailTabs({super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [l10n.bookingAppointments, l10n.generalInfo, l10n.reviews];
    return Container(
      height: 58,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cE6E6E6),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      12,
                      i == index ? AppColors.white : AppColors.c3D4C5E,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
