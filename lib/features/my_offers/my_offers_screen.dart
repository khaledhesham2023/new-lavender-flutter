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
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/repositories/offers_repository.dart';
import '../../router/routes.dart';
import 'my_offers_cubit.dart';
import 'widgets/my_offer_card.dart';

/// Port of `MyOffersFragment` (`fragment_my_offers.xml`).
class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyOffersCubit(sl<OffersRepository>())..load(),
      // Transparent status bar over the purple header, light icons.
      child: const SystemUi(statusBarIconsDark: false, child: _MyOffersView()),
    );
  }
}

class _MyOffersView extends StatelessWidget {
  const _MyOffersView();

  Widget _body(BuildContext context, MyOffersState state) {
    final cubit = context.read<MyOffersCubit>();
    switch (state.status) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return const LoadingView();
      case ViewStatus.failure:
        // Unknown failures are only toasted (Android `else` branch).
        return switch (state.failure) {
          NetworkFailure() => StateView.connectionLost(onRetry: cubit.load),
          ServerFailure() => const StateView.serverError(),
          _ => const SizedBox.expand(),
        };
      case ViewStatus.success:
        final offers = state.offers;
        if (offers.isEmpty) {
          return StateView.empty(
            icon: AppAssets.icEmptyFavorites,
            title: context.l10n.noMyOffersTitle,
            body: context.l10n.noMyOffersBody,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          itemCount: offers.length,
          itemBuilder: (context, i) {
            final offer = offers[i];
            return MyOfferCard(
              offer: offer,
              onTap: () => context.push(Routes.myOfferDetailsOf(offer.id ?? 0)),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<MyOffersCubit, MyOffersState>(
        listenWhen: (prev, curr) =>
            curr.failure is UnknownFailure && prev.failure != curr.failure,
        listener: (context, state) => showFailureToast(context, state.failure!),
        builder: (context, state) {
          final cubit = context.read<MyOffersCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(tab: state.tab, onTab: cubit.selectTab),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cubit.load,
                  child: _body(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// `containerActionBar`: background image, white back arrow and title, and the
/// pill toggle Valid / Completed.
class _Header extends StatelessWidget {
  final MyOffersTab tab;
  final ValueChanged<MyOffersTab> onTab;

  const _Header({required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(AppAssets.icBackgroundSearch, fit: BoxFit.cover),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 54, 16, 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l10n.myOffers,
                        style: AppTextStyles.bold(18, AppColors.white),
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      child: AppBackButton(
                        onTap: () => context.pop(),
                        boxSize: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalSpacer(16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.cA3A3A3, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ToggleButton(
                        text: l10n.valid,
                        selected: tab == MyOffersTab.valid,
                        onTap: () => onTab(MyOffersTab.valid),
                      ),
                    ),
                    Expanded(
                      child: _ToggleButton(
                        text: l10n.completed,
                        selected: tab == MyOffersTab.completed,
                        onTap: () => onTab(MyOffersTab.completed),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.white : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: AppTextStyles.bold(
            14,
            selected ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }
}
