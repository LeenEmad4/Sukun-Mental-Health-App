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
/// import 'l10n/app_localizations.dart';
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

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get changeLanguage;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Find Calm. One Step at a Time.'**
  String get tagline;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'A gentle space for your mental wellbeing, built with care and understanding.'**
  String get description;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your account and we\'ll send you a reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email.'**
  String get resetLinkSent;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted'**
  String get applicationSubmitted;

  /// No description provided for @applicationPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your therapist application is under review. We\'ll notify you as soon as the admin team finishes reviewing your documents and professional details.'**
  String get applicationPendingMessage;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or username.'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get enterPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// No description provided for @applicationRejectedSupport.
  ///
  /// In en, this message translates to:
  /// **'Your application was rejected. Please contact support.'**
  String get applicationRejectedSupport;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @therapist.
  ///
  /// In en, this message translates to:
  /// **'Therapist'**
  String get therapist;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get fullNameHint;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @anonymousSignup.
  ///
  /// In en, this message translates to:
  /// **'Sign up anonymously (username only)'**
  String get anonymousSignup;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @privacyText.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our privacy policy. Your information is safe with us.'**
  String get privacyText;

  /// No description provided for @submitProfile.
  ///
  /// In en, this message translates to:
  /// **'Submit Profile'**
  String get submitProfile;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @qualifications.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualifications;

  /// No description provided for @qualificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Degree, certification, license'**
  String get qualificationsHint;

  /// No description provided for @sessionRate.
  ///
  /// In en, this message translates to:
  /// **'Session Rate (JD)'**
  String get sessionRate;

  /// No description provided for @sessionRateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your hourly rate'**
  String get sessionRateHint;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio / About Me'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience and approach'**
  String get bioHint;

  /// No description provided for @uploadDocs.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents / Certificates'**
  String get uploadDocs;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get uploadFiles;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get enterFullName;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @selectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one specialty.'**
  String get selectSpecialty;

  /// No description provided for @specialtyAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get specialtyAnxiety;

  /// No description provided for @specialtyDepression.
  ///
  /// In en, this message translates to:
  /// **'Depression'**
  String get specialtyDepression;

  /// No description provided for @specialtyTrauma.
  ///
  /// In en, this message translates to:
  /// **'Trauma'**
  String get specialtyTrauma;

  /// No description provided for @specialtyStressManagement.
  ///
  /// In en, this message translates to:
  /// **'Stress Management'**
  String get specialtyStressManagement;

  /// No description provided for @specialtyFamilyTherapy.
  ///
  /// In en, this message translates to:
  /// **'Family Therapy'**
  String get specialtyFamilyTherapy;

  /// No description provided for @specialtyStressBurnout.
  ///
  /// In en, this message translates to:
  /// **'Stress & Burnout'**
  String get specialtyStressBurnout;

  /// No description provided for @specialtyCBT.
  ///
  /// In en, this message translates to:
  /// **'CBT'**
  String get specialtyCBT;

  /// No description provided for @specialtyRelationshipCounseling.
  ///
  /// In en, this message translates to:
  /// **'Relationship Counseling'**
  String get specialtyRelationshipCounseling;

  /// No description provided for @specialtyGriefLoss.
  ///
  /// In en, this message translates to:
  /// **'Grief & Loss'**
  String get specialtyGriefLoss;

  /// No description provided for @specialtyAddiction.
  ///
  /// In en, this message translates to:
  /// **'Addiction'**
  String get specialtyAddiction;

  /// No description provided for @specialtySelfEsteem.
  ///
  /// In en, this message translates to:
  /// **'Self-Esteem'**
  String get specialtySelfEsteem;

  /// No description provided for @specialtyLifeTransitions.
  ///
  /// In en, this message translates to:
  /// **'Life Transitions'**
  String get specialtyLifeTransitions;

  /// No description provided for @pricePerSession.
  ///
  /// In en, this message translates to:
  /// **'{rate} JD per session'**
  String pricePerSession(num rate);

  /// No description provided for @enterQualifications.
  ///
  /// In en, this message translates to:
  /// **'Please enter your qualifications or license number.'**
  String get enterQualifications;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @enterSessionRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter your session rate.'**
  String get enterSessionRate;

  /// No description provided for @enterBio.
  ///
  /// In en, this message translates to:
  /// **'Please add a short bio.'**
  String get enterBio;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Please log in.'**
  String get accountCreated;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @profileSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Therapist profile submitted for review'**
  String get profileSubmitted;

  /// No description provided for @filesUploaded.
  ///
  /// In en, this message translates to:
  /// **'Documents marked as uploaded for testing.'**
  String get filesUploaded;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeUser;

  /// No description provided for @supportQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like support today?'**
  String get supportQuestion;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to Chatbot'**
  String get chatbotTitle;

  /// No description provided for @chatbotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have a conversation whenever you need it, day or night'**
  String get chatbotSubtitle;

  /// No description provided for @bookSession.
  ///
  /// In en, this message translates to:
  /// **'Book Session'**
  String get bookSession;

  /// No description provided for @bookSessionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule time with a professional who understands'**
  String get bookSessionSubtitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @browseTherapists.
  ///
  /// In en, this message translates to:
  /// **'Browse Therapists'**
  String get browseTherapists;

  /// No description provided for @searchTherapists.
  ///
  /// In en, this message translates to:
  /// **'Search therapists...'**
  String get searchTherapists;

  /// No description provided for @filterTherapists.
  ///
  /// In en, this message translates to:
  /// **'Filter Therapists'**
  String get filterTherapists;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @sortByPrice.
  ///
  /// In en, this message translates to:
  /// **'Sort by Price'**
  String get sortByPrice;

  /// No description provided for @lowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Low to High'**
  String get lowToHigh;

  /// No description provided for @highToLow.
  ///
  /// In en, this message translates to:
  /// **'High to Low'**
  String get highToLow;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @noTherapistsFound.
  ///
  /// In en, this message translates to:
  /// **'No therapists found'**
  String get noTherapistsFound;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @filterComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Filter options will be added later'**
  String get filterComingSoon;

  /// No description provided for @anxietyDepression.
  ///
  /// In en, this message translates to:
  /// **'Anxiety & Depression'**
  String get anxietyDepression;

  /// No description provided for @trauma.
  ///
  /// In en, this message translates to:
  /// **'Trauma & PTSD'**
  String get trauma;

  /// No description provided for @stress.
  ///
  /// In en, this message translates to:
  /// **'Stress & Burnout'**
  String get stress;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship Therapy'**
  String get relationship;

  /// No description provided for @selfEsteem.
  ///
  /// In en, this message translates to:
  /// **'Self-Esteem & Identity'**
  String get selfEsteem;

  /// No description provided for @leilaDescription.
  ///
  /// In en, this message translates to:
  /// **'Specializing in cognitive behavioral therapy with 10+ years experience'**
  String get leilaDescription;

  /// No description provided for @leilaAbout.
  ///
  /// In en, this message translates to:
  /// **'I believe in creating a safe, non-judgmental space where you can explore your thoughts and feelings. My approach combines evidence-based techniques with compassionate listening to help you navigate life\'s challenges.'**
  String get leilaAbout;

  /// No description provided for @leilaQualification1.
  ///
  /// In en, this message translates to:
  /// **'PhD in Clinical Psychology, University of Jordan'**
  String get leilaQualification1;

  /// No description provided for @leilaQualification2.
  ///
  /// In en, this message translates to:
  /// **'10+ years of experience in mental health care'**
  String get leilaQualification2;

  /// No description provided for @leilaQualification3.
  ///
  /// In en, this message translates to:
  /// **'Certified in Cognitive Behavioral Therapy (CBT)'**
  String get leilaQualification3;

  /// No description provided for @leilaQualification4.
  ///
  /// In en, this message translates to:
  /// **'Specialized training in anxiety and depression treatment'**
  String get leilaQualification4;

  /// No description provided for @leilaAvailability.
  ///
  /// In en, this message translates to:
  /// **'Available Sunday through Thursday, 9:00 AM - 6:00 PM'**
  String get leilaAvailability;

  /// No description provided for @omarDescription.
  ///
  /// In en, this message translates to:
  /// **'Evidence-based approach to healing and recovery'**
  String get omarDescription;

  /// No description provided for @omarAbout.
  ///
  /// In en, this message translates to:
  /// **'I work with clients to process trauma at a steady, supportive pace using structured, evidence-based methods that build safety, resilience, and trust.'**
  String get omarAbout;

  /// No description provided for @omarQualification1.
  ///
  /// In en, this message translates to:
  /// **'Doctorate in Counseling Psychology'**
  String get omarQualification1;

  /// No description provided for @omarQualification2.
  ///
  /// In en, this message translates to:
  /// **'10 years of trauma-focused clinical practice'**
  String get omarQualification2;

  /// No description provided for @omarQualification3.
  ///
  /// In en, this message translates to:
  /// **'Certified in EMDR and trauma-informed care'**
  String get omarQualification3;

  /// No description provided for @omarQualification4.
  ///
  /// In en, this message translates to:
  /// **'Specialized in PTSD recovery planning'**
  String get omarQualification4;

  /// No description provided for @omarAvailability.
  ///
  /// In en, this message translates to:
  /// **'Available Sunday through Thursday, 10:00 AM - 5:00 PM'**
  String get omarAvailability;

  /// No description provided for @noorDescription.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness-based therapy for modern life challenges'**
  String get noorDescription;

  /// No description provided for @noorAbout.
  ///
  /// In en, this message translates to:
  /// **'My sessions focus on helping clients manage stress, prevent burnout, and create healthier routines through mindfulness and practical coping skills.'**
  String get noorAbout;

  /// No description provided for @noorQualification1.
  ///
  /// In en, this message translates to:
  /// **'Masters in Clinical Psychology'**
  String get noorQualification1;

  /// No description provided for @noorQualification2.
  ///
  /// In en, this message translates to:
  /// **'8+ years supporting stress and burnout recovery'**
  String get noorQualification2;

  /// No description provided for @noorQualification3.
  ///
  /// In en, this message translates to:
  /// **'Certified mindfulness-based therapy practitioner'**
  String get noorQualification3;

  /// No description provided for @noorQualification4.
  ///
  /// In en, this message translates to:
  /// **'Experience with workplace wellbeing support'**
  String get noorQualification4;

  /// No description provided for @noorAvailability.
  ///
  /// In en, this message translates to:
  /// **'Available Monday through Thursday, 11:00 AM - 7:00 PM'**
  String get noorAvailability;

  /// No description provided for @yasminDescription.
  ///
  /// In en, this message translates to:
  /// **'Supporting individuals and couples through life transitions'**
  String get yasminDescription;

  /// No description provided for @yasminAbout.
  ///
  /// In en, this message translates to:
  /// **'I help individuals and couples communicate more clearly, navigate transitions, and strengthen emotional understanding in their relationships.'**
  String get yasminAbout;

  /// No description provided for @yasminQualification1.
  ///
  /// In en, this message translates to:
  /// **'Masters in Marriage and Family Therapy'**
  String get yasminQualification1;

  /// No description provided for @yasminQualification2.
  ///
  /// In en, this message translates to:
  /// **'9+ years of relationship counseling experience'**
  String get yasminQualification2;

  /// No description provided for @yasminQualification3.
  ///
  /// In en, this message translates to:
  /// **'Certified couples communication facilitator'**
  String get yasminQualification3;

  /// No description provided for @yasminQualification4.
  ///
  /// In en, this message translates to:
  /// **'Specialized in transition and adjustment support'**
  String get yasminQualification4;

  /// No description provided for @yasminAvailability.
  ///
  /// In en, this message translates to:
  /// **'Available Sunday through Wednesday, 9:30 AM - 4:30 PM'**
  String get yasminAvailability;

  /// No description provided for @amiraDescription.
  ///
  /// In en, this message translates to:
  /// **'Compassionate guidance for personal growth and self-discovery'**
  String get amiraDescription;

  /// No description provided for @amiraAbout.
  ///
  /// In en, this message translates to:
  /// **'I provide a reflective, encouraging space for clients exploring self-worth, identity, confidence, and long-term personal growth.'**
  String get amiraAbout;

  /// No description provided for @amiraQualification1.
  ///
  /// In en, this message translates to:
  /// **'PhD in Counseling and Human Development'**
  String get amiraQualification1;

  /// No description provided for @amiraQualification2.
  ///
  /// In en, this message translates to:
  /// **'11 years of experience in personal growth therapy'**
  String get amiraQualification2;

  /// No description provided for @amiraQualification3.
  ///
  /// In en, this message translates to:
  /// **'Certified in strength-based therapeutic approaches'**
  String get amiraQualification3;

  /// No description provided for @amiraQualification4.
  ///
  /// In en, this message translates to:
  /// **'Specialized in identity and self-esteem support'**
  String get amiraQualification4;

  /// No description provided for @amiraAvailability.
  ///
  /// In en, this message translates to:
  /// **'Available Sunday through Thursday, 12:00 PM - 8:00 PM'**
  String get amiraAvailability;

  /// No description provided for @therapistDetails.
  ///
  /// In en, this message translates to:
  /// **'Therapist Details'**
  String get therapistDetails;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @contactForAvailability.
  ///
  /// In en, this message translates to:
  /// **'Contact therapist for availability'**
  String get contactForAvailability;

  /// No description provided for @sessionPrice.
  ///
  /// In en, this message translates to:
  /// **'Session Price'**
  String get sessionPrice;

  /// No description provided for @sessionPriceValue.
  ///
  /// In en, this message translates to:
  /// **'10 JD per session'**
  String get sessionPriceValue;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectedTime.
  ///
  /// In en, this message translates to:
  /// **'Selected Time'**
  String get selectedTime;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @selectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Please select a time slot'**
  String get selectTimeSlot;

  /// No description provided for @noAvailableSlots.
  ///
  /// In en, this message translates to:
  /// **'No available slots for this therapist yet.'**
  String get noAvailableSlots;

  /// No description provided for @sessionDuration.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get sessionDuration;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Sukun Chat'**
  String get chatTitle;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @tapToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to start a new chat'**
  String get tapToStartChat;

  /// No description provided for @chatSession.
  ///
  /// In en, this message translates to:
  /// **'Chat session'**
  String get chatSession;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @chatStart.
  ///
  /// In en, this message translates to:
  /// **'You can start by telling me how you feel.'**
  String get chatStart;

  /// No description provided for @chatSafe.
  ///
  /// In en, this message translates to:
  /// **'This is a safe space. Take your time.'**
  String get chatSafe;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @crisisHotlines.
  ///
  /// In en, this message translates to:
  /// **'Crisis Hotlines'**
  String get crisisHotlines;

  /// No description provided for @crisisTapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view emergency contacts'**
  String get crisisTapToView;

  /// No description provided for @crisisYouAreNotAlone.
  ///
  /// In en, this message translates to:
  /// **'You are not alone'**
  String get crisisYouAreNotAlone;

  /// No description provided for @crisisContactProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Please contact professionals immediately'**
  String get crisisContactProfessionals;

  /// No description provided for @crisisJordanEmergency.
  ///
  /// In en, this message translates to:
  /// **'JCPA Hotline'**
  String get crisisJordanEmergency;

  /// No description provided for @crisisNationalMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'National Center for Mental Health'**
  String get crisisNationalMentalHealth;

  /// No description provided for @crisisFamilyProtection.
  ///
  /// In en, this message translates to:
  /// **'Family Protection Department'**
  String get crisisFamilyProtection;

  /// No description provided for @crisisChatDisabled.
  ///
  /// In en, this message translates to:
  /// **'This chat is temporarily disabled to keep you safe. Please reach out to a professional.'**
  String get crisisChatDisabled;

  /// No description provided for @chatConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, connection error. Please try again.'**
  String get chatConnectionError;

  /// No description provided for @botReply.
  ///
  /// In en, this message translates to:
  /// **'I\'m here with you. We can take this one step at a time.'**
  String get botReply;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @upcomingSessions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Sessions'**
  String get upcomingSessions;

  /// No description provided for @completedSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed Sessions'**
  String get completedSessions;

  /// No description provided for @noUpcoming.
  ///
  /// In en, this message translates to:
  /// **'You have no upcoming sessions right now.'**
  String get noUpcoming;

  /// No description provided for @noCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions will appear here.'**
  String get noCompleted;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @appointmentCanceled.
  ///
  /// In en, this message translates to:
  /// **'appointment canceled'**
  String get appointmentCanceled;

  /// No description provided for @newlyBooked.
  ///
  /// In en, this message translates to:
  /// **'Newly booked session'**
  String get newlyBooked;

  /// No description provided for @traumaTherapist.
  ///
  /// In en, this message translates to:
  /// **'Trauma Therapist'**
  String get traumaTherapist;

  /// No description provided for @familyCounseling.
  ///
  /// In en, this message translates to:
  /// **'Family Counseling'**
  String get familyCounseling;

  /// No description provided for @stressManagement.
  ///
  /// In en, this message translates to:
  /// **'Stress Management'**
  String get stressManagement;

  /// No description provided for @dateExample1.
  ///
  /// In en, this message translates to:
  /// **'Tue, Apr 8'**
  String get dateExample1;

  /// No description provided for @dateExample2.
  ///
  /// In en, this message translates to:
  /// **'Fri, Apr 11'**
  String get dateExample2;

  /// No description provided for @dateExample3.
  ///
  /// In en, this message translates to:
  /// **'Mon, Mar 24'**
  String get dateExample3;

  /// No description provided for @dateExample4.
  ///
  /// In en, this message translates to:
  /// **'Thu, Mar 13'**
  String get dateExample4;

  /// No description provided for @price25.
  ///
  /// In en, this message translates to:
  /// **'25 JD'**
  String get price25;

  /// No description provided for @price30.
  ///
  /// In en, this message translates to:
  /// **'30 JD'**
  String get price30;

  /// No description provided for @price20.
  ///
  /// In en, this message translates to:
  /// **'20 JD'**
  String get price20;

  /// No description provided for @price22.
  ///
  /// In en, this message translates to:
  /// **'22 JD'**
  String get price22;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String durationMinutes(int minutes);

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session Notes'**
  String get sessionNotes;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @anxietyStressManagement.
  ///
  /// In en, this message translates to:
  /// **'Anxiety & Stress Management'**
  String get anxietyStressManagement;

  /// No description provided for @defaultDuration.
  ///
  /// In en, this message translates to:
  /// **'50 minutes'**
  String get defaultDuration;

  /// No description provided for @defaultSessionNotes.
  ///
  /// In en, this message translates to:
  /// **'We discussed coping mechanisms for managing work-related stress and explored breathing techniques. Made progress on identifying triggers and developed a personalized relaxation routine. Practiced mindfulness exercises and set goals for the week ahead. Continue with daily meditation practice and journaling.'**
  String get defaultSessionNotes;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @sessionSuccessfullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Your session has been\nsuccessfully booked'**
  String get sessionSuccessfullyBooked;

  /// No description provided for @goToMyAppointments.
  ///
  /// In en, this message translates to:
  /// **'Go to My Appointments'**
  String get goToMyAppointments;

  /// No description provided for @confirmationEmailNote.
  ///
  /// In en, this message translates to:
  /// **'You will also receive a confirmation email shortly'**
  String get confirmationEmailNote;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @paymentFailedTestCard.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Use test card: 4242 4242 4242 4242'**
  String get paymentFailedTestCard;

  /// No description provided for @mobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile Wallet'**
  String get mobileWallet;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @paymentsSecureEncrypted.
  ///
  /// In en, this message translates to:
  /// **'All payments are secure and encrypted.'**
  String get paymentsSecureEncrypted;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @sessionType.
  ///
  /// In en, this message translates to:
  /// **'Session Type'**
  String get sessionType;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @invalidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 16-digit card number.'**
  String get invalidCardNumber;

  /// No description provided for @invalidExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid expiry date.'**
  String get invalidExpiryDate;

  /// No description provided for @invalidCvv.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 3-digit CVV.'**
  String get invalidCvv;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// No description provided for @publicPrivacyMode.
  ///
  /// In en, this message translates to:
  /// **'Public Privacy Mode'**
  String get publicPrivacyMode;

  /// No description provided for @privacyModeDescription.
  ///
  /// In en, this message translates to:
  /// **'When enabled, your real identity is hidden from public display. Only your public username will be shown to therapists and others.'**
  String get privacyModeDescription;

  /// No description provided for @publicUsername.
  ///
  /// In en, this message translates to:
  /// **'Public Username'**
  String get publicUsername;

  /// No description provided for @realName.
  ///
  /// In en, this message translates to:
  /// **'Real Name'**
  String get realName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @myAppointmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your upcoming and completed sessions'**
  String get myAppointmentsSubtitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully!'**
  String get changesSaved;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcomeBackDr.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Dr.'**
  String get welcomeBackDr;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @noNotesProvided.
  ///
  /// In en, this message translates to:
  /// **'No notes provided'**
  String get noNotesProvided;

  /// No description provided for @sessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionLabel;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Sukun User'**
  String get anonymousUser;

  /// No description provided for @appointmentConfirmedFor.
  ///
  /// In en, this message translates to:
  /// **'Appointment confirmed for {name}'**
  String appointmentConfirmedFor(String name);

  /// No description provided for @appointmentRejectedRefund.
  ///
  /// In en, this message translates to:
  /// **'Appointment rejected. Refund issued to {name}.'**
  String appointmentRejectedRefund(String name);

  /// No description provided for @tapToJoinOrManage.
  ///
  /// In en, this message translates to:
  /// **'Tap a session to join or manage requests'**
  String get tapToJoinOrManage;

  /// No description provided for @cancelSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel session?'**
  String get cancelSessionTitle;

  /// No description provided for @cancelSessionBody.
  ///
  /// In en, this message translates to:
  /// **'This will cancel the confirmed session, refund the patient, and free the time slot. This cannot be undone.'**
  String get cancelSessionBody;

  /// No description provided for @keepSession.
  ///
  /// In en, this message translates to:
  /// **'Keep session'**
  String get keepSession;

  /// No description provided for @cancelSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel session'**
  String get cancelSessionConfirm;

  /// No description provided for @sessionCancelledRefunded.
  ///
  /// In en, this message translates to:
  /// **'Session cancelled and patient refunded.'**
  String get sessionCancelledRefunded;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @joinSession.
  ///
  /// In en, this message translates to:
  /// **'Join Session'**
  String get joinSession;

  /// No description provided for @meetingUrlNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Meeting URL not available'**
  String get meetingUrlNotAvailable;

  /// No description provided for @appointmentCancelledRefund.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled. Full refund processed!'**
  String get appointmentCancelledRefund;

  /// No description provided for @appointmentCancelledNoRefund.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled. No refund — less than 24 hours notice.'**
  String get appointmentCancelledNoRefund;

  /// No description provided for @joiningSession.
  ///
  /// In en, this message translates to:
  /// **'Joining {name}\'s session'**
  String joiningSession(String name);

  /// No description provided for @dashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTab;

  /// No description provided for @availabilityTab.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availabilityTab;

  /// No description provided for @availabilityOverview.
  ///
  /// In en, this message translates to:
  /// **'Set your hours and open slots here.'**
  String get availabilityOverview;

  /// No description provided for @requestsTab.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTab;

  /// No description provided for @requestsOverview.
  ///
  /// In en, this message translates to:
  /// **'Review incoming session requests here.'**
  String get requestsOverview;

  /// No description provided for @profileOverview.
  ///
  /// In en, this message translates to:
  /// **'Manage your therapist profile here.'**
  String get profileOverview;

  /// No description provided for @overviewAvailable.
  ///
  /// In en, this message translates to:
  /// **'Overview is available here.'**
  String get overviewAvailable;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get navAvailability;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @manageProfessionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Manage your professional information'**
  String get manageProfessionalInfo;

  /// No description provided for @profileVisibleToPatients.
  ///
  /// In en, this message translates to:
  /// **'Your profile information is visible to patients when they book sessions'**
  String get profileVisibleToPatients;

  /// No description provided for @professionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get professionalInformation;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @licenseQualifications.
  ///
  /// In en, this message translates to:
  /// **'License / Qualifications'**
  String get licenseQualifications;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// No description provided for @bioAboutMe.
  ///
  /// In en, this message translates to:
  /// **'Bio / About Me'**
  String get bioAboutMe;

  /// No description provided for @uploadUpdateDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload / Update Documents'**
  String get uploadUpdateDocuments;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @documentUploadLater.
  ///
  /// In en, this message translates to:
  /// **'Document upload will be connected to storage later'**
  String get documentUploadLater;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{years} years experience'**
  String yearsExperience(String years);

  /// No description provided for @requestsAwaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'{count} requests awaiting your response'**
  String requestsAwaitingResponse(int count);

  /// No description provided for @tapAcceptOrReject.
  ///
  /// In en, this message translates to:
  /// **'Tap Accept or Reject to manage patient requests'**
  String get tapAcceptOrReject;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get note;

  /// No description provided for @manageAvailability.
  ///
  /// In en, this message translates to:
  /// **'Manage Availability'**
  String get manageAvailability;

  /// No description provided for @addTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Time Slot'**
  String get addTimeSlot;

  /// No description provided for @slotConflict.
  ///
  /// In en, this message translates to:
  /// **'You already have a slot at this time!'**
  String get slotConflict;

  /// No description provided for @slotAdded.
  ///
  /// In en, this message translates to:
  /// **'Slot added successfully!'**
  String get slotAdded;

  /// No description provided for @availableSlots.
  ///
  /// In en, this message translates to:
  /// **'{count} available slots'**
  String availableSlots(int count);

  /// No description provided for @noSlotsAdded.
  ///
  /// In en, this message translates to:
  /// **'No slots added for this day yet.'**
  String get noSlotsAdded;

  /// No description provided for @tapSlotToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap a slot to edit or block time. Available slots can be booked by patients.'**
  String get tapSlotToEdit;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @therapistApplication.
  ///
  /// In en, this message translates to:
  /// **'Therapist Application'**
  String get therapistApplication;

  /// No description provided for @allActionsAffectAccounts.
  ///
  /// In en, this message translates to:
  /// **'All actions here affect therapist accounts and notifications will be sent automatically'**
  String get allActionsAffectAccounts;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @documentsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'{count} Documents Submitted'**
  String documentsSubmitted(int count);

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date}'**
  String submittedOn(String date);

  /// No description provided for @bioAbout.
  ///
  /// In en, this message translates to:
  /// **'Bio / About Me'**
  String get bioAbout;

  /// No description provided for @approveApplication.
  ///
  /// In en, this message translates to:
  /// **'Approve Application'**
  String get approveApplication;

  /// No description provided for @rejectApplication.
  ///
  /// In en, this message translates to:
  /// **'Reject Application'**
  String get rejectApplication;

  /// No description provided for @requestMoreInformation.
  ///
  /// In en, this message translates to:
  /// **'Request More Information'**
  String get requestMoreInformation;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @pendingApplications.
  ///
  /// In en, this message translates to:
  /// **'Pending Applications'**
  String get pendingApplications;

  /// No description provided for @approvedTherapists.
  ///
  /// In en, this message translates to:
  /// **'Approved Therapists'**
  String get approvedTherapists;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @documentsSubmittedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} documents submitted'**
  String documentsSubmittedCount(int count);

  /// No description provided for @approvedAsTherapist.
  ///
  /// In en, this message translates to:
  /// **'{name} was approved as a therapist'**
  String approvedAsTherapist(String name);

  /// No description provided for @applicationRejected.
  ///
  /// In en, this message translates to:
  /// **'{name} application was rejected'**
  String applicationRejected(String name);

  /// No description provided for @requestedMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Requested more information from {name}'**
  String requestedMoreInfo(String name);

  /// No description provided for @newApplicationFrom.
  ///
  /// In en, this message translates to:
  /// **'New therapist application from {name}'**
  String newApplicationFrom(String name);

  /// No description provided for @therapistApplicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Therapist Application'**
  String get therapistApplicationTitle;

  /// No description provided for @therapistApplicationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your application. Our team will review and get back to you.'**
  String get therapistApplicationSubtitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @documentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your license, degree, or any supporting documents.'**
  String get documentsSubtitle;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocuments;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+962 7X XXX XXXX'**
  String get phoneNumberHint;

  /// No description provided for @licenseNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. JO-PSY-12345'**
  String get licenseNumberHint;

  /// No description provided for @qualificationsHint2.
  ///
  /// In en, this message translates to:
  /// **'e.g. PhD in Clinical Psychology'**
  String get qualificationsHint2;

  /// No description provided for @pleaseUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one document'**
  String get pleaseUploadDocument;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterLicense.
  ///
  /// In en, this message translates to:
  /// **'Please enter your license number'**
  String get pleaseEnterLicense;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications yet.'**
  String get noNotifications;

  /// No description provided for @notifTitleBookingRequest.
  ///
  /// In en, this message translates to:
  /// **'New session request'**
  String get notifTitleBookingRequest;

  /// No description provided for @notifBodyBookingRequest.
  ///
  /// In en, this message translates to:
  /// **'You have a new session request awaiting your response.'**
  String get notifBodyBookingRequest;

  /// No description provided for @notifTitleBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get notifTitleBookingConfirmed;

  /// No description provided for @notifBodyBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your session has been confirmed.'**
  String get notifBodyBookingConfirmed;

  /// No description provided for @notifTitleBookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Session cancelled'**
  String get notifTitleBookingCancelled;

  /// No description provided for @notifBodyBookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your session was cancelled and a refund has been issued.'**
  String get notifBodyBookingCancelled;

  /// No description provided for @notifTitleApplicationApproved.
  ///
  /// In en, this message translates to:
  /// **'Application approved'**
  String get notifTitleApplicationApproved;

  /// No description provided for @notifBodyApplicationApproved.
  ///
  /// In en, this message translates to:
  /// **'Your application has been approved. Welcome to Sukun.'**
  String get notifBodyApplicationApproved;

  /// No description provided for @notifTitleApplicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Application not approved'**
  String get notifTitleApplicationRejected;

  /// No description provided for @notifBodyApplicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your application was not approved. Please contact support for details.'**
  String get notifBodyApplicationRejected;

  /// No description provided for @notifTitleSessionReminder.
  ///
  /// In en, this message translates to:
  /// **'Session reminder'**
  String get notifTitleSessionReminder;

  /// No description provided for @notifBodySessionReminder1hr.
  ///
  /// In en, this message translates to:
  /// **'Your session starts in about an hour.'**
  String get notifBodySessionReminder1hr;

  /// No description provided for @notifBodySessionReminder24hr.
  ///
  /// In en, this message translates to:
  /// **'You have a session tomorrow.'**
  String get notifBodySessionReminder24hr;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @noMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your conversations with therapists will appear here'**
  String get noMessagesSubtitle;

  /// No description provided for @messageTherapist.
  ///
  /// In en, this message translates to:
  /// **'Message Therapist'**
  String get messageTherapist;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;
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
