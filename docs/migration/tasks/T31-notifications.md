# T31 - Notifications screen

## Goal
Port the notifications list: paging, unread dot, mark read + navigate by type, swipe to delete, allow-notifications switch,
pull to refresh, guest prompt.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/notifications/NotificationsFragment.kt` (whole file), `NotificationsViewModel.kt`, `NotificationsAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/data/paging/NotificationsPagingSource.kt`, `PagingkConfig.kt`
- `res/layout/fragment_notifications.xml`, `recycler_item_notification.xml`, `switch_thumb_selector.xml`, `switch_track_selector.xml`
- `docs/migration/CONTEXT.md` §7.4 (Notifications row)
- `lib/data/repositories/notifications_repository.dart`

## Build
- `lib/features/notifications/notifications_screen.dart`, `notifications_cubit.dart` (switch + actions), `widgets/notification_item.dart`
- Router: replace `notifications`.

## Steps
1. `flutter pub add infinite_scroll_pagination`. Use a `PagingController<int, NotificationModel>` (first page 1; next = page+1; last page when a page is empty).
   Page errors map to the same views as Android: first-page error → `StateView.forFailure(retry: controller.refresh)`; next-page error → footer with retry.
   Empty (first page empty) → `StateView.empty` with the Kotlin's empty icon/strings (look at `errorOrEmptyState` call for the empty case, e.g. `ic_empty_message`, `thereAreNoMessagesYet`).
2. Header: back, title; logged in → switch "allow notifications" initialized from `prefs.allowNotifications`; banner `tvNotificationsDisabledSection` visible when off.
   Toggle → `toggleAllow()`; success → set value from response + save prefs; failure → revert switch + toast.
3. Item: unread dot when `is_readed == false`, title, body, `date_formated`/`sending_time_ago` (check adapter). Tap → `markRead(id)`; on success mark it read locally
   and navigate by `data.notify_type`: appointment → `Routes.appointmentDetails(notify_id)`, offer → `Routes.offerDetails(notify_id)`, report → `Routes.myReports`,
   user_offer → `Routes.myOfferDetails(notify_id)` (all `push`).
4. Swipe to delete: `Dismissible` direction end-to-start in LTR, start-to-end in RTL (Android computes by layout direction — `DismissDirection.endToStart` already flips in RTL; verify visually),
   background as in `onChildDraw` (check color/icon). On dismiss → `delete(id)`; success → remove from the controller's item list; failure → toast and `refresh()`.
5. Pull to refresh → `controller.refresh()`.
6. Guest: must-login `StateView` (strings from Kotlin `setupViewsForGuest`), refresh disabled, no switch.
7. Back → pop. Status bar per Kotlin (`onResume`).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device with > 15 notifications: second page loads on scroll; tapping marks read and opens the right screen; swipe deletes; switch toggles and the banner follows; guest sees the prompt.

## Out of scope
- Push delivery and badge updates (T39).

## Gotchas
- The Android adapter retries pagination on any scroll (`setOnScrollChangeListener { retry() }`); the package's built-in retry is enough.
- `NotificationModel.id` is a string UUID.
