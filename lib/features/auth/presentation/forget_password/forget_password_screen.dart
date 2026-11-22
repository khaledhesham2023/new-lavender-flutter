import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_link.dart';
import '../../../../core/widgets/failure_toast.dart';
import '../../../../core/widgets/progress_button.dart';
import '../../../../core/widgets/system_ui.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import '../../../../app/router/route_args.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../widgets/phone_field.dart';
import 'forget_password_cubit.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordCubit(sl<AuthRepository>()),
      child: const _ForgetPasswordView(),
    );
  }
}

class _ForgetPasswordView extends StatefulWidget {
  const _ForgetPasswordView();

  @override
  State<_ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<_ForgetPasswordView> {
  final _phone = TextEditingController();
  final _phoneKey = GlobalKey<PhoneFieldState>();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  /// Android navigateUp: back to Login (always below us when opened from there).
  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.authLogin);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_phoneKey.currentState!.validate()) {
      context.read<ForgetPasswordCubit>().submit(_phone.text);
    }
  }

  void _onState(BuildContext context, ForgetPasswordState state) {
    final cubit = context.read<ForgetPasswordCubit>();
    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    if (state.event == ForgetPasswordEvent.navigateOtp) {
      final phone = _phone.text;
      cubit.consumeEvent();
      context.push(
        Routes.authOtp,
        extra: OtpArgs(
          phone: phone,
          phoneCode: PhoneFieldState.phoneCode,
          fromDestination: OtpDestination.resetPassword,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
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
                        title: l10n.forgetPasswordTitle,
                        body: l10n.forgetPasswordBody,
                        onBack: _back,
                        gapBelowImage: 21,
                      ),
                      PhoneField(
                        key: _phoneKey,
                        controller: _phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: ProgressButton(
                          text: l10n.sendOtp,
                          loading: state.isLoading,
                          onPressed: _submit,
                        ),
                      ),
                      Text(
                        l10n.waitRememberPassword,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regular(14, AppColors.c666666),
                      ),
                      VerticalSpacer(4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppLink(
                          text: l10n.backToLogin,
                          textAlign: TextAlign.center,
                          onTap: _back,
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
