import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sukun/l10n/app_localizations.dart';

import '../../main.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = supabase.auth.currentUser?.id;
if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await supabase
          .from('notifications')
          .select('id, title, body, type, is_read, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? rawCreatedAt) {
    if (rawCreatedAt == null) return '';
    try {
      final utc = DateTime.parse(rawCreatedAt).toUtc();
      final local = utc.toLocal();
      return DateFormat('yyyy-MM-dd · HH:mm').format(local);
    } catch (e) {
      return '';
    }
  }

  String _notifTitle(String? type, AppLocalizations lang, String fallback) {
    switch (type) {
      case 'booking_request': return lang.notifTitleBookingRequest;
      case 'booking_confirmed': return lang.notifTitleBookingConfirmed;
      case 'booking_cancelled': return lang.notifTitleBookingCancelled;
      case 'application_approved': return lang.notifTitleApplicationApproved;
      case 'application_rejected': return lang.notifTitleApplicationRejected;
      case 'session_reminder_1hr':
      case 'session_reminder_24hr': return lang.notifTitleSessionReminder;
      default: return fallback;
    }
  }

  String _notifBody(String? type, AppLocalizations lang, String fallback) {
    switch (type) {
      case 'booking_request': return lang.notifBodyBookingRequest;
      case 'booking_confirmed': return lang.notifBodyBookingConfirmed;
      case 'booking_cancelled': return lang.notifBodyBookingCancelled;
      case 'application_approved': return lang.notifBodyApplicationApproved;
      case 'application_rejected': return lang.notifBodyApplicationRejected;
      case 'session_reminder_1hr': return lang.notifBodySessionReminder1hr;
      case 'session_reminder_24hr': return lang.notifBodySessionReminder24hr;
      default: return fallback;
    }
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      if (mounted) {
        setState(() {
          _notifications[index] = {
            ..._notifications[index],
            'is_read': true,
          };
        });
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textPrimary,
        title: Text(lang.notifications),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryGreen))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: _textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.noNotifications,
                        style: TextStyle(color: _textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final isUnread = item['is_read'] == false;

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: isUnread
                            ? () => _markAsRead(item['id'] as String, index)
                            : null,
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnread
                                    ? _primaryGreen
                                    : Colors.transparent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _notifTitle(item['type'] as String?, lang, (item['title'] ?? '') as String),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _notifBody(item['type'] as String?, lang, (item['body'] ?? '') as String),
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: _textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(item['created_at']?.toString()),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
                ),
    );
  }
}
