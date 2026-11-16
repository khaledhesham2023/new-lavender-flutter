import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';

/// `SvgPicture.asset` that flips auto-mirrored vectors (`autoMirroredSvgs`) in RTL.
class AppSvg extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppSvg(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    Widget svg = SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
    if (autoMirroredSvgs.contains(asset) && Directionality.of(context) == TextDirection.rtl) {
      svg = Transform.flip(flipX: true, child: svg);
    }
    return svg;
  }
}
