import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/system_ui.dart';
import '../domain/repositories/profile_repository.dart';
import '../../../app/router/route_args.dart';
import '../../../app/router/routes.dart';
import 'general_sheet.dart';
import 'language_sheet.dart';
import 'profile_cubit.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';
import 'profile_state.dart';

/// Port of `ProfileFragment` (bottom-navigation "Account" tab). Logged-in users
/// get the profile header and the full menu; guests a login prompt and a short
/// menu.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The tab is rebuilt every time it is shown, which is Android's onResume.
      create: (_) =>
          ProfileCubit(sl<ProfileRepository>(), sl<SessionCubit>())..refresh(),
      child: const SystemUi(
        statusBarIconsDark: false,
        child: _ProfileBody(),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  /// Pushes [route] and refreshes the profile when it comes back.
  Future<void> _open(BuildContext context, String route, {Object? extra}) async {
    final cubit = context.read<ProfileCubit>();
    await context.push<Object?>(route, extra: extra);
    if (!cubit.isClosed) cubit.refresh();
  }

  void _onMenu(BuildContext context, ProfileMenu item) {
    final session = context.read<SessionCubit>().state;
    switch (item) {
      case ProfileMenu.password:
        final user = session.user;
        _open(
          context,
          Routes.changePassword,
          extra: ChangePasswordArgs(
            phone: user?.phone ?? '',
            code: '+${user?.phoneCode ?? ''}',
          ),
        );
      case ProfileMenu.myOffers:
        _open(context, Routes.myOffers);
      case ProfileMenu.reports:
        _open(context, Routes.myReports);
      case ProfileMenu.notifications:
        _open(context, Routes.notifications);
      case ProfileMenu.language:
        showLanguageSheet(context);
      case ProfileMenu.contactUs:
        _open(context, Routes.contactUs);
      case ProfileMenu.rateTheApp:
        openStore();
      case ProfileMenu.whoAreWe:
        _open(context, Routes.aboutUs);
      case ProfileMenu.aboutApp:
        _open(context, Routes.aboutApp);
      case ProfileMenu.logout:
        showGeneralSheet(context, GeneralType.logout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<SessionCubit, bool>(
      (c) => c.state.isLoggedIn,
    );
    final items = loggedIn ? ProfileMenu.loggedIn : ProfileMenu.guest;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (prev, curr) => curr.failure != null,
        listener: (context, state) {
          showFailureToast(context, state.failure!);
          context.read<ProfileCubit>().consumeFailure();
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loggedIn)
                ProfileHeader(
                  onEdit: () => _open(context, Routes.editProfile),
                )
              else ...[
                const ProfileGuestHeader(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProgressButton(
                    text: context.l10n.login,
                    onPressed: () => context.push(Routes.authStart),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  children: [
                    for (final item in items)
                      ProfileMenuItem(
                        item: item,
                        onTap: () => _onMenu(context, item),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
