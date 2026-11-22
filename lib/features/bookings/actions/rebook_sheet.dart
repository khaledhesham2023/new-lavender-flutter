import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/state_view.dart';
import '../../../shared/domain/repositories/booking_repository.dart';
import '../../booking/day_time_logic.dart';
import '../../booking/widgets/day_time_picker.dart';
import 'rebook_cubit.dart';

export 'rebook_cubit.dart' show RebookArgs, RebookOutcome, ChangeRequested, Rebooked;

/// Port of `ChooseRebookAppointmentSheetFragment`. Not dismissible by tapping
/// outside (Android `isCancel = false`); Cancel / back close it with null.
Future<RebookOutcome?> showRebookSheet(BuildContext context, RebookArgs args) {
  return showAppBottomSheet<RebookOutcome>(
    context,
    isDismissible: false,
    builder: (_) => BlocProvider(
      create: (_) => RebookCubit(sl<BookingRepository>(), args)..load(),
      child: const _RebookView(),
    ),
  );
}

class _RebookView extends StatelessWidget {
  const _RebookView();

  Future<void> _confirm(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<RebookCubit>();
    final result = await cubit.confirm();
    if (!context.mounted) return;
    switch (result) {
      case RebookNeedsDay():
        AppToast.show(context, l10n.pleaseSelectDay, ToastType.failed);
      case RebookNeedsTime():
        AppToast.show(context, l10n.pleaseSelectTime, ToastType.failed);
      case RebookDone(:final outcome):
        Navigator.pop(context, outcome);
      case RebookFailed(:final failure):
        showFailureToast(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RebookCubit>();
    final l10n = context.l10n;
    final title = cubit.args.type == 'book'
        ? l10n.pickUpBookingAppointment
        : l10n.pickUpRebookingAppointment;
    return BlocConsumer<RebookCubit, RebookState>(
      listenWhen: (prev, curr) =>
          curr.failure is UnknownFailure && prev.failure != curr.failure,
      listener: (context, state) => showFailureToast(context, state.failure!),
      builder: (context, state) {
        final Widget body;
        switch (state.status) {
          case ViewStatus.initial:
          case ViewStatus.loading:
            body = const SizedBox(height: 240, child: LoadingView());
          case ViewStatus.failure:
            final failure = state.failure;
            body = SizedBox(
              height: 420,
              child: switch (failure) {
                NetworkFailure() => StateView.connectionLost(
                  onRetry: cubit.load,
                ),
                ServerFailure(code: 404) => StateView.empty(
                  icon: AppAssets.icNoAvailableBookings,
                  title: l10n.noAvailableTimesToday,
                  buttonTitle: l10n.back,
                  onButton: () => Navigator.pop(context),
                ),
                _ => StateView.empty(
                  icon: AppAssets.icServerError2,
                  title: l10n.serverError,
                  body: l10n.serverErrorBody2,
                  buttonTitle: l10n.back,
                  onButton: () => Navigator.pop(context),
                ),
              },
            );
          case ViewStatus.success:
            final showButtons =
                state.days.isEmpty || dayHasTimes(state.selectedDay);
            body = Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: DayTimePicker(
                      title: title,
                      days: state.days,
                      selectedDay: state.selectedDay,
                      selectedTime: state.selectedTime,
                      onDayChanged: cubit.selectDay,
                      onTimeChanged: cubit.selectTime,
                    ),
                  ),
                  if (showButtons)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ProgressButton(
                              text: l10n.confirm,
                              loading: state.submitting,
                              onPressed: () => _confirm(context),
                            ),
                          ),
                          const SizedBox(width: 32),
                          const Expanded(child: _CancelButton()),
                        ],
                      ),
                    ),
                ],
              ),
            );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: AppColors.cDCDCE4,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            body,
          ],
        );
      },
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Text(
              context.l10n.cancel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bold(14, AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
