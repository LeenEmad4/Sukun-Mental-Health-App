import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:sukun/utils/specialty_labels.dart';
import '../../main.dart';

class SessionDetailsScreen extends StatefulWidget {
  const SessionDetailsScreen({
    super.key,
    this.initialTherapistName = 'Dr. Laila Al Masri',
    this.initialSpecialty = 'Anxiety & Stress Management',
    this.initialDate = 'March 15, 2026',
    this.initialTime = '2:00 PM',
    this.initialDuration = '50 minutes',
    this.initialSessionNotes = '',
    this.initialPatientNotes = '',
    this.appointmentId = '',
    this.therapistId = '',
    this.isCompleted = false,
    this.isTherapist = false,
  });

  final String initialTherapistName;
  final String initialSpecialty;
  final String initialDate;
  final String initialTime;
  final String initialDuration;
  final String initialSessionNotes;
  final String initialPatientNotes;
  final String appointmentId;
  final String therapistId;
  final bool isCompleted;
  final bool isTherapist;

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _dividerColor = Color(0xFFE8E1D9);
  static const Color _notesColor = Color(0xCC5E6F5C);
  static const Color _textSecondary = Color(0xFF8D8E87);

  late String _therapistName;
  late String _specialty;
  late String _date;
  late String _time;
  late String _duration;
  late final TextEditingController _notesController;
  late final TextEditingController _patientNotesController;
  bool _alreadyReviewed = false;
  bool _canReview = false;
  bool _isSavingNotes = false;

  // Therapist edits their notes before the session.
  bool get _canEditTherapistNotes =>
      widget.appointmentId.isNotEmpty && widget.isTherapist && !widget.isCompleted;

  // Patient edits their notes after the session.
  bool get _canEditPatientNotes =>
      widget.appointmentId.isNotEmpty && !widget.isTherapist && widget.isCompleted;

  @override
  void initState() {
    super.initState();
    _therapistName = widget.initialTherapistName;
    _specialty = widget.initialSpecialty;
    _date = widget.initialDate;
    _time = widget.initialTime;
    _duration = widget.initialDuration;
    _notesController = TextEditingController(text: widget.initialSessionNotes);
    _patientNotesController = TextEditingController(text: widget.initialPatientNotes);
    if (!widget.isTherapist && widget.isCompleted && widget.appointmentId.isNotEmpty) {
      _checkIfReviewed();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _patientNotesController.dispose();
    super.dispose();
  }

  Future<void> _checkIfReviewed() async {
    try {
      final patientId = supabase.auth.currentUser?.id;
      if (patientId == null || widget.therapistId.isEmpty) return;

      final existing = await supabase
          .from('reviews')
          .select('id')
          .eq('appointment_id', widget.appointmentId)
          .maybeSingle();

      // Fetch all non-cancelled, non-pending sessions for this patient+therapist.
      // We then count those that are truly "done": either the DB marks them
      // completed, or the session time + 60 min has already passed — matching
      // the same rule used in the UI (Appointment.isPast).
      final sessions = await supabase
          .from('appointments')
          .select('id, scheduled_date, scheduled_time, status')
          .eq('patient_id', patientId)
          .eq('therapist_id', widget.therapistId)
          .neq('status', 'cancelled')
          .neq('status', 'pending');

      final now = DateTime.now();
      final doneCount = (sessions as List).where((a) {
        if (a['status'] == 'completed') return true;
        try {
          final dt = DateTime.parse(
              '${a['scheduled_date']} ${a['scheduled_time']}:00');
          return now.isAfter(dt.add(const Duration(minutes: 60)));
        } catch (_) {
          return false;
        }
      }).length;

      if (mounted) {
        setState(() {
          _alreadyReviewed = existing != null;
          _canReview = doneCount >= 3;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveTherapistNotes() async {
    if (widget.appointmentId.isEmpty) return;
    setState(() => _isSavingNotes = true);
    try {
      await supabase
          .from('appointments')
          .update({'session_notes': _notesController.text.trim()})
          .eq('id', widget.appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingNotes = false);
    }
  }

  Future<void> _savePatientNotes() async {
    if (widget.appointmentId.isEmpty) return;
    setState(() => _isSavingNotes = true);
    try {
      await supabase
          .from('appointments')
          .update({'patient_notes': _patientNotesController.text.trim()})
          .eq('id', widget.appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingNotes = false);
    }
  }

  void _handleBack() => Navigator.of(context).maybePop();

  String _durationLabel(AppLocalizations lang) {
    final mins = int.tryParse(_duration.replaceAll(RegExp(r'[^0-9]'), ''));
    return mins != null ? lang.durationMinutes(mins) : _duration;
  }

  Future<void> _showReviewSheet() async {
    if (_alreadyReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reviewed this session.')),
      );
      return;
    }

    int selectedRating = 0;
    final commentController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
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
                  color: Color(0xFF4D514A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _therapistName,
                style: const TextStyle(fontSize: 14, color: _textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedRating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 42,
                        color: _primaryGreen,
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
                  hintStyle:
                      const TextStyle(color: Color(0xFFA6A69F), fontSize: 14),
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
                  onPressed: selectedRating == 0
                      ? null
                      : () async {
                          try {
                            await supabase.from('reviews').insert({
                              'therapist_id': widget.therapistId,
                              'patient_id': supabase.auth.currentUser!.id,
                              'appointment_id': widget.appointmentId,
                              'rating': selectedRating,
                              'comment': commentController.text.trim().isEmpty
                                  ? null
                                  : commentController.text.trim(),
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              setState(() => _alreadyReviewed = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Review submitted. Thank you!')),
                              );
                            }
                          } catch (_) {}
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBFC5B9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final sessionIsCompleted = !widget.isTherapist &&
        widget.isCompleted &&
        widget.appointmentId.isNotEmpty &&
        widget.therapistId.isNotEmpty;
    final showReviewButton = sessionIsCompleted && _canReview;
    final showReviewHint = sessionIsCompleted && !_canReview;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 26,
                      color: _primaryGreen,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.sessionDetails,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 26),
              _buildSessionInfoCard(lang),
              if (_canEditTherapistNotes) ...[
                const SizedBox(height: 16),
                _buildSaveButton(_saveTherapistNotes),
              ],
              if (_canEditPatientNotes) ...[
                const SizedBox(height: 16),
                _buildSaveButton(_savePatientNotes),
              ],
              if (showReviewHint) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE3D9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_outline_rounded, size: 18, color: Color(0xFF8D8E87)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Reviews unlock after your 3rd session with this therapist',
                          style: TextStyle(fontSize: 13, color: Color(0xFF8D8E87)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (showReviewButton) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _alreadyReviewed
                      ? OutlinedButton.icon(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAE3D9),
                            disabledForegroundColor: _textSecondary,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          icon: const Icon(Icons.star_rounded, size: 18),
                          label: const Text(
                            'Review Submitted',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _showReviewSheet,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          icon: const Icon(Icons.star_outline_rounded, size: 18),
                          label: const Text('Leave a Review'),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(AppLocalizations lang) {
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
          Text(
            _therapistName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _primaryGreen,
            ),
          ),
          if (_specialty.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              localizedSpecialties(_specialty, lang),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _primaryGreen,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(height: 1, color: _dividerColor),
          const SizedBox(height: 18),
          _buildLabeledText(
            label: lang.dateAndTime,
            value: '$_date ${lang.at} $_time',
          ),
          const SizedBox(height: 14),
          _buildLabeledText(
            label: lang.duration,
            value: _durationLabel(lang),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: _dividerColor),
          const SizedBox(height: 18),
          // ── Therapist's notes ──────────────────────────────────────────
          Text(
            widget.isTherapist ? 'My Notes' : 'Therapist\'s Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _notesColor),
          ),
          const SizedBox(height: 12),
          if (_canEditTherapistNotes)
            _buildNotesField(_notesController, 'Add pre-session notes…')
          else
            _buildNotesReadOnly(_notesController.text),
          // ── Patient's notes ────────────────────────────────────────────
          const SizedBox(height: 18),
          Container(height: 1, color: _dividerColor),
          const SizedBox(height: 18),
          Text(
            widget.isTherapist ? 'Patient\'s Notes' : 'My Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _notesColor),
          ),
          const SizedBox(height: 12),
          if (_canEditPatientNotes)
            _buildNotesField(_patientNotesController, 'Write your session notes…')
          else
            _buildNotesReadOnly(_patientNotesController.text),
        ],
      ),
    );
  }

  Widget _buildNotesField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 5,
      minLines: 3,
      style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF4D514A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA6A69F), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF4EFEA),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryGreen, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildNotesReadOnly(String text) {
    return Text(
      text.isEmpty ? '—' : text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: _notesColor,
      ),
    );
  }

  Widget _buildSaveButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSavingNotes ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFBFC5B9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        icon: _isSavingNotes
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: const Text('Save Notes'),
      ),
    );
  }

  Widget _buildLabeledText({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _notesColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _primaryGreen,
          ),
        ),
      ],
    );
  }
}
