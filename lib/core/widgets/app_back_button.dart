import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import 'app_svg.dart';

/// Back arrow used in screen headers (`ivBack`); mirrored in RTL by [AppSvg].
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  /// Tap area (square); the icon is centered inside it.
  final double boxSize;

  const AppBackButton({
    super.key,
    this.onTap,
    this.size = 36,
    this.color,
    this.boxSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap ?? () => Navigator.maybePop(context),
      radius: boxSize / 2,
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: Center(
          child: AppSvg(
            AppAssets.icBack,
            width: size,
            height: size,
            color: color,
          ),
        ),
      ),
    );
  }
}
