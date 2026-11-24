import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Page transition for the whole app: a medicine capsule spins in over the
/// current page, then splits open and its halves slide away to reveal the new
/// page. Popping plays the same animation in reverse (the capsule closes).
///
/// Plugged into [ThemeData.pageTransitionsTheme] (every `builder:` route) and
/// into the custom pages of `app_router.dart`.
class CapsulePageTransitionsBuilder extends PageTransitionsBuilder {
  const CapsulePageTransitionsBuilder();

  @override
  Duration get transitionDuration => CapsuleTransition.forwardDuration;

  @override
  Duration get reverseTransitionDuration => CapsuleTransition.reverseDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CapsuleTransition(animation: animation, child: child);
  }
}

class CapsuleTransition extends StatelessWidget {
  const CapsuleTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  static const Duration forwardDuration = Duration(milliseconds: 600);
  static const Duration reverseDuration = Duration(milliseconds: 450);

  /// 0 → [_coverEnd]: scrim fades in and the capsule spins/scales in.
  /// [_coverEnd] → [_openStart]: the closed capsule holds.
  /// [_openStart] → 1: the halves part and the new page shows through.
  static const double _coverEnd = 0.3;
  static const double _openStart = 0.4;

  final Animation<double> animation;
  final Widget child;

  static final Color _scrimColor = Color.alphaBlend(
    AppColors.primary.withValues(alpha: 0.07),
    AppColors.white,
  );

  static double _segment(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final capsuleWidth = math.min(size.width * 0.8, 340.0);
    return AnimatedBuilder(
      animation: animation,
      // The page is built once and re-parented, never rebuilt per frame.
      child: child,
      builder: (context, page) {
        final t = animation.value;
        final cover = Curves.easeOutCubic.transform(_segment(t, 0, _coverEnd));
        final open = Curves.easeInOutCubic.transform(
          _segment(t, _openStart, 1),
        );
        final scrim = t < _openStart
            ? cover
            : 1 - Curves.easeIn.transform(_segment(t, _openStart, 0.7));
        final halvesFade = 1 - _segment(open, 0.75, 1);
        return Stack(
          fit: StackFit.expand,
          children: [
            // Hidden (but kept alive) until the scrim fully covers the old page.
            Visibility(
              visible: t >= _coverEnd,
              maintainState: true,
              child: page!,
            ),
            if (t > 0 && t < 1)
              IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: _scrimColor.withValues(alpha: scrim)),
                    Center(
                      child: Opacity(
                        opacity: (cover * halvesFade).clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: -0.6 * (1 - cover),
                          child: Transform.scale(
                            scale: 0.55 + 0.45 * cover,
                            child: _Capsule(
                              width: capsuleWidth,
                              shift: open * (size.width / 2 + 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Two-tone capsule whose halves are pushed [shift] pixels apart.
class _Capsule extends StatelessWidget {
  const _Capsule({required this.width, required this.shift});

  final double width;
  final double shift;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.38;
    final radius = Radius.circular(height / 2);
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        // Physical left/right regardless of the app's RTL locale.
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Transform.translate(
              offset: Offset(-shift, 0),
              child: _Half(
                color: AppColors.primary,
                borderRadius: BorderRadius.horizontal(left: radius),
                glossAlignment: Alignment.topLeft,
                glossInset: height / 2,
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: Offset(shift, 0),
              child: _Half(
                color: AppColors.white,
                borderColor: AppColors.primary,
                borderRadius: BorderRadius.horizontal(right: radius),
                glossAlignment: Alignment.topRight,
                glossInset: height / 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({
    required this.color,
    required this.borderRadius,
    required this.glossAlignment,
    required this.glossInset,
    this.borderColor,
  });

  final Color color;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final Alignment glossAlignment;
  final double glossInset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Align(
        alignment: glossAlignment,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            glossInset * 0.8,
            10,
            glossInset * 0.8,
            0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (borderColor == null ? AppColors.white : AppColors.primary)
                  .withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const SizedBox(height: 6, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
