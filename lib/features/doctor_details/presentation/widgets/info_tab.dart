import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/capsule_transition.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../data/models/responses/doctor.dart';
import 'expandable_text.dart';

/// Port of `GeneralInfoFragment`: about (4 lines + show more), work days and the
/// certificates strip (hidden when empty).
class InfoTab extends StatelessWidget {
  final DoctorModel doctor;

  const InfoTab({super.key, required this.doctor});

  static const _divider = Divider(
    height: 1,
    thickness: 1,
    color: AppColors.cE6E6E6,
  );

  Widget _title(String text, double size) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(text, style: AppTextStyles.bold(size, AppColors.c3D4C5E)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final certificates = doctor.certificates;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const VerticalSpacer(24),
          _title(l10n.aboutDoctor, 13),
          const VerticalSpacer(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExpandableText(
              doctor.about ?? l10n.noInformationAvailable,
              maxLines: 4,
              style: AppTextStyles.medium(13, AppColors.c3D4C5E),
              linkColor: AppColors.primary,
            ),
          ),
          const VerticalSpacer(24),
          _divider,
          const VerticalSpacer(24),
          _title(l10n.workingTimes, 14),
          const VerticalSpacer(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              doctor.doctorWorkTimesDays.join('-'),
              style: AppTextStyles.medium(14, AppColors.c3D4C5E),
            ),
          ),
          const VerticalSpacer(24),
          _divider,
          if (certificates.isNotEmpty) ...[
            const VerticalSpacer(24),
            _title(l10n.certificates, 14),
            const VerticalSpacer(10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: certificates.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => showCertificateViewer(
                    context,
                    certificates,
                    startIndex: i,
                  ),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: AppNetworkImage(
                      url: certificates[i].media,
                      width: 130,
                      height: 80,
                      radius: 10,
                    ),
                  ),
                ),
              ),
            ),
            const VerticalSpacer(5),
          ],
        ],
      ),
    );
  }
}

/// Port of `openImagesViewer`: full-screen zoomable gallery starting at
/// [startIndex], black background, swipe between certificates.
Future<void> showCertificateViewer(
  BuildContext context,
  List<CertificateModel> certificates, {
  required int startIndex,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: AppColors.black,
      pageBuilder: (_, _, _) => _CertificateViewer(
        certificates: certificates,
        startIndex: startIndex,
      ),
      transitionDuration: CapsuleTransition.forwardDuration,
      reverseTransitionDuration: CapsuleTransition.reverseDuration,
      transitionsBuilder: (_, animation, _, child) =>
          CapsuleTransition(animation: animation, child: child),
    ),
  );
}

class _CertificateViewer extends StatefulWidget {
  final List<CertificateModel> certificates;
  final int startIndex;

  const _CertificateViewer({
    required this.certificates,
    required this.startIndex,
  });

  @override
  State<_CertificateViewer> createState() => _CertificateViewerState();
}

class _CertificateViewerState extends State<_CertificateViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.startIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _controller,
            itemCount: widget.certificates.length,
            backgroundDecoration: const BoxDecoration(color: AppColors.black),
            loadingBuilder: (_, _) => const LoadingView(),
            builder: (context, i) {
              final url = widget.certificates[i].media ?? '';
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(url),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              );
            },
          ),
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + 8,
            end: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: AppColors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
