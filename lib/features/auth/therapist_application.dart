class TherapistApplication {
  const TherapistApplication({
    required this.id,
    required this.name,
    required this.specialty,
    required this.licenseNumber,
    required this.qualifications,
    required this.submissionDate,
    required this.bio,
    required this.documents,
    required this.phone,
    this.documentUrls = const [],
  });

  final String id;
  final String name;
  final String specialty;
  final String licenseNumber;
  final String qualifications;
  final String submissionDate;
  final String bio;
  final String phone;
  final List<String> documents;
  final List<String> documentUrls;
}

enum TherapistApplicationAction {
  approve,
  reject,
  requestMoreInfo,
}
