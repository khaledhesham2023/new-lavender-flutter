import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/debounced_search_field.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/enums/enums.dart';
import '../../data/models/responses/appointment.dart';
import '../../data/repositories/booking_repository.dart';
import '../../router/routes.dart';
import 'actions/booking_actions.dart';
import 'bookings_cubit.dart';
import 'filter_by_date_sheet.dart';
import 'filter_by_type_sheet.dart';
import 'widgets/booking_card.dart';
import 'widgets/status_tabs.dart';

/// Port of `BookingsFragment` (bottom-navigation "Bookings" tab). Guests see
/// the login prompt; logged-in users get the status tabs, search, filters and
/// the list of appointments.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<SessionCubit, bool>(
      (c) => c.state.isLoggedIn,
    );
    return loggedIn ? const _LoggedInView() : const _GuestView();
  }
}

/// Transparent status bar over the 130dp header image, then the "you must log
/// in" empty view (`containerActionBar` + `errorLayout`).
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
            SizedBox(
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
                        l10n.myBookings,
                        maxLines: 1,
                        style: AppTextStyles.bold(18, AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StateView.empty(
                  icon: AppAssets.icMustLogin,
                  title: l10n.youMustLoginTitle,
                  body: l10n.youHaveToLoginFirstBodyReservationsAndTrackFavorites,
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
      create: (_) => BookingsCubit(sl<BookingRepository>())..load(),
      // Transparent status bar over the white page (dark icons): a solid white
      // bar would stay bright above a sheet's dimmed barrier.
      child: const SystemUi(child: _BookingsBody()),
    );
  }
}

class _BookingsBody extends StatelessWidget {
  const _BookingsBody();

  Future<void> _pickDate(BuildContext context, BookingsCubit cubit) async {
    final result = await showFilterByDateSheet(
      context,
      current: cubit.state.month,
    );
    if (result != null) cubit.setMonth(result.value);
  }

  Future<void> _pickType(BuildContext context, BookingsCubit cubit) async {
    final result = await showFilterByTypeSheet(
      context,
      current: cubit.state.type,
    );
    if (result != null) cubit.setType(result.value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<BookingsCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 16,
                end: 16,
                top: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 20),
                      child: Text(
                        l10n.myBookings,
                        style: AppTextStyles.bold(16, AppColors.c0F0102),
                      ),
                    ),
                  ),
                  BlocSelector<BookingsCubit, BookingsState, bool>(
                    selector: (s) => s.hasDateFilter,
                    builder: (context, active) => _FilterIcon(
                      icon: AppAssets.icFilterByTime,
                      showDot: active,
                      onTap: () => _pickDate(context, cubit),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalSpacer(25),
            BlocSelector<BookingsCubit, BookingsState, BookingStatus>(
              selector: (s) => s.status,
              builder: (context, status) =>
                  StatusTabs(selected: status, onSelected: cubit.selectTab),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 16,
                end: 16,
                top: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DebouncedSearchField(
                      hint: l10n.searchBySpecialityOrDoctor,
                      // Android waits 1 s after the last keystroke.
                      debounce: const Duration(milliseconds: 1000),
                      onChanged: cubit.setKeyword,
                    ),
                  ),
                  const HorizontalSpacer(10),
                  BlocSelector<BookingsCubit, BookingsState, bool>(
                    selector: (s) => s.hasTypeFilter,
                    builder: (context, active) => _FilterIcon(
                      icon: AppAssets.icFilterByType,
                      showDot: active,
                      onTap: () => _pickType(context, cubit),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<BookingsCubit, BookingsState>(
                listenWhen: (prev, curr) =>
                    curr.failure is UnknownFailure &&
                    prev.failure != curr.failure,
                listener: (context, state) =>
                    showFailureToast(context, state.failure!),
                builder: (context, state) => RefreshIndicator(
                  color: AppColors.primary,
                  // Android hides the spinner at once; the list has its own loader.
                  onRefresh: () async {
                    cubit.load();
                  },
                  child: _BookingsList(state: state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter icon with the 10dp red dot at its top-start corner.
class _FilterIcon extends StatelessWidget {
  final String icon;
  final bool showDot;
  final VoidCallback onTap;

  const _FilterIcon({
    required this.icon,
    required this.showDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          AppSvg(icon),
          if (showDot)
            const PositionedDirectional(
              start: 0,
              top: 0,
              child: SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cED1C24,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final BookingsState state;

  const _BookingsList({required this.state});

  Future<void> _open(BuildContext context, AppointmentData item) async {
    final id = item.id;
    if (id == null) return;
    final cubit = context.read<BookingsCubit>();
    await context.push(
      item.offer != null
          ? Routes.sessionDetailsOf(id)
          : Routes.appointmentDetailsOf(id),
    );
    // The details screen may have changed the booking.
    if (!cubit.isClosed) cubit.load();
  }

  /// Applies what a booking action asks of the list. The item is looked up by
  /// id again: the list may have changed while the sheets were open.
  void _apply(
    BookingsCubit cubit,
    AppointmentData item,
    BookingActionResult result,
  ) {
    if (cubit.isClosed) return;
    switch (result) {
      case BookingActionResult.none:
        break;
      case BookingActionResult.removed:
        cubit.removeAt(cubit.state.items.indexWhere((e) => e.id == item.id));
      case BookingActionResult.reload:
        cubit.load();
    }
  }

  Future<void> _cancel(BuildContext context, AppointmentData item) async {
    final id = item.id;
    if (id == null) return;
    final cubit = context.read<BookingsCubit>();
    final result = await const BookingActions().cancel(context, id);
    _apply(cubit, item, result);
  }

  Future<void> _edit(BuildContext context, AppointmentData item) async {
    final cubit = context.read<BookingsCubit>();
    final result = await const BookingActions().edit(
      context,
      item,
      BookingStatus.fromValue(item.status) ?? cubit.state.status,
    );
    _apply(cubit, item, result);
  }

  Future<void> _rate(BuildContext context, AppointmentData item) async {
    final cubit = context.read<BookingsCubit>();
    final result = await const BookingActions().rate(context, item);
    _apply(cubit, item, result);
  }

  Future<void> _rebook(BuildContext context, AppointmentData item) async {
    final cubit = context.read<BookingsCubit>();
    final result = await const BookingActions().rebook(
      context,
      item,
      BookingStatus.fromValue(item.status) ?? cubit.state.status,
    );
    _apply(cubit, item, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget fill(Widget child) => CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );
    Widget padded(Widget child) =>
        Padding(padding: const EdgeInsets.only(top: 20), child: child);

    switch (state.viewStatus) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return fill(const LoadingView());
      case ViewStatus.failure:
        return fill(
          padded(switch (state.failure) {
            // Android shows no retry button on these list views.
            NetworkFailure() => StateView.empty(
              icon: AppAssets.icNetworkError2,
              title: l10n.noInternetConncetion,
              body: l10n.noInternetConncetionBody2,
            ),
            ServerFailure() => StateView.serverError(body: l10n.serverErrorBody2),
            // Unknown failures are only toasted.
            _ => const SizedBox.expand(),
          }),
        );
      case ViewStatus.success:
        if (state.items.isEmpty) {
          return fill(
            padded(
              StateView.empty(
                icon: AppAssets.icEmptyBookingsList,
                title: l10n.noReservationsTitle,
                body: l10n.noReservationsBody,
              ),
            ),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: state.items.length,
          itemBuilder: (context, i) {
            final item = state.items[i];
            return BookingCard(
              key: ValueKey(item.id),
              item: item,
              onTap: () => _open(context, item),
              onCancel: (item) => _cancel(context, item),
              onEdit: (item) => _edit(context, item),
              onRate: (item) => _rate(context, item),
              onRebook: (item) => _rebook(context, item),
            );
          },
        );
    }
  }
}
