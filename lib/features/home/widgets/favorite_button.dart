import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/widgets/app_svg.dart';

/// Heart with the Android bounce (scale 1 -> 1.4 -> 1, 180 ms each way, overshoot).
class FavoriteButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onTap;

  const FavoriteButton({super.key, required this.isFav, required this.onTap});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 1,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AppSvg(
          widget.isFav ? AppAssets.icFavoriteActive : AppAssets.icFavoriteInactive,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
