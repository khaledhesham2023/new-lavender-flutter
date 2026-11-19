import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/responses/doctor.dart';

/// `recycler_appointment_day_selected.xml`: day name over `M/d`.
/// Inactive days are greyed out and not tappable; tapping the selected day does nothing.
class DayChip extends StatelessWidget {
  final WorkTimeModel day;
  final bool selected;
  final VoidCallback onTap;

  const DayChip({
    super.key,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = day.isActive != 0;
    final highlighted = active && selected;
    final dayColor = !active
        ? AppColors.cE6E6E6
        : (highlighted ? AppColors.white : AppColors.c3D4C5E);
    final dateColor = !active
        ? AppColors.cE6E6E6
        : (highlighted ? AppColors.white : AppColors.c251836);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 14),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active && !selected ? onTap : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(9, 10, 9, 10),
          decoration: BoxDecoration(
            color: highlighted ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: highlighted ? null : Border.all(color: AppColors.cE6E6E6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day.dayTranslated ?? '',
                style: AppTextStyles.medium(13, dayColor),
              ),
              const SizedBox(height: 12),
              Text(
                formatDateToDayMonth(day.date ?? ''),
                style: AppTextStyles.semiBold(15, dateColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
