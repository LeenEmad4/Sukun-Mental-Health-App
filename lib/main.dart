import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sukun/services/push_notification_service.dart';
import 'package:sukun/utils/perf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'features/auth/welcome_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/auth/create_account_screen.dart';
import 'features/auth/application_pending_screen.dart';
import 'features/auth/therapist_application.dart';

// Patient
import 'features/patient/patient_home_screen.dart';
import 'features/patient/browse_therapists_screen.dart';
import 'features/patient/therapist_details_screen.dart';
import 'features/patient/book_session_screen.dart';
import 'features/patient/payment_screen.dart';
import 'features/patient/booking_confirmation_screen.dart';
import 'features/patient/my_appointements_screen.dart';
import 'features/patient/profile_screen.dart';
import 'features/patient/chatbot_screen.dart';
import 'features/patient/chat_sessions_screen.dart';
import 'features/patient/notifications_screen.dart';

// Therapist
import 'features/therapist/therapist_dashboard_screen.dart';
import 'features/therapist/therapist_pending_requests_screen.dart';
import 'features/therapist/therapist_manage_availability_screen.dart';
import 'features/therapist/therapist_profile_screen.dart';
import 'features/therapist/session_details_screen.dart';
import 'features/admin/pending_therapist_application_screen.dart';

// Messaging
import 'features/messaging/conversations_screen.dart';
import 'features/messaging/chat_room_screen.dart';

// Admin
import 'features/admin/admin_dashboard._screen.dart';

// Common
import 'features/common/error_screen.dart';
import 'features/auth/set_new_password_screen.dart';


final supabase = Supabase.instance.client;
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final _launchWatch = Stopwatch()..start();
Future<void> main() async { // ← CHANGE void to Future<void> and add async
  WidgetsFlutterBinding.ensureInitialized(); // ← ADD

  // Firebase is only used for push notifications on mobile.
  // Skip it on web to avoid the missing-FirebaseOptions crash.
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.initialize();
  }

  await Supabase.initialize( // ← ADD
    url: 'https://yyxsvadjinfnrbxvczzp.supabase.co',
    anonKey: 'sb_publishable_PyHwI_El3R_KlsWMcOwG1A_NKzvzvVL',
  );

  runApp(const SukunApp()); // this line stays the same
}

class AppRoutes {
  // Auth
  static const String welcome        = '/';
  static const String login          = '/login';
  static const String resetPassword       = '/reset-password';
  static const String setNewPassword      = '/set-new-password';
  static const String register            = '/register';
  static const String applicationPending  = '/application-pending';

  // Patient
  static const String patientHome         = '/patient/home';
  static const String browseTherapists    = '/patient/browse-therapists';
  static const String therapistDetails    = '/patient/therapist-details';
  static const String bookSession         = '/patient/book-session';
  static const String payment             = '/patient/payment';
  static const String bookingConfirmation = '/patient/booking-confirmation';
  static const String appointments        = '/patient/appointments';
  static const String patientProfile      = '/patient/profile';
  static const String chatbot             = '/patient/chatbot';
  static const String chatSessions        = '/patient/chat-sessions';
  static const String notifications       = '/patient/notifications';
  static const String patientSessionDetails    = '/patient/session-details';
  static const String therapistSessionDetails  = '/therapist/session-details';

  // Therapist
  static const String therapistDashboard    = '/therapist/dashboard';
  static const String therapistRequests     = '/therapist/pending-requests';
  static const String therapistAvailability = '/therapist/availability';
  static const String therapistProfile      = '/therapist/profile';
  static const String therapistApplication  = '/therapist/application';

  // Admin
  static const String adminDashboard = '/admin/dashboard';

  // Messaging
  static const String patientMessages   = '/patient/messages';
  static const String therapistMessages = '/therapist/messages';
  static const String chatRoom          = '/chat-room';
}

class SukunApp extends StatefulWidget {
  const SukunApp({super.key});

  @override
  State<SukunApp> createState() => _SukunAppState();
}

class _SukunAppState extends State<SukunApp> {
  Locale _locale = const Locale('en');
  final _navigatorKey = GlobalKey<NavigatorState>();
  Widget? _home;
  StreamSubscription<AuthState>? _authSub;
  bool _launchLogged = false;

  @override
  void initState() {
    super.initState();
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        if (mounted) setState(() => _home = const SetNewPasswordScreen());
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.setNewPassword, (_) => false,
        );
      }
    });
    _resolveInitialScreen();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _resolveInitialScreen() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      if (mounted) setState(() => _home = WelcomeScreen(onToggleLanguage: _toggleLocale));
      return;
    }

    try {
      final userId = session.user.id;

      final profile = await timeAsync('resolve_initial_screen', () async {
        final profile = await supabase
            .from('profiles')
            .select('role, full_name')
            .eq('id', userId)
            .single();
        return profile;
      });

      final role = profile['role'] as String;
      Widget screen;

      if (role == 'admin') {
        screen = const AdminDashboardScreen();
      } else if (role == 'therapist') {
        final therapist = await supabase
            .from('therapists')
            .select('status')
            .eq('id', userId)
            .single();
        if (therapist['status'] == 'approved') {
          screen = TherapistDashboardScreen(
            isLoggedIn: true,
            hasTherapistAccess: true,
            therapistName: profile['full_name'] ?? 'Therapist',
          );
        } else {
          screen = const ApplicationPendingScreen();
        }
      } else {
        screen = PatientHomeScreen(onToggleLanguage: _toggleLocale);
      }

      if (mounted) setState(() => _home = screen);
    } catch (_) {
      // Session invalid or network error — fall back to welcome.
      if (mounted) setState(() => _home = WelcomeScreen(onToggleLanguage: _toggleLocale));
    }
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
    });
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    Widget page;

    switch (settings.name) {
      // ── Auth ────────────────────────────────────────────────────────────────
      case AppRoutes.welcome:
        page = WelcomeScreen(onToggleLanguage: _toggleLocale);
        break;

      case AppRoutes.login:
        page = LoginScreen(onToggleLanguage: _toggleLocale);
        break;

      case AppRoutes.resetPassword:
        page = const ResetPasswordScreen();
        break;

      case AppRoutes.setNewPassword:
        page = const SetNewPasswordScreen();
        break;

      case AppRoutes.register:
        page = const CreateAccountScreen();
        break;

      case AppRoutes.applicationPending:
        page = const ApplicationPendingScreen();
        break;

      // ── Patient ─────────────────────────────────────────────────────────────
      case AppRoutes.patientHome:
        page = PatientHomeScreen(onToggleLanguage: _toggleLocale);
        break;

      case AppRoutes.browseTherapists:
        page = const BrowseTherapistsScreen();
        break;

      case AppRoutes.therapistDetails:
        final therapist = args is Map<String, dynamic> ? args : null;
        page = TherapistDetailsScreen(therapist: therapist);
        break;

      case AppRoutes.bookSession:
        final therapist = args is Map<String, dynamic> ? args : null;
        page = BookSessionScreen(therapist: therapist);
        break;

      case AppRoutes.payment:
        final pm = args is Map ? args : const <String, dynamic>{};
        page = PaymentScreen(
          therapistName:      pm['therapistName']      as String? ?? 'Dr. Leila Ahmed',
          therapistSpecialty: pm['therapistSpecialty'] as String? ?? 'Anxiety & Depression',
          sessionPrice:       pm['sessionPrice']       as String? ?? '10 JD',
          sessionDate:        pm['sessionDate']        as String? ?? 'Today, Jan 9',
          sessionTime:        pm['sessionTime']        as String? ?? '2:00 PM',
          sessionDuration:    pm['sessionDuration']    as String? ?? '1 hour',
          totalPrice:         pm['totalPrice']         as String? ?? '10 JD',
          therapistId:        pm['therapistId']        as String? ?? '',
          slotId:             pm['slotId']             as String? ?? '',
        );
        break;

      case AppRoutes.bookingConfirmation:
        final bc = args is Map ? args : const <String, dynamic>{};
        page = BookingConfirmationScreen(
          initialTherapistName: bc['therapistName']      as String? ?? 'Dr. Leila Ahmed',
          initialSpecialty:     bc['therapistSpecialty'] as String? ?? 'Anxiety & Depression',
          initialDate:          bc['sessionDate']        as String? ?? 'Today, Jan 9',
          initialTime:          bc['sessionTime']        as String? ?? '2:00 PM',
          initialDuration:      bc['sessionDuration']    as String? ?? '1 hour',
          initialTotalPaid:     bc['totalPrice']         as String? ?? '10 JD',
        );
        break;

      case AppRoutes.appointments:
        page = const MyAppointmentsScreen();
        break;

      case AppRoutes.patientProfile:
        page = ProfileScreen(onToggleLanguage: _toggleLocale);
        break;

      case AppRoutes.chatbot:
        page = const ChatbotScreen();
        break;

      case AppRoutes.chatSessions:
        page = const ChatSessionsScreen();
        break;

      case AppRoutes.notifications:
        page = const NotificationsScreen();
        break;

      case AppRoutes.patientSessionDetails:
        final sd = args is Map ? args : const <String, dynamic>{};
        page = SessionDetailsScreen(
          initialTherapistName: sd['therapistName'] as String? ?? 'Dr. Laila Al Masri',
          initialSpecialty:     sd['specialty']     as String? ?? 'Anxiety & Stress Management',
          initialDate:          sd['date']          as String? ?? 'March 15, 2026',
          initialTime:          sd['time']          as String? ?? '2:00 PM',
          initialDuration:      sd['duration']      as String? ?? '50 minutes',
          initialSessionNotes:  sd['notes']         as String? ?? '',
          initialPatientNotes:  sd['patientNotes']  as String? ?? '',
          appointmentId:        sd['appointmentId'] as String? ?? '',
          therapistId:          sd['therapistId']   as String? ?? '',
          isCompleted:          sd['isCompleted']   as bool?   ?? false,
        );
        break;

      case AppRoutes.therapistSessionDetails:
        final tsd = args is Map ? args : const <String, dynamic>{};
        page = SessionDetailsScreen(
          initialTherapistName: tsd['therapistName'] as String? ?? '',
          initialSpecialty:     tsd['specialty']     as String? ?? '',
          initialDate:          tsd['date']          as String? ?? '',
          initialTime:          tsd['time']          as String? ?? '',
          initialDuration:      tsd['duration']      as String? ?? '',
          initialSessionNotes:  tsd['notes']         as String? ?? '',
          initialPatientNotes:  tsd['patientNotes']  as String? ?? '',
          appointmentId:        tsd['appointmentId'] as String? ?? '',
          therapistId:          tsd['therapistId']   as String? ?? '',
          isCompleted:          tsd['isCompleted']   as bool?   ?? false,
          isTherapist:          true,
        );
        break;

      // ── Therapist ────────────────────────────────────────────────────────────
      case AppRoutes.therapistDashboard:
        final map = args is Map ? args : const <String, dynamic>{};
        page = TherapistDashboardScreen(
          isLoggedIn: map['isLoggedIn'] as bool? ?? false,
          hasTherapistAccess: map['hasTherapistAccess'] as bool? ?? false,
          therapistName: map['therapistName'] as String? ?? 'Leila',
        );
        break;

      case AppRoutes.therapistRequests:
        final map = args is Map ? args : const <String, dynamic>{};
        page = TherapistPendingRequestsScreen(
          isLoggedIn: map['isLoggedIn'] as bool? ?? false,
          hasTherapistAccess: map['hasTherapistAccess'] as bool? ?? false,
          therapistName: map['therapistName'] as String? ?? 'Leila',
        );
        break;

      case AppRoutes.therapistAvailability:
        final map = args is Map ? args : const <String, dynamic>{};
        page = TherapistManageAvailabilityScreen(
          isLoggedIn: map['isLoggedIn'] as bool? ?? false,
          hasTherapistAccess: map['hasTherapistAccess'] as bool? ?? false,
          therapistName: map['therapistName'] as String? ?? 'Leila',
        );
        break;

      case AppRoutes.therapistProfile:
        final map = args is Map ? args : const <String, dynamic>{};
        page = TherapistProfileScreen(
          isLoggedIn: map['isLoggedIn'] as bool? ?? false,
          hasTherapistAccess: map['hasTherapistAccess'] as bool? ?? false,
        );
        break;

      case AppRoutes.therapistApplication:
        if (args is TherapistApplication) {
          page = PendingTherapistApplicationScreen(application: args);
        } else {
          page = WelcomeScreen(onToggleLanguage: _toggleLocale);
        }
        break;

      // ── Messaging ────────────────────────────────────────────────────────────
      case AppRoutes.patientMessages:
        page = const ConversationsScreen(isTherapist: false);
        break;

      case AppRoutes.therapistMessages:
        page = const ConversationsScreen(isTherapist: true);
        break;

      case AppRoutes.chatRoom:
        final cr = args is Map ? args : const <String, dynamic>{};
        page = ChatRoomScreen(
          conversationId:  cr['conversationId']  as String? ?? '',
          otherPersonId:   cr['otherPersonId']   as String? ?? '',
          otherPersonName: cr['otherPersonName'] as String? ?? '',
          isTherapist:     cr['isTherapist']     as bool?   ?? false,
        );
        break;

      // ── Admin ────────────────────────────────────────────────────────────────
      case AppRoutes.adminDashboard:
        page = const AdminDashboardScreen();
        break;

      default:
        page = const ErrorScreen();
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    if (_home != null && !_launchLogged) {
      _launchLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchWatch.stop();
        debugPrint('PERF | app_launch | ${_launchWatch.elapsedMilliseconds} ms');
      });
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Sukun',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        textTheme: const TextTheme().apply(
          fontFamilyFallback: ['Arial'],
        ),
      ),
      home: _home ?? const Scaffold(
        backgroundColor: Color(0xFFF4EFEA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6B7E67))),
      ),
      onGenerateRoute: _onGenerateRoute,
      navigatorObservers: [routeObserver],
    );
  }
}
