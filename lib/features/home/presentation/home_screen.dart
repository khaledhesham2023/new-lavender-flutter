import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../app/push/push_service.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../shared/domain/repositories/general_repository.dart';
import '../../../shared/domain/repositories/home_repository.dart';
import '../../../app/router/routes.dart';
import 'home_cubit.dart';
import 'widgets/banners_section.dart';
import '../../../shared/widgets/doctor_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/guest_card.dart';
import 'widgets/next_reservation_card.dart';
import 'widgets/section_header.dart';
import 'widgets/special_offer_card.dart';
import 'widgets/specialities_section.dart';

/// Home tab (port of `HomeFragment`). The shell rebuilds this screen every time
/// the tab is selected, so it reloads like Android's `initializeComponents`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        // The Android 13+ notification dialog, once, the first time Home shows (T39).
        unawaited(sl<PushService>().requestPermissionOnce());
        return HomeCubit(
          sl<HomeRepository>(),
          sl<GeneralRepository>(),
          sl<AppPrefs>(),
        )..load();
      },
      // Guest -> login -> `context.go(Routes.home)` keeps this very page (same
      // page key), so the cubit is not recreated: reload when the session's
      // login state changes (Android reloads in `onResume`).
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (prev, curr) => prev.isLoggedIn != curr.isLoggedIn,
        listener: (context, _) => context.read<HomeCubit>().load(),
        child: const SystemUi(child: _HomeView()),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: BlocConsumer<HomeCubit, HomeState>(
          listenWhen: (prev, curr) =>
              (curr.failure is UnknownFailure &&
                  prev.failure != curr.failure) ||
              (curr.favoriteFailure != null &&
                  prev.favoriteFailure != curr.favoriteFailure),
          listener: (context, state) {
            final cubit = context.read<HomeCubit>();
            if (state.favoriteFailure != null) {
              showFailureToast(context, state.favoriteFailure!);
              cubit.consumeFavoriteFailure();
            } else if (state.failure != null) {
              showFailureToast(context, state.failure!);
            }
          },
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();
            switch (state.status) {
              case ViewStatus.initial:
              case ViewStatus.loading:
                return const LoadingView();
              case ViewStatus.failure:
                return switch (state.failure) {
                  NetworkFailure() => StateView.connectionLost(
                    onRetry: cubit.load,
                  ),
                  ServerFailure() => StateView.serverError(
                    title: context.l10n.somethingWrongHappen,
                  ),
                  // Unknown failures are only toasted; the screen stays empty.
                  _ => const SizedBox.expand(),
                };
              case ViewStatus.success:
                return const _HomeContent();
            }
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<HomeCubit>().state;
    final data = state.data!;
    final cubit = context.read<HomeCubit>();
    final isLoggedIn = context.read<SessionCubit>().state.isLoggedIn;
    final specialities = buildHomeSpecialities(
      data.specialties,
      l10n.medicalOffers,
    );
    final reservation = data.nextReservation;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GreetingHeader(
            isLoggedIn: isLoggedIn,
            userName: data.userName,
            userImage: data.userImage,
            notificationsCount: data.notificationsCount,
            onNotifications: () => context.push(Routes.notifications),
          ),
          // The 24dp gap stays even without a reservation (Android keeps the
          // include's margin while both of its children are gone).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: !isLoggedIn
                ? GuestCard(onLogin: () => context.push(Routes.authStart))
                : reservation == null
                ? const SizedBox.shrink()
                : NextReservationCard(
                    reservation: reservation,
                    onTap: () async {
                      final id = reservation.id;
                      if (id != null) {
                        await context.push(Routes.appointmentDetailsOf(id));
                        if (!cubit.isClosed) cubit.refresh();
                      }
                    },
                  ),
          ),
          const _SearchBox(),
          if (data.banners.isNotEmpty)
            BannersSection(
              banners: data.banners,
              onTap: (b) => context.push(Routes.offerDetailsOf(b.offerId)),
            ),
          if (data.specialties.isNotEmpty)
            SpecialitiesSection(
              items: specialities,
              onShowAll: () => context.push(Routes.allSpecialities),
              onOffers: () => context.push(Routes.offers),
              onMore: () => context.push(Routes.allSpecialities),
              onSpeciality: (s) => context.push(Routes.searchDetails, extra: s),
            ),
          if (state.doctors.isNotEmpty) ...[
            SectionHeader(title: l10n.recentlyAddedDoctors),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < state.doctors.length; i++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: DoctorCard(
                            doctor: state.doctors[i],
                            onTap: () async {
                              final id = state.doctors[i].id;
                              if (id != null) {
                                await context.push(Routes.doctorDetailsOf(id));
                                if (!cubit.isClosed) cubit.refresh();
                              }
                            },
                            onFavorite: isLoggedIn
                                ? () => cubit.toggleFavorite(i)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (data.offers.isNotEmpty) ...[
            SectionHeader(
              title: l10n.featuredMedicalOffers,
              titleIcon: const AppSvg(AppAssets.icGift, width: 19, height: 19),
              onShowAll: () => context.push(Routes.offers),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final offer in data.offers)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: SpecialOfferCard(
                            offer: offer,
                            onTap: () {
                              final id = offer.id;
                              if (id != null) {
                                context.push(Routes.offerDetailsOf(id));
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// Read-only search box: opens the Search tab.
class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(Routes.search),
        child: Container(
          height: 50,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cFAFAFA,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cE6E6E6),
          ),
          child: Row(
            children: [
              const AppSvg(AppAssets.icSearch, width: 20, height: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.searchBySpecialityOrDoctor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(12, AppColors.c666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
