import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_view.dart';
import '../../../data/models/responses/doctor.dart';
import '../../../data/models/responses/search.dart';
import '../../../data/models/responses/speciality.dart';

/// `layout_search_result.xml`: "Specialities" / "Doctors" tabs (swipeable, like
/// the ViewPager2) with one result list each.
class SearchResultsView extends StatelessWidget {
  final SearchResultsData results;
  final ValueChanged<SpecialityModel> onSpeciality;
  final ValueChanged<DoctorModel> onDoctor;

  const SearchResultsView({
    super.key,
    required this.results,
    required this.onSpeciality,
    required this.onDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            dividerColor: AppColors.transparent,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.c99000000,
            labelStyle: AppTextStyles.medium(14),
            unselectedLabelStyle: AppTextStyles.medium(14),
            overlayColor: const WidgetStatePropertyAll(AppColors.transparent),
            splashFactory: NoSplash.splashFactory,
            tabs: [
              Tab(text: l10n.specialities),
              Tab(text: l10n.doctors),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ResultList(
                  isEmpty: results.specialties.isEmpty,
                  emptyBody: l10n.noSearchResultsSpecialtiesBody,
                  itemCount: results.specialties.length,
                  itemBuilder: (context, i) {
                    final s = results.specialties[i];
                    return _ResultItem(
                      type: l10n.specialty,
                      title: s.name ?? '',
                      subtitle: l10n.availableDoctorsWithNumber(
                        s.appointmentsCount.toString(),
                      ),
                      image: s.image,
                      onTap: () => onSpeciality(s),
                    );
                  },
                ),
                _ResultList(
                  isEmpty: results.doctors.isEmpty,
                  emptyBody: l10n.noSearchResultsDoctorsBody,
                  itemCount: results.doctors.length,
                  itemBuilder: (context, i) {
                    final d = results.doctors[i];
                    return _ResultItem(
                      type: l10n.doctor,
                      title: d.name ?? '',
                      subtitle: d.subSpecialty ?? d.specialty ?? '',
                      image: d.image,
                      onTap: () => onDoctor(d),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tab body (`fragment_search_result.xml`): the list, or the empty view.
class _ResultList extends StatelessWidget {
  final bool isEmpty;
  final String emptyBody;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const _ResultList({
    required this.isEmpty,
    required this.emptyBody,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: StateView.empty(
          icon: AppAssets.icNoDoctorsFound,
          title: context.l10n.noSearchResultsTitle,
          body: emptyBody,
        ),
      );
    }
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// `recycler_search_result_item.xml`: image, title, subtitle and the type label
/// ("Specialty" / "Doctor") at the end.
class _ResultItem extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String? image;
  final VoidCallback onTap;

  const _ResultItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 41,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cF8F6FA,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppNetworkImage(url: image, fit: BoxFit.fill),
                ),
                const HorizontalSpacer(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(14, AppColors.c090B0E),
                      ),
                      const VerticalSpacer(6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium(14, AppColors.c666666),
                      ),
                    ],
                  ),
                ),
                const HorizontalSpacer(10),
                Text(type, style: AppTextStyles.medium(13, AppColors.primary)),
              ],
            ),
            const VerticalSpacer(16),
            const SizedBox(
              height: 1,
              child: ColoredBox(color: AppColors.cE6E6E6),
            ),
          ],
        ),
      ),
    );
  }
}
