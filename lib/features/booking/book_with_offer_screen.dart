import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/progress_button.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/models/requests/booking_draft.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/booking_repository.dart';
import '../../router/routes.dart';
import 'book_appointment_cubit.dart';
import 'change_appointment_sheet.dart';
import 'widgets/booking_info_card.dart';
import 'widgets/doctor_summary_card.dart';

/// Port of `BookAppointmentWithOfferFragment`: like the book screen, but books a
/// session of the chosen [offer] (`user_offer_id` travels in [draft]) and shows
/// the offer card in place of the price. Reuses [BookAppointmentCubit].
class BookWithOfferScreen extends StatelessWidget {
  final BookingDraft draft;
  final OfferModel offer;

  const BookWithOfferScreen({
    super.key,
    required this.draft,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookAppointmentCubit(sl<BookingRepository>(), draft),
      child: SystemUi(
        statusBarColor: AppColors.white,
        child: _BookWithOfferView(offer: offer),
      ),
    );
  }
}

class _BookWithOfferView extends StatefulWidget {
  final OfferModel offer;

  const _BookWithOfferView({required this.offer});

  @override
  State<_BookWithOfferView> createState() => _BookWithOfferViewState();
}

class _BookWithOfferViewState extends State<_BookWithOfferView> {
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    final cubit = context.read<BookAppointmentCubit>();
    final lang = Localizations.localeOf(context).languageCode;
    final request = await showChangeAppointmentSheet(
      context,
      cubit.state.draft.doctorId ?? 0,
    );
    if (request == null) return;
    cubit.changeTo(request, lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<BookAppointmentCubit>();
    final offer = widget.offer;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<BookAppointmentCubit, BookAppointmentState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              (curr.status == ViewStatus.success ||
                  curr.status == ViewStatus.failure),
          listener: (context, state) {
            final id = state.bookedId;
            final failure = state.failure;
            cubit.consume();
            if (id != null) {
              context.push(Routes.sessionRequestedOf(id));
            } else if (failure != null) {
              showFailureToast(context, failure);
            }
          },
          builder: (context, state) {
            final draft = state.draft;
            final time = draft.time;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 8,
                                ),
                                child: AppBackButton(
                                  onTap: () => context.pop(),
                                ),
                              ),
                            ),
                            Text(
                              l10n.bookAnAppointment,
                              style: AppTextStyles.bold(16, AppColors.c0F0102),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.cE6E6E6,
                      ),
                      const VerticalSpacer(24),
                      DoctorSummaryCard(
                        image: draft.doctorImage,
                        name: draft.doctorName,
                        brief: draft.doctorSpecialization,
                        rate: draft.rate,
                        reviewsCount: draft.reviewsCount,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Text(
                          l10n.bookingDetails,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bold(14, AppColors.c3D4C5E),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: BookingInfoCard(
                          icon: AppAssets.icAppointmentDetailsDate,
                          title: l10n.dateAndTime,
                          trailing: GestureDetector(
                            onTap: _change,
                            child: Text(
                              l10n.changeAppointment,
                              style: AppTextStyles.semiBold(
                                14,
                                AppColors.primary,
                              ),
                            ),
                          ),
                          children: [
                            BookingLabelValue(
                              label: l10n.date,
                              value: state.dayText,
                              top: 8,
                            ),
                            BookingLabelValue(
                              label: l10n.time,
                              value: time == null
                                  ? ''
                                  : convertTo24HourTime(time, lang),
                              top: 4,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: BookingInfoCard(
                          icon: AppAssets.icAppointmentDetailsOffer,
                          title: l10n.bookAnOffer,
                          children: [
                            BookingValueText(offer.name ?? ''),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                // Android's last-writer order: (number, used_number).
                                l10n.remainingSessions(
                                  '${offer.number}',
                                  '${offer.usedNumber}',
                                ),
                                style: AppTextStyles.semiBold(
                                  12,
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: BookingInfoCard(
                          icon: AppAssets.icAppointmentDetailsTime,
                          title: l10n.examinationDurationNoColon,
                          children: [
                            BookingValueText(
                              l10n.minValues('${draft.duration}'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        color: AppColors.cE6E6E6,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              l10n.medicalConditionDescription,
                              style: AppTextStyles.semiBold(
                                14,
                                AppColors.c251836,
                              ),
                            ),
                            const HorizontalSpacer(1),
                            Text(
                              l10n.optional,
                              style: AppTextStyles.semiBold(
                                12,
                                AppColors.c666666,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 130,
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cD9DBE9),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        child: TextField(
                          controller: _notes,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          style: AppTextStyles.medium(12, AppColors.c666666),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: l10n.enterYourMedicalCondition,
                            hintStyle: AppTextStyles.medium(
                              12,
                              AppColors.c666666,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const VerticalSpacer(40),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            top: BorderSide(color: AppColors.cE6E6E6),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: ProgressButton(
                            text: l10n.reserveConfirmation,
                            loading: state.saving,
                            onPressed: () => cubit.book(_notes.text),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
