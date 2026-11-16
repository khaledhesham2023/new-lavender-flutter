import 'package:flutter/widgets.dart';

import '../l10n/l10n_ext.dart';
import '../network/api_result.dart';
import 'app_toast.dart';

/// Port of `CommonUtils.handleAllKindOfExceptions` (PLAN 4.4).
void showFailureToast(BuildContext context, ApiFailure<dynamic> failure) {
  final connectionError = context.l10n.connectionError;
  final message = switch (failure) {
    ServerFailure(:final message) => message,
    NetworkFailure() => connectionError,
    UnknownFailure(:final message) => message.isEmpty ? connectionError : message,
  };
  AppToast.show(context, message, ToastType.failed);
}
