import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/domain/validators.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/router/route_args.dart';
import '../../../app/router/routes.dart';
import '../widgets/auth_header.dart';
import '../widgets/labeled_field.dart';
import '../widgets/password_field.dart';
import '../widgets/phone_field.dart';
import '../widgets/terms_row.dart';
import 'register_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(sl<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _nameKey = GlobalKey<LabeledFieldState>();
  final _emailKey = GlobalKey<LabeledFieldState>();
  final _phoneKey = GlobalKey<PhoneFieldState>();
  final _passwordKey = GlobalKey<PasswordFieldState>();
  final _confirmKey = GlobalKey<PasswordFieldState>();

  bool _termsChecked = false;
  bool _termsError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _nameRule(BuildContext context, String text) {
    final l10n = context.l10n;
    return switch (validateName(text)) {
      NameError.ok => null,
      NameError.empty => l10n.pleaseEnterYourName,
      NameError.tooShort => l10n.nameMustBeAtLeast2Characters,
    };
  }

  /// Optional: only a non-empty value is checked.
  String? _emailRule(BuildContext context, String text) {
    if (text.isNotEmpty && !isValidEmail(text)) {
      return context.l10n.enterValidEmail;
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    // Android `isValid` order; only the first failing field shows its error.
    if (!(_nameKey.currentState!.validate() &&
        _emailKey.currentState!.validate() &&
        _phoneKey.currentState!.validate() &&
        _passwordKey.currentState!.validate() &&
        _confirmKey.currentState!.validate())) {
      return;
    }
    if (!_termsChecked) {
      setState(() => _termsError = true);
      return;
    }
    context.read<RegisterCubit>().submit(
      phone: _phone.text,
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
      passwordConfirmation: _confirm.text,
    );
  }

  void _onState(BuildContext context, RegisterState state) {
    final cubit = context.read<RegisterCubit>();
    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    if (state.event == RegisterEvent.navigateOtp) {
      final phone = state.otpPhone ?? '';
      cubit.consumeEvent();
      // Android uses Destination.LOGIN for register too.
      // Replace Register so back from OTP does not return to the filled form.
      context.pushReplacement(
        Routes.authOtp,
        extra: OtpArgs(
          phone: phone,
          phoneCode: PhoneFieldState.phoneCode,
          fromDestination: OtpDestination.login,
        ),
      );
    }
  }

  InlineSpan _emailLabel(BuildContext context) {
    final l10n = context.l10n;
    return TextSpan(
      children: [
        TextSpan(
          text: '${l10n.email}* ',
          style: AppTextStyles.regular(14, AppColors.primary),
        ),
        TextSpan(
          text: l10n.optional,
          style: AppTextStyles.regular(14, AppColors.c7E94B0),
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
        body: BlocConsumer<RegisterCubit, RegisterState>(
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
                        title: l10n.startYourHealthJourneyNowTitle,
                        body: l10n.startYourHealthJourneyNowBody,
                        onBack: () => context.pop(),
                      ),
                      LabeledField(
                        key: _nameKey,
                        controller: _name,
                        label: l10n.name,
                        iconAsset: AppAssets.icName,
                        iconAtEnd: true,
                        startRuleMessage: (c) => c.l10n.nameMustStartWithALetter,
                        rule: _nameRule,
                      ),
                      const VerticalSpacer(34),
                      PhoneField(key: _phoneKey, controller: _phone),
                      const VerticalSpacer(34),
                      LabeledField(
                        key: _emailKey,
                        controller: _email,
                        labelBuilder: () => _emailLabel(context),
                        iconAsset: AppAssets.icEmail,
                        iconAlwaysLeft: true,
                        keyboardType: TextInputType.emailAddress,
                        startRuleMessage: (c) => c.l10n.nameMustStartWithALetter,
                        rule: _emailRule,
                      ),
                      const VerticalSpacer(34),
                      PasswordField(
                        key: _passwordKey,
                        controller: _password,
                        label: l10n.passwordWithStar,
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
                      const VerticalSpacer(34),
                      TermsRow(
                        checked: _termsChecked,
                        showError: _termsError,
                        onChanged: (v) => setState(() {
                          _termsChecked = v;
                          if (v) _termsError = false;
                        }),
                        onOpenTerms: () => context.push(Routes.terms),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
                        child: ProgressButton(
                          text: l10n.createAccount,
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
