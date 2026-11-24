import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutDoctor.
  ///
  /// In en, this message translates to:
  /// **'About Doctor:'**
  String get aboutDoctor;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully.'**
  String get accountCreatedSuccessfully;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add your comment..'**
  String get addComment;

  /// No description provided for @addYourBookReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Add your rating and share your opinion about the doctor'**
  String get addYourBookReviewBody;

  /// No description provided for @addYourBookReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your rate for the doctor'**
  String get addYourBookReviewTitle;

  /// No description provided for @agreeToThe.
  ///
  /// In en, this message translates to:
  /// **'Agree to the'**
  String get agreeToThe;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allDoctors.
  ///
  /// In en, this message translates to:
  /// **'All doctors {p1}'**
  String allDoctors(String p1);

  /// No description provided for @allMedicalSpecialities.
  ///
  /// In en, this message translates to:
  /// **'All medical specialties'**
  String get allMedicalSpecialities;

  /// No description provided for @allReservations.
  ///
  /// In en, this message translates to:
  /// **'All Reservations'**
  String get allReservations;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved to the Tibi application 2025'**
  String get allRightsReserved;

  /// No description provided for @allYourMedicalServicesInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'All your medical services in one place'**
  String get allYourMedicalServicesInOnePlace;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lavender Land Clinics'**
  String get appName;

  /// No description provided for @appProvides.
  ///
  /// In en, this message translates to:
  /// **'The app also provides the ability to explore offers and discounts, receive notifications of booking dates and important alerts, and the flexibility to manage and reschedule appointments when needed.'**
  String get appProvides;

  /// No description provided for @appointmentCanceledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The reservation was successfully cancelled'**
  String get appointmentCanceledSuccessfully;

  /// No description provided for @appointmentChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The appointment has been changed successfully'**
  String get appointmentChangedSuccessfully;

  /// No description provided for @appointmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Appointments available'**
  String get appointmentsAvailable;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @areYouSureAboutYourDecisionBody.
  ///
  /// In en, this message translates to:
  /// **'All your data will be lost and you will not be able to recover it after deletion'**
  String get areYouSureAboutYourDecisionBody;

  /// No description provided for @areYouSureAboutYourDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure about your decision?'**
  String get areYouSureAboutYourDecisionTitle;

  /// No description provided for @availableDoctorsWithNumber.
  ///
  /// In en, this message translates to:
  /// **'{p1} available doctor/s'**
  String availableDoctorsWithNumber(String p1);

  /// No description provided for @availableTimes.
  ///
  /// In en, this message translates to:
  /// **'Available times'**
  String get availableTimes;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backToHomePage.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get backToHomePage;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @basedOnNoOfReviews.
  ///
  /// In en, this message translates to:
  /// **'Based on {p1} reviews'**
  String basedOnNoOfReviews(String p1);

  /// No description provided for @bookAnAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get bookAnAppointment;

  /// No description provided for @bookAnOffer.
  ///
  /// In en, this message translates to:
  /// **'Book an offer'**
  String get bookAnOffer;

  /// No description provided for @bookEasilyAnytime.
  ///
  /// In en, this message translates to:
  /// **'Book easily anytime'**
  String get bookEasilyAnytime;

  /// No description provided for @bookNormalExaminationWithValue.
  ///
  /// In en, this message translates to:
  /// **'Book normal examination for {p1} SAR'**
  String bookNormalExaminationWithValue(String p1);

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @bookYourAppointments.
  ///
  /// In en, this message translates to:
  /// **'Book your appointments, consult specialist doctors, and track your health easily through our medical app.'**
  String get bookYourAppointments;

  /// No description provided for @bookingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Booking Appointments'**
  String get bookingAppointments;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetails;

  /// No description provided for @bookingDetailsWithColon.
  ///
  /// In en, this message translates to:
  /// **'Booking Details:'**
  String get bookingDetailsWithColon;

  /// No description provided for @bookingDetailsWithValue.
  ///
  /// In en, this message translates to:
  /// **'Booking details {p1}'**
  String bookingDetailsWithValue(String p1);

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @browseTheListOfDoctorsAndServices.
  ///
  /// In en, this message translates to:
  /// **'Browse the list of doctors and services, choose the one that suits you best, and schedule an appointment that suits you with the click of a button, without calls or long waits.'**
  String get browseTheListOfDoctorsAndServices;

  /// No description provided for @calender.
  ///
  /// In en, this message translates to:
  /// **'Calender'**
  String get calender;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @changeAppointment.
  ///
  /// In en, this message translates to:
  /// **'Change Appointment'**
  String get changeAppointment;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @changePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a strong password that contains at least 8 characters, numbers, and symbols.'**
  String get changePasswordBody;

  /// No description provided for @checkTheDoctors.
  ///
  /// In en, this message translates to:
  /// **'Check the doctors'**
  String get checkTheDoctors;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get choosePaymentMethod;

  /// No description provided for @chooseSubSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more sub-specialities'**
  String get chooseSubSpecialities;

  /// No description provided for @chooseTheLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you want'**
  String get chooseTheLanguage;

  /// No description provided for @codeNotCorrect.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the code number is incorrect.'**
  String get codeNotCorrect;

  /// No description provided for @commentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your comment has been added successfully'**
  String get commentAddedSuccessfully;

  /// No description provided for @complainSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The complaint has been sent successfully'**
  String get complainSentSuccessfully;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmCancelAppointmentBody.
  ///
  /// In en, this message translates to:
  /// **'You are now about to cancel your current reservation. You will not be able to undo this step and you can start a new reservation.'**
  String get confirmCancelAppointmentBody;

  /// No description provided for @confirmCancelAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the reservation?'**
  String get confirmCancelAppointmentTitle;

  /// No description provided for @confirmChangeAppointmentBody.
  ///
  /// In en, this message translates to:
  /// **'You are about to change your current reservation date. Are you sure about this change?'**
  String get confirmChangeAppointmentBody;

  /// No description provided for @confirmChangeAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change the appointment?'**
  String get confirmChangeAppointmentTitle;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password*'**
  String get confirmNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password*'**
  String get confirmPassword;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'copied'**
  String get copied;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @creditCards.
  ///
  /// In en, this message translates to:
  /// **'Credit Cards'**
  String get creditCards;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password*'**
  String get currentPassword;

  /// No description provided for @dataModifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The data has been modified successfully'**
  String get dataModifiedSuccessfully;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get date;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get dateAndTime;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @dentistry.
  ///
  /// In en, this message translates to:
  /// **'Dentistry'**
  String get dentistry;

  /// No description provided for @dermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get dermatology;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details :'**
  String get details;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountWithPercent.
  ///
  /// In en, this message translates to:
  /// **'{p1}%'**
  String discountWithPercent(String p1);

  /// No description provided for @doYouWantToLeaveNowBody.
  ///
  /// In en, this message translates to:
  /// **'You can come back anytime to enjoy our services again!'**
  String get doYouWantToLeaveNowBody;

  /// No description provided for @doYouWantToLeaveNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to leave now?'**
  String get doYouWantToLeaveNowTitle;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @doctorDetails.
  ///
  /// In en, this message translates to:
  /// **'Doctor Details'**
  String get doctorDetails;

  /// No description provided for @doctorF.
  ///
  /// In en, this message translates to:
  /// **'Doctor(Female)'**
  String get doctorF;

  /// No description provided for @doctorIsOffToday.
  ///
  /// In en, this message translates to:
  /// **'Doctor is off today'**
  String get doctorIsOffToday;

  /// No description provided for @doctorM.
  ///
  /// In en, this message translates to:
  /// **'Doctor(Male)'**
  String get doctorM;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @downloadThisApp.
  ///
  /// In en, this message translates to:
  /// **'Download this app'**
  String get downloadThisApp;

  /// No description provided for @downloadingWithValue.
  ///
  /// In en, this message translates to:
  /// **'Downloading {p1}'**
  String downloadingWithValue(String p1);

  /// No description provided for @editBooking.
  ///
  /// In en, this message translates to:
  /// **'Edit Booking'**
  String get editBooking;

  /// No description provided for @elgbeelElsnaaya.
  ///
  /// In en, this message translates to:
  /// **'Jubail Industrial City'**
  String get elgbeelElsnaaya;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @emailMustStartWithALetter.
  ///
  /// In en, this message translates to:
  /// **'Email must start with a letter.'**
  String get emailMustStartWithALetter;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterADescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a description of your medical condition.'**
  String get enterADescription;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @enterMessageHeadline.
  ///
  /// In en, this message translates to:
  /// **'Enter message headline'**
  String get enterMessageHeadline;

  /// No description provided for @enterNewPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Save your new password in a safe place. If you forget it, you will have to reset the forgotten password again.'**
  String get enterNewPasswordBody;

  /// No description provided for @enterNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password'**
  String get enterNewPasswordTitle;

  /// No description provided for @enterOtpBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to phone number {p1} to confirm your account.'**
  String enterOtpBody(String p1);

  /// No description provided for @enterOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the confirmation code'**
  String get enterOtpTitle;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterTheCodeSentToThePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to the phone number'**
  String get enterTheCodeSentToThePhoneNumber;

  /// No description provided for @enterTheConfirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the confirmation code'**
  String get enterTheConfirmationCode;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get enterValidEmail;

  /// No description provided for @enterYourMedicalCondition.
  ///
  /// In en, this message translates to:
  /// **'Enter your medical condition'**
  String get enterYourMedicalCondition;

  /// No description provided for @enterYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get enterYourMessage;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @examinationBook.
  ///
  /// In en, this message translates to:
  /// **'Examination Book'**
  String get examinationBook;

  /// No description provided for @examinationDuration.
  ///
  /// In en, this message translates to:
  /// **'Examination duration:'**
  String get examinationDuration;

  /// No description provided for @examinationDurationNoColon.
  ///
  /// In en, this message translates to:
  /// **'Examination duration'**
  String get examinationDurationNoColon;

  /// No description provided for @examinationPrice.
  ///
  /// In en, this message translates to:
  /// **'Examination Price:'**
  String get examinationPrice;

  /// No description provided for @examinationPriceNoColon.
  ///
  /// In en, this message translates to:
  /// **'Examination Price'**
  String get examinationPriceNoColon;

  /// No description provided for @favoriteDoctors.
  ///
  /// In en, this message translates to:
  /// **'Favorite doctors'**
  String get favoriteDoctors;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @featuredMedicalOffers.
  ///
  /// In en, this message translates to:
  /// **'Featured Medical Offers'**
  String get featuredMedicalOffers;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterByType;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgetPassword;

  /// No description provided for @forgetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a code that will allow you to change your password.'**
  String get forgetPasswordBody;

  /// No description provided for @forgetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password..!'**
  String get forgetPasswordTitle;

  /// No description provided for @fromToValues.
  ///
  /// In en, this message translates to:
  /// **'From {p1}  to {p2}'**
  String fromToValues(String p1, String p2);

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameMustBeAtLeast2Letters.
  ///
  /// In en, this message translates to:
  /// **'\"Full Name must be at least 2 letters \"'**
  String get fullNameMustBeAtLeast2Letters;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get generalInfo;

  /// No description provided for @generalMedicine.
  ///
  /// In en, this message translates to:
  /// **'General medicine'**
  String get generalMedicine;

  /// No description provided for @getTheOffer.
  ///
  /// In en, this message translates to:
  /// **'Get the offer'**
  String get getTheOffer;

  /// No description provided for @gifFilesAreNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'GIF files are not allowed'**
  String get gifFilesAreNotAllowed;

  /// No description provided for @goToReservations.
  ///
  /// In en, this message translates to:
  /// **'Go to reservations'**
  String get goToReservations;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon{p1}'**
  String goodAfternoon(String p1);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening{p1}'**
  String goodEvening(String p1);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning{p1}'**
  String goodMorning(String p1);

  /// No description provided for @highToLowPrice.
  ///
  /// In en, this message translates to:
  /// **'Price from highest to lowest'**
  String get highToLowPrice;

  /// No description provided for @highToLowRate.
  ///
  /// In en, this message translates to:
  /// **'Rating from highest to lowest'**
  String get highToLowRate;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @howAreYouFeelingToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today..?'**
  String get howAreYouFeelingToday;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help ?'**
  String get howCanWeHelp;

  /// No description provided for @invalidImage.
  ///
  /// In en, this message translates to:
  /// **'Invalid Image'**
  String get invalidImage;

  /// No description provided for @keepADigitalMedicalRecordThatIncludesYourPreviousAppointments.
  ///
  /// In en, this message translates to:
  /// **'Keep a digital medical record that includes your previous appointments, test results, and doctor recommendations, with notifications to continuously monitor your health status.'**
  String get keepADigitalMedicalRecordThatIncludesYourPreviousAppointments;

  /// No description provided for @laboratory.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get laboratory;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @last12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get last12Months;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6Months;

  /// No description provided for @latestSearchResults.
  ///
  /// In en, this message translates to:
  /// **'“Latest search results”'**
  String get latestSearchResults;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginScreenBody.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number and password to log in.'**
  String get loginScreenBody;

  /// No description provided for @loginScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in now ..!'**
  String get loginScreenTitle;

  /// No description provided for @loginStart.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginStart;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @lowToHighPrice.
  ///
  /// In en, this message translates to:
  /// **'Price from lowest to highest'**
  String get lowToHighPrice;

  /// No description provided for @lowToHighRate.
  ///
  /// In en, this message translates to:
  /// **'Rating from lowest to highest'**
  String get lowToHighRate;

  /// No description provided for @makeSureYouCancelYourAccountBecauseYouWonTBeAbleToLogBackInWithThisInformation.
  ///
  /// In en, this message translates to:
  /// **'Make sure you cancel your trip, because you won\'t be able to log back in with this information'**
  String
  get makeSureYouCancelYourAccountBecauseYouWonTBeAbleToLogBackInWithThisInformation;

  /// No description provided for @medicalConditionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description of medical condition'**
  String get medicalConditionDescription;

  /// No description provided for @medicalOffers.
  ///
  /// In en, this message translates to:
  /// **'Medical offers'**
  String get medicalOffers;

  /// No description provided for @medicalReport.
  ///
  /// In en, this message translates to:
  /// **'The attached medical report'**
  String get medicalReport;

  /// No description provided for @medicalReportPdf.
  ///
  /// In en, this message translates to:
  /// **'Medical Report PDF'**
  String get medicalReportPdf;

  /// No description provided for @mental.
  ///
  /// In en, this message translates to:
  /// **'Mental health'**
  String get mental;

  /// No description provided for @messageHeadline.
  ///
  /// In en, this message translates to:
  /// **'Message Headline'**
  String get messageHeadline;

  /// No description provided for @messageHeadlineMustBeAtLeast2Letters.
  ///
  /// In en, this message translates to:
  /// **'message headline must be at least 2 letters'**
  String get messageHeadlineMustBeAtLeast2Letters;

  /// No description provided for @messageMustBeAtLeast2Letters.
  ///
  /// In en, this message translates to:
  /// **'message must be at least 2 letters'**
  String get messageMustBeAtLeast2Letters;

  /// No description provided for @minValues.
  ///
  /// In en, this message translates to:
  /// **'{p1} minute(s)'**
  String minValues(String p1);

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @modifyPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Modify personal information'**
  String get modifyPersonalInformation;

  /// No description provided for @mogamaaElkhazamyEltiby.
  ///
  /// In en, this message translates to:
  /// **'Lavender Land Medical Complex'**
  String get mogamaaElkhazamyEltiby;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moreThanOneTimeWithValue.
  ///
  /// In en, this message translates to:
  /// **'{p1} times'**
  String moreThanOneTimeWithValue(String p1);

  /// No description provided for @mostPopularSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Most popular specialities'**
  String get mostPopularSpecialities;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @myOffers.
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get myOffers;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name*'**
  String get name;

  /// No description provided for @nameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get nameMustBeAtLeast2Characters;

  /// No description provided for @nameMustStartWithALetter.
  ///
  /// In en, this message translates to:
  /// **'Name must start with a letter.'**
  String get nameMustStartWithALetter;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password*'**
  String get newPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get noAddress;

  /// No description provided for @noAddressesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No Addresses added yet'**
  String get noAddressesAddedYet;

  /// No description provided for @noAppFoundToHandleTheRequest.
  ///
  /// In en, this message translates to:
  /// **'No app found to handle the request.'**
  String get noAppFoundToHandleTheRequest;

  /// No description provided for @noAppFoundToOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'No app found to open maps'**
  String get noAppFoundToOpenMaps;

  /// No description provided for @noAvailableTimesToday.
  ///
  /// In en, this message translates to:
  /// **'There are no available times today..!'**
  String get noAvailableTimesToday;

  /// No description provided for @noDataToPreview.
  ///
  /// In en, this message translates to:
  /// **'No data to preview'**
  String get noDataToPreview;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No medical condition description'**
  String get noDescription;

  /// No description provided for @noDoctorsInThisSpeciality.
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsInThisSpeciality;

  /// No description provided for @noDoctorsInThisSpecialityBody.
  ///
  /// In en, this message translates to:
  /// **'No doctors found in this specialty'**
  String get noDoctorsInThisSpecialityBody;

  /// No description provided for @noDoctorsToFilter.
  ///
  /// In en, this message translates to:
  /// **'No doctors to filter'**
  String get noDoctorsToFilter;

  /// No description provided for @noFavoriteDoctorsBody.
  ///
  /// In en, this message translates to:
  /// **'You can add any doctor you like and it will appear here in your favourites list.'**
  String get noFavoriteDoctorsBody;

  /// No description provided for @noFavoriteDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any favorite doctors.'**
  String get noFavoriteDoctorsTitle;

  /// No description provided for @noInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No available information'**
  String get noInformationAvailable;

  /// No description provided for @noInternetConncetion.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConncetion;

  /// No description provided for @noInternetConncetionBody.
  ///
  /// In en, this message translates to:
  /// **'Please connect first'**
  String get noInternetConncetionBody;

  /// No description provided for @noInternetConncetionBody2.
  ///
  /// In en, this message translates to:
  /// **'Internet connection has been interrupted. Please check your connection and try again later.'**
  String get noInternetConncetionBody2;

  /// No description provided for @noMyOffersBody.
  ///
  /// In en, this message translates to:
  /// **'If you subscribe to Tibi offers, you will be able to check all your offers here'**
  String get noMyOffersBody;

  /// No description provided for @noMyOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no offers'**
  String get noMyOffersTitle;

  /// No description provided for @noNeedToSearchInMultiplePlaces.
  ///
  /// In en, this message translates to:
  /// **'No need to search in multiple places! We offer you the ability to book doctors, tests, x-rays, and medical consultations easily and quickly from your location.'**
  String get noNeedToSearchInMultiplePlaces;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'When any changes occur, you will be notified here via notifications.'**
  String get noNotificationsBody;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsTitle;

  /// No description provided for @noOffersBody.
  ///
  /// In en, this message translates to:
  /// **'You have no available offers in that specialty'**
  String get noOffersBody;

  /// No description provided for @noOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'No available offers'**
  String get noOffersTitle;

  /// No description provided for @noReportsBody.
  ///
  /// In en, this message translates to:
  /// **'All reports submitted by your doctors will appear here'**
  String get noReportsBody;

  /// No description provided for @noReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no reports'**
  String get noReportsTitle;

  /// No description provided for @noReservations.
  ///
  /// In en, this message translates to:
  /// **'No reservation made yet..!'**
  String get noReservations;

  /// No description provided for @noReservationsBody.
  ///
  /// In en, this message translates to:
  /// **'When any changes occur, you will be notified via notifications'**
  String get noReservationsBody;

  /// No description provided for @noReservationsSearchResultsBody.
  ///
  /// In en, this message translates to:
  /// **'No appointments with the given doctor name'**
  String get noReservationsSearchResultsBody;

  /// No description provided for @noReservationsSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get noReservationsSearchResultsTitle;

  /// No description provided for @noReservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no reservations yet'**
  String get noReservationsTitle;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'There are no reviews yet..!'**
  String get noReviews;

  /// No description provided for @noSearchResultsDoctorsBody.
  ///
  /// In en, this message translates to:
  /// **'Please try to find other doctors.'**
  String get noSearchResultsDoctorsBody;

  /// No description provided for @noSearchResultsSpecialtiesBody.
  ///
  /// In en, this message translates to:
  /// **'Please try to find other specialties.'**
  String get noSearchResultsSpecialtiesBody;

  /// No description provided for @noSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sorry we couldn\'t find what you were looking for..'**
  String get noSearchResultsTitle;

  /// No description provided for @noSubspecialtiesBody.
  ///
  /// In en, this message translates to:
  /// **'No subspecialties for that specialty'**
  String get noSubspecialtiesBody;

  /// No description provided for @noSubspecialtiesTitle.
  ///
  /// In en, this message translates to:
  /// **'No subspecialties'**
  String get noSubspecialtiesTitle;

  /// No description provided for @noSuitableAppFoundToOpenTheLink.
  ///
  /// In en, this message translates to:
  /// **'No suitable app found to open the link'**
  String get noSuitableAppFoundToOpenTheLink;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @normalReservations.
  ///
  /// In en, this message translates to:
  /// **'Normal Reservations'**
  String get normalReservations;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @nowLoading.
  ///
  /// In en, this message translates to:
  /// **'Now Loading'**
  String get nowLoading;

  /// No description provided for @numberOfOfferBookings.
  ///
  /// In en, this message translates to:
  /// **'Number of offer bookings'**
  String get numberOfOfferBookings;

  /// No description provided for @numberOfSessions.
  ///
  /// In en, this message translates to:
  /// **'Number of sessions:'**
  String get numberOfSessions;

  /// No description provided for @numberOfSessionsNoColon.
  ///
  /// In en, this message translates to:
  /// **'Number of sessions'**
  String get numberOfSessionsNoColon;

  /// No description provided for @numberOfSessionsWithValue.
  ///
  /// In en, this message translates to:
  /// **'({p1}/{p2}) session'**
  String numberOfSessionsWithValue(String p1, String p2);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// No description provided for @offerDetails.
  ///
  /// In en, this message translates to:
  /// **'Offer details'**
  String get offerDetails;

  /// No description provided for @offerObtainedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The offer has been successfully obtained'**
  String get offerObtainedSuccessfully;

  /// No description provided for @offerValidityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Offer Validity Period'**
  String get offerValidityPeriod;

  /// No description provided for @offersReservations.
  ///
  /// In en, this message translates to:
  /// **'Offers Reservations'**
  String get offersReservations;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get oneTime;

  /// No description provided for @openCalender.
  ///
  /// In en, this message translates to:
  /// **'Open Calender'**
  String get openCalender;

  /// No description provided for @openWith.
  ///
  /// In en, this message translates to:
  /// **'Open With'**
  String get openWith;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @orYouCan.
  ///
  /// In en, this message translates to:
  /// **'Or you can'**
  String get orYouCan;

  /// No description provided for @ordinal1.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get ordinal1;

  /// No description provided for @ordinal10.
  ///
  /// In en, this message translates to:
  /// **'Tenth'**
  String get ordinal10;

  /// No description provided for @ordinal100.
  ///
  /// In en, this message translates to:
  /// **'Hundredth'**
  String get ordinal100;

  /// No description provided for @ordinal11.
  ///
  /// In en, this message translates to:
  /// **'Eleventh'**
  String get ordinal11;

  /// No description provided for @ordinal12.
  ///
  /// In en, this message translates to:
  /// **'Twelfth'**
  String get ordinal12;

  /// No description provided for @ordinal13.
  ///
  /// In en, this message translates to:
  /// **'Thirteenth'**
  String get ordinal13;

  /// No description provided for @ordinal14.
  ///
  /// In en, this message translates to:
  /// **'Fourteenth'**
  String get ordinal14;

  /// No description provided for @ordinal15.
  ///
  /// In en, this message translates to:
  /// **'Fifteenth'**
  String get ordinal15;

  /// No description provided for @ordinal16.
  ///
  /// In en, this message translates to:
  /// **'Sixteenth'**
  String get ordinal16;

  /// No description provided for @ordinal17.
  ///
  /// In en, this message translates to:
  /// **'Seventeenth'**
  String get ordinal17;

  /// No description provided for @ordinal18.
  ///
  /// In en, this message translates to:
  /// **'Eighteenth'**
  String get ordinal18;

  /// No description provided for @ordinal19.
  ///
  /// In en, this message translates to:
  /// **'Nineteenth'**
  String get ordinal19;

  /// No description provided for @ordinal2.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get ordinal2;

  /// No description provided for @ordinal20.
  ///
  /// In en, this message translates to:
  /// **'Twentieth'**
  String get ordinal20;

  /// No description provided for @ordinal3.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get ordinal3;

  /// No description provided for @ordinal30.
  ///
  /// In en, this message translates to:
  /// **'Thirtieth'**
  String get ordinal30;

  /// No description provided for @ordinal4.
  ///
  /// In en, this message translates to:
  /// **'Fourth'**
  String get ordinal4;

  /// No description provided for @ordinal40.
  ///
  /// In en, this message translates to:
  /// **'Fortieth'**
  String get ordinal40;

  /// No description provided for @ordinal5.
  ///
  /// In en, this message translates to:
  /// **'Fifth'**
  String get ordinal5;

  /// No description provided for @ordinal50.
  ///
  /// In en, this message translates to:
  /// **'Fiftieth'**
  String get ordinal50;

  /// No description provided for @ordinal6.
  ///
  /// In en, this message translates to:
  /// **'Sixth'**
  String get ordinal6;

  /// No description provided for @ordinal60.
  ///
  /// In en, this message translates to:
  /// **'Sixtieth'**
  String get ordinal60;

  /// No description provided for @ordinal7.
  ///
  /// In en, this message translates to:
  /// **'Seventh'**
  String get ordinal7;

  /// No description provided for @ordinal70.
  ///
  /// In en, this message translates to:
  /// **'Seventieth'**
  String get ordinal70;

  /// No description provided for @ordinal8.
  ///
  /// In en, this message translates to:
  /// **'Eighth'**
  String get ordinal8;

  /// No description provided for @ordinal80.
  ///
  /// In en, this message translates to:
  /// **'Eightieth'**
  String get ordinal80;

  /// No description provided for @ordinal9.
  ///
  /// In en, this message translates to:
  /// **'Ninth'**
  String get ordinal9;

  /// No description provided for @ordinal90.
  ///
  /// In en, this message translates to:
  /// **'Ninetieth'**
  String get ordinal90;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our vision:'**
  String get ourVision;

  /// No description provided for @ourVisionDescription.
  ///
  /// In en, this message translates to:
  /// **'We seek to revolutionize the digital healthcare field by providing integrated services that facilitate access to the highest quality and fastest healthcare for everyone. Our vision is to make booking and availing medical services a seamless and safe experience, meeting patients\' needs efficiently and comfortably.'**
  String get ourVisionDescription;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The password has been changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordChangedSuccessfullyBody.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully. Go to login again.'**
  String get passwordChangedSuccessfullyBody;

  /// No description provided for @passwordChangedSuccessfullyBtn.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get passwordChangedSuccessfullyBtn;

  /// No description provided for @passwordChangedSuccessfullyTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordChangedSuccessfullyTitle;

  /// No description provided for @passwordMustBeAtLeast8CharactersLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordMustBeAtLeast8CharactersLong;

  /// No description provided for @passwordMustStartWithALetter.
  ///
  /// In en, this message translates to:
  /// **'Password must start with a letter or digit.'**
  String get passwordMustStartWithALetter;

  /// No description provided for @passwordNotCorrect.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the password is incorrect.'**
  String get passwordNotCorrect;

  /// No description provided for @passwordRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to phone number {p1} to retrieve your password'**
  String passwordRecoveryBody(String p1);

  /// No description provided for @passwordRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get passwordRecoveryTitle;

  /// No description provided for @passwordWithStar.
  ///
  /// In en, this message translates to:
  /// **'Password*'**
  String get passwordWithStar;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get paymentSummary;

  /// No description provided for @pediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get pediatrics;

  /// No description provided for @pendingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingForConfirmation;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number*'**
  String get phone;

  /// No description provided for @phoneChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The phone number has been changed successfully.'**
  String get phoneChangedSuccessfully;

  /// No description provided for @phoneExample.
  ///
  /// In en, this message translates to:
  /// **'5********'**
  String get phoneExample;

  /// No description provided for @phoneNotCorrect.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the phone number is incorrect.'**
  String get phoneNotCorrect;

  /// No description provided for @pickUpBookingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Pick up your booking appointment'**
  String get pickUpBookingAppointment;

  /// No description provided for @pickUpRebookingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Pick up your rebooking appointment'**
  String get pickUpRebookingAppointment;

  /// No description provided for @pleaseAcceptTheTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and conditions'**
  String get pleaseAcceptTheTermsAndConditions;

  /// No description provided for @pleaseEnterHowWeCanHelpYou.
  ///
  /// In en, this message translates to:
  /// **'please enter how we can help you'**
  String get pleaseEnterHowWeCanHelpYou;

  /// No description provided for @pleaseEnterTheMessageHeadline.
  ///
  /// In en, this message translates to:
  /// **'please enter the message headline'**
  String get pleaseEnterTheMessageHeadline;

  /// No description provided for @pleaseEnterThePassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the password'**
  String get pleaseEnterThePassword;

  /// No description provided for @pleaseEnterThePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter the phone number'**
  String get pleaseEnterThePhoneNumber;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseSelectAppointmentType.
  ///
  /// In en, this message translates to:
  /// **'Select an appointment'**
  String get pleaseSelectAppointmentType;

  /// No description provided for @pleaseSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Please select day'**
  String get pleaseSelectDay;

  /// No description provided for @pleaseSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select time'**
  String get pleaseSelectTime;

  /// No description provided for @policyOfUse.
  ///
  /// In en, this message translates to:
  /// **'📌Usage Policy⚖️📜'**
  String get policyOfUse;

  /// No description provided for @priceAfterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Price after discount'**
  String get priceAfterDiscount;

  /// No description provided for @priceBeforeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Price before discount'**
  String get priceBeforeDiscount;

  /// No description provided for @priceWithValue.
  ///
  /// In en, this message translates to:
  /// **'{p1} SAR'**
  String priceWithValue(String p1);

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @quickReplies.
  ///
  /// In en, this message translates to:
  /// **'Quick replies:'**
  String get quickReplies;

  /// No description provided for @radiology.
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get radiology;

  /// No description provided for @radiologyAndAnalysisReports.
  ///
  /// In en, this message translates to:
  /// **'Radiology and analysis reports'**
  String get radiologyAndAnalysisReports;

  /// No description provided for @rateBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking Review'**
  String get rateBooking;

  /// No description provided for @rateNumberOfReviewsWithValues.
  ///
  /// In en, this message translates to:
  /// **'({p1}) {p2}'**
  String rateNumberOfReviewsWithValues(String p1, String p2);

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateTheApp;

  /// No description provided for @ratesWithValue.
  ///
  /// In en, this message translates to:
  /// **'Reviews {p1}'**
  String ratesWithValue(String p1);

  /// No description provided for @reReserve.
  ///
  /// In en, this message translates to:
  /// **'Re-reserve'**
  String get reReserve;

  /// No description provided for @rebook.
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebook;

  /// No description provided for @recentlyAddedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Newly added doctors'**
  String get recentlyAddedDoctors;

  /// No description provided for @regularMonitoringOfYourHealth.
  ///
  /// In en, this message translates to:
  /// **'Regular monitoring of your health'**
  String get regularMonitoringOfYourHealth;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @remainingSessions.
  ///
  /// In en, this message translates to:
  /// **'Remaining ({p1}/{p2}) session/s'**
  String remainingSessions(String p1, String p2);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove all'**
  String get removeAll;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resendWithin.
  ///
  /// In en, this message translates to:
  /// **'Resend within:'**
  String get resendWithin;

  /// No description provided for @reservationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed'**
  String get reservationConfirmed;

  /// No description provided for @reservationRequestSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your reservation request has been sent successfully.'**
  String get reservationRequestSentSuccessfully;

  /// No description provided for @reserveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reservation'**
  String get reserveConfirmation;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @reviewsTotalNumber.
  ///
  /// In en, this message translates to:
  /// **'Reviews {p1}'**
  String reviewsTotalNumber(String p1);

  /// No description provided for @reviewsWithNumber.
  ///
  /// In en, this message translates to:
  /// **'{p1} reviews'**
  String reviewsWithNumber(String p1);

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'{p1} SAR'**
  String sar(String p1);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchByDoctorsName.
  ///
  /// In en, this message translates to:
  /// **'Search by doctor name'**
  String get searchByDoctorsName;

  /// No description provided for @searchBySpecialityOrDoctor.
  ///
  /// In en, this message translates to:
  /// **'Search by specialty or doctor\'s name'**
  String get searchBySpecialityOrDoctor;

  /// No description provided for @searchIn.
  ///
  /// In en, this message translates to:
  /// **'Search in'**
  String get searchIn;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get second;

  /// No description provided for @selectedDayNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'The Doctor is not available in that day'**
  String get selectedDayNotAvailableYet;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendOtp;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @serverErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Internet access error'**
  String get serverErrorBody;

  /// No description provided for @serverErrorBody2.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please check your connection and try again later.'**
  String get serverErrorBody2;

  /// No description provided for @sessionWithValue.
  ///
  /// In en, this message translates to:
  /// **'{p1} session'**
  String sessionWithValue(String p1);

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @showBookings.
  ///
  /// In en, this message translates to:
  /// **'Show bookings'**
  String get showBookings;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show Details'**
  String get showDetails;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResults;

  /// No description provided for @sideMenu.
  ///
  /// In en, this message translates to:
  /// **'Side menu'**
  String get sideMenu;

  /// No description provided for @somethingWrongHappen.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWrongHappen;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get sortByDate;

  /// No description provided for @sortingBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortingBy;

  /// No description provided for @specialities.
  ///
  /// In en, this message translates to:
  /// **'Specialities'**
  String get specialities;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @startABetterHealthyJourney.
  ///
  /// In en, this message translates to:
  /// **'Start a better healthy journey with us now!'**
  String get startABetterHealthyJourney;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @startYourHealthJourneyNowBody.
  ///
  /// In en, this message translates to:
  /// **'Register your account in minutes to access the best doctors and medical services, and book your appointments with complete ease'**
  String get startYourHealthJourneyNowBody;

  /// No description provided for @startYourHealthJourneyNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your health journey now'**
  String get startYourHealthJourneyNowTitle;

  /// No description provided for @subSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Sub-Specialties'**
  String get subSpecialties;

  /// No description provided for @subscriptionDate.
  ///
  /// In en, this message translates to:
  /// **'Subscription Date:'**
  String get subscriptionDate;

  /// No description provided for @subscriptionDateNoColon.
  ///
  /// In en, this message translates to:
  /// **'Subscription Date'**
  String get subscriptionDateNoColon;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get termsAndConditions;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'📌Terms of use⚖️📜'**
  String get termsOfUse;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUseTitle;

  /// No description provided for @text1.
  ///
  /// In en, this message translates to:
  /// **'1'**
  String get text1;

  /// No description provided for @text2.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get text2;

  /// No description provided for @text3.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get text3;

  /// No description provided for @text4.
  ///
  /// In en, this message translates to:
  /// **'4'**
  String get text4;

  /// No description provided for @text5.
  ///
  /// In en, this message translates to:
  /// **'5'**
  String get text5;

  /// No description provided for @theConfirmationPasswordDoesNotMatchWithTheOriginalPassword.
  ///
  /// In en, this message translates to:
  /// **'The confirmation password does not match with the original password.'**
  String get theConfirmationPasswordDoesNotMatchWithTheOriginalPassword;

  /// No description provided for @theLinkIsInvalidOrEmpty.
  ///
  /// In en, this message translates to:
  /// **'The link is invalid or empty'**
  String get theLinkIsInvalidOrEmpty;

  /// No description provided for @thePhoneNumberIsInvalidPleaseStartWith5.
  ///
  /// In en, this message translates to:
  /// **'The phone number is invalid, please start with 5'**
  String get thePhoneNumberIsInvalidPleaseStartWith5;

  /// No description provided for @thePhoneNumberMustBeAtLeast9CharactersLong.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 9 characters long'**
  String get thePhoneNumberMustBeAtLeast9CharactersLong;

  /// No description provided for @thereAreNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'There are no messages yet.'**
  String get thereAreNoMessagesYet;

  /// No description provided for @thisCodeIsInvalidPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'This code is invalid. Please try again.'**
  String get thisCodeIsInvalidPleaseTryAgain;

  /// No description provided for @thisOfferAppliesOnSpecialty.
  ///
  /// In en, this message translates to:
  /// **'This offer applies to all doctors in the specialty of {p1}'**
  String thisOfferAppliesOnSpecialty(String p1);

  /// No description provided for @thisOfferNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This offer is no longer available'**
  String get thisOfferNoLongerAvailable;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get time;

  /// No description provided for @toConfirmYourAccount.
  ///
  /// In en, this message translates to:
  /// **'To confirm your account'**
  String get toConfirmYourAccount;

  /// No description provided for @toRetrieveYourPassword.
  ///
  /// In en, this message translates to:
  /// **'To retrieve your password'**
  String get toRetrieveYourPassword;

  /// No description provided for @trySearchForDoctorOrSpeciality.
  ///
  /// In en, this message translates to:
  /// **'Try searching for the doctor\'s name or medical specialty.'**
  String get trySearchForDoctorOrSpeciality;

  /// No description provided for @tvGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Simple steps to book your examination >>'**
  String get tvGuestBody;

  /// No description provided for @tvGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with the distinguished medical team'**
  String get tvGuestTitle;

  /// No description provided for @unableToGetCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get current location'**
  String get unableToGetCurrentLocation;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @valid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get valid;

  /// No description provided for @waitRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Wait! Remembered the password'**
  String get waitRememberPassword;

  /// No description provided for @weightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight loss and Nutrition'**
  String get weightLoss;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome {p1}'**
  String welcome(String p1);

  /// No description provided for @welcomeWithName.
  ///
  /// In en, this message translates to:
  /// **'Welcome {p1}'**
  String welcomeWithName(String p1);

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for ?'**
  String get whatAreYouLookingFor;

  /// No description provided for @whatDoesTibiAppPresents.
  ///
  /// In en, this message translates to:
  /// **'What does Tibi application offer?'**
  String get whatDoesTibiAppPresents;

  /// No description provided for @whatDoesTibiAppPresentsAnswer.
  ///
  /// In en, this message translates to:
  /// **'The \"Tibi\" app is your integrated platform for obtaining medical services quickly and easily. Through it, you can book appointments with doctors in various specialties and request medical tests such as x-rays and lab tests from the best accredited centers.'**
  String get whatDoesTibiAppPresentsAnswer;

  /// No description provided for @whatsappNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp not installed'**
  String get whatsappNotInstalled;

  /// No description provided for @whenAnyChangesOccurYouWillBeNotifiedByNotifications.
  ///
  /// In en, this message translates to:
  /// **'When any changes occur, you will be notified by notifications.'**
  String get whenAnyChangesOccurYouWillBeNotifiedByNotifications;

  /// No description provided for @whoAreWe.
  ///
  /// In en, this message translates to:
  /// **'Who are we ?'**
  String get whoAreWe;

  /// No description provided for @whoAreWeDescription.
  ///
  /// In en, this message translates to:
  /// **'We offer comprehensive medical services, including doctor appointments, examinations, and tests, to provide you with easy and fast healthcare.'**
  String get whoAreWeDescription;

  /// No description provided for @whoWeAre.
  ///
  /// In en, this message translates to:
  /// **'Who we are'**
  String get whoWeAre;

  /// No description provided for @whyChoosingUs.
  ///
  /// In en, this message translates to:
  /// **'Why us ?'**
  String get whyChoosingUs;

  /// No description provided for @whyChoosingUsDescription.
  ///
  /// In en, this message translates to:
  /// **'We provide you with a comprehensive medical experience that combines convenience, speed, and accuracy. Through our platform, you can easily book doctors, checkups, and tests, while ensuring the highest quality standards in the services provided. We are here to make healthcare easier and safer for you and your family. 💙'**
  String get whyChoosingUsDescription;

  /// No description provided for @workingTimes.
  ///
  /// In en, this message translates to:
  /// **'Working times:'**
  String get workingTimes;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsOfExperience;

  /// No description provided for @yesSure.
  ///
  /// In en, this message translates to:
  /// **'Yes, sure'**
  String get yesSure;

  /// No description provided for @youCanNoLongerReceiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to receive new notifications. Activate notifications.'**
  String get youCanNoLongerReceiveNotifications;

  /// No description provided for @youDoNotMakeReservationsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'There are no reservations made yet..!'**
  String get youDoNotMakeReservationsYetTitle;

  /// No description provided for @youHaveToLoginFirstBodyReservationsAndGetNotified.
  ///
  /// In en, this message translates to:
  /// **'Log in to schedule your appointment and stay updated with notifications'**
  String get youHaveToLoginFirstBodyReservationsAndGetNotified;

  /// No description provided for @youHaveToLoginFirstBodyReservationsAndTrackFavorites.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account so you can book your appointment, track your appointments, or add your favorite doctors'**
  String get youHaveToLoginFirstBodyReservationsAndTrackFavorites;

  /// No description provided for @youHaveToLoginFirstBodyReservationsOrFavorites.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account so you can book your appointment or add your favorite doctors.'**
  String get youHaveToLoginFirstBodyReservationsOrFavorites;

  /// No description provided for @youHaveToLoginFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'You must log in first'**
  String get youHaveToLoginFirstTitle;

  /// No description provided for @youMustLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account so you can book your appointment or add your favorite doctors'**
  String get youMustLoginBody;

  /// No description provided for @youMustLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'You must log in first'**
  String get youMustLoginTitle;

  /// No description provided for @yourComplainSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The complaint has been sent successfully.'**
  String get yourComplainSentSuccessfully;

  /// No description provided for @yourNextReservation.
  ///
  /// In en, this message translates to:
  /// **'Your Next Reservation'**
  String get yourNextReservation;

  /// No description provided for @yourReservationRequestHasBeenSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your reservation request has been sent successfully'**
  String get yourReservationRequestHasBeenSentSuccessfully;

  /// No description provided for @offer_name_1.
  ///
  /// In en, this message translates to:
  /// **'Cold peel session (one area of your choice)'**
  String get offer_name_1;

  /// No description provided for @offer_desc_1.
  ///
  /// In en, this message translates to:
  /// **'A cold peel treatment for pigmentation, evening out skin tone, and revitalizing the skin.'**
  String get offer_desc_1;

  /// No description provided for @offer_details_1.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive treatment that targets pigmentation, evens out skin tone, and restores vitality and radiance. It covers one area of ​​your choice: hands, knees, elbows, underarms, the bikini area, or the neck. Suitability for the session will be determined following an assessment by a specialist.'**
  String get offer_details_1;

  /// No description provided for @spec_dermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get spec_dermatology;

  /// No description provided for @spec_dentistry.
  ///
  /// In en, this message translates to:
  /// **'Dentistry'**
  String get spec_dentistry;

  /// No description provided for @offer_name_2.
  ///
  /// In en, this message translates to:
  /// **'A Smile That Lasts Forever'**
  String get offer_name_2;

  /// No description provided for @offer_desc_2.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive dental care and aesthetic package, featuring 6 key services at a 20% discount.'**
  String get offer_desc_2;

  /// No description provided for @offer_details_2.
  ///
  /// In en, this message translates to:
  /// **'Get our comprehensive dental care package, designed to ensure the health and beauty of your smile. The package includes a thorough examination, teeth cleaning and polishing, gum treatment, and a full range of preventive applications (services 1 through 6). This limited-time offer also features specialized consultations and ongoing follow-up care at a discounted price.'**
  String get offer_details_2;

  /// No description provided for @offer_name_3.
  ///
  /// In en, this message translates to:
  /// **'Black Friday - Laser Hair Removal (3 Sessions)'**
  String get offer_name_3;

  /// No description provided for @offer_desc_3.
  ///
  /// In en, this message translates to:
  /// **'3 sessions of Laser Hair Removal available for Small (85 SAR), Medium (95 SAR), Large (105 SAR), or X-Large (175 SAR) areas'**
  String get offer_desc_3;

  /// No description provided for @offer_details_3.
  ///
  /// In en, this message translates to:
  /// **'Package includes 3 sessions of Laser Hair Removal. Pricing tiers: Small Areas (85 SAR), Medium Areas (95 SAR), Large Areas (105 SAR), X-Large Areas (175 SAR). Terms: All sales are final. Limit 1 per customer. Sale ends 11/25/2026 or without notice based on availability.'**
  String get offer_details_3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
