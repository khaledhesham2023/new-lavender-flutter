import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_back_button.dart';
import 'spacers.dart';

/// The purple header of My offers and My reports: background image, white back
/// arrow and [title], and the outlined pill toggle over [labels]
/// (`toggle_out_line_*` + `toggle_widget_background`: the selected pill is white
/// with primary text, the others are transparent with white text).
class ToggleHeader extends StatelessWidget {
  final String title;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const ToggleHeader({
    super.key,
    required this.title,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(AppAssets.icBackgroundSearch, fit: BoxFit.cover),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 54, 16, 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        title,
                        style: AppTextStyles.bold(18, AppColors.white),
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      child: AppBackButton(
                        onTap: () => context.pop(),
                        boxSize: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalSpacer(16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.cA3A3A3, width: 0.5),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: _ToggleButton(
                          text: labels[i],
                          selected: i == selected,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.white : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: AppTextStyles.bold(
            14,
            selected ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }
}
