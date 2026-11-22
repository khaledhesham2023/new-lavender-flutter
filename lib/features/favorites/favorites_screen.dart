import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/debounced_search_field.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../router/routes.dart';
import '../home/widgets/doctor_card.dart';
import 'favorites_cubit.dart';

/// Port of `FavoritesFragment` (bottom-navigation "Favorites" tab). Guests see
/// the login prompt; logged-in users get the search field and their favorite
/// doctors.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<SessionCubit, bool>(
      (c) => c.state.isLoggedIn,
    );
    return loggedIn ? const _LoggedInView() : const _GuestView();
  }
}

/// The 130dp header image with the white title (transparent status bar).
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: Text(
                context.l10n.favoriteDoctors,
                maxLines: 1,
                style: AppTextStyles.bold(18, AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      statusBarIconsDark: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StateView.empty(
                  icon: AppAssets.icMustLogin,
                  title: l10n.youMustLoginTitle,
                  body: l10n.youMustLoginBody,
                  buttonTitle: l10n.login,
                  onButton: () => context.push(Routes.authStart),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  const _LoggedInView();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesCubit(sl<FavoritesRepository>())..load(),
      child: const SystemUi(
        statusBarIconsDark: false,
        child: _FavoritesBody(),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<FavoritesCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: DebouncedSearchField(
              hint: l10n.searchByDoctorsName,
              // Android waits 1 s after the last keystroke.
              debounce: const Duration(milliseconds: 1000),
              onChanged: cubit.setKeyword,
            ),
          ),
          Expanded(
            child: BlocConsumer<FavoritesCubit, FavoritesState>(
              listenWhen: (prev, curr) =>
                  (curr.failure is UnknownFailure &&
                      prev.failure != curr.failure) ||
                  (curr.toggleFailure != null &&
                      prev.toggleFailure != curr.toggleFailure),
              listener: (context, state) {
                final toggle = state.toggleFailure;
                if (toggle != null) {
                  showFailureToast(context, toggle);
                  cubit.consumeToggleFailure();
                } else if (state.failure != null) {
                  showFailureToast(context, state.failure!);
                }
              },
              builder: (context, state) => _Content(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final FavoritesState state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<FavoritesCubit>();
    final bottom = MediaQuery.paddingOf(context).bottom;

    if (state.status == ViewStatus.failure) {
      return switch (state.failure) {
        ServerFailure() => StateView.serverError(body: l10n.serverErrorBody2),
        // Android shows no retry button on this list view.
        NetworkFailure() => StateView.empty(
          icon: AppAssets.icNetworkError2,
          title: l10n.noInternetConncetion,
          body: l10n.noInternetConncetionBody2,
        ),
        // Unknown failures are only toasted.
        _ => const SizedBox.expand(),
      };
    }
    if (state.status != ViewStatus.success && state.doctors.isEmpty) {
      return const LoadingView();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      // Android hides the spinner at once; the list has its own loader.
      onRefresh: () async {
        cubit.load();
      },
      child: state.doctors.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: state.keyword == null
                        ? StateView.empty(
                            icon: AppAssets.icEmptyFavorites,
                            title: l10n.noFavoriteDoctorsTitle,
                            body: l10n.noFavoriteDoctorsBody,
                          )
                        : StateView.empty(
                            icon: AppAssets.icNoDoctorsFound,
                            title: l10n.noSearchResultsTitle,
                            body: l10n.noSearchResultsDoctorsBody,
                          ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 10 + bottom),
              itemCount: state.doctors.length,
              separatorBuilder: (_, _) => const VerticalSpacer(10),
              itemBuilder: (context, i) {
                final doctor = state.doctors[i];
                return DoctorCard(
                  doctor: doctor,
                  width: double.infinity,
                  onFavorite: () => cubit.unfavorite(i),
                  onTap: () async {
                    final id = doctor.id;
                    if (id == null) return;
                    await context.push(Routes.doctorDetailsOf(id));
                    // The favorite may have changed in the details screen.
                    if (!cubit.isClosed) cubit.load();
                  },
                );
              },
            ),
    );
  }
}
