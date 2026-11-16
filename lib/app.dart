import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/env.dart';
import 'core/l10n/l10n_ext.dart';
import 'core/theme/app_assets.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
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
      theme: AppTheme.light(),
      // Temporary home (T10 replaces it): verifies assets, fonts and theme.
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppAssets.icGift),
                SizedBox(
                  height: 120,
                  child: Lottie.asset(AppAssets.lavenderLogo),
                ),
                Text(
                  Env.isConfigured ? context.l10n.appName : 'Missing env: run with --dart-define-from-file=env/debug.json',
                  style: AppTextStyles.bold(24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
