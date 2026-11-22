import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// Port of `TextView.setHtmlContent` (`HtmlCompat.fromHtml`): renders the server HTML
/// with [style] as the base text style. [center] mirrors `gravity="center"`.
class HtmlContent extends StatelessWidget {
  final String html;
  final TextStyle style;
  final bool center;

  const HtmlContent({
    super.key,
    required this.html,
    required this.style,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = center ? '<div style="text-align:center">$html</div>' : html;
    return HtmlWidget(body, textStyle: style);
  }
}
