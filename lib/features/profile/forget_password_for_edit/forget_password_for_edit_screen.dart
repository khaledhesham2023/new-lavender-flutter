import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/router/route_args.dart';
import '../../../app/router/routes.dart';
import '../../auth/widgets/auth_header.dart';
import '../../auth/widgets/password_field.dart';
import '../success_sheet.dart';
import 'forget_password_for_edit_cubit.dart';

/// Port of `ForgetPasswordForEditPasswordFragment` (`fragment_forget_for_edit_password.xml`):
/// new password after the code sent to the own phone; on success the user is logged out.
class ForgetPasswordForEditScreen extends StatelessWidget {
  final NewPasswordArgs args;
  const ForgetPasswordForEditScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordForEditCubit(
        sl<AuthRepository>(),
        sl<SessionCubit>(),
        sl<AppPrefs>(),
        args,
      ),
      child: const _ForgetPasswordForEditView(),
    );
  }
}

class _ForgetPasswordForEditView extends StatefulWidget {
  const _ForgetPasswordForEditView();

  @override
  State<_ForgetPasswordForEditView> createState() =>
      _ForgetPasswordForEditViewState();
}

class _ForgetPasswordForEditViewState
    extends State<_ForgetPasswordForEditView> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordKey = GlobalKey<PasswordFieldState>();
  final _confirmKey = GlobalKey<PasswordFieldState>();
  bool _sheetOpen = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Android `ForgetPasswordToProfile` (arrow and system back).
  void _backToProfile() => context.go(Routes.profile);

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_passwordKey.currentState!.validate() &&
        _confirmKey.currentState!.validate()) {
      context.read<ForgetPasswordForEditCubit>().submit(
        _password.text,
        _confirm.text,
      );
    }
  }

  Future<void> _onState(
    BuildContext context,
    ForgetPasswordForEditState state,
  ) async {
    final cubit = context.read<ForgetPasswordForEditCubit>();

    switch (state.event) {
      case ForgetPasswordForEditEvent.none:
        if (state.failure != null) {
          showFailureToast(context, state.failure!);
          cubit.consumeEvent();
        }
      case ForgetPasswordForEditEvent.changed:
        cubit.consumeEvent();
        setState(() => _sheetOpen = true);
        await showProfileSuccessSheet(
          context,
          ProfileSuccessType.forgetPasswordForEdit,
        );
        if (!mounted) return;
        setState(() => _sheetOpen = false);
        // The password is set; end the session (Android does it from Profile).
        cubit.logout();
      case ForgetPasswordForEditEvent.loggedOut:
        cubit.consumeEvent();
        context.go(Routes.authStart);
      case ForgetPasswordForEditEvent.logoutFailed:
        final failure = state.failure;
        cubit.consumeEvent();
        if (failure != null) showFailureToast(context, failure);
        context.go(Routes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToProfile();
      },
      child: SystemUi(
        statusBarColor: _sheetOpen
            ? dimmedWhiteStatusBar
            : AppColors.transparent,
        child: Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: true,
          body:
              BlocConsumer<
                ForgetPasswordForEditCubit,
                ForgetPasswordForEditState
              >(
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
                              onBack: _backToProfile,
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
                                loading: state.loading,
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
