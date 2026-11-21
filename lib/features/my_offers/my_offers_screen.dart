import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../core/widgets/toggle_header.dart';
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
              ToggleHeader(
                title: context.l10n.myOffers,
                labels: [context.l10n.valid, context.l10n.completed],
                selected: state.tab.index,
                onChanged: (i) => cubit.selectTab(MyOffersTab.values[i]),
              ),
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
