import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';

import '../../main.dart';
import 'therapist_bottom_nav_bar.dart';

class PendingTherapistRequest {
  const PendingTherapistRequest({
    required this.id,
    required this.patientName,
    required this.sessionType,
    required this.dateTime,
    required this.note,
    this.isPatientAnonymous = false,
  });

  final String id;
  final String patientName;
  final String sessionType;
  final String dateTime;
  final String note;
  final bool isPatientAnonymous;
}

class TherapistPendingRequestsScreen extends StatefulWidget {
  const TherapistPendingRequestsScreen({
    super.key,
    required this.isLoggedIn,
    required this.hasTherapistAccess,
    this.therapistName = 'Leila',
  });

  final bool isLoggedIn;
  final bool hasTherapistAccess;
  final String therapistName;

  @override
  State<TherapistPendingRequestsScreen> createState() =>
      _TherapistPendingRequestsScreenState();
}

class _TherapistPendingRequestsScreenState
    extends State<TherapistPendingRequestsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textMuted = Color(0xFFA6A69F);

  List<PendingTherapistRequest> _pendingRequests = [];
  bool _hasRedirected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      final therapistId = supabase.auth.currentUser?.id;
      if (therapistId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final data = await supabase
          .from('appointments')
          .select('id, scheduled_date, scheduled_time, session_notes, patient_id')
          .eq('therapist_id', therapistId)
          .eq('status', 'pending')
          .order('scheduled_date', ascending: true)
          .order('scheduled_time', ascending: true);

      final patientIds = (data as List)
          .map((a) => a['patient_id'] as String)
          .toSet()
          .toList();

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

      final List<PendingTherapistRequest> requests = [];
      for (final a in data) {
        final isAnon = patientAnonymous[a['patient_id']] ?? false;
        final id = a['patient_id'] as String;
        final patientName = isAnon
            ? (patientUsernames[id] ?? 'Anonymous')
            : (patientFullNames[id] ?? patientUsernames[id] ?? 'Patient');
        requests.add(PendingTherapistRequest(
          id: a['id'],
          patientName: patientName,
          sessionType: 'Session',
          dateTime: '${a['scheduled_date']}\n${a['scheduled_time']}',
          note: (a['session_notes'] != null && a['session_notes'].toString().isNotEmpty)
              ? a['session_notes']
              : '',
          isPatientAnonymous: patientAnonymous[a['patient_id']] ?? false,
        ));
      }

      if (!mounted) return;
      setState(() {
        _pendingRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
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

  void _handleBack() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.therapistDashboard,
      arguments: {'isLoggedIn': widget.isLoggedIn, 'hasTherapistAccess': widget.hasTherapistAccess, 'therapistName': widget.therapistName},
    );
  }

  Future<void> _handleAccept(PendingTherapistRequest request) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': 'confirmed'})
          .eq('id', request.id);

      setState(() {
        _pendingRequests = _pendingRequests
            .where((item) => item.id != request.id)
            .toList();
      });

      if (mounted) {
        final lang = AppLocalizations.of(context)!;
        final name = request.patientName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.appointmentConfirmedFor(name)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error accepting request: $e');
    }
  }

  Future<void> _handleReject(PendingTherapistRequest request) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', request.id);

      await supabase
          .from('payments')
          .update({'status': 'refunded'})
          .eq('appointment_id', request.id);

      setState(() {
        _pendingRequests = _pendingRequests
            .where((item) => item.id != request.id)
            .toList();
      });

      if (mounted) {
        final lang = AppLocalizations.of(context)!;
        final name = request.patientName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.appointmentRejectedRefund(name)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error rejecting request: $e');
    }
  }

  void _handleTabChange(TherapistNavTab tab) {
    final args = {'isLoggedIn': widget.isLoggedIn, 'hasTherapistAccess': widget.hasTherapistAccess, 'therapistName': widget.therapistName};
    switch (tab) {
      case TherapistNavTab.dashboard:
        Navigator.of(context).pushReplacementNamed(AppRoutes.therapistDashboard, arguments: args);
        return;
      case TherapistNavTab.availability:
        Navigator.of(context).pushReplacementNamed(AppRoutes.therapistAvailability, arguments: args);
        return;
      case TherapistNavTab.requests:
        return;
      case TherapistNavTab.profile:
        Navigator.of(context).pushReplacementNamed(AppRoutes.therapistProfile, arguments: args);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn || !widget.hasTherapistAccess) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: SizedBox.shrink(),
      );
    }

    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _primaryGreen,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lang.pendingRequests,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                lang.requestsAwaitingResponse(_pendingRequests.length),
                style: const TextStyle(
                  fontSize: 14,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 18),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(
                      color: Color(0xFF5E6F5C),
                    ),
                  ),
                )
              else if (_pendingRequests.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      lang.noPendingRequests,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFA6A69F),
                      ),
                    ),
                  ),
                )
              else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final request = _pendingRequests[index];
                  return _PendingRequestCard(
                    request: request,
                    onAccept: () => _handleAccept(request),
                    onReject: () => _handleReject(request),
                    acceptLabel: lang.accept,
                    rejectLabel: lang.reject,
                    noteLabel: lang.note,
                    sessionTypeText: lang.sessionLabel,
                    noteText: request.note.isEmpty ? lang.noNotesProvided : request.note,
                    patientNameText: request.patientName,
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
                  lang.tapAcceptOrReject,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: TherapistBottomNavBar(
        currentTab: TherapistNavTab.requests,
        onTabSelected: _handleTabChange,
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.acceptLabel,
    required this.rejectLabel,
    required this.noteLabel,
    required this.sessionTypeText,
    required this.noteText,
    required this.patientNameText,
  });

  final PendingTherapistRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final String acceptLabel;
  final String rejectLabel;
  final String noteLabel;
  final String sessionTypeText;
  final String noteText;
  final String patientNameText;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _rejectRed = Color(0xFFE57373);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA6A69F);
  static const Color _noteFill = Color(0xFFF2EEE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: _textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                patientNameText,
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
            sessionTypeText,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: _textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                request.dateTime,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            noteLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _noteFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              noteText,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _RequestActionButton(
                  label: acceptLabel,
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  icon: Icons.check_rounded,
                  onTap: onAccept,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RequestActionButton(
                  label: rejectLabel,
                  backgroundColor: _rejectRed,
                  foregroundColor: Colors.white,
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

class _RequestActionButton extends StatelessWidget {
  const _RequestActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
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
