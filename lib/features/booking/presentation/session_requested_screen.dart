import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/models/responses/offer.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/speed_lottie.dart';
import 'session_requested_cubit.dart';
import '../../../shared/widgets/booking_info_card.dart';
import '../../../shared/widgets/doctor_summary_card.dart';

/// Port of `SuccessfulAppointmentRequestFragmentWithOfferFragment`: loads the
/// created offer session and shows it under the success banner.
class SessionRequestedScreen extends StatelessWidget {
  final int sessionId;

  const SessionRequestedScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SessionRequestedCubit(sl<OffersRepository>(), sessionId)..load(),
      child: const SystemUi(
        statusBarColor: AppColors.white,
        child: _SessionRequestedView(),
      ),
    );
  }
}

class _SessionRequestedView extends StatelessWidget {
  const _SessionRequestedView();

  /// Android's back goes to the Home tab, not to the booking screen.
  void _goHome(BuildContext context) => context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SessionRequestedCubit>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<SessionRequestedCubit, SessionRequestedState>(
            listenWhen: (prev, curr) =>
                curr.failure is UnknownFailure && prev.failure != curr.failure,
            listener: (context, state) =>
                showFailureToast(context, state.failure!),
            builder: (context, state) {
              switch (state.status) {
                case ViewStatus.initial:
                case ViewStatus.loading:
                  return const LoadingView();
                case ViewStatus.failure:
                  return state.failure is NetworkFailure
                      ? StateView.connectionLost(
                          onRetry: cubit.load,
                        )
                      : const StateView.serverError();
                case ViewStatus.success:
                  return _Content(
                    session: state.session!,
                    onBack: () => _goHome(context),
                    onGoToReservations: () => context.go(Routes.bookings),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final SessionDetailsModel session;
  final VoidCallback onBack;
  final VoidCallback onGoToReservations;

  const _Content({
    required this.session,
    required this.onBack,
    required this.onGoToReservations,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final doctor = session.doctor;
    final id = session.id;
    final from = session.from;
    final to = session.to;
    final fromText = from == null ? '' : convertTo24HourTime(from, lang);
    final toText = to == null ? '' : convertTo24HourTime(to, lang);
    final notes = session.notes;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 199,
                child: Stack(
                  children: [
                    // Two looping confetti animations, one on each side.
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      width: 300,
                      height: 199,
                      child: const SpeedLottie(
                        asset: AppAssets.congratsReservationRequest,
                        speed: 1.5,
                        repeat: true,
                      ),
                    ),
                    PositionedDirectional(
                      top: 0,
                      start: 0,
                      width: 300,
                      height: 199,
                      child: const SpeedLottie(
                        asset: AppAssets.congratsReservationRequest,
                        speed: 1.5,
                        repeat: true,
                      ),
                    ),
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: AppBackButton(onTap: onBack),
                    ),
                    const Positioned(
                      top: 109,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AppSvg(AppAssets.icSuccess, width: 90, height: 90),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                child: Text(
                  l10n.yourReservationRequestHasBeenSentSuccessfully,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(16, AppColors.c251836),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
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
                  icon: AppAssets.icMedicalConditionDescription,
                  title: l10n.medicalConditionDescription,
                  children: [BookingValueText(notes ?? l10n.noDescription)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  l10n.doctorDetails,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bold(14, AppColors.c3D4C5E),
                ),
              ),
              const VerticalSpacer(10),
              DoctorSummaryCard(
                bordered: true,
                image: doctor?.image,
                name: doctor?.name,
                brief: doctor?.subSpecialty ?? doctor?.specialty,
                rate: doctor?.rate,
                reviewsCount: doctor?.reviewsCount,
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const VerticalSpacer(23),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.cE6E6E6)),
                ),
                child: SafeArea(
                  top: false,
                  child: ProgressButton(
                    text: l10n.goToReservations,
                    onPressed: onGoToReservations,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
