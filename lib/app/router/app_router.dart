import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/capsule_transition.dart';
import '../../data/models/requests/booking_draft.dart';
import '../../data/models/responses/offer.dart';
import '../../data/models/responses/speciality.dart';
import '../../features/appointment_details/presentation/appointment_details_screen.dart';
import '../../features/auth/presentation/forget_password/forget_password_screen.dart';
import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/new_password/new_password_screen.dart';
import '../../features/auth/presentation/otp/otp_screen.dart';
import '../../features/auth/presentation/register/register_screen.dart';
import '../../features/auth/presentation/start_now_screen.dart';
import '../../features/auth/presentation/success/auth_success_screen.dart';
import '../../features/booking/presentation/appointment_requested_screen.dart';
import '../../features/booking/presentation/book_appointment_screen.dart';
import '../../features/booking/presentation/book_with_offer_screen.dart';
import '../../features/booking/presentation/session_requested_screen.dart';
import '../../features/bookings/presentation/bookings_screen.dart';
import '../../features/content/presentation/about_app_screen.dart';
import '../../features/content/presentation/about_us_screen.dart';
import '../../features/content/presentation/contact_us_screen.dart';
import '../../features/content/presentation/html_page_screen.dart';
import '../../features/doctor_details/presentation/screens/doctor_details_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/filter/presentation/filter_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/my_offers/presentation/my_offer_details_screen.dart';
import '../../features/my_offers/presentation/my_offers_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/offers/presentation/offer_details_screen.dart';
import '../../features/offers/presentation/offers_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/change_password/change_password_screen.dart';
import '../../features/purchase_offer/presentation/offer_purchased_screen.dart';
import '../../features/purchase_offer/presentation/purchase_offer_screen.dart';
import '../../features/profile/presentation/edit_profile/edit_profile_screen.dart';
import '../../features/profile/presentation/forget_password_for_edit/forget_password_for_edit_screen.dart';
import '../../features/profile/presentation/otp_change_phone/otp_change_phone_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reports/presentation/my_reports_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/search_details/presentation/search_details_screen.dart';
import '../../features/session_details/presentation/session_details_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/specialities/presentation/all_specialities_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'route_args.dart';
import 'routes.dart';
import '../../features/content/presentation/content_kind.dart';

/// Registers every route of the app; never add a route outside this file.
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

      // Auth flow and profile edit pages.
      GoRoute(
        path: Routes.authStart,
        pageBuilder: (context, state) =>
            _capsule(state, const StartNowScreen()),
      ),
      GoRoute(
        path: Routes.authLogin,
        pageBuilder: (context, state) => _capsule(state, const LoginScreen()),
      ),
      GoRoute(
        path: Routes.authRegister,
        pageBuilder: (context, state) =>
            _capsule(state, const RegisterScreen()),
      ),
      GoRoute(
        path: Routes.authForgetPassword,
        pageBuilder: (context, state) =>
            _capsule(state, const ForgetPasswordScreen()),
      ),
      GoRoute(
        path: Routes.authOtp,
        pageBuilder: (context, state) {
          final args = state.extra! as OtpArgs;
          return _capsule(state, OtpScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.authNewPassword,
        pageBuilder: (context, state) {
          final args = state.extra! as NewPasswordArgs;
          return _capsule(state, NewPasswordScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.authSuccess,
        pageBuilder: (context, state) =>
            _capsule(state, const AuthSuccessScreen()),
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
        builder: (context, state) =>
            PurchaseOfferScreen(offer: state.extra! as OfferModel),
      ),
      GoRoute(
        path: Routes.offerPurchased,
        builder: (context, state) =>
            OfferPurchasedScreen(userOfferId: _id(state)),
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
            _capsule(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: Routes.otpChangePhone,
        pageBuilder: (context, state) {
          final args = state.extra! as OtpArgs;
          return _capsule(state, OtpChangePhoneScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.changePassword,
        pageBuilder: (context, state) {
          final args = state.extra! as ChangePasswordArgs;
          return _capsule(state, ChangePasswordScreen(args: args));
        },
      ),
      GoRoute(
        path: Routes.forgetPasswordForEdit,
        pageBuilder: (context, state) {
          final args = state.extra! as NewPasswordArgs;
          return _capsule(state, ForgetPasswordForEditScreen(args: args));
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
      GoRoute(
        path: Routes.myReports,
        builder: (context, state) => const MyReportsScreen(),
      ),
    ],
  );
}

int _id(GoRouterState state) => int.parse(state.pathParameters['id']!);

/// Same capsule-opening transition the theme applies to `builder:` routes.
CustomTransitionPage<void> _capsule(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: CapsuleTransition.forwardDuration,
    reverseTransitionDuration: CapsuleTransition.reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CapsuleTransition(animation: animation, child: child),
  );
}
