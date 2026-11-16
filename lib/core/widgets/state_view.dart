// ignore_for_file: prefer_initializing_formals
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_ext.dart';
import '../network/api_result.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_svg.dart';

enum _Kind { serverError, connectionLost, empty }

/// Port of `error_empty_layout.xml` + `EmptyErrorDelegateImp`: icon, title, body and
/// an optional primary button, centered in the available space.
class StateView extends StatelessWidget {
  final _Kind _kind;
  final String? _icon;
  final String? _title;
  final String? _body;
  final String? _buttonTitle;
  final VoidCallback? _onButton;

  const StateView._(
    this._kind, {
    super.key,
    String? icon,
    String? title,
    String? body,
    String? buttonTitle,
    VoidCallback? onButton,
  })  : _icon = icon,
        _title = title,
        _body = body,
        _buttonTitle = buttonTitle,
        _onButton = onButton;

  /// Server error (`ic_server_error_2`). The button shows only when [onRetry] is set.
  const StateView.serverError({Key? key, String? title, String? body, VoidCallback? onRetry})
      : this._(_Kind.serverError, key: key, title: title, body: body, onButton: onRetry);

  /// No connection (`ic_network_error_2`) with a Retry button.
  const StateView.connectionLost({Key? key, required VoidCallback onRetry})
      : this._(_Kind.connectionLost, key: key, onButton: onRetry);

  /// Empty list / custom message. [icon] is an `AppAssets` path (svg or png).
  const StateView.empty({
    Key? key,
    required String icon,
    required String title,
    String body = '',
    String? buttonTitle,
    VoidCallback? onButton,
  }) : this._(_Kind.empty,
            key: key, icon: icon, title: title, body: body, buttonTitle: buttonTitle, onButton: onButton);

  /// serverError for Server/Unknown failures, connectionLost for network failures.
  factory StateView.forFailure(ApiFailure<dynamic> failure, {Key? key, VoidCallback? onRetry}) {
    if (failure is NetworkFailure) {
      return StateView.connectionLost(key: key, onRetry: onRetry ?? () {});
    }
    return StateView.serverError(key: key, onRetry: onRetry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String icon;
    final String title;
    final String body;
    String? buttonTitle = _buttonTitle;
    switch (_kind) {
      case _Kind.serverError:
        icon = AppAssets.icServerError2;
        title = _title ?? l10n.serverError;
        body = _body ?? l10n.serverErrorBody2;
        if (_onButton != null) buttonTitle ??= l10n.retry;
      case _Kind.connectionLost:
        icon = AppAssets.icNetworkError2;
        title = l10n.noInternetConncetion;
        body = l10n.noInternetConncetionBody2;
        buttonTitle ??= l10n.retry;
      case _Kind.empty:
        icon = _icon!;
        title = _title ?? '';
        body = _body ?? '';
    }
    final showButton = _onButton != null && buttonTitle != null;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 150,
              child: icon.endsWith('.svg') ? AppSvg(icon) : Image.asset(icon, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.semiBold(20, AppColors.black),
              ),
            ),
            if (body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular(14, AppColors.c656B78).copyWith(height: 20 / 14),
                ),
              ),
            if (showButton)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: _onButton,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(buttonTitle, style: AppTextStyles.semiBold(14, AppColors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
