import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

/// Lottie played at a custom speed (`lottie_speed`), once or looping.
class SpeedLottie extends StatefulWidget {
  final String asset;
  final double speed;
  final bool repeat;

  const SpeedLottie({
    super.key,
    required this.asset,
    required this.speed,
    required this.repeat,
  });

  @override
  State<SpeedLottie> createState() => _AssetLottieState();
}

class _AssetLottieState extends State<SpeedLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  LottieComposition? _composition;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final composition = await AssetLottie(widget.asset).load();
    if (!mounted) return;
    setState(() => _composition = composition);
    _controller.duration = composition.duration * (1 / widget.speed);
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final composition = _composition;
    if (composition == null) return const SizedBox.shrink();
    // Clip: the animation can paint outside its box (e.g. under the status bar).
    return ClipRect(
      child: Lottie(
        composition: composition,
        controller: _controller,
        frameRate: FrameRate.max,
      ),
    );
  }
}
