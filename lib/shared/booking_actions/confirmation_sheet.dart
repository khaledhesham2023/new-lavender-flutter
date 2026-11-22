import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/bottom_sheet_frame.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/progress_button.dart';
import '../domain/repositories/booking_repository.dart';
import 'confirmation_cubit.dart';
import 'confirm_action.dart';
import 'confirmation_state.dart';

export 'confirm_action.dart';

/// Port of `ConfirmationSheetFragment`: runs [action] when Confirm is tapped.
/// Resolves to true after it succeeded, false when cancelled / closed.
Future<bool> showConfirmationSheet(
  BuildContext context, {
  required String title,
  required String body,
  required ConfirmAction action,
}) async {
  final result = await showAppBottomSheet<bool>(
    context,
    builder: (_) => BlocProvider(
      create: (_) => ConfirmationCubit(sl<BookingRepository>(), action),
      child: _ConfirmationView(title: title, body: body),
    ),
  );
  return result ?? false;
}

class _ConfirmationView extends StatelessWidget {
  final String title;
  final String body;

  const _ConfirmationView({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ConfirmationCubit, ConfirmationState>(
      listenWhen: (prev, curr) =>
          (curr.failure != null && prev.failure != curr.failure) ||
          (curr.done && !prev.done),
      listener: (context, state) {
        if (state.done) {
          Navigator.pop(context, true);
        } else if (state.failure != null) {
          showFailureToast(context, state.failure!);
        }
      },
      builder: (context, state) => Column(
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
          const VerticalSpacer(38),
          const AppSvg(AppAssets.icConfirmSheet, width: 55, height: 48),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bold(16, AppColors.c251836),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(14, AppColors.c3D4C5E),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 33, 16, 30),
            child: Row(
              children: [
                Expanded(
                  child: ProgressButton(
                    text: l10n.confirm,
                    height: 52,
                    loading: state.loading,
                    onPressed: () =>
                        context.read<ConfirmationCubit>().confirm(),
                  ),
                ),
                const HorizontalSpacer(32),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: Material(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, false),
                        child: Center(
                          child: Text(
                            l10n.cancel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bold(14, AppColors.primary),
                          ),
                        ),
                      ),
                    ),
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
