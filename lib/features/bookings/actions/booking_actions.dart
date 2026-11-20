import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/widgets/success_dialog.dart';
import '../../../data/enums/enums.dart';
import '../../../data/models/responses/appointment.dart';
import '../../../router/routes.dart';
import 'add_comment_sheet.dart';
import 'confirmation_sheet.dart';
import 'rebook_sheet.dart';

/// What the caller (Bookings list, details screens) must do afterwards.
enum BookingActionResult {
  /// Nothing changed (cancelled / dismissed / failed).
  none,

  /// The booking left the current list.
  removed,

  /// The booking changed: refetch.
  reload,
}

/// The full action flows of `BookingsFragment` (cancel, edit, rebook, rate),
/// reused by the bookings list and the appointment / session details screens.
/// Each sheet resolves to a result instead of Android's shared-ViewModel flags.
/// [context] must be the screen's context: it is checked after every await.
class BookingActions {
  const BookingActions();

  /// Cancel a pending / confirmed booking.
  Future<BookingActionResult> cancel(
    BuildContext context,
    int id,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmationSheet(
      context,
      title: l10n.confirmCancelAppointmentTitle,
      body: l10n.confirmCancelAppointmentBody,
      action: CancelAction(id),
    );
    if (!confirmed || !context.mounted) return BookingActionResult.none;
    await showSuccessDialog(context, l10n.appointmentCanceledSuccessfully);
    return BookingActionResult.removed;
  }

  /// Change the slot of a pending / confirmed booking.
  Future<BookingActionResult> edit(
    BuildContext context,
    AppointmentData item,
    BookingStatus status,
  ) async {
    final id = item.id;
    final doctorId = item.doctor?.id;
    if (id == null || doctorId == null) return BookingActionResult.none;
    final outcome = await showRebookSheet(
      context,
      RebookArgs(
        appointmentId: id,
        doctorId: doctorId,
        status: status,
        type: 'book',
      ),
    );
    if (outcome is! ChangeRequested || !context.mounted) {
      return BookingActionResult.none;
    }
    final l10n = context.l10n;
    final confirmed = await showConfirmationSheet(
      context,
      title: l10n.confirmChangeAppointmentTitle,
      body: l10n.confirmChangeAppointmentBody,
      action: UpdateAction(id, outcome.request),
    );
    if (!confirmed || !context.mounted) return BookingActionResult.none;
    await showSuccessDialog(context, l10n.appointmentChangedSuccessfully);
    // Android removes a confirmed booking from its list and reloads pending.
    return status == BookingStatus.confirmed
        ? BookingActionResult.removed
        : BookingActionResult.reload;
  }

  /// Book again a completed / canceled / rejected booking. Navigates to the
  /// "requested" screen on success.
  Future<BookingActionResult> rebook(
    BuildContext context,
    AppointmentData item,
    BookingStatus status,
  ) async {
    final id = item.id;
    final doctorId = item.doctor?.id;
    if (id == null || doctorId == null) return BookingActionResult.none;
    final outcome = await showRebookSheet(
      context,
      RebookArgs(
        appointmentId: id,
        doctorId: doctorId,
        status: status,
        type: 'rebook',
        forOffer: item.offer != null,
      ),
    );
    if (outcome is! Rebooked || !context.mounted) {
      return BookingActionResult.none;
    }
    await context.push(
      outcome.forOffer
          ? Routes.sessionRequestedOf(outcome.newId)
          : Routes.appointmentRequestedOf(outcome.newId),
    );
    return BookingActionResult.none;
  }

  /// Rate a completed booking.
  Future<BookingActionResult> rate(
    BuildContext context,
    AppointmentData item,
  ) async {
    final id = item.id;
    final doctorId = item.doctor?.id;
    if (id == null || doctorId == null) return BookingActionResult.none;
    final sent = await showAddCommentSheet(
      context,
      doctorId: doctorId,
      appointmentId: id,
    );
    return sent ? BookingActionResult.reload : BookingActionResult.none;
  }
}
