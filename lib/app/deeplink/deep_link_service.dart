import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../push/push_service.dart';
import '../../shared/session/session_cubit.dart';
import 'doctor_link.dart';

// App Links for doctor pages
class DeepLinkService {
  DeepLinkService(this._push, this._session, {AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final PushService _push;
  final SessionCubit _session;
  final AppLinks _appLinks;

  GoRouter? _router;
  String? _pendingTarget;
  StreamSubscription<Uri>? _sub;

  /// The route a link asked for before the app could open it (cold start).
  String? takePendingTarget() {
    final target = _pendingTarget;
    _pendingTarget = null;
    return target;
  }

  /// Call once after the router exists (app start).
  Future<void> init(GoRouter router) async {
    _router = router;
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _onLink(initial, cold: true);
    } catch (e) {
      debugPrint('Initial link failed: $e');
    }
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _onLink(uri, cold: false),
      onError: (Object e) => debugPrint('Link stream error: $e'),
    );
  }

  void _onLink(Uri uri, {required bool cold}) {
    final id = parseDoctorId(uri);
    if (id == null) return;
    final target = Routes.doctorDetailsOf(id);
    if (cold) {
      // Opened by the link: the splash consumes it (logged in users only).
      _pendingTarget = target;
      return;
    }
    // Android `delay(500)` before navigating.
    Timer(const Duration(milliseconds: 500), () {
      if (_router == null || !_session.state.isLoggedIn) return;
      _push.openTarget(target);
    });
  }

  Future<void> dispose() async => _sub?.cancel();
}
