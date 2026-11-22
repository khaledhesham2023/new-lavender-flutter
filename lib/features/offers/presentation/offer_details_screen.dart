import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/icon_info_box.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../shared/widgets/must_login_sheet.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/models/responses/offer.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import '../../../app/router/routes.dart';
import 'offer_details_cubit.dart';
import '../../../shared/widgets/discount_badge.dart';

/// Port of `OfferDetailsFragment`. The route is id-based so a notification can
/// open it too (T39).
class OfferDetailsScreen extends StatelessWidget {
  final int offerId;

  const OfferDetailsScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfferDetailsCubit(sl<OffersRepository>(), offerId)..load(),
      // Light icons over the banner image; the loading/error states below
      // switch back to dark icons because they sit on white.
      child: const SystemUi(
        statusBarIconsDark: false,
        child: _OfferDetailsView(),
      ),
    );
  }
}

class _OfferDetailsView extends StatelessWidget {
  const _OfferDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<OfferDetailsCubit, OfferDetailsState>(
        listenWhen: (prev, curr) =>
            curr.failure is UnknownFailure && prev.failure != curr.failure,
        listener: (context, state) => showFailureToast(context, state.failure!),
        builder: (context, state) {
          switch (state.status) {
            case ViewStatus.initial:
            case ViewStatus.loading:
              return const SystemUi(child: LoadingView());
            case ViewStatus.failure:
              // White background: dark icons (light ones only fit the banner).
              return SystemUi(child: SafeArea(child: _failure(context, state)));
            case ViewStatus.success:
              return _Details(offer: state.offer!);
          }
        },
      ),
    );
  }

  Widget _failure(BuildContext context, OfferDetailsState state) {
    if (state.notFound) {
      return StateView.empty(
        icon: AppAssets.icNoNotifications,
        title: context.l10n.thisOfferNoLongerAvailable,
        buttonTitle: context.l10n.back,
        onButton: () => context.pop(),
      );
    }
    return switch (state.failure) {
      NetworkFailure() => StateView.connectionLost(
        onRetry: context.read<OfferDetailsCubit>().load,
      ),
      ServerFailure() => const StateView.serverError(),
      // Unknown failures are only toasted.
      _ => const SizedBox.expand(),
    };
  }
}

class _Details extends StatelessWidget {
  static const double bannerHeight = 310;

  /// The sheet starts at 93% of the banner (`vGuide`).
  static const double sheetTop = 0.93 * (bannerHeight - 1);

  final OfferModel offer;

  const _Details({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      // Fill the screen: the sheet is positioned from the banner down to the bottom.
      fit: StackFit.expand,
      children: [
        // Banner with a 25% black scrim.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: bannerHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: offer.image, fit: BoxFit.cover),
              const ColoredBox(color: AppColors.c40000000),
            ],
          ),
        ),
        PositionedDirectional(
          start: 16,
          end: 16,
          top: 60,
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(),
                  child: const AppSvg(AppAssets.icOfferBack),
                ),
                Expanded(
                  child: Text(
                    l10n.offerDetails,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold(18, AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          top: sheetTop,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24),
                    child: _SheetBody(offer: offer),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: ProgressButton(
                    text: l10n.getTheOffer,
                    onPressed: () => _getOffer(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _getOffer(BuildContext context) {
    if (context.read<SessionCubit>().state.isLoggedIn) {
      context.push(Routes.purchaseOffer, extra: offer);
    } else {
      showMustLoginSheet(context);
    }
  }
}

class _SheetBody extends StatelessWidget {
  final OfferModel offer;

  const _SheetBody({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final number = offer.number;
    final bookings = switch (number) {
      1 => l10n.oneTime,
      0 => l10n.none,
      _ => l10n.moreThanOneTimeWithValue('$number'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.name ?? '',
                      style: AppTextStyles.bold(15).copyWith(height: 1.4),
                    ),
                    const VerticalSpacer(8),
                    Text(
                      offer.description ?? '',
                      style: AppTextStyles.semiBold(
                        12,
                        AppColors.c666666,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const HorizontalSpacer(10),
              DiscountBadge(discount: offer.discount),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, top: 12),
          child: Row(
            children: [
              Text(
                l10n.priceWithValue(formatDecimal(offer.price)),
                style: AppTextStyles.semiBold(
                  12,
                  AppColors.c7E94B0,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
              const HorizontalSpacer(6),
              Text(
                l10n.priceWithValue(formatDecimal(offer.finalPrice)),
                style: AppTextStyles.bold(16, AppColors.primary),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 20,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: IconInfoBox(
                    icon: AppAssets.icOfferCalender,
                    value: '${offer.startDate}:${offer.endDate}',
                    label: l10n.offerValidityPeriod,
                    labelStart: 12,
                    valueTop: 13,
                  ),
                ),
                const HorizontalSpacer(11),
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
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 20,
          ),
          child: Text(
            l10n.details,
            style: AppTextStyles.bold(14, AppColors.c3D4C5E),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 10,
            bottom: 16,
          ),
          child: Text(
            offer.details ?? '',
            style: AppTextStyles.medium(
              13,
              AppColors.c3D4C5E,
            ).copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
