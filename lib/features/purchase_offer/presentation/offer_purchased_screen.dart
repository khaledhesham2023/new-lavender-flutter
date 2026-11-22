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
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/icon_info_box.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/models/responses/offer.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/speed_lottie.dart';
import '../../../shared/cubits/my_offer_details_cubit.dart';
import 'widgets/offer_summary_card.dart';
import '../../../shared/cubits/my_offer_details_state.dart';

/// Port of `SuccessfulOfferPurchaseFragment`: loads the purchased (user) offer
/// and shows it under the success banner. The id is a user-offer id.
class OfferPurchasedScreen extends StatelessWidget {
  final int userOfferId;

  const OfferPurchasedScreen({super.key, required this.userOfferId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Same request as My offer details (`GetMyOfferDetails`), so its cubit is reused.
      create: (_) =>
          MyOfferDetailsCubit(sl<OffersRepository>(), userOfferId)..load(),
      child: const SystemUi(
        statusBarColor: AppColors.white,
        child: _OfferPurchasedView(),
      ),
    );
  }
}

class _OfferPurchasedView extends StatelessWidget {
  const _OfferPurchasedView();

  /// Android's back goes to the Home tab (`NavigateToBackStack`).
  void _goHome(BuildContext context) => context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyOfferDetailsCubit>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<MyOfferDetailsCubit, MyOfferDetailsState>(
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
                  // Android's retry re-requests `GetOfferDetails` with the
                  // user-offer id (a bug); retrying `myOfferDetails` is the fix.
                  return switch (state.failure) {
                    NetworkFailure() => StateView.connectionLost(
                      onRetry: cubit.load,
                    ),
                    ServerFailure() => const StateView.serverError(),
                    _ => const SizedBox.expand(),
                  };
                case ViewStatus.success:
                  return _Content(
                    offer: state.offer!,
                    onBack: () => _goHome(context),
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
  final OfferModel offer;
  final VoidCallback onBack;

  const _Content({required this.offer, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final number = offer.number;
    final bookings = switch (number) {
      1 => l10n.oneTime,
      0 => l10n.none,
      _ => l10n.moreThanOneTimeWithValue('$number'),
    };
    final specialty = offer.specialtyModel;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: back arrow, title, two looping confetti animations and the
              // 90x90 check (75 below the arrow, which ends 46 from the top).
              SizedBox(
                height: 241,
                child: Stack(
                  children: [
                    const PositionedDirectional(
                      top: 0,
                      end: 0,
                      width: 300,
                      height: 241,
                      child: SpeedLottie(
                        asset: AppAssets.congratsReservationRequest,
                        speed: 1.5,
                        repeat: true,
                      ),
                    ),
                    const PositionedDirectional(
                      top: 0,
                      start: 0,
                      width: 300,
                      height: 241,
                      child: SpeedLottie(
                        asset: AppAssets.congratsReservationRequest,
                        speed: 1.5,
                        repeat: true,
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 0,
                      right: 0,
                      child: Text(
                        l10n.bookAnAppointment,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bold(16, AppColors.c0F0102),
                      ),
                    ),
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: AppBackButton(onTap: onBack),
                    ),
                    const Positioned(
                      top: 121,
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
                  l10n.offerObtainedSuccessfully,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(16, AppColors.c251836),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                child: Text(
                  l10n.bookingDetailsWithColon,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bold(14, AppColors.c3D4C5E),
                ),
              ),
              const VerticalSpacer(20),
              OfferSummaryCard(offer: offer),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: IconInfoBox(
                          icon: AppAssets.icOfferCalender,
                          value: '${offer.startDate} : ${offer.endDate}',
                          label: l10n.offerValidityPeriod,
                          labelStart: 12,
                          valueTop: 13,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: IconInfoBox(
                          icon: AppAssets.icOfferTicket,
                          value: bookings,
                          label: l10n.numberOfOfferBookings,
                          labelStart: 10,
                        ),
                      ),
                    ],
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
              const Spacer(),
              Container(
                width: double.infinity,
                color: AppColors.cF8F6FA,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const AppSvg(AppAssets.icHint),
                    const HorizontalSpacer(10),
                    Expanded(
                      child: Text(
                        l10n.thisOfferAppliesOnSpecialty(specialty?.name ?? ''),
                        style: AppTextStyles.semiBold(12, AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 23),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.cE6E6E6)),
                ),
                child: SafeArea(
                  top: false,
                  child: ProgressButton(
                    text: l10n.checkTheDoctors,
                    onPressed: () {
                      if (specialty != null) {
                        context.push(Routes.searchDetails, extra: specialty);
                      }
                    },
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
