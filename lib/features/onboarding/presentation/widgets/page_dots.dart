import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';

/// Circular page dots. The selected indicator stretches from the old dot to the
/// new one (leading edge moves first, trailing edge catches up), then settles.
class PageDots extends StatefulWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  State<PageDots> createState() => PageDotsState();
}

class PageDotsState extends State<PageDots>
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
  void didUpdateWidget(PageDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _from = oldWidget.index;
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
    final width =
        widget.count * _dot + (widget.count - 1) * _gap + _selectedExtra;
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
    const dot = PageDotsState._dot;
    const gap = PageDotsState._gap;
    const extra = PageDotsState._selectedExtra;
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
      old.t != t ||
      old.rtl != rtl ||
      old.from != from ||
      old.to != to ||
      old.count != count;
}
