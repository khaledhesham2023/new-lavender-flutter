import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/session/session_cubit.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/system_ui.dart';
import '../../core/widgets/spacers.dart';
import '../../router/routes.dart';

/// Measured real duration of `loader.gif` (75 frames). Android plays it once.
const Duration _loaderGifDuration = Duration(milliseconds: 2510);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  Timer? _timer;
  Timer? _watchdog;
  bool _showLoader = false;
  bool _navigated = false;
  LottieComposition? _composition;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_showLoader) _onLogoDone();
    });
    // Never stay on the splash: if the animation or its timers stall (e.g. the
    // app was backgrounded and relaunched), navigate anyway.
    _watchdog = Timer(const Duration(seconds: 6), _navigate);
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    try {
      final composition = await AssetLottie(AppAssets.lavenderLogo).load();
      if (!mounted) return;
      setState(() => _composition = composition);
      // Android plays the logo once at 2x speed.
      _controller.duration = composition.duration ~/ 2;
      await _controller.forward(from: 0);
    } catch (_) {
      _navigate();
    }
  }

  void _onLogoDone() {
    setState(() => _showLoader = true);
    _timer = Timer(_loaderGifDuration, _navigate);
  }

  void _navigate() {
    if (!mounted || _navigated) return;
    _navigated = true;
    if (sl<AppPrefs>().isFirstTime) {
      context.go(Routes.onboarding);
    } else if (sl<SessionCubit>().state.isLoggedIn) {
      context.go(Routes.home);
    } else {
      context.go(Routes.authStart);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _watchdog?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      statusBarColor: AppColors.primary,
      statusBarIconsDark: false,
      navigationBarColor: AppColors.primary,
      navigationBarIconsDark: false,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.bgSplash),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 17,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Text(
                        l10n.mogamaaElkhazamyEltiby,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.messiriBold(16, AppColors.white),
                      ),
                      const VerticalSpacer(1),
                      Text(
                        l10n.elgbeelElsnaaya,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regular(14, AppColors.white),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: _composition == null
                        ? null
                        : Lottie(
                            composition: _composition,
                            controller: _controller,
                            frameRate: FrameRate.max,
                          ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.nowLoading,
                        style: AppTextStyles.semiBold(18, AppColors.white),
                      ),
                      const HorizontalSpacer(6),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: _showLoader
                            ? Image.asset(AppAssets.loader, fit: BoxFit.fill)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
