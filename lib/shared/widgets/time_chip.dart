import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/responses/doctor.dart';

/// `recycler_available_time_item.xml`: a 37dp-high rounded cell with the time.
/// Reserved times are greyed out and not tappable.
class TimeChip extends StatelessWidget {
  final TimeModel time;
  final bool selected;
  final VoidCallback onTap;

  const TimeChip({
    super.key,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reserved = time.isReserved;
    final highlighted = !reserved && selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: reserved ? null : onTap,
        child: Container(
          height: 37,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlighted ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: highlighted ? null : Border.all(color: AppColors.cE6E6E6),
          ),
          child: Text(
            time.time ?? '',
            style: AppTextStyles.semiBold(
              13,
              reserved
                  ? AppColors.cE6E6E6
                  : (highlighted ? AppColors.white : AppColors.c3D4C5E),
            ),
          ),
        ),
      ),
    );
  }
}
