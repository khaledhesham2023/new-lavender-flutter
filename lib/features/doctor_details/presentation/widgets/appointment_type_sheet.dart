import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/bottom_sheet_frame.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../../../core/widgets/progress_button.dart';
import '../../../../data/models/responses/offer.dart';

/// Id of the sentinel [OfferModel] meaning "normal examination".
const normalExaminationId = -1;

/// Port of `AppointmentTypeSheetFragment`: pick a normal examination or one of
/// the doctor's purchased offers. Resolves to the chosen offer (id
/// [normalExaminationId] for the normal examination) or null when closed.
Future<OfferModel?> showAppointmentTypeSheet(
  BuildContext context, {
  required String? price,
  required List<OfferModel> offers,
}) {
  final l10n = context.l10n;
  // Android passes `examinationPrice?.toFloat()` into the string ("150.0").
  final rows = <OfferModel>[
    OfferModel(
      id: normalExaminationId,
      name: l10n.examinationBook,
      description: l10n.bookNormalExaminationWithValue(
        double.tryParse(price ?? '').toString(),
      ),
    ),
    ...offers,
  ];
  return showAppBottomSheet<OfferModel>(
    context,
    builder: (_) => _AppointmentTypeView(rows: rows),
  );
}

class _AppointmentTypeView extends StatefulWidget {
  final List<OfferModel> rows;

  const _AppointmentTypeView({required this.rows});

  @override
  State<_AppointmentTypeView> createState() => _AppointmentTypeViewState();
}

class _AppointmentTypeViewState extends State<_AppointmentTypeView> {
  int? _selected;

  void _confirm() {
    final index = _selected;
    if (index == null) {
      AppToast.show(
        context,
        context.l10n.pleaseSelectAppointmentType,
        ToastType.failed,
      );
    } else {
      Navigator.pop(context, widget.rows[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 5,
          margin: const EdgeInsets.only(top: 21),
          decoration: BoxDecoration(
            color: AppColors.cD9DBE9,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Text(
            l10n.bookAnAppointment,
            textAlign: TextAlign.center,
            style: AppTextStyles.bold(20, AppColors.c101010),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.cE6E6E6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 16),
            itemCount: widget.rows.length,
            itemBuilder: (_, i) => _TypeRow(
              offer: widget.rows[i],
              showSessions: i != 0,
              selected: _selected == i,
              onChanged: (checked) => setState(
                () => _selected = checked
                    ? i
                    : (_selected == i ? null : _selected),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ProgressButton(text: l10n.confirm, onPressed: _confirm),
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  final OfferModel offer;
  final bool showSessions;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _TypeRow({
    required this.offer,
    required this.showSessions,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DashedBorderBox(
        borderColor: selected ? AppColors.primary : AppColors.cE6E6E6,
        fillColor: selected ? AppColors.cF8F6FA : AppColors.white,
        // The whole row (any child included) toggles the selection.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!selected),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              16,
              16,
              0,
              showSessions ? 16 : 39,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name ?? '',
                        style: AppTextStyles.semiBold(14, AppColors.c1A0304),
                      ),
                      const VerticalSpacer(12),
                      Text(
                        offer.description ?? '',
                        style: AppTextStyles.medium(12, AppColors.c3D4C5E),
                      ),
                      if (showSessions) ...[
                        const VerticalSpacer(12),
                        Text(
                          context.l10n.remainingSessions(
                            '${offer.number}',
                            '${offer.usedNumber}',
                          ),
                          style: AppTextStyles.semiBold(12, AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 8),
                  child: AppSvg(
                    selected
                        ? AppAssets.icRadioButtonSelected
                        : AppAssets.icRadioButtonUnSelected,
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
