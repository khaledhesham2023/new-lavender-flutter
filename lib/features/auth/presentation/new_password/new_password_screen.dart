import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/failure_toast.dart';
import '../../../../core/widgets/progress_button.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../core/widgets/system_ui.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import '../../../../app/router/route_args.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/password_field.dart';
import 'new_password_cubit.dart';
import 'new_password_event.dart';
import 'new_password_state.dart';

class NewPasswordScreen extends StatelessWidget {
  final NewPasswordArgs args;

  const NewPasswordScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewPasswordCubit(sl<AuthRepository>(), args),
      child: const _NewPasswordView(),
    );
  }
}

class _NewPasswordView extends StatefulWidget {
  const _NewPasswordView();

  @override
  State<_NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<_NewPasswordView> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordKey = GlobalKey<PasswordFieldState>();
  final _confirmKey = GlobalKey<PasswordFieldState>();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Android backToLogin (arrow and system back): Login, dropping OTP etc.
  void _backToLogin() => context.go(Routes.authLogin);

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_passwordKey.currentState!.validate() &&
        _confirmKey.currentState!.validate()) {
      context.read<NewPasswordCubit>().submit(_password.text, _confirm.text);
    }
  }

  void _onState(BuildContext context, NewPasswordState state) {
    final cubit = context.read<NewPasswordCubit>();
    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    if (state.event == NewPasswordEvent.navigateSuccess) {
      cubit.consumeEvent();
      context.go(Routes.authSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLogin();
      },
      child: SystemUi(
        child: Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: true,
          body: BlocConsumer<NewPasswordCubit, NewPasswordState>(
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
                          title: l10n.enterNewPasswordTitle,
                          body: l10n.enterNewPasswordBody,
                          onBack: _backToLogin,
                          gapBelowImage: 21,
                        ),
                        PasswordField(
                          key: _passwordKey,
                          controller: _password,
                          label: l10n.newPassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const VerticalSpacer(34),
                        PasswordField(
                          key: _confirmKey,
                          controller: _confirm,
                          label: l10n.confirmPassword,
                          confirmOf: _password,
                          onSubmitted: (_) => _submit(),
                        ),
                        const VerticalSpacer(56),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ProgressButton(
                            text: l10n.saveChanges,
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
      ),
    );
  }
}
