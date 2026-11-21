import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/deeplink/deep_link_service.dart';
import 'core/di/injection.dart';
import 'core/push/push_service.dart';
import 'core/session/session_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/system_ui.dart';
import 'l10n/generated/app_localizations.dart';
import 'router/app_router.dart';

class LavenderApp extends StatefulWidget {
  const LavenderApp({super.key});

  @override
  State<LavenderApp> createState() => _LavenderAppState();
}

class _LavenderAppState extends State<LavenderApp> {
  late final GoRouter _router = createRouter();

  @override
  void initState() {
    super.initState();
    // Notification taps navigate through this router (T39).
    sl<PushService>().attachRouter(_router);
    // App Links for /doctor/<id> (T40).
    unawaited(sl<DeepLinkService>().init(_router));
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (a, b) => a.languageCode != b.languageCode,
      builder: (context, session) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Lavender',
        themeMode: ThemeMode.light,
        // Not AppLocalizations.localizationsDelegates: since Flutter 3.47 its
        // Global*Localizations come from the deprecated flutter_localizations.
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(session.languageCode),
        theme: AppTheme.light(),
        routerConfig: _router,
        // App-wide default bars; a screen overrides with its own SystemUi.
        builder: (context, child) => SystemUi(child: child!),
      ),
    );
  }
}
