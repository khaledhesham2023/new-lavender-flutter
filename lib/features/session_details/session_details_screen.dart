import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/file_downloader.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/enums/enums.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/offers_repository.dart';
import '../appointment_details/widgets/details_widgets.dart';
import '../appointment_details/widgets/status_pill.dart';
import '../booking/widgets/booking_info_card.dart';
import '../booking/widgets/doctor_summary_card.dart';
import '../bookings/actions/booking_actions.dart';
import 'session_details_cubit.dart';

/// Port of `SessionDetailsFragment`: an appointment booked with an offer —
/// like the appointment details plus the offer name and remaining sessions.
class SessionDetailsScreen extends StatelessWidget {
  final int sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SessionDetailsCubit(sl<OffersRepository>(), sessionId)..load(),
      child: const SystemUi(
        statusBarColor: AppColors.white,
        child: _SessionDetailsView(),
      ),
    );
  }
}

class _SessionDetailsView extends StatelessWidget {
  const _SessionDetailsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SessionDetailsCubit>();
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
              child: BlocConsumer<SessionDetailsCubit, SessionDetailsState>(
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
                        ServerFailure() => StateView.serverError(
                          body: l10n.serverErrorBody2,
                          onRetry: cubit.reload,
                        ),
                        NetworkFailure() => StateView.connectionLost(
                          onRetry: cubit.reload,
                        ),
                        // Unknown failures are only toasted.
                        _ => const SizedBox.expand(),
                      };
                    case ViewStatus.success:
                      return _Content(session: state.session!);
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
  final SessionDetailsModel session;

  const _Content({required this.session});

  /// Any changed booking is refetched (Android reloads the details).
  Future<void> _apply(
    SessionDetailsCubit cubit,
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
    final cubit = context.read<SessionDetailsCubit>();
    final doctor = session.doctor;
    final id = session.id;
    final status = BookingStatus.fromValue(session.status);
    final from = session.from;
    final to = session.to;
    final fromText = from == null ? '' : convertTo24HourTime(from, lang);
    final toText = to == null ? '' : convertTo24HourTime(to, lang);
    final report = session.report;
    final appointment = sessionToAppointment(session);
    const actions = BookingActions();

    final buttons = switch (status) {
      BookingStatus.pending || BookingStatus.confirmed => Row(
        children: [
          Expanded(
            child: DetailsBarButton(
              label: l10n.editBooking,
              filled: true,
              enabled: session.canReschedule,
              onTap: () => _apply(
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
              label: session.isReviewed ? l10n.reviewed : l10n.rateBooking,
              filled: true,
              enabled: !session.isReviewed,
              icon: session.isReviewed
                  ? AppAssets.icRateStarSolidWhite
                  : AppAssets.icRateStarWhite,
              onTap: () => _apply(cubit, actions.rate(context, appointment)),
            ),
          ),
          const HorizontalSpacer(16),
          Expanded(
            child: DetailsBarButton(
              label: l10n.rebook,
              onTap: () => _apply(
                cubit,
                actions.rebook(context, appointment, BookingStatus.completed),
              ),
            ),
          ),
        ],
      ),
      BookingStatus.canceled || BookingStatus.rejected => DetailsBarButton(
        label: l10n.rebook,
        onTap: () =>
            _apply(cubit, actions.rebook(context, appointment, status!)),
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
                  status: session.status,
                  text: session.statusTrans,
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
                  icon: AppAssets.icAppointmentDetailsOffer,
                  title: l10n.bookAnOffer,
                  children: [
                    BookingValueText(session.offer?.name ?? ''),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.remainingSessions(
                          '${session.number}',
                          '${session.usedNumber}',
                        ),
                        style: AppTextStyles.semiBold(12, AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: BookingInfoCard(
                  icon: AppAssets.icAppointmentDetailsDate,
                  title: l10n.dateAndTime,
                  children: [
                    BookingValueText(session.formatedDate ?? ''),
                    BookingValueText(
                      l10n.fromToValues(fromText, toText),
                      top: 4,
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
                    BookingValueText(l10n.minValues('${doctor?.duration}')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: BookingInfoCard(
                  icon: AppAssets.icAppointmentDetailsSigns,
                  title: l10n.medicalConditionDescription,
                  children: [
                    BookingValueText(session.notes ?? l10n.noDescription),
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
