/// Every path of the app. Typed arguments travel in `extra`; ids in the path.
abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';

  static const authStart = '/auth/start';
  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authForgetPassword = '/auth/forget-password';
  static const authOtp = '/auth/otp'; // extra OtpArgs
  static const authNewPassword = '/auth/new-password'; // extra NewPasswordArgs
  static const authSuccess = '/auth/success';

  // Bottom-navigation tabs.
  static const home = '/home';
  static const search = '/search';
  static const bookings = '/bookings';
  static const favorites = '/favorites';
  static const profile = '/profile';

  static const notifications = '/notifications';
  static const allSpecialities = '/specialities';
  static const offers = '/offers';
  static const offerDetails = '/offers/:id';
  static String offerDetailsOf(int id) => '/offers/$id';
  static const purchaseOffer = '/purchase-offer'; // extra OfferModel
  static const offerPurchased = '/offer-purchased/:id'; // user offer id
  static String offerPurchasedOf(int id) => '/offer-purchased/$id';
  static const searchDetails = '/search-details'; // extra SpecialityModel
  static const filter = '/filter'; // extra FilterArgs (T21)
  static const doctorDetails = '/doctor/:id';
  static String doctorDetailsOf(int id) => '/doctor/$id';
  static const bookAppointment = '/book-appointment'; // extra BookingDraft
  static const bookAppointmentWithOffer =
      '/book-appointment-offer'; // extra BookWithOfferArgs
  static const appointmentRequested = '/appointment-requested/:id';
  static String appointmentRequestedOf(int id) => '/appointment-requested/$id';
  static const sessionRequested = '/session-requested/:id';
  static String sessionRequestedOf(int id) => '/session-requested/$id';
  static const appointmentDetails = '/appointments/:id';
  static String appointmentDetailsOf(int id) => '/appointments/$id';
  static const sessionDetails = '/sessions/:id';
  static String sessionDetailsOf(int id) => '/sessions/$id';

  static const editProfile = '/profile/edit';
  static const otpChangePhone = '/profile/otp'; // extra OtpArgs
  static const changePassword = '/profile/password'; // extra ChangePasswordArgs
  static const forgetPasswordForEdit =
      '/profile/password/reset'; // extra NewPasswordArgs

  static const contactUs = '/contact-us';
  static const aboutApp = '/about-app';
  static const aboutUs = '/about-us';
  static const terms = '/terms';
  static const privacy = '/privacy';

  static const myOffers = '/my-offers';
  static const myOfferDetails = '/my-offers/:id';
  static String myOfferDetailsOf(int id) => '/my-offers/$id';
  static const myReports = '/reports';

  /// The five shell tabs in bottom-bar order.
  static const tabs = [home, search, bookings, favorites, profile];
}
