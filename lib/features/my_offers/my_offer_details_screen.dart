import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_utils.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/progress_button.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/offers_repository.dart';
import '../../router/routes.dart';
import '../offers/widgets/discount_badge.dart';
import 'my_offer_details_cubit.dart';
import 'widgets/offer_bookings_tab.dart';
import 'widgets/offer_general_info_tab.dart';

/// Port of `MyOfferDetailsFragment` (`fragment_my_offer_details.xml`). The route is
/// id-based so a `user_offer` notification can open it too (T39).
class MyOfferDetailsScreen extends StatelessWidget {
  final int offerId;

  const MyOfferDetailsScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyOfferDetailsCubit(sl<OffersRepository>(), offerId)..load(),
      child: const _MyOfferDetailsView(),
    );
  }
}

class _MyOfferDetailsView extends StatelessWidget {
  const _MyOfferDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<MyOfferDetailsCubit, MyOfferDetailsState>(
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
              // Light icons over the banner image.
              return SystemUi(
                statusBarIconsDark: false,
                child: _Details(offer: state.offer!),
              );
          }
        },
      ),
    );
  }

  Widget _failure(BuildContext context, MyOfferDetailsState state) {
    return switch (state.failure) {
      NetworkFailure() => StateView.connectionLost(
        onRetry: context.read<MyOfferDetailsCubit>().load,
      ),
      ServerFailure() => const StateView.serverError(),
      // Unknown failures are only toasted.
      _ => const SizedBox.expand(),
    };
  }
}

class _Details extends StatefulWidget {
  final OfferModel offer;

  const _Details({required this.offer});

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  static const double bannerHeight = 250;

  /// The sheet starts at 93% of the banner (`vGuide`).
  static const double sheetTop = 0.93 * (bannerHeight - 1);

  int _tab = 0;

  /// The "book" button: the offer's specialty opens Search details.
  void _goToDoctors() {
    final specialty = widget.offer.specialtyModel;
    if (specialty != null) context.push(Routes.searchDetails, extra: specialty);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offer = widget.offer;
    return Stack(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(offer: offer),
                        _OfferTabs(
                          index: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: IndexedStack(
                            index: _tab,
                            alignment: AlignmentDirectional.topStart,
                            children: [
                              OfferGeneralInfoTab(offer: offer),
                              OfferBookingsTab(offer: offer),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // `clFooter`: white strip with a grey top line and the button.
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(top: BorderSide(color: AppColors.cE6E6E6)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: ProgressButton(
                    text: l10n.checkTheDoctors,
                    onPressed: _goToDoctors,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Name, description, discount badge and the two prices at the top of the sheet.
class _Header extends StatelessWidget {
  final OfferModel offer;

  const _Header({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 24,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
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
              ),
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
      ],
    );
  }
}

/// The two custom tab buttons (`tabLayoutHolder`): selected = primary fill with white
/// text, the other transparent with `c3D4C5E` text (same style as Doctor details).
class _OfferTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _OfferTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [l10n.generalInfo, l10n.showBookings];
    return Container(
      height: 58,
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cE6E6E6),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      12,
                      i == index ? AppColors.white : AppColors.c3D4C5E,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
