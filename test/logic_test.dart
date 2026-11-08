// Unit tests for pure business logic.
// Run with: flutter test test/logic_test.dart
//
// These tests do NOT need a device, Supabase, or LiveKit.

import 'package:flutter_test/flutter_test.dart';
import 'package:sukun/features/patient/my_appointements_screen.dart';

// ── Helpers replicated from payment_screen.dart ───────────────────────────────

int parseTimeToMinutes(String time) {
  try {
    final upper = time.toUpperCase();
    final colonParts = time.split(':');
    int hours = int.parse(colonParts[0].trim());
    int minutes = int.parse(colonParts[1].trim().split(' ')[0]);
    if (upper.contains('PM') && hours != 12) hours += 12;
    if (upper.contains('AM') && hours == 12) hours = 0;
    return hours * 60 + minutes;
  } catch (_) {
    return 0;
  }
}

bool appointmentsOverlap(int newMins, int existingMins) =>
    (newMins - existingMins).abs() < 60;

// ── Helpers replicated from patient_home_screen.dart ─────────────────────────

String formatDate(String date) {
  try {
    final dt = DateTime.parse(date);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  } catch (_) {
    return date;
  }
}

String formatTime(String time) {
  try {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final min = parts[1].padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$min $period';
  } catch (_) {
    return time;
  }
}

// ── Patient display name logic (therapist_dashboard_screen.dart) ──────────────

String resolvePatientDisplayName({
  required bool isAnon,
  required String? username,
  required String? fullName,
}) {
  if (isAnon) {
    return username?.isNotEmpty == true ? username! : 'Anonymous';
  }
  return fullName?.isNotEmpty == true
      ? fullName!
      : (username?.isNotEmpty == true ? username! : 'Patient');
}

// ── Appointment builder helper ────────────────────────────────────────────────

Appointment _appt({
  required Duration offsetFromNow,
  String dbStatus = 'confirmed',
}) {
  final dt = DateTime.now().add(offsetFromNow);
  final date =
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  final time =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return Appointment(
    id: 'test',
    therapistName: 'Dr. Test',
    specialty: '',
    date: date,
    time: time,
    price: '10 JD',
    status: AppointmentStatus.upcoming,
    dbStatus: dbStatus,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Appointment.canJoinNow ─────────────────────────────────────────────────
  group('Appointment.canJoinNow', () {
    test('not joinable when appointment is 20 min away (outside early window)', () {
      expect(_appt(offsetFromNow: const Duration(minutes: 20)).canJoinNow, isFalse);
    });

    test('joinable when appointment is 14 min away (inside 15-min early window)', () {
      expect(_appt(offsetFromNow: const Duration(minutes: 14)).canJoinNow, isTrue);
    });

    test('joinable when session started 1 min ago', () {
      expect(_appt(offsetFromNow: const Duration(minutes: -1)).canJoinNow, isTrue);
    });

    test('joinable when session started 59 min ago', () {
      expect(_appt(offsetFromNow: const Duration(minutes: -59)).canJoinNow, isTrue);
    });

    test('not joinable when session started 61 min ago (window closed)', () {
      expect(_appt(offsetFromNow: const Duration(minutes: -61)).canJoinNow, isFalse);
    });

    test('never joinable when status is pending', () {
      expect(
        _appt(offsetFromNow: const Duration(minutes: -1), dbStatus: 'pending').canJoinNow,
        isFalse,
      );
    });

    test('never joinable when status is completed', () {
      expect(
        _appt(offsetFromNow: const Duration(minutes: -1), dbStatus: 'completed').canJoinNow,
        isFalse,
      );
    });
  });

  // ── Appointment.isPast ─────────────────────────────────────────────────────
  group('Appointment.isPast', () {
    test('not past when appointment is in the future', () {
      expect(_appt(offsetFromNow: const Duration(hours: 2)).isPast, isFalse);
    });

    test('not past when session ended 59 min ago (still in window)', () {
      expect(_appt(offsetFromNow: const Duration(minutes: -59)).isPast, isFalse);
    });

    test('is past when session ended 61 min ago', () {
      expect(_appt(offsetFromNow: const Duration(minutes: -61)).isPast, isTrue);
    });

    test('is past when session was yesterday', () {
      expect(_appt(offsetFromNow: const Duration(hours: -25)).isPast, isTrue);
    });
  });

  // ── parseTimeToMinutes ─────────────────────────────────────────────────────
  group('parseTimeToMinutes', () {
    test('00:00 → 0', () => expect(parseTimeToMinutes('00:00'), 0));
    test('01:00 → 60', () => expect(parseTimeToMinutes('01:00'), 60));
    test('09:30 → 570', () => expect(parseTimeToMinutes('09:30'), 570));
    test('14:00 → 840', () => expect(parseTimeToMinutes('14:00'), 840));
    test('23:59 → 1439', () => expect(parseTimeToMinutes('23:59'), 1439));
    test('14:00:00 (with seconds) → 840', () => expect(parseTimeToMinutes('14:00:00'), 840));
    test('2:00 PM → 840', () => expect(parseTimeToMinutes('2:00 PM'), 840));
    test('12:00 PM → 720', () => expect(parseTimeToMinutes('12:00 PM'), 720));
    test('12:00 AM → 0 (midnight)', () => expect(parseTimeToMinutes('12:00 AM'), 0));
    test('11:59 PM → 1439', () => expect(parseTimeToMinutes('11:59 PM'), 1439));
  });

  // ── Double-booking overlap ─────────────────────────────────────────────────
  group('Double-booking overlap detection', () {
    test('same time → overlap', () {
      expect(appointmentsOverlap(840, 840), isTrue);
    });

    test('30 min apart → overlap', () {
      expect(appointmentsOverlap(870, 840), isTrue);
    });

    test('59 min apart → overlap', () {
      expect(appointmentsOverlap(899, 840), isTrue);
    });

    test('exactly 60 min apart → no overlap', () {
      expect(appointmentsOverlap(900, 840), isFalse);
    });

    test('90 min apart → no overlap', () {
      expect(appointmentsOverlap(930, 840), isFalse);
    });

    test('new booking is earlier → still checks correctly', () {
      expect(appointmentsOverlap(810, 840), isTrue);  // 30 min before → overlaps
      expect(appointmentsOverlap(780, 840), isFalse); // 60 min before → no overlap
    });
  });

  // ── Patient display name ───────────────────────────────────────────────────
  group('Patient display name (therapist view)', () {
    test('anonymous with username → shows username', () {
      expect(
        resolvePatientDisplayName(isAnon: true, username: 'StarLight', fullName: 'Ahmad Ali'),
        'StarLight',
      );
    });

    test('anonymous without username → shows Anonymous', () {
      expect(
        resolvePatientDisplayName(isAnon: true, username: null, fullName: 'Ahmad Ali'),
        'Anonymous',
      );
    });

    test('anonymous with empty username → shows Anonymous', () {
      expect(
        resolvePatientDisplayName(isAnon: true, username: '', fullName: 'Ahmad Ali'),
        'Anonymous',
      );
    });

    test('non-anonymous with full_name → shows full_name (not username)', () {
      expect(
        resolvePatientDisplayName(isAnon: false, username: 'StarLight', fullName: 'Ahmad Ali'),
        'Ahmad Ali',
      );
    });

    test('non-anonymous without full_name → falls back to username', () {
      expect(
        resolvePatientDisplayName(isAnon: false, username: 'StarLight', fullName: null),
        'StarLight',
      );
    });

    test('non-anonymous with neither → Patient', () {
      expect(
        resolvePatientDisplayName(isAnon: false, username: null, fullName: null),
        'Patient',
      );
    });
  });

  // ── Date / time formatting ─────────────────────────────────────────────────
  group('formatDate', () {
    test('formats to short weekday + month + day', () {
      expect(formatDate('2026-06-01'), 'Mon, Jun 1');
      expect(formatDate('2026-12-25'), 'Fri, Dec 25');
    });

    test('returns original string on bad input', () {
      expect(formatDate('not-a-date'), 'not-a-date');
    });
  });

  group('formatTime', () {
    test('00:00 → 12:00 AM', () => expect(formatTime('00:00'), '12:00 AM'));
    test('09:00 → 9:00 AM', () => expect(formatTime('09:00'), '9:00 AM'));
    test('12:00 → 12:00 PM', () => expect(formatTime('12:00'), '12:00 PM'));
    test('14:00 → 2:00 PM', () => expect(formatTime('14:00'), '2:00 PM'));
    test('23:59 → 11:59 PM', () => expect(formatTime('23:59'), '11:59 PM'));
    test('returns original string on bad input', () {
      expect(formatTime('invalid'), 'invalid');
    });
  });
}
