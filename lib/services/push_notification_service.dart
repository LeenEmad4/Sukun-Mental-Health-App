import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:sukun/utils/perf.dart';
import '../main.dart'; // for the global `supabase` client

// Background handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The system tray displays background `notification` payloads automatically.
  debugPrint('Background message received: ${message.messageId}');
}

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'sukun_high_importance',
    'Sukun Notifications',
    description: 'Booking and session notifications',
    importance: Importance.high,
  );

  // Call ONCE at app startup (after Firebase.initializeApp), before login.
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      // Create the Android channel.
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Init local notifications (Android icon uses the app launcher icon).
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotifications.initialize(initSettings);

      // Foreground messages: build a local notification manually so a banner shows.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });

      debugPrint('Push notifications initialized');
    } catch (e) {
      debugPrint('Push init failed (non-blocking): $e');
    }
  }

  // Call this AFTER a user has logged in (we need their user id).
  static Future<void> saveTokenForUser(String userId) async {
    if (kIsWeb) return;
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Push permission status: ${settings.authorizationStatus}');

      final token = await messaging.getToken();
      debugPrint('FCM token: $token');
      if (token == null) return;

      // One row per user (keyed by user_id). Logging in updates this user's token.
      await supabase.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
      }, onConflict: 'user_id');

      debugPrint('Device token saved for user $userId');
    } catch (e) {
      debugPrint('saveTokenForUser failed (non-blocking): $e');
    }
  }

  // Sends a push notification to a specific user via the send-push Edge Function.
  // Wrapped so a failure never breaks the calling action.
  static Future<void> sendPushToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await timeAsync('push_send_call', () => http.post(
        Uri.parse(
          'https://yyxsvadjinfnrbxvczzp.supabase.co/functions/v1/send-push',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${supabase.auth.currentSession?.accessToken}',
        },
        body: jsonEncode({
          'user_id': userId,
          'title': title,
          'body': body,
        }),
      ));
      debugPrint('send-push status: ${response.statusCode}, body: ${response.body}');
    } catch (e) {
      debugPrint('sendPushToUser failed (non-blocking): $e');
    }
  }
}
