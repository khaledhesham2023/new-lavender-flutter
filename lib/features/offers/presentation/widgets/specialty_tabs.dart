import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/responses/speciality.dart';

/// Horizontal specialty chips (`rvCategory` + `OffersTabAdapter`). Tapping a chip
/// scrolls it into view and reports it through [onSelected].
class SpecialtyTabs extends StatefulWidget {
  final List<SpecialityModel> specialities;
  final int? selectedId;
  final ValueChanged<SpecialityModel> onSelected;

  const SpecialtyTabs({
    super.key,
    required this.specialities,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<SpecialtyTabs> createState() => _SpecialtyTabsState();
}

class _SpecialtyTabsState extends State<SpecialtyTabs> {
  final Map<int, GlobalKey> _keys = {};

  void _scrollTo(int id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[id]?.currentContext;
      if (ctx == null || !ctx.mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final tab in widget.specialities)
            _Tab(
              key: _keys.putIfAbsent(tab.id, GlobalKey.new),
              title: tab.name ?? '',
              selected: tab.id == widget.selectedId,
              onTap: () {
                widget.onSelected(tab);
                _scrollTo(tab.id);
              },
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
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 6),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(
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
