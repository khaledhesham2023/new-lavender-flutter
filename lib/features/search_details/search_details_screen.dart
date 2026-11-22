import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/debounced_search_field.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/models/responses/speciality.dart';
import '../../shared/domain/repositories/home_repository.dart';
import '../../shared/domain/repositories/specialities_repository.dart';
import '../../app/router/route_args.dart';
import '../../app/router/routes.dart';
import '../../shared/widgets/doctor_card.dart';
import 'search_details_cubit.dart';
import 'search_filter.dart';
import 'sort_sheet.dart';

/// Port of `SearchDetailsFragment`: doctors of one speciality with name search,
/// sort sheet, filter entry point and favorite hearts.
class SearchDetailsScreen extends StatelessWidget {
  final SpecialityModel speciality;

  const SearchDetailsScreen({super.key, required this.speciality});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchDetailsCubit(
        sl<SpecialitiesRepository>(),
        sl<HomeRepository>(),
        speciality,
      )..load(),
      child: const SystemUi(
        statusBarIconsDark: false,
        child: _SearchDetailsView(),
      ),
    );
  }
}

class _SearchDetailsView extends StatelessWidget {
  const _SearchDetailsView();

  Future<void> _openFilter(BuildContext context) async {
    final cubit = context.read<SearchDetailsCubit>();
    final result = await context.push<SearchFilter>(
      Routes.filter,
      extra: FilterArgs(cubit.speciality.id, cubit.state.filter),
    );
    if (result != null) cubit.applyFilter(result);
  }

  Future<void> _openSort(BuildContext context) async {
    final cubit = context.read<SearchDetailsCubit>();
    final result = await showSortSheet(
      context,
      current: cubit.state.filter.sortBy,
    );
    if (result != null) cubit.setSort(result.value);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchDetailsCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocListener<SearchDetailsCubit, SearchDetailsState>(
        listenWhen: (prev, curr) =>
            (curr.failure is UnknownFailure && prev.failure != curr.failure) ||
            (curr.favoriteFailure != null &&
                prev.favoriteFailure != curr.favoriteFailure),
        listener: (context, state) {
          final favorite = state.favoriteFailure;
          if (favorite != null) {
            showFailureToast(context, favorite);
            cubit.consumeFavoriteFailure();
          } else if (state.failure != null) {
            showFailureToast(context, state.failure!);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(title: cubit.speciality.name ?? ''),
            // Hidden (state kept, so the typed text survives) while the list
            // shows the loader or the server / network error view. While a
            // name search is active the field stays, otherwise the keyboard
            // would close after every debounced query.
            BlocSelector<SearchDetailsCubit, SearchDetailsState, bool>(
              selector: (s) => switch (s.status) {
                ViewStatus.initial => true,
                ViewStatus.loading => s.name == null,
                ViewStatus.failure =>
                  s.failure is NetworkFailure || s.failure is ServerFailure,
                ViewStatus.success => false,
              },
              builder: (context, hidden) => Visibility(
                visible: !hidden,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DebouncedSearchField(
                          hint: context.l10n.searchBySpecialityOrDoctor,
                          debounce: const Duration(milliseconds: 1000),
                          onChanged: cubit.setName,
                        ),
                      ),
                      const HorizontalSpacer(10),
                      BlocSelector<
                        SearchDetailsCubit,
                        SearchDetailsState,
                        _Bar
                      >(
                        selector: (s) => _Bar(
                          visible: s.status == ViewStatus.success,
                          dot: s.filter.hasFilter,
                        ),
                        builder: (context, bar) => Visibility(
                          visible: bar.visible,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 16),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _openFilter(context),
                              child: _Dotted(
                                showDot: bar.dot,
                                child: AppSvg(
                                  AppAssets.icFilter,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchDetailsCubit, SearchDetailsState>(
                builder: (context, state) {
                  switch (state.status) {
                    case ViewStatus.initial:
                    case ViewStatus.loading:
                      return const LoadingView();
                    case ViewStatus.failure:
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: switch (state.failure) {
                          NetworkFailure() => StateView.connectionLost(
                            onRetry: cubit.load,
                          ),
                          ServerFailure() => const StateView.serverError(),
                          // Unknown failures are only toasted.
                          _ => const SizedBox.expand(),
                        },
                      );
                    case ViewStatus.success:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CountAndSort(
                            state: state,
                            onSort: () => _openSort(context),
                          ),
                          Expanded(child: _DoctorsList(state: state)),
                        ],
                      );
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

class _Bar {
  final bool visible;
  final bool dot;

  const _Bar({required this.visible, required this.dot});

  @override
  bool operator ==(Object other) =>
      other is _Bar && other.visible == visible && other.dot == dot;

  @override
  int get hashCode => Object.hash(visible, dot);
}

/// Adds the 8dp red badge (`bg_circle_red`) at the start-top corner.
class _Dotted extends StatelessWidget {
  final bool showDot;
  final Widget child;

  const _Dotted({required this.showDot, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showDot)
          const PositionedDirectional(
            start: 0,
            top: 0,
            child: SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFED1C24),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Purple header (`ic_background_search`): back arrow, "Search in" caption and
/// the speciality name.
class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.icBackgroundSearch, fit: BoxFit.cover),
          PositionedDirectional(
            start: 16,
            top: 76,
            child: AppBackButton(
              onTap: () => context.pop(),
              size: 36,
              boxSize: 36,
              color: AppColors.white,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.searchIn,
                  style: AppTextStyles.bold(12, AppColors.cFDF9ED),
                ),
                const VerticalSpacer(6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: AppTextStyles.bold(18, AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "All doctors (n)" at the start and the Sort button (red dot when set) at the
/// end.
class _CountAndSort extends StatelessWidget {
  final SearchDetailsState state;
  final VoidCallback onSort;

  const _CountAndSort({required this.state, required this.onSort});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = state.doctors.isEmpty ? '' : '(${state.count})';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              l10n.allDoctors(count),
              style: AppTextStyles.medium(16, AppColors.black),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSort,
            child: _Dotted(
              showDot: state.filter.sortBy != null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSvg(AppAssets.icSort),
                  const HorizontalSpacer(10),
                  Text(
                    l10n.sortingBy,
                    style: AppTextStyles.medium(14, AppColors.black),
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

class _DoctorsList extends StatelessWidget {
  final SearchDetailsState state;

  const _DoctorsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SearchDetailsCubit>();
    final isLoggedIn = context.read<SessionCubit>().state.isLoggedIn;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return RefreshIndicator(
      color: AppColors.primary,
      // Android hides the spinner at once; the list shows its own loader.
      onRefresh: () async => cubit.load(),
      child: state.doctors.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: StateView.empty(
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
                  onFavorite: isLoggedIn ? () => cubit.toggleFavorite(i) : null,
                  onTap: () async {
                    final id = doctor.id;
                    if (id == null) return;
                    await context.push(Routes.doctorDetailsOf(id));
                    // Android reloads in onResume, so favorites changed in the
                    // details screen show up.
                    if (context.mounted) cubit.load();
                  },
                );
              },
            ),
    );
  }
}
