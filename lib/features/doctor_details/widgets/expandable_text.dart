import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';

/// Port of `showMoreText` / `showLessText`: when [text] is longer than
/// [maxLines] it is cut at the end of the last allowed line, followed by ".." and
/// an underlined "Show More" link; expanded, it ends with "Show Less".
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;
  final Color linkColor;

  const ExpandableText(
    this.text, {
    super.key,
    this.maxLines = 4,
    required this.style,
    required this.linkColor,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  final TapGestureRecognizer _tap = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _tap.onTap = () => setState(() => _expanded = !_expanded);
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  /// Offset where line [widget.maxLines] ends, or null when the text fits.
  int? _cutOffset(double width, TextDirection direction) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: direction,
    )..layout(maxWidth: width);
    final lines = painter.computeLineMetrics();
    if (lines.length <= widget.maxLines) return null;
    var y = 0.0;
    for (var i = 0; i < widget.maxLines - 1; i++) {
      y += lines[i].height;
    }
    y += lines[widget.maxLines - 1].height / 2;
    final pos = painter.getPositionForOffset(Offset(width, y));
    return painter.getLineBoundary(pos).end;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final direction = Directionality.of(context);
    final linkStyle = widget.style.copyWith(
      color: widget.linkColor,
      decoration: TextDecoration.underline,
      decorationColor: widget.linkColor,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final cut = _cutOffset(constraints.maxWidth, direction);
        if (cut == null) return Text(widget.text, style: widget.style);
        if (_expanded) {
          return Text.rich(
            TextSpan(
              style: widget.style,
              children: [
                TextSpan(text: '${widget.text} '),
                TextSpan(
                  text: l10n.showLess,
                  style: linkStyle,
                  recognizer: _tap,
                ),
              ],
            ),
          );
        }
        return Text.rich(
          TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: '${widget.text.substring(0, cut)}..'),
              TextSpan(
                text: l10n.showMore,
                style: linkStyle,
                recognizer: _tap,
              ),
            ],
          ),
        );
      },
    );
  }
}
