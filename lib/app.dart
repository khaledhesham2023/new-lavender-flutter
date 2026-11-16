import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';

import 'core/config/env.dart';
import 'core/l10n/l10n_ext.dart';
import 'l10n/generated/app_localizations.dart';

class LavenderApp extends StatelessWidget {
  const LavenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // T10 replaces this with SessionCubit.languageCode (default "ar").
      locale: const Locale('ar'),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => Text(
              Env.isConfigured ? context.l10n.appName : 'Missing env: run with --dart-define-from-file=env/debug.json',
            ),
          ),
        ),
      ),
    );
  }
}
