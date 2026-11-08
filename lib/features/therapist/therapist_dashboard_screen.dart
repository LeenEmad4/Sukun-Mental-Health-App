import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/services/push_notification_service.dart';
import 'package:sukun/utils/perf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../services/video_call_service.dart';
import 'therapist_bottom_nav_bar.dart';

class TherapistRequest {
  const TherapistRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.sessionType,
    required this.dateTime,
    required this.meetingUrl,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.dbStatus,
    this.sessionNotes = '',
    this.patientNotes = '',
    this.durationMinutes = 60,
    this.isPatientAnonymous = false,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String sessionType;
  final String dateTime;
  final String meetingUrl;
  final String scheduledDate;
  final String scheduledTime;
  final String dbStatus;
  final String sessionNotes;
  final String patientNotes;
  final int durationMinutes;
  final bool isPatientAnonymous;

  DateTime? get sessionDateTime {
    try {
      return DateTime.parse('$scheduledDate $scheduledTime:00');
    } catch (e) {
      return null;
    }
  }

  bool get isPast {
    final dt = sessionDateTime;
    if (dt == null) return false;
    return DateTime.now().isAfter(dt.add(const Duration(minutes: 60)));
  }

  bool get canJoinNow {
    if (dbStatus != 'confirmed') return false;
    final dt = sessionDateTime;
    if (dt == null) return false;
    final now = DateTime.now();
    final joinStart = dt.subtract(const Duration(minutes: 15));
    final joinEnd = dt.add(const Duration(minutes: 60));
    return now.isAfter(joinStart) && now.isBefore(joinEnd);
  }
}

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({
    super.key,
    required this.isLoggedIn,
    required this.hasTherapistAccess,
    this.therapistName = 'Leila',
    this.initialTab = TherapistNavTab.dashboard,
  });

  final bool isLoggedIn;
  final bool hasTherapistAccess;
  final String therapistName;
  final TherapistNavTab initialTab;

  @override
  State<TherapistDashboardScreen> createState() =>
      _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA6A69F);

  late TherapistNavTab _currentTab;
  late String _therapistName;
  List<TherapistRequest> _pendingRequests = [];
  List<TherapistRequest> _upcomingSessions = [];
  bool _hasRedirected = false;
  bool _isLoading = true;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _therapistName = widget.therapistName;
    _loadDashboardData();
    _subscribeToAppointments();
  }

  void _subscribeToAppointments() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    _realtimeChannel = supabase
        .channel('therapist-appointments-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'therapist_id',
            value: userId,
          ),
          callback: (_) { if (mounted) _loadDashboardData(); },
        )
        .subscribe();
  }

  @override
  void dispose() {
    if (_realtimeChannel != null) supabase.removeChannel(_realtimeChannel!);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final therapistId = supabase.auth.currentUser?.id;
      if (therapistId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final result = await timeAsync('therapist_dashboard_load', () async {
        // Load therapist name from therapists table
        final therapistData = await supabase
            .from('therapists')
            .select('full_name')
            .eq('id', therapistId)
            .maybeSingle();

        String? therapistName;
        if (therapistData != null && therapistData['full_name'] != null) {
          therapistName = therapistData['full_name'];
        }

        // Step 1: Get appointments
        final data = await supabase
            .from('appointments')
            .select('id, scheduled_date, scheduled_time, status, meeting_url, patient_id, session_notes, patient_notes, duration_minutes')
            .eq('therapist_id', therapistId)
            .neq('status', 'cancelled')
            .order('scheduled_date', ascending: true)
            .order('scheduled_time', ascending: true);

        // Step 2: Get unique patient IDs
        final patientIds = (data as List)
            .map((a) => a['patient_id'] as String)
            .toSet()
            .toList();

        // Step 3: Get patient display names
        Map<String, String> patientUsernames = {};
        Map<String, String> patientFullNames = {};
        Map<String, bool> patientAnonymous = {};
        if (patientIds.isNotEmpty) {
          final patientProfiles = await supabase
              .from('patient_profiles')
              .select('id, username, is_anonymous')
              .inFilter('id', patientIds);

          for (final p in patientProfiles) {
            if (p['username'] != null) {
              patientUsernames[p['id']] = p['username'];
            }
            patientAnonymous[p['id']] = p['is_anonymous'] ?? false;
          }

          final profiles = await supabase
              .from('profiles')
              .select('id, full_name')
              .inFilter('id', patientIds);

          for (final p in profiles) {
            if (p['full_name'] != null) {
              patientFullNames[p['id']] = p['full_name'];
            }
          }
        }

        final List<TherapistRequest> pending = [];
        final List<TherapistRequest> upcoming = [];

        for (final a in data) {
          final isAnon = patientAnonymous[a['patient_id']] ?? false;
          final id = a['patient_id'] as String;
          final patientName = isAnon
              ? (patientUsernames[id] ?? 'Anonymous')
              : (patientFullNames[id] ?? patientUsernames[id] ?? 'Patient');

          final request = TherapistRequest(
            id: a['id'],
            patientId: a['patient_id'] ?? '',
            patientName: patientName,
            sessionType: 'Session',
            dateTime: '${a['scheduled_date']}   ${a['scheduled_time']}',
            meetingUrl: a['meeting_url'] ?? '',
            scheduledDate: a['scheduled_date'] ?? '',
            scheduledTime: a['scheduled_time'] ?? '',
            dbStatus: a['status'] ?? 'pending',
            sessionNotes: a['session_notes'] as String? ?? '',
            patientNotes: a['patient_notes'] as String? ?? '',
            durationMinutes: a['duration_minutes'] as int? ?? 60,
            isPatientAnonymous: isAnon,
          );

          // Skip past sessions — they should be in completed
          if (request.isPast) {
            continue;
          }

          if (a['status'] == 'pending') {
            pending.add(request);
          } else if (a['status'] == 'confirmed') {
            upcoming.add(request);
          }
        }

        return (therapistName: therapistName, pending: pending, upcoming: upcoming);
      });

      if (result.therapistName != null) {
        _therapistName = result.therapistName!;
      }

      if (!mounted) return;
      setState(() {
        _pendingRequests = result.pending;
        _upcomingSessions = result.upcoming;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if ((!widget.isLoggedIn || !widget.hasTherapistAccess) && !_hasRedirected) {
      _hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
    }
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  Future<void> _handleAccept(TherapistRequest request) async {
    final lang = AppLocalizations.of(context)!;
    final name = request.patientName;
    try {
      await supabase
          .from('appointments')
          .update({'status': 'confirmed'})
          .eq('id', request.id);

      setState(() {
        _pendingRequests = _pendingRequests.where((item) => item.id != request.id).toList();
        _upcomingSessions = [..._upcomingSessions, request];
      });

      try {
        await supabase.from('notifications').insert({
          'user_id': request.patientId,
          'title': 'Booking confirmed',
          'body': 'Your session on ${request.scheduledDate} at ${request.scheduledTime} has been confirmed.',
          'type': 'booking_confirmed',
        });
      } catch (e) {
        debugPrint('Notification insert failed (non-blocking): $e');
      }

      await PushNotificationService.sendPushToUser(
        userId: request.patientId,
        title: 'Booking confirmed',
        body: 'Your session on ${request.scheduledDate} at ${request.scheduledTime} has been confirmed.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.appointmentConfirmedFor(name))),
        );
      }
    } catch (e) {
      debugPrint('Error accepting: $e');
    }
  }

  Future<void> _handleReject(TherapistRequest request) async {
    final lang = AppLocalizations.of(context)!;
    final name = request.patientName;
    try {
      await supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', request.id);

      // Refund the payment
      await supabase
          .from('payments')
          .update({'status': 'refunded'})
          .eq('appointment_id', request.id);

      setState(() {
        _pendingRequests = _pendingRequests.where((item) => item.id != request.id).toList();
      });

      try {
        await supabase.from('notifications').insert({
          'user_id': request.patientId,
          'title': 'Booking declined',
          'body': 'Your session request for ${request.scheduledDate} at ${request.scheduledTime} was declined. A refund has been issued.',
          'type': 'booking_cancelled',
        });
      } catch (e) {
        debugPrint('Notification insert failed (non-blocking): $e');
      }

      await PushNotificationService.sendPushToUser(
        userId: request.patientId,
        title: 'Booking declined',
        body: 'Your session request for ${request.scheduledDate} at ${request.scheduledTime} was declined. A refund has been issued.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.appointmentRejectedRefund(name))),
        );
      }
    } catch (e) {
      debugPrint('Error rejecting: $e');
    }
  }

  Future<void> _handleJoinSession(TherapistRequest request) async {
    await VideoCallService.joinSession(
      context: context,
      appointmentId: request.id,
      displayName: _therapistName,
      isAnonymous: false,
    );
  }

  Future<void> _handleCancelSession(TherapistRequest request) async {
    final lang = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.cancelSessionTitle),
        content: Text(lang.cancelSessionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(lang.keepSession),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(lang.cancelSessionConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', request.id);

      await supabase
          .from('payments')
          .update({'status': 'refunded'})
          .eq('appointment_id', request.id);

      await supabase
          .from('availability_slots')
          .update({'status': 'available'})
          .eq('therapist_id', supabase.auth.currentUser!.id)
          .eq('start_time', request.scheduledTime)
          .filter('slot_date', 'eq', request.scheduledDate);

      if (mounted) {
        setState(() {
          _upcomingSessions =
              _upcomingSessions.where((s) => s.id != request.id).toList();
        });
      }

      try {
        await supabase.from('notifications').insert({
          'user_id': request.patientId,
          'title': 'Session cancelled',
          'body':
              'Your therapist had to cancel the session on ${request.scheduledDate} at ${request.scheduledTime}. A full refund has been issued.',
          'type': 'booking_cancelled',
        });
      } catch (e) {
        debugPrint('Notification insert failed (non-blocking): $e');
      }

      await PushNotificationService.sendPushToUser(
        userId: request.patientId,
        title: 'Session cancelled',
        body: 'Your therapist had to cancel the session on ${request.scheduledDate} at ${request.scheduledTime}. A full refund has been issued.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.sessionCancelledRefunded)),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling session: $e');
    }
  }

  void _handleViewSessionDetails(TherapistRequest request) {
    Navigator.of(context).pushNamed(
      AppRoutes.therapistSessionDetails,
      arguments: {
        'therapistName': _therapistName,
        'specialty':     '',
        'date':          request.scheduledDate,
        'time':          request.scheduledTime,
        'duration':      '${request.durationMinutes} minutes',
        'notes':         request.sessionNotes,
        'patientNotes':  request.patientNotes,
        'appointmentId': request.id,
        'therapistId':   supabase.auth.currentUser?.id ?? '',
        'isCompleted':   false,
      },
    );
  }

  void _handleTabChange(TherapistNavTab tab) {
    final args = {
      'isLoggedIn': widget.isLoggedIn,
      'hasTherapistAccess': widget.hasTherapistAccess,
      'therapistName': _therapistName,
    };

    if (tab == TherapistNavTab.availability) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.therapistAvailability, arguments: args);
      return;
    }

    if (tab == TherapistNavTab.requests) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.therapistRequests, arguments: args);
      return;
    }

    if (tab == TherapistNavTab.profile) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.therapistProfile, arguments: args);
      return;
    }

    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    if (!widget.isLoggedIn || !widget.hasTherapistAccess) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(lang),
              const SizedBox(height: 10),
              Text(
                '${lang.welcomeBackDr} $_therapistName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              if (_currentTab == TherapistNavTab.dashboard) ...[
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: CircularProgressIndicator(color: Color(0xFF5E6F5C)),
                    ),
                  )
                else
                  _buildDashboardContent(lang),
              ] else ...[
                _buildPlaceholderTabContent(lang),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: TherapistBottomNavBar(
        currentTab: _currentTab,
        onTabSelected: _handleTabChange,
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations lang) {
    return Row(
      children: [
        Expanded(
          child: Text(
            lang.dashboard,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _primaryGreen,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.therapistMessages),
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: _primaryGreen,
            size: 22,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: _primaryGreen,
            size: 22,
          ),
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(
            Icons.logout_rounded,
            color: _primaryGreen,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(AppLocalizations lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: lang.pendingRequests,
                count: '${_pendingRequests.length}',
                icon: Icons.notifications_none_rounded,
                iconTint: const Color(0xFFF0CDB3),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _OverviewCard(
                title: lang.upcomingSessions,
                count: '${_upcomingSessions.length}',
                icon: Icons.calendar_today_outlined,
                iconTint: const Color(0xFFC7D2C4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          lang.pendingRequests,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final request = _pendingRequests[index];
            return _RequestCard(
              patientName: request.patientName,
              sessionType: lang.sessionLabel,
              dateTime: request.dateTime,
              acceptLabel: lang.accept,
              rejectLabel: lang.reject,
              onAccept: () => _handleAccept(request),
              onReject: () => _handleReject(request),
              onNotes: () => _handleViewSessionDetails(request),
            );
          },
        ),
        const SizedBox(height: 22),
        Text(
          lang.upcomingSessions,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _upcomingSessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final session = _upcomingSessions[index];
            return _UpcomingSessionCard(
              patientName: session.isPatientAnonymous ? lang.anonymousUser : session.patientName,
              sessionType: lang.sessionLabel,
              dateTime: session.dateTime,
              joinLabel: lang.joinSession,
              cancelLabel: lang.cancelSessionConfirm,
              onJoinSession: session.canJoinNow
                  ? () => _handleJoinSession(session)
                  : null,
              onCancelSession: () => _handleCancelSession(session),
              onNotes: () => _handleViewSessionDetails(session),
            );
          },
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E1D8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            lang.tapToJoinOrManage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: _textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTabContent(AppLocalizations lang) {
    late final String title;
    late final String subtitle;

    switch (_currentTab) {
      case TherapistNavTab.dashboard:
        title = lang.dashboardTab;
        subtitle = lang.overviewAvailable;
        break;
      case TherapistNavTab.availability:
        title = lang.availabilityTab;
        subtitle = lang.availabilityOverview;
        break;
      case TherapistNavTab.requests:
        title = lang.requestsTab;
        subtitle = lang.requestsOverview;
        break;
      case TherapistNavTab.profile:
        title = lang.profile;
        subtitle = lang.profileOverview;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconTint,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color iconTint;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              height: 1.25,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.patientName,
    required this.sessionType,
    required this.dateTime,
    required this.acceptLabel,
    required this.rejectLabel,
    required this.onAccept,
    required this.onReject,
    required this.onNotes,
  });

  final String patientName;
  final String sessionType;
  final String dateTime;
  final String acceptLabel;
  final String rejectLabel;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onNotes;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _rejectRed = Color(0xFFE57373);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: _textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                patientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sessionType,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: _textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onNotes,
              style: TextButton.styleFrom(
                foregroundColor: _primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              icon: const Icon(Icons.notes_rounded, size: 16),
              label: const Text('Notes', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _TherapistActionButton(
                  label: acceptLabel,
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  icon: Icons.check_rounded,
                  onTap: onAccept,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TherapistActionButton(
                  label: rejectLabel,
                  backgroundColor: Colors.white,
                  foregroundColor: _rejectRed,
                  borderColor: _rejectRed,
                  icon: Icons.close_rounded,
                  onTap: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({
    required this.patientName,
    required this.sessionType,
    required this.dateTime,
    required this.joinLabel,
    required this.cancelLabel,
    required this.onJoinSession,
    required this.onCancelSession,
    required this.onNotes,
  });

  final String patientName;
  final String sessionType;
  final String dateTime;
  final String joinLabel;
  final String cancelLabel;
  final VoidCallback? onJoinSession;
  final VoidCallback onCancelSession;
  final VoidCallback onNotes;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: _textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                patientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sessionType,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: _textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (onJoinSession != null)
            SizedBox(
              width: double.infinity,
              child: _TherapistActionButton(
                label: joinLabel,
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                icon: Icons.video_call_outlined,
                onTap: onJoinSession!,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onNotes,
                style: TextButton.styleFrom(
                  foregroundColor: _primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                icon: const Icon(Icons.notes_rounded, size: 16),
                label: const Text('Notes', style: TextStyle(fontSize: 13)),
              ),
              TextButton(
                onPressed: onCancelSession,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(cancelLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TherapistActionButton extends StatelessWidget {
  const _TherapistActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final hasBorder = borderColor != null;

    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: hasBorder
              ? BorderSide(color: borderColor!, width: 1.2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(label),
      ),
    );
  }
}
