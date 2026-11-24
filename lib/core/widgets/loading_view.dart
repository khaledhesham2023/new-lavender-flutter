import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import 'app_svg.dart';

/// Port of `loader_layout.xml`: a thin primary-colored circular indicator with the
/// Lavender logo in the middle, centered in its parent.
class LoadingView extends StatelessWidget {
  /// Diameter of the indicator (Android `indicatorSize`, 50dp).
  final double size;

  const LoadingView({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
         child: Lottie.asset("assets/lottie/lavender_loader.json", width: size, height: size, repeat: true, animate: true,)
        )
      ),
    );
  }
}
