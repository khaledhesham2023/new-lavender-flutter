import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/network/api_result.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/failure_toast.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/system_ui.dart';
import '../../../../core/enums/enums.dart';
import '../../../../data/models/responses/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../../../app/router/routes.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_item.dart';

/// Port of `NotificationsFragment`. Guests see the login prompt; logged-in users
/// get the allow switch and the paged list (swipe to delete, tap to open).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<SessionCubit, bool>(
      (c) => c.state.isLoggedIn,
    );
    return loggedIn ? const _LoggedInView() : const _GuestView();
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
            // `containerActionBar`: 130dp header image with the white title.
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
                        l10n.notifications,
                        maxLines: 1,
                        style: AppTextStyles.bold(18, AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StateView.empty(
                icon: AppAssets.icMustLogin,
                title: l10n.youMustLoginTitle,
                body: l10n.youHaveToLoginFirstBodyReservationsAndGetNotified,
                buttonTitle: l10n.login,
                onButton: () => context.push(Routes.authStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A page request that failed; kept as the paging error so the screen can pick
/// the matching view.
class _PageFailure implements Exception {
  final ApiFailure<dynamic> failure;

  const _PageFailure(this.failure);
}

class _LoggedInView extends StatefulWidget {
  const _LoggedInView();

  @override
  State<_LoggedInView> createState() => _LoggedInViewState();
}

class _LoggedInViewState extends State<_LoggedInView> {
  late final NotificationsCubit _cubit = NotificationsCubit(
    sl<NotificationsRepository>(),
    sl<AppPrefs>(),
  );
  late final PagingController<int, NotificationModel> _controller =
      PagingController<int, NotificationModel>(
        // First page is 1; a page that comes back empty is the end.
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: _fetchPage,
      );

  /// Ids whose "mark as read" request is running (ignores repeated taps).
  final _reading = <String>{};

  @override
  void initState() {
    super.initState();
    _controller.fetchNextPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<List<NotificationModel>> _fetchPage(int page) async {
    final result = await _cubit.getPage(page);
    return switch (result) {
      ApiSuccess(:final data) => data.items,
      ApiFailure() => throw _PageFailure(result),
    };
  }

  void _reload() {
    _controller.refresh();
    _controller.fetchNextPage();
  }

  void _updateItems(
    List<NotificationModel> Function(List<NotificationModel> page) change,
  ) {
    final pages = _controller.value.pages;
    if (pages == null) return;
    _controller.value = _controller.value.copyWith(
      pages: [for (final page in pages) change(page)],
    );
  }

  Future<void> _onTap(NotificationModel notification) async {
    final id = notification.id;
    if (id == null || !_reading.add(id)) return;
    final result = await _cubit.markRead(id);
    _reading.remove(id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        _updateItems(
          (page) => [
            for (final n in page)
              if (n.id == id) n.copyWith(isReaded: true) else n,
          ],
        );
        _open(notification.data);
      case ApiFailure():
        showFailureToast(context, result);
    }
  }

  /// Opens the screen the notification is about (`data.notify_type`).
  void _open(NotificationTypeData? data) {
    final id = data?.notifyId;
    switch (NotificationType.fromValue(data?.notifyType)) {
      case NotificationType.appointment:
        if (id != null) context.push(Routes.appointmentDetailsOf(id));
      case NotificationType.offer:
        context.push(Routes.offerDetailsOf(id ?? 0));
      case NotificationType.report:
        context.push(Routes.myReports);
      case NotificationType.userOffer:
        context.push(Routes.myOfferDetailsOf(id ?? 0));
      case null:
        break;
    }
  }

  /// The row is already gone from the tree when this runs (Dismissible), so it
  /// is removed from the list first; a failed request reloads the list.
  Future<void> _delete(NotificationModel notification) async {
    final id = notification.id;
    if (id == null) return;
    _updateItems(
      (page) => [
        for (final n in page)
          if (n.id != id) n,
      ],
    );
    final result = await _cubit.delete(id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final message):
        if (message.isNotEmpty) {
          AppToast.show(context, message, ToastType.success);
        }
        // Nothing left on screen: ask the server again (more pages may exist).
        if (_controller.value.items?.isEmpty ?? false) _reload();
      case ApiFailure():
        showFailureToast(context, result);
        _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: SystemUi(
        statusBarColor: AppColors.white,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(controller: _controller),
                const _DisabledBanner(),
                Expanded(child: _buildList(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return PagingListener<int, NotificationModel>(
      controller: _controller,
      builder: (context, state, fetchNextPage) {
        switch (state.status) {
          case PagingStatus.loadingFirstPage:
            return const LoadingView();
          case PagingStatus.firstPageError:
            final error = state.error;
            final failure = error is _PageFailure
                ? error.failure
                : const UnknownFailure<dynamic>('');
            return _refreshable(
              StateView.forFailure(failure, onRetry: _reload),
            );
          case PagingStatus.noItemsFound:
            return _refreshable(
              StateView.empty(
                icon: AppAssets.icNoNotifications,
                title: l10n.noNotificationsTitle,
                body: l10n.noNotificationsBody,
              ),
            );
          case PagingStatus.ongoing:
          case PagingStatus.subsequentPageError:
          case PagingStatus.completed:
            return RefreshIndicator(
              color: AppColors.primary,
              // Android hides the spinner at once; the list reloads on its own.
              onRefresh: () async => _reload(),
              child: PagedListView<int, NotificationModel>(
                state: state,
                fetchNextPage: fetchNextPage,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(16, 24, 16, bottom),
                builderDelegate: PagedChildBuilderDelegate<NotificationModel>(
                  itemBuilder: (context, item, index) => Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    dismissThresholds: const {DismissDirection.endToStart: 0.7},
                    background: _DeleteBackground(
                      label: Directionality.of(context) == TextDirection.rtl
                          ? l10n.remove
                          : 'Delete',
                    ),
                    onDismissed: (_) => _delete(item),
                    child: NotificationItem(
                      notification: item,
                      onTap: () => _onTap(item),
                    ),
                  ),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LoadingView(size: 30),
                  ),
                  newPageErrorIndicatorBuilder: (_) => Center(
                    child: TextButton(
                      onPressed: fetchNextPage,
                      child: Text(
                        l10n.retry,
                        style: AppTextStyles.semiBold(14, AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  /// Lets an empty / error view be pulled to refresh.
  Widget _refreshable(Widget child) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _reload(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
      ),
    );
  }
}

/// Back arrow, centered title and the allow switch, over a 1dp line.
class _Header extends StatelessWidget {
  final PagingController<int, NotificationModel> controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 10, start: 16),
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                AppBackButton(boxSize: 36, onTap: () => context.pop()),
                Expanded(
                  child: Text(
                    context.l10n.notifications,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold(16, AppColors.c0F0102),
                  ),
                ),
                // Android hides the switch while the first page is in error.
                ValueListenableBuilder<PagingState<int, NotificationModel>>(
                  valueListenable: controller,
                  builder: (context, state, _) {
                    final hidden = state.status == PagingStatus.firstPageError;
                    return Visibility(
                      visible: !hidden,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: const _AllowSwitch(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 10),
          color: AppColors.cE6E6E6,
        ),
      ],
    );
  }
}

/// `switchNotifications`: a 40x18 pill with an 18dp thumb.
class _AllowSwitch extends StatelessWidget {
  const _AllowSwitch();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (prev, curr) => curr.toggleFailure != null,
      listener: (context, state) {
        showFailureToast(context, state.toggleFailure!);
        cubit.consumeToggleFailure();
      },
      buildWhen: (prev, curr) => prev.allowed != curr.allowed,
      builder: (context, state) {
        final on = state.allowed;
        return GestureDetector(
          onTap: cubit.toggleAllow,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
            child: SizedBox(
              width: 40,
              height: 18,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: on ? AppColors.primary : AppColors.cE6E6E6,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 150),
                    alignment: on
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: on
                            ? Border.all(color: AppColors.primary)
                            : null,
                        boxShadow: on
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 2,
                                ),
                              ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// `tvNotificationsDisabledSection`: shown while notifications are off.
class _DisabledBanner extends StatelessWidget {
  const _DisabledBanner();

  @override
  Widget build(BuildContext context) {
    final allowed = context.select<NotificationsCubit, bool>(
      (c) => c.state.allowed,
    );
    if (allowed) return const SizedBox.shrink();
    return Container(
      height: 54,
      color: AppColors.cE6E6E6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const AppSvg(AppAssets.icNotificationDisabled),
          const HorizontalSpacer(10),
          Expanded(
            child: Text(
              context.l10n.youCanNoLongerReceiveNotifications,
              textAlign: TextAlign.start,
              style: AppTextStyles.semiBold(12, AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// Red area revealed under a swiped row (`onChildDraw`).
class _DeleteBackground extends StatelessWidget {
  final String label;

  const _DeleteBackground({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cE23535,
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(label, style: AppTextStyles.bold(12, AppColors.white)),
    );
  }
}
