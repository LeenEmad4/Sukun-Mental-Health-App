import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:sukun/utils/specialty_labels.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../services/video_call_service.dart';
import '../messaging/chat_room_screen.dart';
import 'patient_bottom_nav_bar.dart';

enum AppointmentStatus {
  upcoming,
  completed,
}

class Appointment {
  const Appointment({
    required this.id,
    required this.therapistName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    this.duration = '60 minutes',
    this.sessionNotes = '',
    this.patientNotes = '',
    this.isNewlyBooked = false,
    this.meetingUrl = '',
    this.therapistId = '',
    this.isAnonymous = false,
    this.patientName = '',
    this.dbStatus = '',
  });

  final String id;
  final String therapistName;
  final String specialty;
  final String date;
  final String time;
  final String price;
  final AppointmentStatus status;
  final String duration;
  final String sessionNotes;
  final String patientNotes;
  final bool isNewlyBooked;
  final String meetingUrl;
  final String therapistId;
  final bool isAnonymous;
  final String patientName;
  final String dbStatus;

  // Returns DateTime of when session starts
  DateTime? get sessionDateTime {
    try {
      return DateTime.parse('$date $time:00');
    } catch (e) {
      return null;
    }
  }

  // Session is in the past (more than 60 minutes after start time)
  bool get isPast {
    final dt = sessionDateTime;
    if (dt == null) return false;
    return DateTime.now().isAfter(dt.add(const Duration(minutes: 60)));
  }

  // Can join 15 minutes before until end of session
  bool get canJoinNow {
    if (dbStatus != 'confirmed') return false;
    final dt = sessionDateTime;
    if (dt == null) return false;
    final now = DateTime.now();
    final joinWindowStart = dt.subtract(const Duration(minutes: 15));
    final joinWindowEnd = dt.add(const Duration(minutes: 60));
    return now.isAfter(joinWindowStart) && now.isBefore(joinWindowEnd);
  }

  // Time until session starts (for display)
  String get timeUntilSession {
    final dt = sessionDateTime;
    if (dt == null) return '';
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Past';
    if (diff.inMinutes < 60) return 'in ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'in ${diff.inHours} hours';
    return 'in ${diff.inDays} days';
  }
}

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> with RouteAware {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _dividerColor = Color(0xFFE9E1D8);

  late List<Appointment> _upcomingAppointments;
  late List<Appointment> _completedAppointments;
  bool _isLoading = true;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _upcomingAppointments = [];
    _completedAppointments = [];
    _isLoading = true;
    _loadAppointments();
    _subscribeToAppointments();
  }

  void _subscribeToAppointments() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    _realtimeChannel = supabase
        .channel('patient-appointments-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: userId,
          ),
          callback: (_) { if (mounted) _loadAppointments(); },
        )
        .subscribe();
  }

  Future<void> _loadAppointments() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final patientId = supabase.auth.currentUser!.id;

      final data = await supabase
          .from('appointments')
          .select('id, scheduled_date, scheduled_time, status, price, duration_minutes, session_notes, patient_notes, meeting_url, therapist_id, therapists(full_name, specialties), patient_profiles(username, is_anonymous)')
          .eq('patient_id', patientId)
          .neq('status', 'cancelled')
          .order('scheduled_date', ascending: true);

      final List<Appointment> upcoming = [];
      final List<Appointment> completed = [];

      for (final a in data) {
        final therapist = a['therapists'] as Map<String, dynamic>?;
        final specialties = therapist?['specialties'] as List?;

        final dbStatus = a['status'] as String? ?? 'pending';

        final appointment = Appointment(
          id: a['id'],
          therapistName: therapist?['full_name'] ?? 'Unknown',
          specialty: specialties != null ? specialties.join(', ') : '',
          date: a['scheduled_date'] ?? '',
          time: a['scheduled_time'] ?? '',
          price: '${a['price'] ?? 0} JD',
          status: AppointmentStatus.upcoming,
          duration: '${a['duration_minutes'] ?? 60} minutes',
          sessionNotes: a['session_notes'] ?? '',
          patientNotes: a['patient_notes'] ?? '',
          meetingUrl: a['meeting_url'] ?? '',
          therapistId: a['therapist_id'] ?? '',
          isAnonymous: a['patient_profiles']?['is_anonymous'] ?? false,
          patientName: a['patient_profiles']?['username'] ?? '',
          dbStatus: dbStatus,
        );

        // Determine real status:
        // - If db says completed → completed
        // - If session is in the past → completed (auto)
        // - Otherwise → upcoming
        if (dbStatus == 'completed' || appointment.isPast) {
          completed.add(Appointment(
            id: appointment.id,
            therapistName: appointment.therapistName,
            specialty: appointment.specialty,
            date: appointment.date,
            time: appointment.time,
            price: appointment.price,
            status: AppointmentStatus.completed,
            duration: appointment.duration,
            sessionNotes: appointment.sessionNotes,
            patientNotes: appointment.patientNotes,
            meetingUrl: appointment.meetingUrl,
            therapistId: appointment.therapistId,
            isAnonymous: appointment.isAnonymous,
            patientName: appointment.patientName,
            dbStatus: dbStatus,
          ));
        } else {
          upcoming.add(appointment);
        }
      }

      if (!mounted) return;
      setState(() {
        _upcomingAppointments = upcoming;
        _completedAppointments = completed;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (_realtimeChannel != null) supabase.removeChannel(_realtimeChannel!);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadAppointments();
  }

  void _handleViewDetails(Appointment appointment) {
    Navigator.of(context).pushNamed(
      AppRoutes.patientSessionDetails,
      arguments: {
        'therapistName': appointment.therapistName,
        'specialty':     appointment.specialty,
        'date':          appointment.date,
        'time':          appointment.time,
        'duration':      appointment.duration,
        'notes':         appointment.sessionNotes,
        'patientNotes':  appointment.patientNotes,
        'appointmentId': appointment.id,
        'therapistId':   appointment.therapistId,
        'isCompleted':   appointment.status == AppointmentStatus.completed,
      },
    );
  }

  Future<void> _handleJoin(Appointment appointment) async {
    await VideoCallService.joinSession(
      context: context,
      appointmentId: appointment.id,
      displayName: appointment.patientName,
      isAnonymous: appointment.isAnonymous,
    );
  }

  Future<void> _handleCancel(Appointment appointment) async {
    final lang = AppLocalizations.of(context)!;
    try {
      // Check if cancellation is within 24 hours of session
      final sessionDateTime = DateTime.parse(
        '${appointment.date} ${appointment.time}:00',
      );
      final hoursUntilSession = sessionDateTime
          .difference(DateTime.now())
          .inHours;

      final isEligibleForRefund = hoursUntilSession >= 24;

      // Cancel appointment
      await supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointment.id);

      // Handle refund
      if (isEligibleForRefund) {
        final patientId = supabase.auth.currentUser!.id;
        await supabase
            .from('payments')
            .update({'status': 'refunded'})
            .eq('appointment_id', appointment.id)
            .eq('patient_id', patientId);
      }

      // Free up the slot
      await supabase
          .from('availability_slots')
          .update({'status': 'available'})
          .eq('therapist_id', appointment.therapistId)
          .eq('start_time', appointment.time)
          .filter('slot_date', 'eq', appointment.date);

      if (!mounted) return;
      await _loadAppointments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEligibleForRefund
                ? lang.appointmentCancelledRefund
                : lang.appointmentCancelledNoRefund,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('Error cancelling: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    }
  }

  Future<void> _showReviewSheet(Appointment appointment) async {
    final patientId = supabase.auth.currentUser!.id;

    // Gate 1: require at least 3 completed sessions with this therapist
    final sessionsWithTherapist = _completedAppointments
        .where((a) => a.therapistId == appointment.therapistId)
        .length;
    if (sessionsWithTherapist < 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need at least 3 completed sessions with ${appointment.therapistName} to leave a review. You have $sessionsWithTherapist so far.',
          ),
        ),
      );
      return;
    }

    // Gate 2: one review per therapist (not per session)
    try {
      final existing = await supabase
          .from('reviews')
          .select('id')
          .eq('patient_id', patientId)
          .eq('therapist_id', appointment.therapistId)
          .maybeSingle();
      if (!mounted) return;
      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have already reviewed ${appointment.therapistName}.'),
          ),
        );
        return;
      }
    } catch (_) {}
    if (!mounted) return;

    int selectedRating = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4EFEA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leave a Review',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4D514A)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appointment.therapistName,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8D8E87)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedRating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 40,
                            color: const Color(0xFF5E6F5C),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience (optional)',
                      hintStyle: const TextStyle(
                          color: Color(0xFFA6A69F), fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSubmitting || selectedRating == 0
                          ? null
                          : () async {
                              setSheetState(() => isSubmitting = true);
                              try {
                                await supabase.from('reviews').insert({
                                  'therapist_id': appointment.therapistId,
                                  'patient_id': patientId,
                                  'rating': selectedRating,
                                  'comment': commentController.text.trim().isEmpty
                                      ? null
                                      : commentController.text.trim(),
                                });
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                        content: Text('Review submitted. Thank you!')),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isSubmitting = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Failed to submit review. Please try again.')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF5E6F5C),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFBFC5B9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Review'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    commentController.dispose();
  }

  Future<void> _openOrCreateConversation(Appointment appointment) async {
    final patientId = supabase.auth.currentUser?.id;
    if (patientId == null || appointment.therapistId.isEmpty) return;

    try {
      // Find existing conversation
      final existing = await supabase
          .from('conversations')
          .select('id')
          .eq('patient_id', patientId)
          .eq('therapist_id', appointment.therapistId)
          .maybeSingle();

      String conversationId;
      if (existing != null) {
        conversationId = existing['id'] as String;
      } else {
        // Create new conversation
        final created = await supabase
            .from('conversations')
            .insert({
              'patient_id': patientId,
              'therapist_id': appointment.therapistId,
            })
            .select('id')
            .single();
        conversationId = created['id'] as String;
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            conversationId: conversationId,
            otherPersonId: appointment.therapistId,
            otherPersonName: appointment.therapistName,
            isTherapist: false,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      color: const Color(0xFF5E6F5C),
      child: Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (Navigator.of(context).canPop())
                            Align(
                              alignment: Directionality.of(context) == TextDirection.rtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.of(context).maybePop(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                  color: _textPrimary,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          Center(
                            child: Text(
                              lang.myAppointments,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: _textPrimary,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      color: _dividerColor,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(lang.upcomingSessions),
                    const SizedBox(height: 14),
                    _buildAppointmentsList(
                      appointments: _upcomingAppointments,
                      emptyMessage: lang.noUpcoming,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle(lang.completedSessions),
                    const SizedBox(height: 14),
                    _buildAppointmentsList(
                      appointments: _completedAppointments,
                      emptyMessage: lang.noCompleted,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const PatientBottomNavBar(
        currentTab: PatientNavTab.sessions,
      ),
    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildAppointmentsList({
    required List<Appointment> appointments,
    required String emptyMessage,
  }) {
    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: _textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == appointments.length - 1 ? 0 : 16),
          child: _AppointmentCard(
            appointment: appointment,
            onViewDetails: () => _handleViewDetails(appointment),
            onCancel: appointment.status == AppointmentStatus.upcoming
                ? () => _handleCancel(appointment)
                : null,
            onJoin: appointment.canJoinNow
                ? () => _handleJoin(appointment)
                : null,
            onLeaveReview: appointment.status == AppointmentStatus.completed
                ? () => _showReviewSheet(appointment)
                : null,
            onMessageTherapist: appointment.therapistId.isNotEmpty
                ? () => _openOrCreateConversation(appointment)
                : null,
          ),
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onViewDetails,
    this.onCancel,
    this.onJoin,
    this.onLeaveReview,
    this.onMessageTherapist,
  });

  final Appointment appointment;
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onJoin;
  final VoidCallback? onLeaveReview;
  final VoidCallback? onMessageTherapist;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA09F97);
  static const Color _upcomingBadge = Color(0xFFC7D3C3);
  static const Color _completedBadge = Color(0xFFE3E0DA);
  static const Color _completedText = Color(0xFF7D7E78);
  static const Color _cancelFill = Color(0xFFF4EFEA);
  static const Color _highlightBorder = Color(0xFFC7CEBF);
  static const Color _highlightFill = Color(0xFFFFFCF7);

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final isUpcoming = appointment.status == AppointmentStatus.upcoming;
    final badgeColor = isUpcoming ? _upcomingBadge : _completedBadge;
    final badgeTextColor = isUpcoming ? _primaryGreen : _completedText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: appointment.isNewlyBooked ? _highlightFill : _cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: appointment.isNewlyBooked ? _highlightBorder : Colors.transparent,
          width: 1.3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.therapistName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizedSpecialties(appointment.specialty, lang),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(
                label: isUpcoming ? lang.upcoming : lang.completed,
                backgroundColor: badgeColor,
                textColor: badgeTextColor,
              ),
            ],
          ),
          if (appointment.isNewlyBooked) ...[
            const SizedBox(height: 14),
            Text(
              lang.newlyBooked,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _primaryGreen,
              ),
            ),
          ],
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: '${appointment.date} | ${appointment.time}',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.payments_outlined,
            text: lang.pricePerSession(_rateFrom(appointment.price)),
            textColor: _textMuted,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 18),
          Column(
            children: [
              if (isUpcoming && onJoin != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onJoin,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF5E6F5C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.video_call_rounded, size: 22),
                    label: Text(lang.joinSession),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(lang.viewDetails),
                      ),
                    ),
                  ),
                  if (isUpcoming && onCancel != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _cancelFill,
                            foregroundColor: _primaryGreen,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(lang.cancel),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (!isUpcoming && onLeaveReview != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onLeaveReview,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _cancelFill,
                      foregroundColor: _primaryGreen,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.star_outline_rounded, size: 18),
                    label: const Text('Leave a Review'),
                  ),
                ),
              ],
              if (onMessageTherapist != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onMessageTherapist,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _cancelFill,
                      foregroundColor: _primaryGreen,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: Text(AppLocalizations.of(context)!.messageTherapist),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

num _rateFrom(String priceText) =>
    num.tryParse(priceText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.textColor = _textSecondary,
    this.fontWeight = FontWeight.w500,
  });

  final IconData icon;
  final String text;
  final Color textColor;
  final FontWeight fontWeight;

  static const Color _textSecondary = Color(0xFF8D8E87);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: textColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ],
    );
  }
}
