import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

/// Plays an onboarding Lottie once, slower than its authored speed.
class OnboardingArt extends StatefulWidget {
  const OnboardingArt({super.key, required this.asset});

  final String asset;

  @override
  State<OnboardingArt> createState() => OnboardingArtState();
}

class OnboardingArtState extends State<OnboardingArt>
    with SingleTickerProviderStateMixin {
  /// 1.0 = authored speed; larger = slower.
  static const double _slowdown = 1.6;

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
    _controller.duration = composition.duration * _slowdown;
    _controller.forward();
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
    return Lottie(
      composition: composition,
      controller: _controller,
      frameRate: FrameRate.max,
    );
  }
}
