import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';

import '../../main.dart';
import 'therapist_bottom_nav_bar.dart';

enum AvailabilityStatus {
  available,
  blocked,
}

class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final AvailabilityStatus status;

  AvailabilitySlot copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    AvailabilityStatus? status,
  }) {
    return AvailabilitySlot(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }
}

class TherapistManageAvailabilityScreen extends StatefulWidget {
  const TherapistManageAvailabilityScreen({
    super.key,
    required this.isLoggedIn,
    required this.hasTherapistAccess,
    this.therapistName = 'Leila',
  });

  final bool isLoggedIn;
  final bool hasTherapistAccess;
  final String therapistName;

  @override
  State<TherapistManageAvailabilityScreen> createState() =>
      _TherapistManageAvailabilityScreenState();
}

class _TherapistManageAvailabilityScreenState
    extends State<TherapistManageAvailabilityScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA6A69F);

  bool _isLoading = true;
  bool _hasRedirected = false;
  List<AvailabilitySlot> _slots = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final data = await supabase
          .from('availability_slots')
          .select('id, slot_date, start_time, end_time, status')
          .eq('therapist_id', userId)
          .order('slot_date', ascending: true)
          .order('start_time', ascending: true);

      final List<AvailabilitySlot> slots = (data as List).map((s) {
        return AvailabilitySlot(
          id: s['id'],
          date: DateTime.parse(s['slot_date']),
          startTime: s['start_time'],
          endTime: s['end_time'],
          status: s['status'] == 'available'
              ? AvailabilityStatus.available
              : AvailabilityStatus.blocked,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading slots: $e');
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

  Future<void> _handleAddSlot() async {
    final lang = AppLocalizations.of(context)!;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF5E6F5C)),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF5E6F5C)),
        ),
        child: child!,
      ),
    );
    if (startTime == null) return;

    final endTime = TimeOfDay(
      hour: (startTime.hour + 1) % 24,
      minute: startTime.minute,
    );

    final startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    final dateStr = date.toIso8601String().substring(0, 10);

    final hasConflict = _slots.any((slot) =>
      slot.date.year == date.year &&
      slot.date.month == date.month &&
      slot.date.day == date.day &&
      slot.startTime == startStr
    );

    if (hasConflict) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.slotConflict)),
      );
      return;
    }

    try {
      final response = await supabase
          .from('availability_slots')
          .insert({
            'therapist_id': userId,
            'slot_date': dateStr,
            'day_of_week': _getDayOfWeek(date),
            'start_time': startStr,
            'end_time': endStr,
            'status': 'available',
          })
          .select()
          .single();

      final newSlot = AvailabilitySlot(
        id: response['id'],
        date: date,
        startTime: startStr,
        endTime: endStr,
        status: AvailabilityStatus.available,
      );

      setState(() {
        _slots = [..._slots, newSlot];
        _selectedDate = date;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.slotAdded)),
      );
    } catch (e) {
      debugPrint('Error adding slot: $e');
    }
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Future<void> _handleToggleSlot(AvailabilitySlot slot) async {
    try {
      final newStatus = slot.status == AvailabilityStatus.available ? 'blocked' : 'available';

      await supabase
          .from('availability_slots')
          .update({'status': newStatus})
          .eq('id', slot.id);

      setState(() {
        _slots = _slots.map((s) {
          if (s.id == slot.id) {
            return s.copyWith(
              status: slot.status == AvailabilityStatus.available
                  ? AvailabilityStatus.blocked
                  : AvailabilityStatus.available,
            );
          }
          return s;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error toggling slot: $e');
    }
  }

  Future<void> _handleDeleteSlot(AvailabilitySlot slot) async {
    try {
      await supabase
          .from('availability_slots')
          .delete()
          .eq('id', slot.id);

      setState(() {
        _slots = _slots.where((s) => s.id != slot.id).toList();
      });
    } catch (e) {
      debugPrint('Error deleting slot: $e');
    }
  }

  void _handleTabChange(TherapistNavTab tab) {
    final args = {'isLoggedIn': widget.isLoggedIn, 'hasTherapistAccess': widget.hasTherapistAccess, 'therapistName': widget.therapistName};

    if (tab == TherapistNavTab.dashboard) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.therapistDashboard, arguments: args);
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

    final Map<String, List<AvailabilitySlot>> slotsByDate = {};
    for (final slot in _slots) {
      final dateKey = slot.date.toIso8601String().substring(0, 10);
      slotsByDate.putIfAbsent(dateKey, () => []).add(slot);
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                            lang.manageAvailability,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _handleAddSlot,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: Text(lang.addTimeSlot),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_slots.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          lang.noSlotsAdded,
                          style: const TextStyle(fontSize: 15, color: _textSecondary),
                        ),
                      )
                    else
                      ...slotsByDate.entries.map((entry) {
                        final date = DateTime.parse(entry.key);
                        final daySlots = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                '${_getMonthName(date.month)} ${date.day}, ${date.year}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                            ...daySlots.map((slot) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AvailabilitySlotCard(
                                slot: slot,
                                onToggle: () => _handleToggleSlot(slot),
                                onDelete: () => _handleDeleteSlot(slot),
                                availableLabel: lang.available,
                                blockedLabel: lang.blocked,
                                blockLabel: lang.block,
                                unblockLabel: lang.unblock,
                              ),
                            )),
                            const SizedBox(height: 8),
                          ],
                        );
                      }),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E1D8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        lang.tapSlotToEdit,
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
        currentTab: TherapistNavTab.availability,
        onTabSelected: _handleTabChange,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _AvailabilitySlotCard extends StatelessWidget {
  const _AvailabilitySlotCard({
    required this.slot,
    required this.onToggle,
    required this.onDelete,
    required this.availableLabel,
    required this.blockedLabel,
    required this.blockLabel,
    required this.unblockLabel,
  });

  final AvailabilitySlot slot;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final String availableLabel;
  final String blockedLabel;
  final String blockLabel;
  final String unblockLabel;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _rejectRed = Color(0xFFE57373);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.status == AvailabilityStatus.available;
    final statusColor = isAvailable ? _primaryGreen : _rejectRed;
    final statusLabel = isAvailable ? availableLabel : blockedLabel;
    final actionLabel = isAvailable ? blockLabel : unblockLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.startTime} - ${slot.endTime}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 110,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onToggle,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          isAvailable ? Colors.white : const Color(0xFFE9EEE7),
                      foregroundColor:
                          isAvailable ? _rejectRed : _primaryGreen,
                      side: BorderSide(
                        color: isAvailable
                            ? const Color(0xFFF0B4B4)
                            : const Color(0xFFD0D8CD),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(actionLabel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _rejectRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
