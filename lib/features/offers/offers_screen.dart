import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../../data/repositories/specialities_repository.dart';
import '../../router/routes.dart';
import 'offers_cubit.dart';
import 'widgets/offer_card.dart';
import 'widgets/specialty_tabs.dart';

/// Port of `OffersFragment`: specialty tabs and the offers of the selected one.
/// Opened from Home / All specialities ("Medical offers").
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OffersCubit(sl<SpecialitiesRepository>(), sl<OffersRepository>())
            ..load(),
      // Transparent status bar over the teal header: light icons.
      child: const SystemUi(statusBarIconsDark: false, child: _OffersView()),
    );
  }
}

class _OffersView extends StatelessWidget {
  const _OffersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          Expanded(
            child: BlocConsumer<OffersCubit, OffersState>(
              listenWhen: (prev, curr) =>
                  (curr.tabsFailure is UnknownFailure &&
                      prev.tabsFailure != curr.tabsFailure) ||
                  (curr.listFailure is UnknownFailure &&
                      prev.listFailure != curr.listFailure),
              listener: (context, state) {
                final failure = state.listFailure is UnknownFailure
                    ? state.listFailure
                    : state.tabsFailure;
                if (failure != null) showFailureToast(context, failure);
              },
              builder: (context, state) {
                switch (state.tabsStatus) {
                  case ViewStatus.initial:
                  case ViewStatus.loading:
                    return const LoadingView();
                  case ViewStatus.failure:
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: switch (state.tabsFailure) {
                        NetworkFailure() => StateView.connectionLost(
                          onRetry: context.read<OffersCubit>().load,
                        ),
                        ServerFailure() => const StateView.serverError(),
                        // Unknown failures are only toasted.
                        _ => const SizedBox.expand(),
                      },
                    );
                  case ViewStatus.success:
                    return _Content(state: state);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 130dp teal header (`ic_background_search`) drawn under the status bar: white
/// back arrow at the start and the centered "Medical offers" title.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.icBackgroundSearch, fit: BoxFit.cover),
          // Back (36dp, 16dp margins) and title share the same vertical centre.
          PositionedDirectional(
            start: 16,
            top: 55,
            child: AppBackButton(
              onTap: () => context.pop(),
              size: 36,
              boxSize: 36,
              color: AppColors.white,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 55,
            height: 36,
            child: Center(
              child: Text(
                context.l10n.medicalOffers,
                style: AppTextStyles.bold(18, AppColors.cFDF9ED),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final OffersState state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OffersCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 60,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SpecialtyTabs(
                  specialities: state.specialities,
                  selectedId: state.selectedId,
                  onSelected: (tab) => cubit.selectTab(tab.id),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(color: AppColors.cE6E6E6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              // Android hides the spinner at once; the list shows its own loader.
              cubit.refresh();
            },
            child: _OffersList(state: state),
          ),
        ),
      ],
    );
  }
}

class _OffersList extends StatelessWidget {
  final OffersState state;

  const _OffersList({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OffersCubit>();

    Widget fill(Widget child) => CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );

    switch (state.listStatus) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return fill(const LoadingView());
      case ViewStatus.failure:
        return fill(
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: switch (state.listFailure) {
              // No retry button in Android's list error views either.
              NetworkFailure() => StateView.connectionLost(
                onRetry: cubit.refresh,
              ),
              ServerFailure() => const StateView.serverError(),
              _ => const SizedBox.expand(),
            },
          ),
        );
      case ViewStatus.success:
        if (state.offers.isEmpty) {
          return fill(
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: StateView.empty(
                icon: AppAssets.icNoOffers,
                title: l10n.noOffersTitle,
                body: l10n.noOffersBody,
              ),
            ),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: state.offers.length,
          itemBuilder: (context, i) {
            final offer = state.offers[i];
            return OfferCard(
              offer: offer,
              onTap: () {
                final id = offer.id;
                if (id != null) context.push(Routes.offerDetailsOf(id));
              },
            );
          },
        );
    }
  }
}
