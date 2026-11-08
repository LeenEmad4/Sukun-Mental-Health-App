// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get changeLanguage => 'Arabic';

  @override
  String get tagline => 'Find Calm. One Step at a Time.';

  @override
  String get description =>
      'A gentle space for your mental wellbeing, built with care and understanding.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter the email linked to your account and we\'ll send you a reset link.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Password reset link sent to your email.';

  @override
  String get rememberPassword => 'Remember your password?';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get applicationSubmitted => 'Application Submitted';

  @override
  String get applicationPendingMessage =>
      'Your therapist application is under review. We\'ll notify you as soon as the admin team finishes reviewing your documents and professional details.';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get enterEmail => 'Please enter your email or username.';

  @override
  String get enterPassword => 'Please enter your password.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get applicationRejectedSupport =>
      'Your application was rejected. Please contact support.';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get patient => 'Patient';

  @override
  String get therapist => 'Therapist';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Your name';

  @override
  String get createPassword => 'Create a password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get anonymousSignup => 'Sign up anonymously (username only)';

  @override
  String get createAccount => 'Create Account';

  @override
  String get privacyText =>
      'By creating an account, you agree to our privacy policy. Your information is safe with us.';

  @override
  String get submitProfile => 'Submit Profile';

  @override
  String get specialties => 'Specialties';

  @override
  String get qualifications => 'Qualifications';

  @override
  String get qualificationsHint => 'Degree, certification, license';

  @override
  String get sessionRate => 'Session Rate (JD)';

  @override
  String get sessionRateHint => 'Enter your hourly rate';

  @override
  String get bio => 'Bio / About Me';

  @override
  String get bioHint => 'Tell us about your experience and approach';

  @override
  String get uploadDocs => 'Upload Documents / Certificates';

  @override
  String get uploadFiles => 'Upload Files';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get enterFullName => 'Please enter your full name.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get passwordLength => 'Password must be at least 6 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get selectSpecialty => 'Please select at least one specialty.';

  @override
  String get specialtyAnxiety => 'Anxiety';

  @override
  String get specialtyDepression => 'Depression';

  @override
  String get specialtyTrauma => 'Trauma';

  @override
  String get specialtyStressManagement => 'Stress Management';

  @override
  String get specialtyFamilyTherapy => 'Family Therapy';

  @override
  String get specialtyStressBurnout => 'Stress & Burnout';

  @override
  String get specialtyCBT => 'CBT';

  @override
  String get specialtyRelationshipCounseling => 'Relationship Counseling';

  @override
  String get specialtyGriefLoss => 'Grief & Loss';

  @override
  String get specialtyAddiction => 'Addiction';

  @override
  String get specialtySelfEsteem => 'Self-Esteem';

  @override
  String get specialtyLifeTransitions => 'Life Transitions';

  @override
  String pricePerSession(num rate) {
    return '$rate JD per session';
  }

  @override
  String get enterQualifications =>
      'Please enter your qualifications or license number.';

  @override
  String get selected => 'Selected';

  @override
  String get enterSessionRate => 'Please enter your session rate.';

  @override
  String get enterBio => 'Please add a short bio.';

  @override
  String get accountCreated => 'Account created successfully. Please log in.';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get profileSubmitted => 'Therapist profile submitted for review';

  @override
  String get filesUploaded => 'Documents marked as uploaded for testing.';

  @override
  String get welcomeUser => 'Welcome';

  @override
  String get supportQuestion => 'How would you like support today?';

  @override
  String get chatbotTitle => 'Talk to Chatbot';

  @override
  String get chatbotSubtitle =>
      'Have a conversation whenever you need it, day or night';

  @override
  String get bookSession => 'Book Session';

  @override
  String get bookSessionSubtitle =>
      'Schedule time with a professional who understands';

  @override
  String get profile => 'Profile';

  @override
  String get chat => 'Chat';

  @override
  String get sessions => 'Sessions';

  @override
  String get home => 'Home';

  @override
  String get browseTherapists => 'Browse Therapists';

  @override
  String get searchTherapists => 'Search therapists...';

  @override
  String get filterTherapists => 'Filter Therapists';

  @override
  String get specialty => 'Specialty';

  @override
  String get sortByPrice => 'Sort by Price';

  @override
  String get lowToHigh => 'Low to High';

  @override
  String get highToLow => 'High to Low';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get noTherapistsFound => 'No therapists found';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get filterComingSoon => 'Filter options will be added later';

  @override
  String get anxietyDepression => 'Anxiety & Depression';

  @override
  String get trauma => 'Trauma & PTSD';

  @override
  String get stress => 'Stress & Burnout';

  @override
  String get relationship => 'Relationship Therapy';

  @override
  String get selfEsteem => 'Self-Esteem & Identity';

  @override
  String get leilaDescription =>
      'Specializing in cognitive behavioral therapy with 10+ years experience';

  @override
  String get leilaAbout =>
      'I believe in creating a safe, non-judgmental space where you can explore your thoughts and feelings. My approach combines evidence-based techniques with compassionate listening to help you navigate life\'s challenges.';

  @override
  String get leilaQualification1 =>
      'PhD in Clinical Psychology, University of Jordan';

  @override
  String get leilaQualification2 =>
      '10+ years of experience in mental health care';

  @override
  String get leilaQualification3 =>
      'Certified in Cognitive Behavioral Therapy (CBT)';

  @override
  String get leilaQualification4 =>
      'Specialized training in anxiety and depression treatment';

  @override
  String get leilaAvailability =>
      'Available Sunday through Thursday, 9:00 AM - 6:00 PM';

  @override
  String get omarDescription =>
      'Evidence-based approach to healing and recovery';

  @override
  String get omarAbout =>
      'I work with clients to process trauma at a steady, supportive pace using structured, evidence-based methods that build safety, resilience, and trust.';

  @override
  String get omarQualification1 => 'Doctorate in Counseling Psychology';

  @override
  String get omarQualification2 =>
      '10 years of trauma-focused clinical practice';

  @override
  String get omarQualification3 => 'Certified in EMDR and trauma-informed care';

  @override
  String get omarQualification4 => 'Specialized in PTSD recovery planning';

  @override
  String get omarAvailability =>
      'Available Sunday through Thursday, 10:00 AM - 5:00 PM';

  @override
  String get noorDescription =>
      'Mindfulness-based therapy for modern life challenges';

  @override
  String get noorAbout =>
      'My sessions focus on helping clients manage stress, prevent burnout, and create healthier routines through mindfulness and practical coping skills.';

  @override
  String get noorQualification1 => 'Masters in Clinical Psychology';

  @override
  String get noorQualification2 =>
      '8+ years supporting stress and burnout recovery';

  @override
  String get noorQualification3 =>
      'Certified mindfulness-based therapy practitioner';

  @override
  String get noorQualification4 =>
      'Experience with workplace wellbeing support';

  @override
  String get noorAvailability =>
      'Available Monday through Thursday, 11:00 AM - 7:00 PM';

  @override
  String get yasminDescription =>
      'Supporting individuals and couples through life transitions';

  @override
  String get yasminAbout =>
      'I help individuals and couples communicate more clearly, navigate transitions, and strengthen emotional understanding in their relationships.';

  @override
  String get yasminQualification1 => 'Masters in Marriage and Family Therapy';

  @override
  String get yasminQualification2 =>
      '9+ years of relationship counseling experience';

  @override
  String get yasminQualification3 =>
      'Certified couples communication facilitator';

  @override
  String get yasminQualification4 =>
      'Specialized in transition and adjustment support';

  @override
  String get yasminAvailability =>
      'Available Sunday through Wednesday, 9:30 AM - 4:30 PM';

  @override
  String get amiraDescription =>
      'Compassionate guidance for personal growth and self-discovery';

  @override
  String get amiraAbout =>
      'I provide a reflective, encouraging space for clients exploring self-worth, identity, confidence, and long-term personal growth.';

  @override
  String get amiraQualification1 => 'PhD in Counseling and Human Development';

  @override
  String get amiraQualification2 =>
      '11 years of experience in personal growth therapy';

  @override
  String get amiraQualification3 =>
      'Certified in strength-based therapeutic approaches';

  @override
  String get amiraQualification4 =>
      'Specialized in identity and self-esteem support';

  @override
  String get amiraAvailability =>
      'Available Sunday through Thursday, 12:00 PM - 8:00 PM';

  @override
  String get therapistDetails => 'Therapist Details';

  @override
  String get about => 'About';

  @override
  String get availability => 'Availability';

  @override
  String get contactForAvailability => 'Contact therapist for availability';

  @override
  String get sessionPrice => 'Session Price';

  @override
  String get sessionPriceValue => '10 JD per session';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectedTime => 'Selected Time';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get selectTimeSlot => 'Please select a time slot';

  @override
  String get noAvailableSlots => 'No available slots for this therapist yet.';

  @override
  String get sessionDuration => '1 hour';

  @override
  String get online => 'Online';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get at => 'at';

  @override
  String get chatTitle => 'Sukun Chat';

  @override
  String get newChat => 'New Chat';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get tapToStartChat => 'Tap the button below to start a new chat';

  @override
  String get chatSession => 'Chat session';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get recent => 'Recent';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
    );
    return '$_temp0';
  }

  @override
  String get chatStart => 'You can start by telling me how you feel.';

  @override
  String get chatSafe => 'This is a safe space. Take your time.';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get crisisHotlines => 'Crisis Hotlines';

  @override
  String get crisisTapToView => 'Tap to view emergency contacts';

  @override
  String get crisisYouAreNotAlone => 'You are not alone';

  @override
  String get crisisContactProfessionals =>
      'Please contact professionals immediately';

  @override
  String get crisisJordanEmergency => 'JCPA Hotline';

  @override
  String get crisisNationalMentalHealth => 'National Center for Mental Health';

  @override
  String get crisisFamilyProtection => 'Family Protection Department';

  @override
  String get crisisChatDisabled =>
      'This chat is temporarily disabled to keep you safe. Please reach out to a professional.';

  @override
  String get chatConnectionError =>
      'Sorry, connection error. Please try again.';

  @override
  String get botReply =>
      'I\'m here with you. We can take this one step at a time.';

  @override
  String get myAppointments => 'My Appointments';

  @override
  String get upcomingSessions => 'Upcoming Sessions';

  @override
  String get completedSessions => 'Completed Sessions';

  @override
  String get noUpcoming => 'You have no upcoming sessions right now.';

  @override
  String get noCompleted => 'Completed sessions will appear here.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get completed => 'Completed';

  @override
  String get viewDetails => 'View Details';

  @override
  String get cancel => 'Cancel';

  @override
  String get appointmentCanceled => 'appointment canceled';

  @override
  String get newlyBooked => 'Newly booked session';

  @override
  String get traumaTherapist => 'Trauma Therapist';

  @override
  String get familyCounseling => 'Family Counseling';

  @override
  String get stressManagement => 'Stress Management';

  @override
  String get dateExample1 => 'Tue, Apr 8';

  @override
  String get dateExample2 => 'Fri, Apr 11';

  @override
  String get dateExample3 => 'Mon, Mar 24';

  @override
  String get dateExample4 => 'Thu, Mar 13';

  @override
  String get price25 => '25 JD';

  @override
  String get price30 => '30 JD';

  @override
  String get price20 => '20 JD';

  @override
  String get price22 => '22 JD';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get duration => 'Duration';

  @override
  String durationMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get sessionNotes => 'Session Notes';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get anxietyStressManagement => 'Anxiety & Stress Management';

  @override
  String get defaultDuration => '50 minutes';

  @override
  String get defaultSessionNotes =>
      'We discussed coping mechanisms for managing work-related stress and explored breathing techniques. Made progress on identifying triggers and developed a personalized relaxation routine. Practiced mindfulness exercises and set goals for the week ahead. Continue with daily meditation practice and journaling.';

  @override
  String get bookingConfirmed => 'Booking Confirmed';

  @override
  String get sessionSuccessfullyBooked =>
      'Your session has been\nsuccessfully booked';

  @override
  String get goToMyAppointments => 'Go to My Appointments';

  @override
  String get confirmationEmailNote =>
      'You will also receive a confirmation email shortly';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get checkout => 'Checkout';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get paymentFailedTestCard =>
      'Payment failed. Use test card: 4242 4242 4242 4242';

  @override
  String get mobileWallet => 'Mobile Wallet';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get paymentsSecureEncrypted =>
      'All payments are secure and encrypted.';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get sessionType => 'Session Type';

  @override
  String get total => 'Total';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get invalidCardNumber => 'Please enter a valid 16-digit card number.';

  @override
  String get invalidExpiryDate => 'Please enter a valid expiry date.';

  @override
  String get invalidCvv => 'Please enter a valid 3-digit CVV.';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get publicPrivacyMode => 'Public Privacy Mode';

  @override
  String get privacyModeDescription =>
      'When enabled, your real identity is hidden from public display. Only your public username will be shown to therapists and others.';

  @override
  String get publicUsername => 'Public Username';

  @override
  String get realName => 'Real Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get myAppointmentsSubtitle =>
      'View your upcoming and completed sessions';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logOut => 'Log Out';

  @override
  String get changesSaved => 'Changes saved successfully!';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get welcomeBackDr => 'Welcome back, Dr.';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get noNotesProvided => 'No notes provided';

  @override
  String get sessionLabel => 'Session';

  @override
  String get anonymousUser => 'Sukun User';

  @override
  String appointmentConfirmedFor(String name) {
    return 'Appointment confirmed for $name';
  }

  @override
  String appointmentRejectedRefund(String name) {
    return 'Appointment rejected. Refund issued to $name.';
  }

  @override
  String get tapToJoinOrManage => 'Tap a session to join or manage requests';

  @override
  String get cancelSessionTitle => 'Cancel session?';

  @override
  String get cancelSessionBody =>
      'This will cancel the confirmed session, refund the patient, and free the time slot. This cannot be undone.';

  @override
  String get keepSession => 'Keep session';

  @override
  String get cancelSessionConfirm => 'Cancel session';

  @override
  String get sessionCancelledRefunded =>
      'Session cancelled and patient refunded.';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get joinSession => 'Join Session';

  @override
  String get meetingUrlNotAvailable => 'Meeting URL not available';

  @override
  String get appointmentCancelledRefund =>
      'Appointment cancelled. Full refund processed!';

  @override
  String get appointmentCancelledNoRefund =>
      'Appointment cancelled. No refund — less than 24 hours notice.';

  @override
  String joiningSession(String name) {
    return 'Joining $name\'s session';
  }

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get availabilityTab => 'Availability';

  @override
  String get availabilityOverview => 'Set your hours and open slots here.';

  @override
  String get requestsTab => 'Requests';

  @override
  String get requestsOverview => 'Review incoming session requests here.';

  @override
  String get profileOverview => 'Manage your therapist profile here.';

  @override
  String get overviewAvailable => 'Overview is available here.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAvailability => 'Availability';

  @override
  String get navRequests => 'Requests';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get manageProfessionalInfo => 'Manage your professional information';

  @override
  String get profileVisibleToPatients =>
      'Your profile information is visible to patients when they book sessions';

  @override
  String get professionalInformation => 'Professional Information';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get licenseQualifications => 'License / Qualifications';

  @override
  String get yearsOfExperience => 'Years of Experience';

  @override
  String get bioAboutMe => 'Bio / About Me';

  @override
  String get uploadUpdateDocuments => 'Upload / Update Documents';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get documentUploadLater =>
      'Document upload will be connected to storage later';

  @override
  String yearsExperience(String years) {
    return '$years years experience';
  }

  @override
  String requestsAwaitingResponse(int count) {
    return '$count requests awaiting your response';
  }

  @override
  String get tapAcceptOrReject =>
      'Tap Accept or Reject to manage patient requests';

  @override
  String get note => 'NOTE';

  @override
  String get manageAvailability => 'Manage Availability';

  @override
  String get addTimeSlot => 'Add Time Slot';

  @override
  String get slotConflict => 'You already have a slot at this time!';

  @override
  String get slotAdded => 'Slot added successfully!';

  @override
  String availableSlots(int count) {
    return '$count available slots';
  }

  @override
  String get noSlotsAdded => 'No slots added for this day yet.';

  @override
  String get tapSlotToEdit =>
      'Tap a slot to edit or block time. Available slots can be booked by patients.';

  @override
  String get available => 'Available';

  @override
  String get blocked => 'Blocked';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get therapistApplication => 'Therapist Application';

  @override
  String get allActionsAffectAccounts =>
      'All actions here affect therapist accounts and notifications will be sent automatically';

  @override
  String get licenseNumber => 'License Number';

  @override
  String documentsSubmitted(int count) {
    return '$count Documents Submitted';
  }

  @override
  String submittedOn(String date) {
    return 'Submitted on $date';
  }

  @override
  String get bioAbout => 'Bio / About Me';

  @override
  String get approveApplication => 'Approve Application';

  @override
  String get rejectApplication => 'Reject Application';

  @override
  String get requestMoreInformation => 'Request More Information';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get pendingApplications => 'Pending Applications';

  @override
  String get approvedTherapists => 'Approved Therapists';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String documentsSubmittedCount(int count) {
    return '$count documents submitted';
  }

  @override
  String approvedAsTherapist(String name) {
    return '$name was approved as a therapist';
  }

  @override
  String applicationRejected(String name) {
    return '$name application was rejected';
  }

  @override
  String requestedMoreInfo(String name) {
    return 'Requested more information from $name';
  }

  @override
  String newApplicationFrom(String name) {
    return 'New therapist application from $name';
  }

  @override
  String get therapistApplicationTitle => 'Therapist Application';

  @override
  String get therapistApplicationSubtitle =>
      'Complete your application. Our team will review and get back to you.';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get documents => 'Documents';

  @override
  String get documentsSubtitle =>
      'Upload your license, degree, or any supporting documents.';

  @override
  String get uploadDocuments => 'Upload Documents';

  @override
  String get submitApplication => 'Submit Application';

  @override
  String get phoneNumberHint => '+962 7X XXX XXXX';

  @override
  String get licenseNumberHint => 'e.g. JO-PSY-12345';

  @override
  String get qualificationsHint2 => 'e.g. PhD in Clinical Psychology';

  @override
  String get pleaseUploadDocument => 'Please upload at least one document';

  @override
  String get pleaseEnterPhone => 'Please enter your phone number';

  @override
  String get pleaseEnterLicense => 'Please enter your license number';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'You have no notifications yet.';

  @override
  String get notifTitleBookingRequest => 'New session request';

  @override
  String get notifBodyBookingRequest =>
      'You have a new session request awaiting your response.';

  @override
  String get notifTitleBookingConfirmed => 'Booking confirmed';

  @override
  String get notifBodyBookingConfirmed => 'Your session has been confirmed.';

  @override
  String get notifTitleBookingCancelled => 'Session cancelled';

  @override
  String get notifBodyBookingCancelled =>
      'Your session was cancelled and a refund has been issued.';

  @override
  String get notifTitleApplicationApproved => 'Application approved';

  @override
  String get notifBodyApplicationApproved =>
      'Your application has been approved. Welcome to Sukun.';

  @override
  String get notifTitleApplicationRejected => 'Application not approved';

  @override
  String get notifBodyApplicationRejected =>
      'Your application was not approved. Please contact support for details.';

  @override
  String get notifTitleSessionReminder => 'Session reminder';

  @override
  String get notifBodySessionReminder1hr =>
      'Your session starts in about an hour.';

  @override
  String get notifBodySessionReminder24hr => 'You have a session tomorrow.';

  @override
  String get messages => 'Messages';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get noMessagesSubtitle =>
      'Your conversations with therapists will appear here';

  @override
  String get messageTherapist => 'Message Therapist';

  @override
  String get typeAMessage => 'Type a message...';
}
