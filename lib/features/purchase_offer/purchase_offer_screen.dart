import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_utils.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/progress_button.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/models/responses/offer.dart';
import '../../shared/domain/repositories/offers_repository.dart';
import '../../app/router/routes.dart';
import '../auth/widgets/terms_row.dart';
import 'purchase_offer_cubit.dart';
import 'tap_payment_service.dart';
import 'widgets/offer_summary_card.dart';

/// Port of `PurchaseOfferFragment` (`fragment_purchase_offer.xml`).
class PurchaseOfferScreen extends StatelessWidget {
  final OfferModel offer;

  /// Replaceable so tests can fake the Tap sheet.
  final TapPaymentService payments;

  const PurchaseOfferScreen({
    super.key,
    required this.offer,
    this.payments = const TapPaymentService(),
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PurchaseOfferCubit(
        sl<OffersRepository>(),
        payments,
        sl<SessionCubit>(),
      ),
      child: SystemUi(
        statusBarColor: AppColors.white,
        child: _PurchaseOfferView(offer: offer),
      ),
    );
  }
}

class _PurchaseOfferView extends StatelessWidget {
  final OfferModel offer;

  const _PurchaseOfferView({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PurchaseOfferCubit>();
    return Scaffold(
      backgroundColor: AppColors.cFAFAFA,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<PurchaseOfferCubit, PurchaseOfferState>(
          listenWhen: (prev, curr) =>
              curr.purchasedId != null ||
              curr.paymentError != null ||
              curr.failure != null,
          listener: (context, state) {
            final id = state.purchasedId;
            final paymentError = state.paymentError;
            final failure = state.failure;
            cubit.consume();
            if (id != null) {
              context.push(Routes.offerPurchasedOf(id));
            } else if (paymentError != null) {
              // Android shows a small popup with the Tap message; a failed
              // toast is the substitute (T37 step 4).
              AppToast.show(
                context,
                paymentError.isEmpty ? l10n.connectionError : paymentError,
                ToastType.failed,
              );
            } else if (failure != null) {
              showFailureToast(context, failure);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 56,
                        color: AppColors.white,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PositionedDirectional(
                              start: 6,
                              child: AppBackButton(onTap: () => context.pop()),
                            ),
                            Text(
                              l10n.bookingDetails,
                              style: AppTextStyles.bold(16, AppColors.c0F0102),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OfferSummaryCard(offer: offer),
                      const SizedBox(height: 16),
                      _PaymentMethodSection(
                        selected: state.methodSelected,
                        onSelect: cubit.selectMethod,
                      ),
                      const SizedBox(height: 16),
                      _PaymentSummary(offer: offer),
                      const SizedBox(height: 16),
                      Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: TermsRow(
                          checked: state.termsAccepted,
                          onChanged: cubit.setTerms,
                          onOpenTerms: () => context.push(Routes.terms),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
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
                            enabled: state.canPay,
                            loading: state.saving,
                            onPressed: () => cubit.pay(offer),
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

/// `clChoosePaymentMethod` with the single "Credit cards" row (`recycler_payment_item`).
class _PaymentMethodSection extends StatelessWidget {
  final bool selected;
  final VoidCallback onSelect;

  const _PaymentMethodSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.choosePaymentMethod,
            style: AppTextStyles.bold(16, AppColors.c1D242D),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSelect,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cE6E6E6),
              ),
              child: Row(
                children: [
                  const AppSvg(AppAssets.icCredit, width: 30, height: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.creditCards,
                      style: AppTextStyles.semiBold(14, AppColors.c3D4C5E),
                    ),
                  ),
                  AppSvg(
                    selected
                        ? AppAssets.icRadioButtonSelected
                        : AppAssets.icRadioButtonUnSelected,
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `clPaymentSummary`: price before discount, discount tag, price after discount.
class _PaymentSummary extends StatelessWidget {
  final OfferModel offer;

  const _PaymentSummary({required this.offer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.paymentSummary,
            style: AppTextStyles.bold(16, AppColors.c1D242D),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.priceBeforeDiscount,
                  style: AppTextStyles.medium(12, AppColors.c3D4C5E),
                ),
              ),
              Text(
                l10n.priceWithValue(formatDecimal(offer.price)),
                style: AppTextStyles.semiBold(12, AppColors.c3D4C5E),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _DiscountTag(
                    child: Text(
                      l10n.discount,
                      style: AppTextStyles.medium(12, AppColors.c0F0102),
                    ),
                  ),
                ),
              ),
              _DiscountTag(
                child: Text(
                  formatPercentage(offer.discount),
                  style: AppTextStyles.semiBold(12, AppColors.cED1C24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Image.asset(
            AppAssets.dashedLineGreyHorizontal,
            width: double.infinity,
            height: 1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.priceAfterDiscount,
                  style: AppTextStyles.semiBold(14, AppColors.c0F0102),
                ),
              ),
              Text(
                l10n.priceWithValue(formatDecimal(offer.finalPrice)),
                style: AppTextStyles.bold(14, AppColors.c0F0102),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A text over `ic_discount_price` stretched to the text width, 24 high.
class _DiscountTag extends StatelessWidget {
  final Widget child;

  const _DiscountTag({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.icDiscountPrice),
          fit: BoxFit.fill,
        ),
      ),
      child: SizedBox(
        height: 24,
        child: Center(widthFactor: 1, child: child),
      ),
    );
  }
}
