import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/models/requests/booking_draft.dart';
import '../data/models/responses/offer.dart';
import '../data/models/responses/speciality.dart';
import '../features/appointment_details/appointment_details_screen.dart';
import '../features/auth/forget_password/forget_password_screen.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/new_password/new_password_screen.dart';
import '../features/auth/otp/otp_screen.dart';
import '../features/auth/register/register_screen.dart';
import '../features/auth/start_now_screen.dart';
import '../features/auth/success/auth_success_screen.dart';
import '../features/booking/appointment_requested_screen.dart';
import '../features/booking/book_appointment_screen.dart';
import '../features/booking/book_with_offer_screen.dart';
import '../features/booking/session_requested_screen.dart';
import '../features/bookings/bookings_screen.dart';
import '../features/content/about_app_screen.dart';
import '../features/content/about_us_screen.dart';
import '../features/content/contact_us_screen.dart';
import '../features/content/content_cubit.dart';
import '../features/content/html_page_screen.dart';
import '../features/doctor_details/doctor_details_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/filter/filter_screen.dart';
import '../features/home/home_screen.dart';
import '../features/my_offers/my_offer_details_screen.dart';
import '../features/my_offers/my_offers_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/offers/offer_details_screen.dart';
import '../features/offers/offers_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/change_password/change_password_screen.dart';
import '../features/profile/edit_profile/edit_profile_screen.dart';
import '../features/profile/forget_password_for_edit/forget_password_for_edit_screen.dart';
import '../features/profile/otp_change_phone/otp_change_phone_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/search_details/search_details_screen.dart';
import '../features/session_details/session_details_screen.dart';
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
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: Routes.search,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: Routes.bookings,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const BookingsScreen(),
            ),
          ),
          GoRoute(
            path: Routes.favorites,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.allSpecialities,
        builder: (context, state) => const AllSpecialitiesScreen(),
      ),
      GoRoute(
        path: Routes.offers,
        builder: (context, state) => const OffersScreen(),
      ),
      GoRoute(
        path: Routes.offerDetails,
        builder: (context, state) => OfferDetailsScreen(offerId: _id(state)),
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
          return SearchDetailsScreen(speciality: speciality);
        },
      ),
      GoRoute(
        path: Routes.filter,
        builder: (context, state) =>
            FilterScreen(args: state.extra! as FilterArgs),
      ),
      GoRoute(
        path: Routes.doctorDetails,
        builder: (context, state) => DoctorDetailsScreen(doctorId: _id(state)),
      ),
      GoRoute(
        path: Routes.bookAppointment,
        builder: (context, state) {
          final draft = state.extra! as BookingDraft;
          return BookAppointmentScreen(draft: draft);
        },
      ),
      GoRoute(
        path: Routes.bookAppointmentWithOffer,
        builder: (context, state) {
          final args = state.extra! as BookWithOfferArgs;
          return BookWithOfferScreen(draft: args.draft, offer: args.offer);
        },
      ),
      GoRoute(
        path: Routes.appointmentRequested,
        builder: (context, state) =>
            AppointmentRequestedScreen(appointmentId: _id(state)),
      ),
      GoRoute(
        path: Routes.sessionRequested,
        builder: (context, state) =>
            SessionRequestedScreen(sessionId: _id(state)),
      ),
      GoRoute(
        path: Routes.appointmentDetails,
        builder: (context, state) =>
            AppointmentDetailsScreen(appointmentId: _id(state)),
      ),
      GoRoute(
        path: Routes.sessionDetails,
        builder: (context, state) =>
            SessionDetailsScreen(sessionId: _id(state)),
      ),
      GoRoute(
        path: Routes.editProfile,
        pageBuilder: (context, state) =>
            _slide(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: Routes.otpChangePhone,
        pageBuilder: (context, state) {
          final args = state.extra! as OtpArgs;
          return _slide(state, OtpChangePhoneScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.changePassword,
        pageBuilder: (context, state) {
          final args = state.extra! as ChangePasswordArgs;
          return _slide(state, ChangePasswordScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.forgetPasswordForEdit,
        pageBuilder: (context, state) {
          final args = state.extra! as NewPasswordArgs;
          return _slide(state, ForgetPasswordForEditScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: Routes.aboutApp,
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: Routes.aboutUs,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: Routes.terms,
        builder: (context, state) =>
            const HtmlPageScreen(kind: ContentKind.terms),
      ),
      GoRoute(
        path: Routes.privacy,
        builder: (context, state) =>
            const HtmlPageScreen(kind: ContentKind.privacy),
      ),
      GoRoute(
        path: Routes.myOffers,
        builder: (context, state) => const MyOffersScreen(),
      ),
      GoRoute(
        path: Routes.myOfferDetails,
        builder: (context, state) => MyOfferDetailsScreen(offerId: _id(state)),
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

/// Android `enter_from_right` / `exit_to_left`.
CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
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
