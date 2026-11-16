import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_assets.dart';
import 'app_svg.dart';
import 'loading_view.dart';

/// Port of `loadImageFromInternet`: a loader while loading, the Android default
/// error image (`ic_server_error`) when the url is empty or fails.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final bool circle;
  final String? errorAsset;

  const AppNetworkImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.circle = false,
    this.errorAsset,
  });

  Widget _error() => Center(
        child: AppSvg(
          errorAsset ?? AppAssets.icServerError,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final u = url;
    final Widget image = (u == null || u.isEmpty)
        ? _error()
        : CachedNetworkImage(
            imageUrl: u,
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (_, _) {
              var s = 50.0;
              for (final d in [width, height]) {
                if (d != null && d.isFinite && d < s) s = d;
              }
              return LoadingView(size: s);
            },
            errorWidget: (_, _, _) => _error(),
          );
    final sized = SizedBox(width: width, height: height, child: image);
    if (circle) return ClipOval(child: sized);
    if (radius > 0) return ClipRRect(borderRadius: BorderRadius.circular(radius), child: sized);
    return sized;
  }
}
