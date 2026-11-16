import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import 'app_svg.dart';

/// Port of `loader_layout.xml`: a thin primary-colored circular indicator with the
/// Lavender logo in the middle, centered in its parent.
class LoadingView extends StatelessWidget {
  /// Diameter of the indicator (Android `indicatorSize`, 50dp).
  final double size;

  const LoadingView({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    final logo = size * 0.6;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
                backgroundColor: Color(0x1F000000),
              ),
            ),
            AppSvg(AppAssets.icSideMenuLogo, width: logo, height: logo),
          ],
        ),
      ),
    );
  }
}
