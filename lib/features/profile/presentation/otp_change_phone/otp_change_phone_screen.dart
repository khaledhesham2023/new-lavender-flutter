import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/failure_toast.dart';
import '../../../../core/widgets/bottom_sheet_frame.dart';
import '../../../../core/widgets/progress_button.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../core/widgets/system_ui.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import '../../../../app/router/route_args.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/field_error.dart';
import '../../../../shared/widgets/otp_input.dart';
import '../success_sheet.dart';
import 'otp_change_phone_cubit.dart';

/// Port of `OtpChangePhoneFragment` (`fragment_otp_change_phone.xml`): confirms the new
/// phone (Edit profile) or the code of the profile forgot-password flow.
class OtpChangePhoneScreen extends StatelessWidget {
  final OtpArgs args;
  const OtpChangePhoneScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OtpChangePhoneCubit(sl<AuthRepository>(), sl<SessionCubit>(), args),
      child: _OtpChangePhoneView(args: args),
    );
  }
}

class _OtpChangePhoneView extends StatefulWidget {
  final OtpArgs args;
  const _OtpChangePhoneView({required this.args});

  @override
  State<_OtpChangePhoneView> createState() => _OtpChangePhoneViewState();
}

class _OtpChangePhoneViewState extends State<_OtpChangePhoneView> {
  final _inputKey = GlobalKey<OtpInputState>();
  String _typed = '';
  bool _sheetOpen = false;

  Future<void> _onState(BuildContext context, OtpChangePhoneState state) async {
    final cubit = context.read<OtpChangePhoneCubit>();

    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    if (state.codeError && !state.loading && _typed.length == OtpInput.length) {
      // Android `resetCodeInputs`: wrong code empties the boxes and refocuses the first.
      _inputKey.currentState?.clear();
      return;
    }

    switch (state.event) {
      case OtpChangePhoneEvent.none:
        break;
      case OtpChangePhoneEvent.phoneChanged:
        final router = GoRouter.of(context);
        cubit.consumeEvent();
        setState(() => _sheetOpen = true);
        await showProfileSuccessSheet(context, ProfileSuccessType.changePhone);
        // Back to Edit profile, which reloads the stored phone.
        if (router.canPop()) router.pop();
      case OtpChangePhoneEvent.navigateNewPassword:
        final otp = state.otp;
        cubit.consumeEvent();
        context.push(
          Routes.forgetPasswordForEdit,
          extra: NewPasswordArgs(
            phone: widget.args.phone,
            phoneCode: widget.args.phoneCode,
            otp: otp,
          ),
        );
    }
  }

  /// One centered paragraph: intro text, the phone number, then the purpose text.
  InlineSpan _bodySpan(BuildContext context) {
    final l10n = context.l10n;
    // Non-breaking space: the number must never split across two lines.
    final phone =
        '${widget.args.phoneCode}${String.fromCharCode(0xA0)}${widget.args.phone}';
    return TextSpan(
      children: [
        TextSpan(text: '${l10n.enterTheCodeSentToThePhoneNumber} '),
        TextSpan(
          // Left-to-right embedding keeps "+966 5..." in order inside the RTL paragraph.
          text:
              '${String.fromCharCode(0x202A)}$phone${String.fromCharCode(0x202C)}',
          style: AppTextStyles.medium(14, AppColors.primary).copyWith(
            height: 1.4,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
        TextSpan(text: ' ${l10n.toConfirmYourAccount}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      // The system paints the status bar, so the sheet's barrier cannot dim it.
      statusBarColor: _sheetOpen ? dimmedWhiteStatusBar : AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<OtpChangePhoneCubit, OtpChangePhoneState>(
          listener: _onState,
          builder: (context, state) {
            final cubit = context.read<OtpChangePhoneCubit>();
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        title: l10n.enterTheConfirmationCode,
                        body: '',
                        bodySpan: _bodySpan(context),
                        onBack: () => context.pop(),
                      ),
                      const VerticalSpacer(22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OtpInput(
                          key: _inputKey,
                          onChanged: (v) => setState(() => _typed = v),
                          onCompleted: cubit.verify,
                        ),
                      ),
                      if (state.codeError)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FieldErrorText(
                            l10n.thisCodeIsInvalidPleaseTryAgain,
                          ),
                        ),
                      const VerticalSpacer(64),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ProgressButton(
                          text: l10n.confirm,
                          loading: state.loading,
                          enabled: _typed.length == OtpInput.length,
                          onPressed: () => cubit.verify(_typed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
