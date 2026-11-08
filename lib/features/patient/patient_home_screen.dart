import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/perf.dart';

import '../../main.dart';
import '../../services/video_call_service.dart';
import 'patient_bottom_nav_bar.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _darkGreen = Color(0xFF5E6F5C);
  static const Color _lightGreen = Color(0xFFBFC5B9);
  static const Color _primaryText = Color(0xFF485047);
  static const Color _secondaryText = Color(0xFF858980);

  String _userName = '';
  bool _isLoadingName = true;
  Map<String, dynamic>? _nextAppointment;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadNextSession();
  }

  Future<void> _loadNextSession() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoadingSession = false);
        return;
      }

      final today = DateTime.now().toIso8601String().substring(0, 10);

      final results = await timeAsync('patient_home_next_session', () => supabase
          .from('appointments')
          .select('id, scheduled_date, scheduled_time, therapist_id, therapists(full_name), patient_profiles(username, is_anonymous)')
          .eq('patient_id', userId)
          .eq('status', 'confirmed')
          .gte('scheduled_date', today)
          .order('scheduled_date', ascending: true)
          .order('scheduled_time', ascending: true)
          .limit(5));

      Map<String, dynamic>? next;
      for (final a in results) {
        final date = a['scheduled_date'] as String;
        final time = a['scheduled_time'] as String;
        DateTime? dt;
        try {
          dt = DateTime.parse('$date $time:00');
        } catch (_) {}
        if (dt == null) { continue; }
        if (DateTime.now().isAfter(dt.add(const Duration(minutes: 60)))) { continue; }
        next = Map<String, dynamic>.from(a);
        break;
      }

      if (mounted) {
        setState(() {
          _nextAppointment = next;
          _isLoadingSession = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading next session: $e');
      if (mounted) { setState(() => _isLoadingSession = false); }
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
    } catch (_) { return date; }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final min = parts[1].padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$min $period';
    } catch (_) { return time; }
  }

  Widget _buildSessionCard() {
    if (_isLoadingSession || _nextAppointment == null) return const SizedBox.shrink();

    final a = _nextAppointment!;
    final therapist = a['therapists'] as Map<String, dynamic>?;
    final therapistName = therapist?['full_name'] as String? ?? 'Therapist';
    final patientProfile = a['patient_profiles'] as Map<String, dynamic>?;
    final isAnon = patientProfile?['is_anonymous'] as bool? ?? false;
    final patientName = isAnon ? 'Anonymous' : (patientProfile?['username'] as String? ?? _userName);
    final date = a['scheduled_date'] as String;
    final time = a['scheduled_time'] as String;
    final appointmentId = a['id'] as String;

    DateTime? dt;
    try { dt = DateTime.parse('$date $time:00'); } catch (_) {}
    final now = DateTime.now();
    final canJoin = dt != null &&
        now.isAfter(dt.subtract(const Duration(minutes: 15))) &&
        now.isBefore(dt.add(const Duration(minutes: 60)));
    final isNow = canJoin;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNow ? const Color(0xFFE8F2E6) : const Color(0xFFF0EDE8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isNow ? 'Session in progress' : 'Upcoming session',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isNow ? const Color(0xFF5E6F5C) : const Color(0xFF8B8E86),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            therapistName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4D514A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF8B8E86)),
              const SizedBox(width: 4),
              Text(_formatDate(date), style: const TextStyle(fontSize: 13, color: Color(0xFF8B8E86))),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8B8E86)),
              const SizedBox(width: 4),
              Text(_formatTime(time), style: const TextStyle(fontSize: 13, color: Color(0xFF8B8E86))),
            ],
          ),
          const SizedBox(height: 14),
          if (canJoin)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => VideoCallService.joinSession(
                  context: context,
                  appointmentId: appointmentId,
                  displayName: patientName,
                  isAnonymous: isAnon,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF5E6F5C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                child: const Text('Join session'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5E6F5C),
                  side: const BorderSide(color: Color(0xFFB8C4B5), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                child: const Text('View details'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadUserName() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoadingName = false);
        return;
      }

      // Try patient_profiles first (has username)
      final patientProfile = await supabase
          .from('patient_profiles')
          .select('username')
          .eq('id', userId)
          .maybeSingle();

      if (patientProfile != null && patientProfile['username'] != null) {
        if (mounted) {
          setState(() {
            _userName = patientProfile['username'];
            _isLoadingName = false;
          });
        }
        return;
      }

      // Fallback to profiles.full_name
      final profile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _userName = profile?['full_name'] ?? '';
          _isLoadingName = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
      if (mounted) setState(() => _isLoadingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${lang.welcomeUser} ${_isLoadingName ? '' : _userName}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: _primaryText,
                        height: 1.15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: _primaryText),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.patientMessages),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: _primaryText),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                lang.supportQuestion,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: _secondaryText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              _buildSessionCard(),
              _SupportCard(
                backgroundColor: _darkGreen,
                iconBackgroundColor: const Color(0xFF73806E),
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Colors.white,
                title: lang.chatbotTitle,
                subtitle: lang.chatbotSubtitle,
                titleColor: Colors.white,
                subtitleColor: const Color(0xFFDCE2D5),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.chatSessions);
                },
              ),
              const SizedBox(height: 20),
              _SupportCard(
                backgroundColor: _lightGreen,
                iconBackgroundColor: const Color(0xFFB6BCB0),
                icon: Icons.calendar_today_outlined,
                iconColor: _primaryText,
                title: lang.bookSession,
                subtitle: lang.bookSessionSubtitle,
                titleColor: _primaryText,
                subtitleColor: const Color(0xFF7D8279),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.browseTherapists);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PatientBottomNavBar(
        currentTab: PatientNavTab.home,
        onToggleLanguage: widget.onToggleLanguage,
      ),
    ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 30),
          constraints: const BoxConstraints(minHeight: 220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: titleColor,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
