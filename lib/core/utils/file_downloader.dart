import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/widgets.dart';

import '../l10n/l10n_ext.dart';
import '../widgets/app_toast.dart';

/// File name for a download: the last path segment of [url] when it has an
/// extension, otherwise `<title>.pdf`.
String downloadFileName(String url, String title) {
  final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
  final last = segments.isEmpty ? '' : segments.last;
  if (last.contains('.') && !last.endsWith('.')) return last;
  final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  return '${safeTitle.isEmpty ? 'file' : safeTitle}.pdf';
}

/// Port of Android's `DownloadManager` download: a system notification
/// "Downloading <title>" while running and a completed one, the file ends up
/// in the public Downloads folder. A failure shows the connection-error toast.
/// The download works without the notification permission (the notification
/// is simply not shown until T39 requests it).
Future<void> downloadFile(
  BuildContext context, {
  required String url,
  required String title,
}) async {
  final l10n = context.l10n;
  final failedMessage = l10n.connectionError;
  final downloader = FileDownloader();
  downloader.configureNotification(
    running: TaskNotification(title, l10n.downloadingWithValue(title)),
    complete: TaskNotification(title, '{filename}'),
    progressBar: true,
    tapOpensFile: true,
  );
  final task = DownloadTask(
    url: url,
    filename: downloadFileName(url, title),
    baseDirectory: BaseDirectory.applicationDocuments,
    updates: Updates.statusAndProgress,
    allowPause: false,
  );
  var ok = false;
  try {
    final result = await downloader.download(task);
    if (result.status == TaskStatus.complete) {
      final moved = await downloader.moveToSharedStorage(
        task,
        SharedStorage.downloads,
      );
      ok = moved != null;
    }
  } catch (e) {
    debugPrint('downloadFile failed: $e');
  }
  if (!ok && context.mounted) {
    AppToast.show(context, failedMessage, ToastType.failed);
  }
}
