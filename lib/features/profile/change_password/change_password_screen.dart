import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../shared/domain/repositories/auth_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../../../app/router/route_args.dart';
import '../../../app/router/routes.dart';
import '../../auth/widgets/password_field.dart';
import '../success_sheet.dart';
import 'change_password_cubit.dart';

/// Port of `EditProfileAddNewPasswordFragment` (`fragment_edit_profile_add_new_password.xml`).
class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordArgs args;
  const ChangePasswordScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(
        sl<ProfileRepository>(),
        sl<AuthRepository>(),
        args,
      ),
      child: _ChangePasswordView(args: args),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  final ChangePasswordArgs args;
  const _ChangePasswordView({required this.args});

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _currentKey = GlobalKey<PasswordFieldState>();
  final _newKey = GlobalKey<PasswordFieldState>();
  final _confirmKey = GlobalKey<PasswordFieldState>();
  bool _sheetOpen = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    // Android `isValid` order; only the first failing field shows its error.
    if (_currentKey.currentState!.validate() &&
        _newKey.currentState!.validate() &&
        _confirmKey.currentState!.validate()) {
      context.read<ChangePasswordCubit>().submit(
        _current.text,
        _new.text,
        _confirm.text,
      );
    }
  }

  Future<void> _onState(BuildContext context, ChangePasswordState state) async {
    final cubit = context.read<ChangePasswordCubit>();

    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }

    switch (state.event) {
      case ChangePasswordEvent.none:
        break;
      case ChangePasswordEvent.changed:
        final router = GoRouter.of(context);
        cubit.consumeEvent();
        setState(() => _sheetOpen = true);
        await showProfileSuccessSheet(
          context,
          ProfileSuccessType.changePassword,
        );
        if (router.canPop()) router.pop();
      case ChangePasswordEvent.codeSent:
        cubit.consumeEvent();
        context.push(
          Routes.otpChangePhone,
          extra: OtpArgs(
            phone: widget.args.phone,
            phoneCode: widget.args.code,
            fromDestination: OtpDestination.editProfileAddNewPassword,
          ),
        );
    }
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
        body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: _onState,
          builder: (context, state) {
            final busy = state.saving || state.sendingCode;
            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTopBar(title: l10n.password),
                        const VerticalSpacer(24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.changePasswordBody,
                            style: AppTextStyles.medium(14, AppColors.c60717F),
                          ),
                        ),
                        const VerticalSpacer(30),
                        PasswordField(
                          key: _currentKey,
                          controller: _current,
                          label: l10n.currentPassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const VerticalSpacer(10),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AppLink(
                              text: l10n.forgetPassword,
                              size: 12,
                              color: AppColors.c3D4C5E,
                              loading: state.sendingCode,
                              onTap: busy
                                  ? null
                                  : () => context
                                        .read<ChangePasswordCubit>()
                                        .forgotPassword(),
                            ),
                          ),
                        ),
                        const VerticalSpacer(34),
                        PasswordField(
                          key: _newKey,
                          controller: _new,
                          label: l10n.newPassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const VerticalSpacer(34),
                        PasswordField(
                          key: _confirmKey,
                          controller: _confirm,
                          label: l10n.confirmPassword,
                          confirmOf: _new,
                          onSubmitted: (_) => _submit(),
                        ),
                        const Spacer(),
                        const VerticalSpacer(8),
                        Container(height: 1, color: AppColors.cE6E6E6),
                        const VerticalSpacer(16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: ProgressButton(
                            text: l10n.saveChanges,
                            loading: state.saving,
                            enabled: !state.sendingCode,
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
