import '../../core/network/api_result.dart';
import 'rebook_outcome.dart';

/// Result of [RebookCubit.confirm].
sealed class RebookConfirm {
  const RebookConfirm();
}

class RebookNeedsDay extends RebookConfirm {
  const RebookNeedsDay();
}

class RebookNeedsTime extends RebookConfirm {
  const RebookNeedsTime();
}

class RebookDone extends RebookConfirm {
  final RebookOutcome outcome;
  const RebookDone(this.outcome);
}

class RebookFailed extends RebookConfirm {
  final ApiFailure<dynamic> failure;
  const RebookFailed(this.failure);
}
