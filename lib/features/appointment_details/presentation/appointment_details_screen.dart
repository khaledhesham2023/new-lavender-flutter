import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/file_downloader.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../core/enums/enums.dart';
import '../../../data/models/responses/appointment.dart';
import '../../../shared/domain/repositories/booking_repository.dart';
import '../../../shared/widgets/booking_info_card.dart';
import '../../../shared/widgets/doctor_summary_card.dart';
import '../../bookings/presentation/actions/booking_actions.dart';
import 'appointment_details_cubit.dart';
import '../../../shared/widgets/details_widgets.dart';
import '../../../shared/widgets/status_pill.dart';

/// Port of `AppointmentDetailsFragment`: the booking's status, doctor, slot,
/// price, notes and the attached medical report, with the actions allowed by
/// its status. [appointmentId] also covers the id of a notification.
class AppointmentDetailsScreen extends StatelessWidget {
  final int appointmentId;

  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AppointmentDetailsCubit(sl<BookingRepository>(), appointmentId)
            ..load(),
      child: const SystemUi(
        statusBarColor: AppColors.white,
        child: _AppointmentDetailsView(),
      ),
    );
  }
}

class _AppointmentDetailsView extends StatelessWidget {
  const _AppointmentDetailsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppointmentDetailsCubit>();
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 18, 56, 0),
                  child: Text(
                    l10n.bookingDetails,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold(16, AppColors.c0F0102),
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  top: 10,
                  child: AppBackButton(onTap: () => context.pop()),
                ),
                const SizedBox(height: 56, width: double.infinity),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Divider(height: 1, thickness: 1, color: AppColors.cE6E6E6),
            ),
            Expanded(
              child:
                  BlocConsumer<AppointmentDetailsCubit, AppointmentDetailsState>(
                    listenWhen: (prev, curr) =>
                        curr.failure is UnknownFailure &&
                        prev.failure != curr.failure,
                    listener: (context, state) =>
                        showFailureToast(context, state.failure!),
                    builder: (context, state) {
                      switch (state.status) {
                        case ViewStatus.initial:
                        case ViewStatus.loading:
                          return const LoadingView();
                        case ViewStatus.failure:
                          return switch (state.failure) {
                            ServerFailure(code: 404) => StateView.empty(
                              icon: AppAssets.icNoNotifications,
                              title: l10n.noDataToPreview,
                              buttonTitle: l10n.back,
                              onButton: () => context.pop(),
                            ),
                            ServerFailure() => StateView.serverError(
                              body: l10n.serverErrorBody2,
                            ),
                            NetworkFailure() => StateView.connectionLost(
                              onRetry: cubit.load,
                            ),
                            // Unknown failures are only toasted.
                            _ => const SizedBox.expand(),
                          };
                        case ViewStatus.success:
                          return _Content(appointment: state.appointment!);
                      }
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final AppointmentData appointment;

  const _Content({required this.appointment});

  /// A removed / changed booking is refetched (Android reloads the details).
  Future<void> _apply(
    BuildContext context,
    AppointmentDetailsCubit cubit,
    Future<BookingActionResult> action,
  ) async {
    final result = await action;
    if (cubit.isClosed) return;
    if (result == BookingActionResult.removed ||
        result == BookingActionResult.reload) {
      cubit.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<AppointmentDetailsCubit>();
    final doctor = appointment.doctor;
    final id = appointment.id;
    final status = BookingStatus.fromValue(appointment.status);
    final price = double.tryParse(doctor?.price ?? '');
    final from = appointment.from;
    final to = appointment.to;
    final fromText = from == null ? '' : convertTo24HourTime(from, lang);
    final toText = to == null ? '' : convertTo24HourTime(to, lang);
    final report = appointment.report;
    const actions = BookingActions();

    final buttons = switch (status) {
      BookingStatus.pending || BookingStatus.confirmed => Row(
        children: [
          Expanded(
            child: DetailsBarButton(
              label: l10n.editBooking,
              filled: true,
              enabled: appointment.canReschedule,
              onTap: () => _apply(
                context,
                cubit,
                actions.edit(context, appointment, status!),
              ),
            ),
          ),
          const HorizontalSpacer(16),
          Expanded(
            child: DetailsBarButton(
              label: l10n.cancelBooking,
              onTap: () => _apply(
                context,
                cubit,
                id == null
                    ? Future.value(BookingActionResult.none)
                    : actions.cancel(context, id),
              ),
            ),
          ),
        ],
      ),
      BookingStatus.completed => Row(
        children: [
          Expanded(
            child: DetailsBarButton(
              label: appointment.isReviewed ? l10n.reviewed : l10n.rateBooking,
              filled: true,
              enabled: !appointment.isReviewed,
              icon: appointment.isReviewed
                  ? AppAssets.icRateStarSolidWhite
                  : AppAssets.icRateStarWhite,
              onTap: () =>
                  _apply(context, cubit, actions.rate(context, appointment)),
            ),
          ),
          const HorizontalSpacer(16),
          Expanded(
            child: DetailsBarButton(
              label: l10n.rebook,
              onTap: () => _apply(
                context,
                cubit,
                actions.rebook(context, appointment, BookingStatus.completed),
              ),
            ),
          ),
        ],
      ),
      BookingStatus.canceled || BookingStatus.rejected => DetailsBarButton(
        label: l10n.rebook,
        onTap: () => _apply(
          context,
          cubit,
          actions.rebook(context, appointment, status!),
        ),
      ),
      BookingStatus.processing || null => null,
    };

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: StatusPill(
                  status: appointment.status,
                  text: appointment.statusTrans,
                ),
              ),
              const VerticalSpacer(24),
              DoctorSummaryCard(
                image: doctor?.image,
                name: doctor?.name,
                brief: doctor?.subSpecialty ?? doctor?.specialty,
                rate: doctor?.rate,
                reviewsCount: doctor?.reviewsCount,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  id == null
                      ? l10n.bookingDetails
                      : l10n.bookingDetailsWithValue('(#$id)'),
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
                  children: [
                    BookingValueText(appointment.formatedDate ?? ''),
                    BookingValueText(
                      l10n.fromToValues(fromText, toText),
                      top: 4,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: BookingInfoCard(
                          icon: AppAssets.icAppointmentDetailsPrice,
                          title: l10n.examinationPriceNoColon,
                          children: [
                            BookingValueText(
                              l10n.priceWithValue(formatDecimal(price)),
                            ),
                          ],
                        ),
                      ),
                      const HorizontalSpacer(10),
                      Expanded(
                        child: BookingInfoCard(
                          icon: AppAssets.icAppointmentDetailsTime,
                          title: l10n.examinationDurationNoColon,
                          children: [
                            BookingValueText(
                              l10n.minValues('${doctor?.duration}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: BookingInfoCard(
                  icon: AppAssets.icAppointmentDetailsSigns,
                  title: l10n.medicalConditionDescription,
                  children: [
                    BookingValueText(appointment.notes ?? l10n.noDescription),
                  ],
                ),
              ),
              if (report != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Text(
                    l10n.medicalReport,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(14, AppColors.c3D4C5E),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ReportRow(
                    onTap: () => downloadFile(
                      context,
                      url: report,
                      title: l10n.medicalReportPdf,
                    ),
                  ),
                ),
              ],
              const VerticalSpacer(16),
            ],
          ),
        ),
        if (buttons != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.cE6E6E6)),
                ),
                child: SafeArea(top: false, child: buttons),
              ),
            ),
          ),
      ],
    );
  }
}
