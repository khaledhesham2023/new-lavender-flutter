/// All API paths (relative; base URL ends with `/api/`, so no leading slash).
abstract final class Endpoints {
  // Auth
  static const login = 'client/login';
  static const register = 'client/register';
  static const verify = 'client/verify';
  static const resend = 'client/resend';
  static const passwordReset = 'client/password/reset';
  static const passwordVerify = 'client/password/verify';
  static const passwordChange = 'client/password/change';
  static const logout = 'client/logout';

  // User
  static const user = 'client/user';
  static const updateProfile = 'client/user/update-profile';
  static const updatePhone = 'client/user/update-phone';
  static const verifyPhone = 'client/user/verify';
  static const changePassword = 'client/user/change-password';
  static const changeLang = 'client/user/change-lang';
  static const allowNotifications = 'client/user/allow-notifications';

  // Static pages / contact
  static const contact = 'client/contact';
  static const about = 'client/about';
  static const aboutApp = 'client/about-app';
  static const terms = 'client/term';
  static const policy = 'client/policy';

  // Notifications
  static const notifications = 'client/notifications';
  static const readAllNotifications = 'client/notifications/read-all';
  static String notification(String id) => 'client/notifications/$id';
  static String readNotification(String id) => 'client/notifications/read/$id';

  // Home / doctors / specialties
  static const home = 'client/home';
  static const fav = 'client/fav';
  static const specialties = 'client/specialty';
  static String specialtyDoctors(int id) => 'client/specialty/$id';

  // Search
  static const searchMost = 'client/search/most';
  static const search = 'client/search';
  static const searchClear = 'client/search/clear';

  // General
  static String filterDetails(int specialtyId) =>
      'general/filter-details/$specialtyId';
  static String doctor(int id) => 'general/doctor/$id';
  static String workTimes(int doctorId) => 'general/work-times/$doctorId';
  static const quickComments = 'general/quick-comments';
  static const countries = 'general/countries';
  static const attachments = 'general/attachments';
  static const settings = 'general/settings';

  // Appointments
  static const appointments = 'client/appointments';
  static String appointment(int id) => 'client/appointments/$id';
  static String rebook(int id) => 'client/appointments/recreate/$id';
  static const reviews = 'client/reviews';
  static const myReports = 'client/my-reports';

  // Offers
  static const offers = 'client/offers';
  static String offer(int id) => 'client/offers/$id';
  static const myOffers = 'client/my-offers';
  static String myOffer(int id) => 'client/my-offers/$id';
  static String session(int id) => 'client/session/$id';
}
