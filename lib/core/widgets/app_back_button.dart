import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import 'app_svg.dart';

/// Back arrow used in screen headers (`ivBack`); mirrored in RTL by [AppSvg].
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  const AppBackButton({super.key, this.onTap, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap ?? () => Navigator.maybePop(context),
      radius: size,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AppSvg(AppAssets.icBack, width: size, height: size, color: color),
      ),
    );
  }
}
