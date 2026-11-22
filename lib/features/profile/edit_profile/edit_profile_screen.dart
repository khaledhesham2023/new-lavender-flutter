import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/domain/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/repositories/general_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../app/router/route_args.dart';
import '../../../app/router/routes.dart';
import '../../auth/widgets/field_error.dart';
import '../../auth/widgets/labeled_field.dart';
import '../general_sheet.dart';
import 'edit_profile_cubit.dart';

/// Port of `EditProfile` (`fragment_edit_profile.xml`).
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileCubit(
        sl<ProfileRepository>(),
        sl<GeneralRepository>(),
        sl<SessionCubit>(),
      )..load(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _nameKey = GlobalKey<LabeledFieldState>();
  final _emailKey = GlobalKey<LabeledFieldState>();
  final _phoneKey = GlobalKey<_EditPhoneFieldState>();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final s = context.read<EditProfileCubit>().state;
    _name = TextEditingController(text: s.name);
    _email = TextEditingController(text: s.email);
    _phone = TextEditingController(text: s.phone);
    // Save depends on the typed name / email.
    _name.addListener(_refresh);
    _email.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  bool _sheetOpen = false;

  Future<void> _openDeleteSheet() async {
    setState(() => _sheetOpen = true);
    await showGeneralSheet(context, GeneralType.deleteAccount);
    if (mounted) setState(() => _sheetOpen = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
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

  Future<void> _pickImage() async {
    final cubit = context.read<EditProfileCubit>();
    try {
      // Resizes to 1024 and fixes the EXIF rotation (Android `UploadImages`).
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (file == null) return;
      final isGif =
          file.name.toLowerCase().endsWith('.gif') ||
          file.path.toLowerCase().endsWith('.gif') ||
          file.mimeType == 'image/gif';
      if (isGif) {
        cubit.rejectImage();
        return;
      }
      cubit.pickedImage(file.path);
    } on PlatformException catch (e) {
      debugPrint('image_picker failed: ${e.code} ${e.message}');
      cubit.rejectImage();
    }
  }

  void _save() {
    FocusScope.of(context).unfocus();
    // Android `isValid` order; only the first failing field shows its error.
    if (!(_nameKey.currentState!.validate() &&
        _emailKey.currentState!.validate() &&
        _phoneKey.currentState!.validate())) {
      return;
    }
    context.read<EditProfileCubit>().save(_name.text, _email.text);
  }

  Future<void> _onState(BuildContext context, EditProfileState state) async {
    final cubit = context.read<EditProfileCubit>();
    final l10n = context.l10n;

    if (state.failure != null) {
      showFailureToast(context, state.failure!);
      cubit.consumeEvent();
      return;
    }

    switch (state.event) {
      case EditProfileEvent.none:
        break;
      case EditProfileEvent.loaded:
        cubit.consumeEvent();
        _name.text = state.name;
        _email.text = state.email;
        _phoneKey.currentState?.setCurrent(state.phone);
      case EditProfileEvent.saved:
        final message = state.message;
        cubit.consumeEvent();
        if (message.isNotEmpty) {
          AppToast.show(context, message, ToastType.success);
        }
        context.pop();
      case EditProfileEvent.invalidImage:
        cubit.consumeEvent();
        AppToast.show(context, l10n.invalidImage, ToastType.failed);
      case EditProfileEvent.phoneCodeSent:
        final phone = state.newPhone;
        final code = '+${state.apiPhoneCode}';
        cubit.consumeEvent();
        await context.push(
          Routes.otpChangePhone,
          extra: OtpArgs(
            phone: phone,
            phoneCode: code,
            fromDestination: OtpDestination.editProfile,
          ),
        );
        // Android recreates the view on return, which reloads the profile.
        if (!context.mounted) return;
        _phone.text = sl<SessionCubit>().state.user?.phone ?? '';
        cubit.load();
    }
  }

  Widget _avatar(EditProfileState state) {
    const size = 99.0;
    final local = state.localImage;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: local != null
                ? Image.file(
                    File(local),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : AppNetworkImage(
                    url: state.image,
                    width: size,
                    height: size,
                    circle: true,
                  ),
          ),
          if (state.uploadingImage)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  InlineSpan _emailLabel(BuildContext context) {
    final l10n = context.l10n;
    return TextSpan(
      children: [
        TextSpan(
          text: '${l10n.email} ',
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
      // The system paints the status bar, so the sheet's barrier cannot dim it.
      statusBarColor: _sheetOpen ? dimmedWhiteStatusBar : AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: _onState,
          builder: (context, state) {
            final cubit = context.read<EditProfileCubit>();
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTopBar(title: l10n.modifyPersonalInformation),
                    const VerticalSpacer(24),
                    Center(child: _avatar(state)),
                    const VerticalSpacer(8),
                    Center(
                      child: AppLink(
                        text: l10n.changeImage,
                        weight: FontWeight.w600,
                        onTap: state.uploadingImage ? null : _pickImage,
                      ),
                    ),
                    const VerticalSpacer(50),
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
                    _EditPhoneField(
                      key: _phoneKey,
                      controller: _phone,
                      initialPhone: state.phone,
                      phoneCode: '+${state.apiPhoneCode}',
                      updating: state.changingPhone,
                      onUpdate: cubit.changePhone,
                    ),
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
                    const VerticalSpacer(92),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ProgressButton(
                        text: l10n.saveChanges,
                        loading: state.saving,
                        enabled: state.canSave(_name.text, _email.text),
                        onPressed: _save,
                      ),
                    ),
                    const VerticalSpacer(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _DeleteAccountButton(
                        text: l10n.deleteAccount,
                        onTap: _openDeleteSheet,
                      ),
                    ),
                    const VerticalSpacer(16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _DeleteAccountButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cED1C24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 56,
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.semiBold(14, AppColors.cED1C24),
            ),
          ),
        ),
      ),
    );
  }
}

/// Phone row of Edit profile: shows the account's own `+code`, and an "Update" button
/// that appears only when the typed number differs from the current one and is valid.
class _EditPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String initialPhone;
  final String phoneCode;
  final bool updating;
  final ValueChanged<String> onUpdate;

  const _EditPhoneField({
    super.key,
    required this.controller,
    required this.initialPhone,
    required this.phoneCode,
    required this.updating,
    required this.onUpdate,
  });

  @override
  State<_EditPhoneField> createState() => _EditPhoneFieldState();
}

class _EditPhoneFieldState extends State<_EditPhoneField> {
  final FocusNode _focus = FocusNode();
  late String _current = widget.initialPhone;
  PhoneError _error = PhoneError.ok;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// The profile was (re)loaded: [phone] is the stored number.
  void setCurrent(String phone) {
    setState(() => _current = phone);
    if (widget.controller.text.isEmpty) widget.controller.text = phone;
  }

  void _onFocusChange() {
    setState(() {
      if (!_focus.hasFocus) {
        final e = validatePhone(widget.controller.text);
        _error = e == PhoneError.mustStartWith5 ? PhoneError.ok : e;
      }
    });
  }

  void _onChanged(String text) {
    if (text.isNotEmpty && !text.startsWith('5')) {
      widget.controller.clear();
      setState(() => _error = PhoneError.mustStartWith5);
    } else {
      setState(() => _error = PhoneError.ok);
    }
  }

  /// Submit validation (empty, < 9, not starting with 5). Shows the error.
  bool validate() {
    final e = validatePhone(widget.controller.text);
    setState(() => _error = e);
    return e == PhoneError.ok;
  }

  bool get _showUpdate {
    final text = widget.controller.text;
    return text != _current && isValidKsaNumber(text);
  }

  String? _message(BuildContext context) {
    final l10n = context.l10n;
    return switch (_error) {
      PhoneError.ok => null,
      PhoneError.empty => l10n.pleaseEnterThePhoneNumber,
      PhoneError.tooShort => l10n.thePhoneNumberMustBeAtLeast9CharactersLong,
      PhoneError.mustStartWith5 => l10n.thePhoneNumberIsInvalidPleaseStartWith5,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = _message(context);
    final hasError = message != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.phone,
            style: AppTextStyles.regular(
              14,
              _focus.hasFocus ? AppColors.primary : AppColors.c7E94B0,
            ),
          ),
        ),
        const VerticalSpacer(7),
        // The prefix + number row is always left-to-right (layoutDirection="ltr").
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    AppAssets.icArabicLanguage,
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                ),
                const HorizontalSpacer(4),
                Text(
                  widget.phoneCode,
                  style: AppTextStyles.medium(14, AppColors.c251836),
                ),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.only(left: 6),
                  color: AppColors.c7E94B0,
                ),
                Expanded(
                  // Center loosens the height so the collapsed field sits on the
                  // same line as the flag and the +code.
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onChanged: _onChanged,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: AppColors.c251836,
                        cursorWidth: 2,
                        style: AppTextStyles.medium(14, AppColors.c251836),
                        decoration: InputDecoration(
                          hintText: l10n.phoneExample,
                          hintStyle: AppTextStyles.medium(
                            14,
                            AppColors.c7E94B0,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showUpdate)
                  _UpdatePhoneButton(
                    text: l10n.update,
                    loading: widget.updating,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      widget.onUpdate(widget.controller.text);
                    },
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: FieldUnderline(error: hasError),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FieldErrorText(message),
          ),
      ],
    );
  }
}

/// `btnUpdatePhone`: 65x31 primary pill next to the phone number.
class _UpdatePhoneButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onTap;
  const _UpdatePhoneButton({
    required this.text,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 31,
      child: Material(
        color: loading ? AppColors.cBEBEBE : AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    text,
                    maxLines: 1,
                    style: AppTextStyles.bold(14, AppColors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
