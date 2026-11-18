import 'package:flutter/widgets.dart';

/// Empty vertical gap of [height] (use in a Column).
class VerticalSpacer extends StatelessWidget {
  final double height;
  const VerticalSpacer(this.height, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// Empty horizontal gap of [width] (use in a Row).
class HorizontalSpacer extends StatelessWidget {
  final double width;
  const HorizontalSpacer(this.width, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}
