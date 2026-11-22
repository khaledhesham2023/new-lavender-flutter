import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';

/// Temporary body for routes whose real screen belongs to a later task.
class PlaceholderScreen extends StatelessWidget {
  final String name;
  final bool showBack;
  final List<Widget> actions;

  const PlaceholderScreen({
    super.key,
    required this.name,
    this.showBack = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AppBackButton(),
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: AppTextStyles.bold(20)),
                    ...actions,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
