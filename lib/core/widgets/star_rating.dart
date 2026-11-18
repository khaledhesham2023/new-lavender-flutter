import 'package:flutter/widgets.dart';

import '../theme/app_assets.dart';
import 'app_svg.dart';
import 'spacers.dart';

/// Port of `CustomRatingBar`. Read-only: shows [score] rounded to the nearest 0.5
/// (full / half / empty stars). Not read-only: tap or drag to choose 1..[count]
/// whole stars, reported through [onChanged]; the parent keeps the value in [score].
class StarRating extends StatelessWidget {
  final double score;
  final double size;
  final bool readOnly;
  final ValueChanged<double>? onChanged;
  final int count;

  static const double _gap = 2;

  const StarRating({
    super.key,
    required this.score,
    this.size = 16,
    this.readOnly = true,
    this.onChanged,
    this.count = 5,
  });

  double get _width => count * size + (count - 1) * _gap;

  /// Android `score` setter: nearest half, capped at [count].
  double get _shown {
    final s = (score * 2).round() / 2.0;
    return s > count ? count.toDouble() : s;
  }

  double _scoreFor(double dx, bool rtl) {
    final x = rtl ? _width - dx : dx;
    final v = (x / (_width / count)).round().toDouble();
    return v.clamp(1, count).toDouble();
  }

  void _update(Offset p, bool rtl) {
    final v = _scoreFor(p.dx, rtl);
    if (v != score) onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    final half = shown != 0 && shown % 0.5 == 0;
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++) ...[
          if (i > 1) const HorizontalSpacer(_gap),
          AppSvg(
            i <= shown
                ? AppAssets.icFullStar
                : (half && i - 0.5 <= shown
                      ? AppAssets.icHalf
                      : AppAssets.icEmptyStar),
            width: size,
            height: size,
          ),
        ],
      ],
    );
    if (readOnly) return stars;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _update(d.localPosition, rtl),
      onHorizontalDragUpdate: (d) => _update(d.localPosition, rtl),
      child: stars,
    );
  }
}
