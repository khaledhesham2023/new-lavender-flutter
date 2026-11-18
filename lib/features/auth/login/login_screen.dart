import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/spacers.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/push/device_token.dart';
import '../../../router/route_args.dart';
import '../../../router/routes.dart';
import '../widgets/auth_header.dart';
import '../widgets/password_field.dart';
import '../widgets/phone_field.dart';
import 'login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        sl<AuthRepository>(),
        sl<SessionCubit>(),
        sl<DeviceTokenProvider>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _phoneKey = GlobalKey<PhoneFieldState>();
  final _passwordKey = GlobalKey<PasswordFieldState>();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Android back goes to Start now; pop when we came from there.
  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.authStart);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    // Order: phone first, then password; only the first failing field shows its error.
    if (_phoneKey.currentState!.validate() &&
        _passwordKey.currentState!.validate()) {
      context.read<LoginCubit>().submit(_phone.text, _password.text);
    }
  }

  void _onState(BuildContext context, LoginState state) {
    final cubit = context.read<LoginCubit>();
    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    switch (state.event) {
      case LoginEvent.navigateHome:
        cubit.consumeEvent();
        context.go(Routes.home);
      case LoginEvent.navigateOtp:
        final phone = state.otpPhone ?? _phone.text;
        cubit.consumeEvent();
        context.push(
          Routes.authOtp,
          extra: OtpArgs(
            phone: phone,
            phoneCode: PhoneFieldState.phoneCode,
            fromDestination: OtpDestination.login,
          ),
        );
      case LoginEvent.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<LoginCubit, LoginState>(
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
                        title: l10n.loginScreenTitle,
                        body: l10n.loginScreenBody,
                        onBack: _back,
                      ),
                      PhoneField(key: _phoneKey, controller: _phone),
                      const VerticalSpacer(34),
                      PasswordField(
                        key: _passwordKey,
                        controller: _password,
                        onSubmitted: (_) => _submit(),
                      ),
                      const VerticalSpacer(16),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                context.push(Routes.authForgetPassword),
                            child: Text(
                              l10n.forgetPassword,
                              style: AppTextStyles.medium(
                                12,
                                AppColors.c3D4C5E,
                              ).copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProgressButton(
                          text: l10n.login,
                          loading: state.isLoading,
                          onPressed: _submit,
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
