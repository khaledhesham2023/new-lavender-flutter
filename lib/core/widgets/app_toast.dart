import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_svg.dart';

enum ToastType { success, warning, failed, normal, failedAttempts }

/// Port of `Toaster` + the `*_custome_toast.xml` layouts: a white card at the TOP of
/// the screen. One toast at a time; a new one replaces the old one.
abstract final class AppToast {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context,
    String message,
    ToastType type, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    dismiss();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        type: type,
        duration: duration,
        onDone: () {
          if (_entry == entry) _entry = null;
          entry.remove();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _Spec {
  final double margin;
  final double radius;
  final Color? border;
  final Color textColor;
  final double textSize;
  final int maxLines;
  final String? iconBg;
  final double iconSize;
  final double textVerticalMargin;
  final double textHorizontalMargin;

  const _Spec({
    required this.margin,
    required this.radius,
    this.border,
    required this.textColor,
    this.textSize = 14,
    this.maxLines = 2,
    this.iconBg,
    this.iconSize = 40,
    this.textVerticalMargin = 0,
    this.textHorizontalMargin = 11,
  });
}

_Spec _specOf(ToastType t) => switch (t) {
      ToastType.success => const _Spec(
          margin: 12,
          radius: 6,
          border: AppColors.c05C07B,
          textColor: AppColors.c05C07B,
          iconBg: AppAssets.bgRoundedGreen,
          iconSize: 37,
        ),
      ToastType.failed => const _Spec(
          margin: 14,
          radius: 6,
          border: AppColors.cE23535,
          textColor: AppColors.cE23535,
          iconBg: AppAssets.bgRoundedRed,
        ),
      ToastType.warning => const _Spec(
          margin: 14,
          radius: 10,
          textColor: Color(0xFFF4A100),
          iconBg: AppAssets.bgRoundedYellow,
        ),
      ToastType.normal => const _Spec(
          margin: 12,
          radius: 4,
          textColor: AppColors.black,
          maxLines: 4,
          textVerticalMargin: 20,
          textHorizontalMargin: 14,
        ),
      ToastType.failedAttempts => const _Spec(
          margin: 12,
          radius: 15,
          textColor: AppColors.black,
          textSize: 12,
          textVerticalMargin: 8,
          textHorizontalMargin: 14,
        ),
    };

class _ToastView extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDone;

  const _ToastView({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  static const _fade = Duration(milliseconds: 200);
  late final AnimationController _c = AnimationController(vsync: this, duration: _fade);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _c.reverse();
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _specOf(widget.type);
    final style = AppTextStyles.medium(s.textSize, s.textColor);
    return Positioned(
      top: MediaQuery.paddingOf(context).top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _c,
          child: Padding(
            padding: EdgeInsets.all(s.margin),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(s.radius),
                border: s.border == null ? null : Border.all(color: s.border!, width: 0.9),
                boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  if (s.iconBg != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(13, 10, 0, 10),
                      child: SizedBox(
                        width: s.iconSize,
                        height: s.iconSize,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppSvg(s.iconBg!),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: AppSvg(AppAssets.icSideMenuLogo),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: s.textHorizontalMargin,
                        vertical: s.textVerticalMargin,
                      ),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        maxLines: s.maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: style.copyWith(decoration: TextDecoration.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
