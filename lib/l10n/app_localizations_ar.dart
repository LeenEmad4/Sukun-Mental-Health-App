// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحبا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get changeLanguage => 'English';

  @override
  String get tagline => 'ابحث عن الهدوء، خطوة بخطوة.';

  @override
  String get description => 'مساحة لطيفة لرفاهك النفسي، صُممت بعناية وتفهم.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رابط إعادة التعيين.';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get resetLinkSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.';

  @override
  String get rememberPassword => 'تتذكر كلمة المرور؟';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get applicationSubmitted => 'تم إرسال الطلب';

  @override
  String get applicationPendingMessage =>
      'طلب التقديم كمعالج قيد المراجعة. سنقوم بإشعارك فور انتهاء فريق الإدارة من مراجعة المستندات والبيانات المهنية.';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get enterEmail => 'الرجاء إدخال البريد الإلكتروني أو اسم المستخدم.';

  @override
  String get enterPassword => 'الرجاء إدخال كلمة المرور.';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get applicationRejectedSupport =>
      'تم رفض طلبك. الرجاء التواصل مع الدعم.';

  @override
  String loginFailed(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get patient => 'مريض';

  @override
  String get therapist => 'معالج';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameHint => 'اسمك الكامل';

  @override
  String get createPassword => 'أنشئ كلمة مرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get anonymousSignup => 'التسجيل بشكل مجهول (اسم مستخدم فقط)';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get privacyText =>
      'بإنشاء حساب، فإنك توافق على سياسة الخصوصية الخاصة بنا. معلوماتك آمنة معنا.';

  @override
  String get submitProfile => 'إرسال الملف الشخصي';

  @override
  String get specialties => 'التخصصات';

  @override
  String get qualifications => 'المؤهلات';

  @override
  String get qualificationsHint => 'الدرجة العلمية أو الشهادة أو الترخيص';

  @override
  String get sessionRate => 'سعر الجلسة (دينار)';

  @override
  String get sessionRateHint => 'أدخل السعر لكل ساعة';

  @override
  String get bio => 'نبذة / عني';

  @override
  String get bioHint => 'أخبرنا عن خبرتك وأسلوبك';

  @override
  String get uploadDocs => 'رفع المستندات / الشهادات';

  @override
  String get uploadFiles => 'رفع الملفات';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get enterFullName => 'الرجاء إدخال الاسم الكامل.';

  @override
  String get invalidEmail => 'الرجاء إدخال بريد إلكتروني صحيح.';

  @override
  String get passwordLength =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل وتتضمن أحرفاً كبيرة وصغيرة وأرقاماً ورموزاً خاصة.';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get selectSpecialty => 'الرجاء اختيار تخصص واحد على الأقل.';

  @override
  String get specialtyAnxiety => 'القلق';

  @override
  String get specialtyDepression => 'الاكتئاب';

  @override
  String get specialtyTrauma => 'الصدمات النفسية';

  @override
  String get specialtyStressManagement => 'إدارة التوتر';

  @override
  String get specialtyFamilyTherapy => 'العلاج الأسري';

  @override
  String get specialtyStressBurnout => 'التوتر والاحتراق النفسي';

  @override
  String get specialtyCBT => 'العلاج المعرفي السلوكي';

  @override
  String get specialtyRelationshipCounseling => 'إرشاد العلاقات';

  @override
  String get specialtyGriefLoss => 'الحزن والفقدان';

  @override
  String get specialtyAddiction => 'الإدمان';

  @override
  String get specialtySelfEsteem => 'تقدير الذات';

  @override
  String get specialtyLifeTransitions => 'التحولات الحياتية';

  @override
  String pricePerSession(num rate) {
    return '$rate دينار للجلسة';
  }

  @override
  String get enterQualifications => 'الرجاء إدخال المؤهلات أو رقم الترخيص.';

  @override
  String get selected => 'المختار';

  @override
  String get enterSessionRate => 'الرجاء إدخال سعر الجلسة.';

  @override
  String get enterBio => 'الرجاء إضافة نبذة قصيرة.';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح. يرجى تسجيل الدخول.';

  @override
  String errorWithMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get profileSubmitted => 'تم إرسال الملف الشخصي للمراجعة';

  @override
  String get filesUploaded => 'تم وضع علامة على المستندات كمرفوعة للاختبار.';

  @override
  String get welcomeUser => 'مرحباً';

  @override
  String get supportQuestion => 'كيف تحب أن تحصل على الدعم اليوم؟';

  @override
  String get chatbotTitle => 'تحدث مع المساعد';

  @override
  String get chatbotSubtitle => 'ابدأ محادثة في أي وقت تحتاجه، ليلاً أو نهاراً';

  @override
  String get bookSession => 'حجز جلسة';

  @override
  String get bookSessionSubtitle => 'حدد موعدًا مع مختص يفهم احتياجاتك';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get chat => 'الدردشة';

  @override
  String get sessions => 'الجلسات';

  @override
  String get home => 'الرئيسية';

  @override
  String get browseTherapists => 'تصفح المعالجين';

  @override
  String get searchTherapists => 'ابحث عن معالج...';

  @override
  String get filterTherapists => 'تصفية المعالجين';

  @override
  String get specialty => 'التخصص';

  @override
  String get sortByPrice => 'الترتيب حسب السعر';

  @override
  String get lowToHigh => 'من الأقل إلى الأعلى';

  @override
  String get highToLow => 'من الأعلى إلى الأقل';

  @override
  String get clearFilters => 'مسح';

  @override
  String get noTherapistsFound => 'لا يوجد معالجون';

  @override
  String get viewProfile => 'عرض الملف الشخصي';

  @override
  String get filterComingSoon => 'سيتم إضافة خيارات التصفية لاحقًا';

  @override
  String get anxietyDepression => 'القلق والاكتئاب';

  @override
  String get trauma => 'الصدمة واضطراب ما بعد الصدمة';

  @override
  String get stress => 'التوتر والإرهاق';

  @override
  String get relationship => 'العلاج الأسري والعلاقات';

  @override
  String get selfEsteem => 'تقدير الذات والهوية';

  @override
  String get leilaDescription =>
      'متخصصة في العلاج السلوكي المعرفي مع خبرة تزيد عن 10 سنوات';

  @override
  String get leilaAbout =>
      'أؤمن بخلق مساحة آمنة وخالية من الأحكام حيث يمكنك استكشاف أفكارك ومشاعرك. يجمع أسلوبي بين التقنيات القائمة على الأدلة والاستماع المتعاطف لمساعدتك على تجاوز تحديات الحياة.';

  @override
  String get leilaQualification1 =>
      'دكتوراه في علم النفس السريري، الجامعة الأردنية';

  @override
  String get leilaQualification2 =>
      'أكثر من 10 سنوات من الخبرة في الرعاية النفسية';

  @override
  String get leilaQualification3 => 'معتمدة في العلاج السلوكي المعرفي';

  @override
  String get leilaQualification4 => 'تدريب متخصص في علاج القلق والاكتئاب';

  @override
  String get leilaAvailability =>
      'متاحة من الأحد إلى الخميس، 9:00 صباحًا - 6:00 مساءً';

  @override
  String get omarDescription => 'نهج قائم على الأدلة للتعافي والشفاء';

  @override
  String get omarAbout =>
      'أعمل مع العملاء لمعالجة الصدمات بوتيرة ثابتة وداعمة باستخدام أساليب منظمة قائمة على الأدلة تبني الأمان والمرونة والثقة.';

  @override
  String get omarQualification1 => 'دكتوراه في علم النفس الإرشادي';

  @override
  String get omarQualification2 =>
      '10 سنوات من الممارسة السريرية المركزة على الصدمات';

  @override
  String get omarQualification3 => 'معتمد في EMDR والرعاية الواعية بالصدمات';

  @override
  String get omarQualification4 =>
      'متخصص في خطط التعافي من اضطراب ما بعد الصدمة';

  @override
  String get omarAvailability =>
      'متاح من الأحد إلى الخميس، 10:00 صباحًا - 5:00 مساءً';

  @override
  String get noorDescription =>
      'علاج قائم على اليقظة الذهنية لتحديات الحياة الحديثة';

  @override
  String get noorAbout =>
      'تركز جلساتي على مساعدة العملاء في إدارة التوتر ومنع الإرهاق وبناء روتين أكثر صحة من خلال اليقظة الذهنية ومهارات التكيف العملية.';

  @override
  String get noorQualification1 => 'ماجستير في علم النفس السريري';

  @override
  String get noorQualification2 =>
      'أكثر من 8 سنوات في دعم التعافي من التوتر والإرهاق';

  @override
  String get noorQualification3 => 'معتمدة في العلاج القائم على اليقظة الذهنية';

  @override
  String get noorQualification4 => 'خبرة في دعم الرفاهية في بيئة العمل';

  @override
  String get noorAvailability =>
      'متاحة من الاثنين إلى الخميس، 11:00 صباحًا - 7:00 مساءً';

  @override
  String get yasminDescription => 'دعم الأفراد والأزواج خلال التحولات الحياتية';

  @override
  String get yasminAbout =>
      'أساعد الأفراد والأزواج على التواصل بشكل أوضح وتجاوز التحولات وتعزيز الفهم العاطفي في علاقاتهم.';

  @override
  String get yasminQualification1 => 'ماجستير في العلاج الأسري والزواجي';

  @override
  String get yasminQualification2 =>
      'أكثر من 9 سنوات من الخبرة في استشارات العلاقات';

  @override
  String get yasminQualification3 => 'معتمدة في تسهيل التواصل بين الأزواج';

  @override
  String get yasminQualification4 => 'متخصصة في دعم التكيف مع التحولات';

  @override
  String get yasminAvailability =>
      'متاحة من الأحد إلى الأربعاء، 9:30 صباحًا - 4:30 مساءً';

  @override
  String get amiraDescription => 'إرشاد متعاطف للنمو الشخصي واكتشاف الذات';

  @override
  String get amiraAbout =>
      'أوفر مساحة تأملية ومشجعة للعملاء الذين يستكشفون تقدير الذات والهوية والثقة والنمو الشخصي طويل المدى.';

  @override
  String get amiraQualification1 => 'دكتوراه في الإرشاد والتنمية البشرية';

  @override
  String get amiraQualification2 => '11 سنة من الخبرة في علاج النمو الشخصي';

  @override
  String get amiraQualification3 =>
      'معتمدة في الأساليب العلاجية القائمة على نقاط القوة';

  @override
  String get amiraQualification4 => 'متخصصة في دعم الهوية وتقدير الذات';

  @override
  String get amiraAvailability =>
      'متاحة من الأحد إلى الخميس، 12:00 ظهرًا - 8:00 مساءً';

  @override
  String get therapistDetails => 'تفاصيل المعالج';

  @override
  String get about => 'نبذة';

  @override
  String get availability => 'أوقات العمل';

  @override
  String get contactForAvailability =>
      'تواصل مع المعالج لمعرفة المواعيد المتاحة.';

  @override
  String get sessionPrice => 'سعر الجلسة';

  @override
  String get sessionPriceValue => '10 دنانير لكل جلسة';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get selectedTime => 'الوقت المختار';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get selectTimeSlot => 'الرجاء اختيار وقت الجلسة.';

  @override
  String get noAvailableSlots => 'لا توجد مواعيد متاحة لهذا المعالج حتى الآن.';

  @override
  String get sessionDuration => 'ساعة واحدة';

  @override
  String get online => 'أونلاين';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get at => 'في';

  @override
  String get chatTitle => 'محادثة سكون';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get noConversationsYet => 'لا توجد محادثات بعد';

  @override
  String get tapToStartChat => 'اضغط على الزر بالأسفل لبدء محادثة جديدة';

  @override
  String get chatSession => 'جلسة محادثة';

  @override
  String get yesterday => 'أمس';

  @override
  String get recent => 'مؤخراً';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوماً',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
    );
    return '$_temp0';
  }

  @override
  String get chatStart => 'يمكنك البدء بإخباري كيف تشعر.';

  @override
  String get chatSafe => 'هذه مساحة آمنة. خذ وقتك.';

  @override
  String get typeMessage => 'اكتب رسالتك...';

  @override
  String get crisisHotlines => 'خطوط الأزمات';

  @override
  String get crisisTapToView => 'اضغط لعرض جهات الاتصال الطارئة';

  @override
  String get crisisYouAreNotAlone => 'أنت لست وحدك';

  @override
  String get crisisContactProfessionals => 'يرجى التواصل مع المختصين فوراً';

  @override
  String get crisisJordanEmergency => 'خط مساعدة JCPA';

  @override
  String get crisisNationalMentalHealth => 'المركز الوطني للصحة النفسية';

  @override
  String get crisisFamilyProtection => 'إدارة حماية الأسرة';

  @override
  String get crisisChatDisabled =>
      'تم تعطيل المحادثة مؤقتاً للحفاظ على سلامتك. يرجى التواصل مع المختصين.';

  @override
  String get chatConnectionError => 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.';

  @override
  String get botReply => 'أنا هنا معك. يمكننا أن نأخذ الأمور خطوة بخطوة.';

  @override
  String get myAppointments => 'مواعيدي';

  @override
  String get upcomingSessions => 'الجلسات القادمة';

  @override
  String get completedSessions => 'الجلسات السابقة';

  @override
  String get noUpcoming => 'لا يوجد لديك جلسات قادمة حالياً.';

  @override
  String get noCompleted => 'ستظهر الجلسات السابقة هنا.';

  @override
  String get upcoming => 'قادمة';

  @override
  String get completed => 'منتهية';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get appointmentCanceled => 'تم إلغاء الموعد';

  @override
  String get newlyBooked => 'جلسة محجوزة حديثاً';

  @override
  String get traumaTherapist => 'معالج صدمات';

  @override
  String get familyCounseling => 'إرشاد أسري';

  @override
  String get stressManagement => 'إدارة التوتر';

  @override
  String get dateExample1 => 'الثلاثاء، 8 أبريل';

  @override
  String get dateExample2 => 'الجمعة، 11 أبريل';

  @override
  String get dateExample3 => 'الاثنين، 24 مارس';

  @override
  String get dateExample4 => 'الخميس، 13 مارس';

  @override
  String get price25 => '25 دينار';

  @override
  String get price30 => '30 دينار';

  @override
  String get price20 => '20 دينار';

  @override
  String get price22 => '22 دينار';

  @override
  String get sessionDetails => 'تفاصيل الجلسة';

  @override
  String get dateAndTime => 'التاريخ والوقت';

  @override
  String get duration => 'المدة';

  @override
  String durationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get sessionNotes => 'ملاحظات الجلسة';

  @override
  String get dateTime => 'التاريخ والوقت';

  @override
  String get anxietyStressManagement => 'القلق وإدارة التوتر';

  @override
  String get defaultDuration => '50 دقيقة';

  @override
  String get defaultSessionNotes =>
      'ناقشنا أساليب للتعامل مع التوتر المرتبط بالعمل واستكشفنا تقنيات التنفس. تم إحراز تقدم في تحديد المحفزات ووضع روتين استرخاء شخصي. كما تمت ممارسة تمارين اليقظة الذهنية وتحديد أهداف للأسبوع القادم مع الاستمرار على التأمل اليومي وكتابة اليوميات.';

  @override
  String get bookingConfirmed => 'تم تأكيد الحجز';

  @override
  String get sessionSuccessfullyBooked => 'تم حجز جلستك\nبنجاح';

  @override
  String get goToMyAppointments => 'الذهاب إلى مواعيدي';

  @override
  String get confirmationEmailNote =>
      'ستتلقى أيضاً بريداً إلكترونياً للتأكيد قريباً';

  @override
  String get totalPaid => 'المبلغ المدفوع';

  @override
  String get checkout => 'الدفع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get paymentFailedTestCard =>
      'فشلت عملية الدفع. استخدم بطاقة الاختبار: 4242 4242 4242 4242';

  @override
  String get mobileWallet => 'محفظة جوال';

  @override
  String get confirmPayment => 'تأكيد الدفع';

  @override
  String get paymentsSecureEncrypted => 'جميع المدفوعات آمنة ومشفرة.';

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get sessionType => 'نوع الجلسة';

  @override
  String get total => 'الإجمالي';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get cvv => 'CVV';

  @override
  String get invalidCardNumber => 'يرجى إدخال رقم بطاقة صالح من 16 رقماً.';

  @override
  String get invalidExpiryDate => 'يرجى إدخال تاريخ انتهاء صالح.';

  @override
  String get invalidCvv => 'يرجى إدخال رمز CVV صالح من 3 أرقام.';

  @override
  String get profileInformation => 'معلومات الملف الشخصي';

  @override
  String get publicPrivacyMode => 'وضع الخصوصية العامة';

  @override
  String get privacyModeDescription =>
      'عند التفعيل، تُخفى هويتك الحقيقية عن العرض العام. سيظهر اسم المستخدم العام فقط للمعالجين والآخرين.';

  @override
  String get publicUsername => 'اسم المستخدم العام';

  @override
  String get realName => 'الاسم الحقيقي';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get myAppointmentsSubtitle => 'عرض جلساتك القادمة والمكتملة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get changesSaved => 'تم حفظ التغييرات بنجاح!';

  @override
  String get language => 'اللغة';

  @override
  String get languageSubtitle => 'اختر لغتك المفضلة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get welcomeBackDr => 'مرحباً بعودتك، د.';

  @override
  String get pendingRequests => 'الطلبات المعلقة';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get noNotesProvided => 'لا توجد ملاحظات';

  @override
  String get sessionLabel => 'جلسة';

  @override
  String get anonymousUser => 'مستخدم سكون';

  @override
  String appointmentConfirmedFor(String name) {
    return 'تم تأكيد الموعد مع $name';
  }

  @override
  String appointmentRejectedRefund(String name) {
    return 'تم رفض الموعد. تمت إعادة المبلغ إلى $name.';
  }

  @override
  String get tapToJoinOrManage => 'اضغط على جلسة للانضمام أو إدارة الطلبات';

  @override
  String get cancelSessionTitle => 'إلغاء الجلسة؟';

  @override
  String get cancelSessionBody =>
      'سيؤدي هذا إلى إلغاء الجلسة المؤكدة، واسترداد المبلغ للمريض، وتحرير الموعد. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get keepSession => 'البقاء على الجلسة';

  @override
  String get cancelSessionConfirm => 'إلغاء الجلسة';

  @override
  String get sessionCancelledRefunded =>
      'تم إلغاء الجلسة واسترداد المبلغ للمريض.';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get joinSession => 'انضم للجلسة';

  @override
  String get meetingUrlNotAvailable => 'رابط الجلسة غير متوفر';

  @override
  String get appointmentCancelledRefund =>
      'تم إلغاء الموعد. تمت إعادة المبلغ بالكامل!';

  @override
  String get appointmentCancelledNoRefund =>
      'تم إلغاء الموعد. لا يوجد استرداد — الإلغاء قبل أقل من 24 ساعة.';

  @override
  String joiningSession(String name) {
    return 'جاري الانضمام لجلسة $name';
  }

  @override
  String get dashboardTab => 'الرئيسية';

  @override
  String get availabilityTab => 'الإتاحة';

  @override
  String get availabilityOverview => 'حدد ساعاتك ومواعيدك المتاحة هنا.';

  @override
  String get requestsTab => 'الطلبات';

  @override
  String get requestsOverview => 'راجع طلبات الجلسات الواردة هنا.';

  @override
  String get profileOverview => 'أدر ملفك الشخصي كمعالج هنا.';

  @override
  String get overviewAvailable => 'النظرة العامة متاحة هنا.';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navAvailability => 'الأوقات المتاحة';

  @override
  String get navRequests => 'الطلبات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get profileAndSettings => 'الملف الشخصي والإعدادات';

  @override
  String get manageProfessionalInfo => 'أدر معلوماتك المهنية';

  @override
  String get profileVisibleToPatients =>
      'معلومات ملفك الشخصي مرئية للمرضى عند حجز الجلسات';

  @override
  String get professionalInformation => 'المعلومات المهنية';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get licenseQualifications => 'الترخيص / المؤهلات';

  @override
  String get yearsOfExperience => 'سنوات الخبرة';

  @override
  String get bioAboutMe => 'نبذة عني';

  @override
  String get uploadUpdateDocuments => 'رفع / تحديث المستندات';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get documentUploadLater => 'سيتم ربط رفع المستندات بالتخزين لاحقاً';

  @override
  String yearsExperience(String years) {
    return '$years سنوات خبرة';
  }

  @override
  String requestsAwaitingResponse(int count) {
    return '$count طلبات تنتظر ردك';
  }

  @override
  String get tapAcceptOrReject => 'اضغط قبول أو رفض لإدارة طلبات المرضى';

  @override
  String get note => 'ملاحظة';

  @override
  String get manageAvailability => 'إدارة الإتاحة';

  @override
  String get addTimeSlot => 'إضافة وقت';

  @override
  String get slotConflict => 'لديك بالفعل موعد في هذا الوقت!';

  @override
  String get slotAdded => 'تمت إضافة الموعد بنجاح!';

  @override
  String availableSlots(int count) {
    return '$count أوقات متاحة';
  }

  @override
  String get noSlotsAdded => 'لم تتم إضافة أوقات لهذا اليوم بعد.';

  @override
  String get tapSlotToEdit =>
      'اضغط على وقت لتعديله أو حجبه. يمكن للمرضى حجز الأوقات المتاحة.';

  @override
  String get available => 'متاح';

  @override
  String get blocked => 'محجوب';

  @override
  String get block => 'حجب';

  @override
  String get unblock => 'إلغاء الحجب';

  @override
  String get monday => 'ن';

  @override
  String get tuesday => 'ث';

  @override
  String get wednesday => 'ر';

  @override
  String get thursday => 'خ';

  @override
  String get friday => 'ج';

  @override
  String get saturday => 'س';

  @override
  String get sunday => 'ح';

  @override
  String get therapistApplication => 'طلب معالج';

  @override
  String get allActionsAffectAccounts =>
      'جميع الإجراءات هنا تؤثر على حسابات المعالجين وسيتم إرسال الإشعارات تلقائياً';

  @override
  String get licenseNumber => 'رقم الترخيص';

  @override
  String documentsSubmitted(int count) {
    return '$count مستندات مقدمة';
  }

  @override
  String submittedOn(String date) {
    return 'تاريخ التقديم: $date';
  }

  @override
  String get bioAbout => 'نبذة عني';

  @override
  String get approveApplication => 'قبول الطلب';

  @override
  String get rejectApplication => 'رفض الطلب';

  @override
  String get requestMoreInformation => 'طلب مزيد من المعلومات';

  @override
  String get adminDashboard => 'لوحة تحكم المشرف';

  @override
  String get pendingApplications => 'الطلبات المعلقة';

  @override
  String get approvedTherapists => 'المعالجون المعتمدون';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String documentsSubmittedCount(int count) {
    return '$count مستندات مقدمة';
  }

  @override
  String approvedAsTherapist(String name) {
    return 'تم قبول $name كمعالج';
  }

  @override
  String applicationRejected(String name) {
    return 'تم رفض طلب $name';
  }

  @override
  String requestedMoreInfo(String name) {
    return 'تم طلب مزيد من المعلومات من $name';
  }

  @override
  String newApplicationFrom(String name) {
    return 'طلب معالج جديد من $name';
  }

  @override
  String get therapistApplicationTitle => 'طلب تسجيل كمعالج';

  @override
  String get therapistApplicationSubtitle =>
      'أكمل طلبك. سيقوم فريقنا بمراجعته والرد عليك.';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get documents => 'المستندات';

  @override
  String get documentsSubtitle => 'ارفع رخصتك أو شهادتك أو أي مستندات داعمة.';

  @override
  String get uploadDocuments => 'رفع المستندات';

  @override
  String get submitApplication => 'إرسال الطلب';

  @override
  String get phoneNumberHint => '07X XXX XXXX+';

  @override
  String get licenseNumberHint => 'مثال: JO-PSY-12345';

  @override
  String get qualificationsHint2 => 'مثال: دكتوراه في علم النفس السريري';

  @override
  String get pleaseUploadDocument => 'الرجاء رفع مستند واحد على الأقل';

  @override
  String get pleaseEnterPhone => 'الرجاء إدخال رقم الهاتف';

  @override
  String get pleaseEnterLicense => 'الرجاء إدخال رقم الترخيص';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات حتى الآن.';

  @override
  String get notifTitleBookingRequest => 'طلب جلسة جديد';

  @override
  String get notifBodyBookingRequest => 'لديك طلب جلسة جديد بانتظار ردك.';

  @override
  String get notifTitleBookingConfirmed => 'تم تأكيد الحجز';

  @override
  String get notifBodyBookingConfirmed => 'تم تأكيد جلستك.';

  @override
  String get notifTitleBookingCancelled => 'تم إلغاء الجلسة';

  @override
  String get notifBodyBookingCancelled => 'تم إلغاء جلستك وإعادة المبلغ إليك.';

  @override
  String get notifTitleApplicationApproved => 'تمت الموافقة على الطلب';

  @override
  String get notifBodyApplicationApproved =>
      'تمت الموافقة على طلبك. مرحباً بك في سكون.';

  @override
  String get notifTitleApplicationRejected => 'لم تتم الموافقة على الطلب';

  @override
  String get notifBodyApplicationRejected =>
      'لم تتم الموافقة على طلبك. يرجى التواصل مع الدعم لمزيد من التفاصيل.';

  @override
  String get notifTitleSessionReminder => 'تذكير بالجلسة';

  @override
  String get notifBodySessionReminder1hr => 'تبدأ جلستك خلال ساعة تقريباً.';

  @override
  String get notifBodySessionReminder24hr => 'لديك جلسة غداً.';

  @override
  String get messages => 'الرسائل';

  @override
  String get noMessages => 'لا رسائل بعد';

  @override
  String get noMessagesSubtitle => 'ستظهر هنا محادثاتك مع المعالجين';

  @override
  String get messageTherapist => 'مراسلة المعالج';

  @override
  String get typeAMessage => 'اكتب رسالة...';
}
