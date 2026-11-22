import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../core/push/device_token.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/success_dialog.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../shared/domain/repositories/auth_repository.dart';
import '../../../app/router/route_args.dart';
import '../../../app/router/routes.dart';
import '../widgets/auth_header.dart';
import '../widgets/field_error.dart';
import '../widgets/otp_input.dart';
import 'otp_cubit.dart';

class OtpScreen extends StatelessWidget {
  final OtpArgs args;
  const OtpScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(
        sl<AuthRepository>(),
        sl<SessionCubit>(),
        sl<DeviceTokenProvider>(),
        args,
      ),
      child: _OtpView(args: args),
    );
  }
}

class _OtpView extends StatefulWidget {
  final OtpArgs args;
  const _OtpView({required this.args});

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final _inputKey = GlobalKey<OtpInputState>();

  bool get _isReset =>
      widget.args.fromDestination == OtpDestination.resetPassword;

  Future<void> _onState(BuildContext context, OtpState state) async {
    final cubit = context.read<OtpCubit>();
    final l10n = context.l10n;

    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    if (state.status == ViewStatus.failure && state.codeError) {
      // Android `resetCodeInputs`: wrong code empties the boxes and refocuses the first.
      _inputKey.currentState?.clear();
      cubit.consumeEvent();
      return;
    }

    switch (state.event) {
      case OtpEvent.none:
        break;
      case OtpEvent.verifiedWithMessage:
        final message = state.message;
        final router = GoRouter.of(context);
        cubit.consumeEvent();
        if (message.isNotEmpty) AppToast.show(context, message, ToastType.success);
        await showSuccessDialog(context, l10n.accountCreatedSuccessfully);
        // Android: MainActivity + finishAffinity -> Home, auth screens gone.
        router.go(Routes.home);
      case OtpEvent.navigateNewPassword:
        final otp = state.otp;
        cubit.consumeEvent();
        context.push(
          Routes.authNewPassword,
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
          text: '${String.fromCharCode(0x202A)}$phone${String.fromCharCode(0x202C)}',
          style: AppTextStyles.medium(14, AppColors.primary).copyWith(
            height: 1.4,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
        TextSpan(
          text:
              ' ${_isReset ? l10n.toRetrieveYourPassword : l10n.toConfirmYourAccount}',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      statusBarColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<OtpCubit, OtpState>(
          listener: _onState,
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        title: _isReset
                            ? l10n.passwordRecoveryTitle
                            : l10n.enterTheConfirmationCode,
                        body: '',
                        bodySpan: _bodySpan(context),
                        onBack: () => context.pop(),
                      ),
                      const VerticalSpacer(22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OtpInput(
                          key: _inputKey,
                          onCompleted: (otp) =>
                              context.read<OtpCubit>().verify(otp),
                        ),
                      ),
                      if (state.codeError)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FieldErrorText(
                            l10n.thisCodeIsInvalidPleaseTryAgain,
                          ),
                        ),
                      // Android's confirm button is `visibility=gone` (auto-submit only):
                      // a small spinner is the only loading feedback.
                      const VerticalSpacer(24),
                      SizedBox(
                        height: 24,
                        child: state.isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
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
