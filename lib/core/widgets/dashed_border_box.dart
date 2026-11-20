import 'package:material_ui/material_ui.dart';

/// Rounded box with a dashed border (`bg_stroke_dashed_*` drawables): a
/// [CustomPainter], no package. Defaults match Android: 1 wide, 2 dash, 2 gap.
class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color fillColor;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.borderColor,
    required this.fillColor,
    this.radius = 10,
    this.strokeWidth = 1,
    this.dashWidth = 2,
    this.dashGap = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderColor: borderColor,
        fillColor: fillColor,
        radius: radius,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  _DashedBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = fillColor);
    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), stroke);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.borderColor != borderColor ||
      old.fillColor != fillColor ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashWidth != dashWidth ||
      old.dashGap != dashGap;
}
