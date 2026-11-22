import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/enums.dart';

/// Scrollable status tabs (`tabLayoutBookingStatus`): Pending, Confirmed,
/// Processing, Completed, Canceled, Rejected. Tapping the selected tab does
/// nothing (Android `onTabReselected`).
class StatusTabs extends StatefulWidget {
  final BookingStatus selected;
  final ValueChanged<BookingStatus> onSelected;

  const StatusTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<StatusTabs> createState() => _StatusTabsState();
}

class _StatusTabsState extends State<StatusTabs> {
  final Map<BookingStatus, GlobalKey> _keys = {
    for (final s in BookingStatus.values) s: GlobalKey(),
  };

  @override
  void didUpdateWidget(StatusTabs old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _scrollToSelected();
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[widget.selected]?.currentContext;
      if (ctx == null || !ctx.mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _label(BuildContext context, BookingStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      BookingStatus.pending => l10n.pendingForConfirmation,
      BookingStatus.confirmed => l10n.confirmed,
      BookingStatus.processing => l10n.processing,
      BookingStatus.completed => l10n.completed,
      BookingStatus.canceled => l10n.canceled,
      BookingStatus.rejected => l10n.rejected,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: [
          for (final status in BookingStatus.values)
            _Tab(
              key: _keys[status],
              title: _label(context, status),
              selected: status == widget.selected,
              onTap: () => widget.onSelected(status),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        // TabLayout scrollable mode: 72dp minimum width, 48dp height.
        constraints: const BoxConstraints(minWidth: 72, minHeight: 48),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                child: Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.semiBold(
                    14,
                    selected ? AppColors.primary : AppColors.c3D4C5E,
                  ),
                ),
              ),
              SizedBox(
                height: 2,
                child: selected
                    ? const ColoredBox(color: AppColors.primary)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
