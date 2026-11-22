import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/bottom_sheet_frame.dart';
import '../../../../core/widgets/failure_toast.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../shared/domain/repositories/booking_repository.dart';
import 'add_comment_cubit.dart';

/// Port of `AddCommentSheetFragment`. Resolves to true after the review was sent.
Future<bool> showAddCommentSheet(
  BuildContext context, {
  required int doctorId,
  required int appointmentId,
}) async {
  final result = await showAppBottomSheet<bool>(
    context,
    builder: (_) => BlocProvider(
      create: (_) => AddCommentCubit(
        sl<BookingRepository>(),
        doctorId: doctorId,
        appointmentId: appointmentId,
      )..loadQuickComments(),
      child: const _AddCommentView(),
    ),
  );
  return result ?? false;
}

class _AddCommentView extends StatefulWidget {
  const _AddCommentView();

  @override
  State<_AddCommentView> createState() => _AddCommentViewState();
}

class _AddCommentViewState extends State<_AddCommentView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AddCommentCubit>();
    final image = context.select<SessionCubit, String?>(
      (c) => c.state.user?.image,
    );
    return BlocListener<AddCommentCubit, AddCommentState>(
      listenWhen: (prev, curr) =>
          (curr.sentMessage != null && prev.sentMessage != curr.sentMessage) ||
          (curr.failure != null && prev.failure != curr.failure),
      listener: (context, state) {
        final message = state.sentMessage;
        if (message != null) {
          AppToast.show(context, message, ToastType.success);
          Navigator.pop(context, true);
        } else if (state.failure != null) {
          showFailureToast(context, state.failure!);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 21),
                decoration: BoxDecoration(
                  color: AppColors.cDCDCE4,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                l10n.addYourBookReviewTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bold(18, AppColors.c020617),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                l10n.addYourBookReviewBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(14, AppColors.c6B6B6B),
              ),
            ),
            const VerticalSpacer(45),
            const _Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 23),
              child: Center(
                child: BlocSelector<AddCommentCubit, AddCommentState, double>(
                  selector: (s) => s.rate,
                  builder: (context, rate) => StarRating(
                    score: rate,
                    size: 36,
                    readOnly: false,
                    onChanged: cubit.setRate,
                  ),
                ),
              ),
            ),
            const _Divider(),
            _QuickComments(
              onPick: (text) {
                _controller.value = TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cF0F1F4,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const HorizontalSpacer(12),
                          AppNetworkImage(
                            url: image,
                            width: 24,
                            height: 24,
                            circle: true,
                          ),
                          const HorizontalSpacer(20),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: AppTextStyles.medium(12, AppColors.c251836),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: l10n.addComment,
                                hintStyle: AppTextStyles.medium(
                                  12,
                                  AppColors.c909DAD,
                                ),
                              ),
                            ),
                          ),
                          const HorizontalSpacer(8),
                        ],
                      ),
                    ),
                  ),
                  const HorizontalSpacer(10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cF0F1F4,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: BlocSelector<AddCommentCubit, AddCommentState, bool>(
                      selector: (s) => s.sending,
                      builder: (context, sending) => sending
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => cubit.send(_controller.text),
                              child: const Center(
                                child: AppSvg(
                                  AppAssets.icSend,
                                  color: AppColors.c130918,
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
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.cE6E6E6);
}

/// "Quick replies:" label + horizontally scrolling chips (`rvQuickResponses`).
class _QuickComments extends StatelessWidget {
  final ValueChanged<String> onPick;

  const _QuickComments({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Text(
                context.l10n.quickReplies,
                style: AppTextStyles.semiBold(12, AppColors.c656B78),
              ),
            ),
            Expanded(
              child: BlocBuilder<AddCommentCubit, AddCommentState>(
                buildWhen: (p, c) =>
                    p.quickComments != c.quickComments ||
                    p.loadingQuickComments != c.loadingQuickComments,
                builder: (context, state) {
                  if (state.loadingQuickComments && state.quickComments.isEmpty) {
                    return const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: state.quickComments.length,
                    itemBuilder: (context, i) {
                      final text = state.quickComments[i].text ?? '';
                      return GestureDetector(
                        onTap: () => onPick(text),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.c3D4C5E,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(10, AppColors.c251836),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
