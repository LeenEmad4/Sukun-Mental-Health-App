import 'package:sukun/l10n/app_localizations.dart';

// Translates a single STORED specialty value (English, as kept in the database)
// to the current language for DISPLAY ONLY. The stored value is never changed,
// so specialty filtering and database writes keep comparing the English value.
String localizedSpecialty(String value, AppLocalizations lang) {
  switch (value.trim()) {
    case 'Anxiety':
      return lang.specialtyAnxiety;
    case 'Depression':
      return lang.specialtyDepression;
    case 'Trauma':
      return lang.specialtyTrauma;
    case 'Stress Management':
      return lang.specialtyStressManagement;
    case 'Family Therapy':
      return lang.specialtyFamilyTherapy;
    case 'Stress & Burnout':
      return lang.specialtyStressBurnout;
    case 'CBT':
      return lang.specialtyCBT;
    case 'Relationship Counseling':
      return lang.specialtyRelationshipCounseling;
    case 'Grief & Loss':
      return lang.specialtyGriefLoss;
    case 'Addiction':
      return lang.specialtyAddiction;
    case 'Self-Esteem':
      return lang.specialtySelfEsteem;
    case 'Life Transitions':
      return lang.specialtyLifeTransitions;
    default:
      return value; // unknown value: show as stored (safe fallback)
  }
}

// Translates a comma-joined specialty string (e.g. "Family Therapy, Trauma")
// for display: splits, translates each piece, re-joins.
String localizedSpecialties(String joined, AppLocalizations lang) {
  if (joined.trim().isEmpty) return joined;
  return joined
      .split(', ')
      .map((s) => localizedSpecialty(s, lang))
      .join(', ');
}
