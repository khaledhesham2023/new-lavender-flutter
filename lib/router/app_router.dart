import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/models/requests/booking_draft.dart';
import '../data/models/responses/offer.dart';
import '../data/models/responses/speciality.dart';
import '../features/auth/forget_password/forget_password_screen.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/new_password/new_password_screen.dart';
import '../features/auth/otp/otp_screen.dart';
import '../features/auth/register/register_screen.dart';
import '../features/auth/start_now_screen.dart';
import '../features/auth/success/auth_success_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/specialities/all_specialities_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/shell/placeholder_screen.dart';
import 'route_args.dart';
import 'routes.dart';

/// Registers every route of the app. Screen tasks (T11+) replace the
/// [PlaceholderScreen] builders; never add a route outside this file.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth flow: slide in from the end (Android enter_from_right).
      GoRoute(
        path: Routes.authStart,
        pageBuilder: (context, state) => _slide(state, const StartNowScreen()),
      ),
      GoRoute(
        path: Routes.authLogin,
        pageBuilder: (context, state) => _slide(state, const LoginScreen()),
      ),
      GoRoute(
        path: Routes.authRegister,
        pageBuilder: (context, state) => _slide(state, const RegisterScreen()),
      ),
      GoRoute(
        path: Routes.authForgetPassword,
        pageBuilder: (context, state) =>
            _slide(state, const ForgetPasswordScreen()),
      ),
      GoRoute(
        path: Routes.authOtp,
        pageBuilder: (context, state) {
          final args = state.extra! as OtpArgs;
          return _slide(state, OtpScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.authNewPassword,
        pageBuilder: (context, state) {
          final args = state.extra! as NewPasswordArgs;
          return _slide(state, NewPasswordScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.authSuccess,
        pageBuilder: (context, state) =>
            _slide(state, const AuthSuccessScreen()),
      ),

      // The five tabs share the bottom-navigation shell.
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          _tab(Routes.search, 'Search'),
          _tab(Routes.bookings, 'Bookings'),
          _tab(Routes.favorites, 'Favorites'),
          _tab(Routes.profile, 'Profile'),
        ],
      ),

      _page(Routes.notifications, 'Notifications'),
      GoRoute(
        path: Routes.allSpecialities,
        builder: (context, state) => const AllSpecialitiesScreen(),
      ),
      _page(Routes.offers, 'Offers'),
      GoRoute(
        path: Routes.offerDetails,
        builder: (context, state) =>
            PlaceholderScreen(name: 'OfferDetails #${_id(state)}'),
      ),
      GoRoute(
        path: Routes.purchaseOffer,
        builder: (context, state) {
          final offer = state.extra! as OfferModel;
          return PlaceholderScreen(name: 'PurchaseOffer #${offer.id}');
        },
      ),
      GoRoute(
        path: Routes.offerPurchased,
        builder: (context, state) =>
            PlaceholderScreen(name: 'OfferPurchased #${_id(state)}'),
      ),
      GoRoute(
        path: Routes.searchDetails,
        builder: (context, state) {
          final speciality = state.extra! as SpecialityModel;
          return PlaceholderScreen(name: 'SearchDetails #${speciality.id}');
        },
      ),
      GoRoute(
        path: Routes.filter,
        builder: (context, state) {
          // FilterArgs is defined in T21.
          final Object? args = state.extra;
          return PlaceholderScreen(name: 'Filter (${args.runtimeType})');
        },
      ),
      GoRoute(
        path: Routes.doctorDetails,
        builder: (context, state) =>
            PlaceholderScreen(name: 'DoctorDetails #${_id(state)}'),
      ),
      GoRoute(
        path: Routes.bookAppointment,
        builder: (context, state) {
          final draft = state.extra! as BookingDraft;
          return PlaceholderScreen(name: 'BookAppointment #${draft.doctorId}');
        },
      ),
      GoRoute(
        path: Routes.bookAppointmentWithOffer,
        builder: (context, state) {
          final args = state.extra! as BookWithOfferArgs;
          return PlaceholderScreen(
            name: 'BookAppointmentWithOffer #${args.offer.id}',
          );
        },
      ),
      GoRoute(
        path: Routes.appointmentRequested,
        builder: (context, state) =>
            PlaceholderScreen(name: 'AppointmentRequested #${_id(state)}'),
      ),
      GoRoute(
        path: Routes.sessionRequested,
        builder: (context, state) =>
            PlaceholderScreen(name: 'SessionRequested #${_id(state)}'),
      ),
      GoRoute(
        path: Routes.appointmentDetails,
        builder: (context, state) =>
            PlaceholderScreen(name: 'AppointmentDetails #${_id(state)}'),
      ),
      GoRoute(
        path: Routes.sessionDetails,
        builder: (context, state) =>
            PlaceholderScreen(name: 'SessionDetails #${_id(state)}'),
      ),
      _page(Routes.editProfile, 'EditProfile'),
      GoRoute(
        path: Routes.otpChangePhone,
        builder: (context, state) {
          final args = state.extra! as OtpArgs;
          return PlaceholderScreen(
            name: 'OtpChangePhone (${args.fromDestination.name})',
          );
        },
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (context, state) {
          final args = state.extra! as ChangePasswordArgs;
          return PlaceholderScreen(name: 'ChangePassword (${args.phone})');
        },
      ),
      GoRoute(
        path: Routes.forgetPasswordForEdit,
        builder: (context, state) {
          final args = state.extra! as NewPasswordArgs;
          return PlaceholderScreen(name: 'ForgetPasswordForEdit (${args.phone})');
        },
      ),
      _page(Routes.contactUs, 'ContactUs'),
      _page(Routes.aboutApp, 'AboutApp'),
      _page(Routes.aboutUs, 'AboutUs'),
      _page(Routes.terms, 'Terms'),
      _page(Routes.privacy, 'Privacy'),
      _page(Routes.myOffers, 'MyOffers'),
      GoRoute(
        path: Routes.myOfferDetails,
        builder: (context, state) =>
            PlaceholderScreen(name: 'MyOfferDetails #${_id(state)}'),
      ),
      _page(Routes.myReports, 'MyReports'),
    ],
  );
}

int _id(GoRouterState state) => int.parse(state.pathParameters['id']!);

GoRoute _page(String path, String name) => GoRoute(
      path: path,
      builder: (context, state) => PlaceholderScreen(name: name),
    );

GoRoute _tab(String path, String name, {List<Widget> actions = const []}) =>
    GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: PlaceholderScreen(name: name, showBack: false, actions: actions),
      ),
    );

/// Android `enter_from_right` / `exit_to_left`.
CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: SlideTransition(
          position: Tween(begin: Offset.zero, end: const Offset(-1, 0)).animate(
            CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}
