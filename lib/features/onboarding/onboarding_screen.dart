import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/system_ui.dart';
import '../../router/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  static const _lottiesAr = [
    AppAssets.onbaording1Ar,
    AppAssets.onbaording2Ar,
    AppAssets.onbaording3Ar,
  ];
  static const _lottiesEn = [
    AppAssets.onboarding1En,
    AppAssets.onboarding2En,
    AppAssets.onboarding3En,
  ];

  Future<void> _next() async {
    if (_index < 2) {
      setState(() => _index++);
      return;
    }
    await sl<AppPrefs>().setFirstTime(false);
    if (mounted) context.go(Routes.authStart);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = sl<AppPrefs>().languageCode == 'ar';
    final titles = [
      l10n.allYourMedicalServicesInOnePlace,
      l10n.bookEasilyAnytime,
      l10n.regularMonitoringOfYourHealth,
    ];
    final bodies = [
      l10n.noNeedToSearchInMultiplePlaces,
      l10n.browseTheListOfDoctorsAndServices,
      l10n.keepADigitalMedicalRecordThatIncludesYourPreviousAppointments,
    ];
    final lottie = (isAr ? _lottiesAr : _lottiesEn)[_index];

    return SystemUi(
      statusBarColor: AppColors.white,
      navigationBarColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _OnboardingArt(
                        key: ValueKey(lottie),
                        asset: lottie,
                      ),
                    ),
                    // on_boarding_color: transparent -> white fade over the art.
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.c00FFFFFF, AppColors.white],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  titles[_index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(20, AppColors.black),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  bodies[_index],
                  textAlign: TextAlign.center,
                  // Box shrinks to the longest line so lines look balanced.
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: AppTextStyles.medium(14, AppColors.c666666),
                ),
              ),
              const SizedBox(height: 36),
              _PageDots(count: 3, index: _index),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: GestureDetector(
                  onTap: _next,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _index == 2 ? l10n.startNow : l10n.next,
                      style: AppTextStyles.bold(14, AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular page dots. The selected indicator stretches from the old dot to the
/// new one (leading edge moves first, trailing edge catches up), then settles.
class _PageDots extends StatefulWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  State<_PageDots> createState() => _PageDotsState();
}

class _PageDotsState extends State<_PageDots>
    with SingleTickerProviderStateMixin {
  static const double _dot = 8;
  static const double _gap = 8;
  static const double _selectedExtra = 16;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1,
  );
  int _from = 0;

  @override
  void initState() {
    super.initState();
    _from = widget.index;
  }

  @override
  void didUpdateWidget(_PageDots old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _from = old.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.count * _dot + (widget.count - 1) * _gap + _selectedExtra;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      width: width,
      height: _dot,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _DotsPainter(
            count: widget.count,
            from: _from,
            to: widget.index,
            t: _controller.value,
            rtl: rtl,
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.count,
    required this.from,
    required this.to,
    required this.t,
    required this.rtl,
  });

  final bool rtl;
  final int count;
  final int from;
  final int to;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (rtl) {
      // Mirror so the first dot is on the right in RTL (Arabic).
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    const dot = _PageDotsState._dot;
    const gap = _PageDotsState._gap;
    const extra = _PageDotsState._selectedExtra;
    // Selection position glides from the old dot to the new one; each dot grows
    // into a rounded rect by how close the selection is (stretches, then settles).
    final s = from + (to - from) * Curves.easeInOut.transform(t);
    var x = 0.0;
    for (var i = 0; i < count; i++) {
      final w = (1 - (i - s).abs()).clamp(0.0, 1.0);
      final width = dot + extra * w;
      final color = Color.lerp(AppColors.cE6E6E6, AppColors.primary, w)!;
      canvas.drawRRect(
        RRect.fromLTRBR(x, 0, x + width, dot, const Radius.circular(dot / 2)),
        Paint()..color = color,
      );
      x += width + gap;
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.t != t || old.rtl != rtl || old.from != from || old.to != to || old.count != count;
}

/// Plays an onboarding Lottie once, slower than its authored speed.
class _OnboardingArt extends StatefulWidget {
  const _OnboardingArt({super.key, required this.asset});

  final String asset;

  @override
  State<_OnboardingArt> createState() => _OnboardingArtState();
}

class _OnboardingArtState extends State<_OnboardingArt>
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
