import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/session/session_cubit.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/progress_button.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/success_dialog.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/repositories/profile_repository.dart';
import '../auth/widgets/field_error.dart';
import 'contact_us_cubit.dart';
import '../../core/widgets/app_top_bar.dart';

/// Port of `ContactUsFragment` (`fragment_contact_us.xml`).
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactUsCubit(sl<ProfileRepository>()),
      child: const _ContactUsView(),
    );
  }
}

class _ContactUsView extends StatefulWidget {
  const _ContactUsView();

  @override
  State<_ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<_ContactUsView> {
  // The name starts as the stored user's name.
  late final _name = TextEditingController(
    text: sl<SessionCubit>().state.user?.name ?? '',
  );
  final _title = TextEditingController();
  final _message = TextEditingController();
  String? _nameError;
  String? _titleError;
  String? _messageError;

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  /// Android `isValid`: the first failing field shows its error (trimmed text, >= 2).
  bool _validate() {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final title = _title.text.trim();
    final message = _message.text.trim();
    String? nameError;
    String? titleError;
    String? messageError;
    if (name.isEmpty) {
      nameError = l10n.pleaseEnterYourName;
    } else if (name.length < 2) {
      nameError = l10n.fullNameMustBeAtLeast2Letters;
    } else if (title.isEmpty) {
      titleError = l10n.pleaseEnterTheMessageHeadline;
    } else if (title.length < 2) {
      titleError = l10n.messageHeadlineMustBeAtLeast2Letters;
    } else if (message.isEmpty) {
      messageError = l10n.pleaseEnterHowWeCanHelpYou;
    } else if (message.length < 2) {
      messageError = l10n.messageMustBeAtLeast2Letters;
    }
    setState(() {
      _nameError = nameError;
      _titleError = titleError;
      _messageError = messageError;
    });
    return nameError == null && titleError == null && messageError == null;
  }

  void _send() {
    FocusScope.of(context).unfocus();
    if (_validate()) {
      context.read<ContactUsCubit>().send(
        _name.text,
        _title.text,
        _message.text,
      );
    }
  }

  Future<void> _onState(BuildContext context, ContactUsState state) async {
    final cubit = context.read<ContactUsCubit>();
    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }
    if (state.sent) {
      final text = context.l10n.yourComplainSentSuccessfully;
      cubit.consumeEvent();
      // Android shows the dialog and stays on this screen.
      await showSuccessDialog(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      statusBarColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocConsumer<ContactUsCubit, ContactUsState>(
            listener: _onState,
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTopBar(
                      title: l10n.contactUs,
                      trailing: GestureDetector(
                        onTap: () =>
                            openWhatsApp(sl<AppPrefs>().whatsAppNumber),
                        behavior: HitTestBehavior.opaque,
                        child: const AppSvg(AppAssets.icWhatsapp),
                      ),
                    ),
                    const VerticalSpacer(10),
                    _Label(l10n.fullName),
                    const VerticalSpacer(8),
                    _BorderedField(
                      controller: _name,
                      hint: l10n.enterFullName,
                      height: 56,
                      textStyle: AppTextStyles.semiBold(14, AppColors.black),
                      hintColor: AppColors.c7E94B0,
                      onChanged: () => setState(() => _nameError = null),
                    ),
                    if (_nameError != null) _Error(_nameError!),
                    const VerticalSpacer(15),
                    _Label(l10n.messageHeadline),
                    const VerticalSpacer(8),
                    _BorderedField(
                      controller: _title,
                      hint: l10n.enterMessageHeadline,
                      height: 56,
                      textStyle: AppTextStyles.regular(14, AppColors.black),
                      hintColor: AppColors.c60717F,
                      onChanged: () => setState(() => _titleError = null),
                    ),
                    if (_titleError != null) _Error(_titleError!),
                    const VerticalSpacer(15),
                    _Label(l10n.howCanWeHelp),
                    const VerticalSpacer(8),
                    _BorderedField(
                      controller: _message,
                      hint: l10n.enterMessageHeadline,
                      height: 198,
                      multiline: true,
                      textStyle: AppTextStyles.regular(14, AppColors.black),
                      hintColor: AppColors.c60717F,
                      onChanged: () => setState(() => _messageError = null),
                    ),
                    if (_messageError != null) _Error(_messageError!),
                    const VerticalSpacer(154),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ProgressButton(
                        text: l10n.send,
                        loading: state.sending,
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, style: AppTextStyles.semiBold(14, AppColors.black)),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String text;
  const _Error(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: FieldErrorText(text),
  );
}

/// `bg_edit_border_gray`: white box, 1dp D9DBE9 border, 10dp corners, 16dp side padding.
class _BorderedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double height;
  final bool multiline;
  final TextStyle textStyle;
  final Color hintColor;
  final VoidCallback onChanged;

  const _BorderedField({
    required this.controller,
    required this.hint,
    required this.height,
    required this.textStyle,
    required this.hintColor,
    required this.onChanged,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(16, multiline ? 16 : 0, 16, 0),
        alignment: multiline
            ? AlignmentDirectional.topStart
            : AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cD9DBE9),
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          keyboardType: multiline
              ? TextInputType.multiline
              : TextInputType.text,
          textInputAction: multiline
              ? TextInputAction.newline
              : TextInputAction.next,
          maxLines: multiline ? null : 1,
          cursorColor: AppColors.c251836,
          cursorWidth: 2,
          style: textStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textStyle.copyWith(color: hintColor),
            isCollapsed: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }
}
