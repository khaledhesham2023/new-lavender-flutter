import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/bottom_sheet_frame.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/progress_button.dart';
import '../../core/widgets/state_view.dart';
import '../../data/models/requests/appointment_requests.dart';
import '../../shared/domain/repositories/booking_repository.dart';
import 'change_appointment_cubit.dart';
import 'day_time_logic.dart';
import 'widgets/day_time_picker.dart';

/// Port of `ChangeAppointmentSheetFragment`: re-pick the day/time from the
/// doctor's work times. Not dismissible by tapping outside; resolves to the new
/// selection, or null when cancelled / closed with back.
Future<ChangeAppointmentRequest?> showChangeAppointmentSheet(
  BuildContext context,
  int doctorId,
) {
  return showAppBottomSheet<ChangeAppointmentRequest>(
    context,
    isDismissible: false,
    builder: (_) => BlocProvider(
      create: (_) =>
          ChangeAppointmentCubit(sl<BookingRepository>(), doctorId)..load(),
      child: const _ChangeAppointmentView(),
    ),
  );
}

class _ChangeAppointmentView extends StatelessWidget {
  const _ChangeAppointmentView();

  void _confirm(BuildContext context) {
    final l10n = context.l10n;
    switch (context.read<ChangeAppointmentCubit>().confirm()) {
      case ChangeNeedsDay():
        AppToast.show(context, l10n.pleaseSelectDay, ToastType.failed);
      case ChangeNeedsTime():
        AppToast.show(context, l10n.pleaseSelectTime, ToastType.failed);
      case ChangeConfirmed(:final request):
        Navigator.pop(context, request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChangeAppointmentCubit>();
    final l10n = context.l10n;
    return BlocConsumer<ChangeAppointmentCubit, ChangeAppointmentState>(
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
            body = SizedBox(
              height: 420,
              child: state.failure is NetworkFailure
                  ? StateView.connectionLost(onRetry: cubit.load)
                  : StateView.empty(
                      icon: AppAssets.icServerError2,
                      title: l10n.serverError,
                      body: l10n.serverErrorBody2,
                      buttonTitle: l10n.back,
                      onButton: () => Navigator.pop(context),
                    ),
            );
          case ViewStatus.success:
            // Android hides the buttons while the selected day has no times.
            final showButtons =
                state.days.isEmpty || dayHasTimes(state.selectedDay);
            body = Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: DayTimePicker(
                      days: state.days,
                      selectedDay: state.selectedDay,
                      selectedTime: state.selectedTime,
                      onDayChanged: cubit.selectDay,
                      onTimeChanged: cubit.selectTime,
                    ),
                  ),
                  if (showButtons)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ProgressButton(
                              text: l10n.confirm,
                              onPressed: () => _confirm(context),
                            ),
                          ),
                          const VerticalSpacer(32),
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
