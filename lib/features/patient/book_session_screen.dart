import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';

class BookSessionScreen extends StatefulWidget {
  const BookSessionScreen({
    super.key,
    this.therapist,
  });

  final Map<String, dynamic>? therapist;

  @override
  State<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends State<BookSessionScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _softGreen = Color(0xFFC7CEBF);
  static const Color _darkGreen = Color(0xFF6B7E67);
  static const Color _lightPink = Color(0xFFF5E9E2);
  static const Color _pinkBorder = Color(0xFFE8D3C8);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8A8C84);

  static const Map<String, dynamic> _dummyTherapist = {
    'name': 'Dr. Leila Ahmed',
    'specialty': 'Anxiety & Depression',
    'price': '10 JD per session',
  };

  late final Map<String, dynamic> _therapistData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableSlots = [];
  Map<String, dynamic>? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _therapistData = widget.therapist ?? _dummyTherapist;
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    try {
      final therapistId = _therapistData['id'] as String?;
      if (therapistId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final slots = await supabase
          .from('availability_slots')
          .select('id, slot_date, start_time, end_time, status')
          .eq('therapist_id', therapistId)
          .eq('status', 'available')
          .gte('slot_date', DateTime.now().toIso8601String().substring(0, 10))
          .order('slot_date', ascending: true)
          .order('start_time', ascending: true);

      final booked = await supabase
          .from('appointments')
          .select('scheduled_date, scheduled_time')
          .eq('therapist_id', therapistId)
          .inFilter('status', ['pending', 'confirmed']);

      final List<Map<String, dynamic>> freeSlots = (slots as List).where((slot) {
        return !(booked as List).any((b) =>
          b['scheduled_date'] == slot['slot_date'] &&
          b['scheduled_time'] == slot['start_time']
        );
      }).map((s) => Map<String, dynamic>.from(s)).toList();

      if (!mounted) return;
      setState(() {
        _availableSlots = freeSlots;
        if (freeSlots.isNotEmpty) _selectedSlot = freeSlots.first;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading slots: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleConfirmBooking() {
    final lang = AppLocalizations.of(context)!;
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.selectTimeSlot)),
      );
      return;
    }

    final therapistName = (_therapistData['name'] as String?) ?? 'Dr.';
    final specialty = (_therapistData['specialty'] as String?) ?? '';
    final price = (_therapistData['price'] as String?) ?? '0 JD';
    final date = _selectedSlot!['slot_date'] as String;
    final time = _selectedSlot!['start_time'] as String;
    final slotId = _selectedSlot!['id'] as String;

    Navigator.of(context).pushNamed(
      AppRoutes.payment,
      arguments: {
        'therapistName': therapistName,
        'therapistSpecialty': specialty,
        'sessionPrice': price,
        'sessionDate': date,
        'sessionTime': time,
        'sessionDuration': lang.sessionDuration,
        'totalPrice': price,
        'therapistId': _therapistData['id'],
        'slotId': slotId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 52,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: _textPrimary,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          Center(
                            child: Text(
                              lang.bookSession,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (_therapistData['name'] as String?) ?? '',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: _textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  localizedSpecialties((_therapistData['specialty'] as String?) ?? '', lang),
                                  style: const TextStyle(fontSize: 14, color: _textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                lang.sessionPrice,
                                style: const TextStyle(fontSize: 14, color: _textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang.pricePerSession((_therapistData['session_rate'] as num?) ?? 0),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      lang.selectTime,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
                    ),
                    const SizedBox(height: 18),
                    if (_availableSlots.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          lang.noAvailableSlots,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF8A8C84)),
                        ),
                      )
                    else
                      _buildSlotsGrouped(),
                    const SizedBox(height: 26),
                    if (_selectedSlot != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        decoration: BoxDecoration(
                          color: _lightPink,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _pinkBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.selectedTime, style: const TextStyle(fontSize: 14, color: _textSecondary)),
                            const SizedBox(height: 10),
                            Text(
                              '${_selectedSlot!['slot_date']} ${lang.at} ${_selectedSlot!['start_time']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _textPrimary),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleConfirmBooking,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _darkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        child: Text(lang.confirmBooking),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSlotsGrouped() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final slot in _availableSlots) {
      final date = slot['slot_date'] as String;
      grouped.putIfAbsent(date, () => []).add(slot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final dateParts = entry.key.split('-');
        final dateLabel = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8A8C84)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: entry.value.map((slot) {
                final isSelected = _selectedSlot?['id'] == slot['id'];
                return _TimeSlotButton(
                  label: slot['start_time'] as String,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedSlot = slot),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

class _TimeSlotButton extends StatelessWidget {
  const _TimeSlotButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _softGreen = Color(0xFFC7CEBF);
  static const Color _darkGreen = Color(0xFF6B7E67);
  static const Color _lightText = Color(0xFFF9F7F3);
  static const Color _darkText = Color(0xFF4F544D);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _darkGreen : _softGreen,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 95,
          height: 46,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? _lightText : _darkText,
            ),
          ),
        ),
      ),
    );
  }
}
