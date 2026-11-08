import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/specialty_labels.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'therapist_application.dart';

class PendingTherapistApplicationScreen extends StatefulWidget {
  const PendingTherapistApplicationScreen({
    super.key,
    required this.application,
  });

  final TherapistApplication application;

  @override
  State<PendingTherapistApplicationScreen> createState() =>
      _PendingTherapistApplicationScreenState();
}

class _PendingTherapistApplicationScreenState
    extends State<PendingTherapistApplicationScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _rejectRed = Color(0xFFE57373);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA5A59D);
  static const Color _softTile = Color(0xFFF4EFEA);

  late String _therapistName;
  late String _specialty;
  late String _licenseNumber;
  late String _qualifications;
  late String _submissionDate;
  late String _bio;
  late String _phone;
  late List<String> _documents;
  late List<String> _documentUrls;

  @override
  void initState() {
    super.initState();
    _therapistName = widget.application.name;
    _specialty = widget.application.specialty;
    _licenseNumber = widget.application.licenseNumber;
    _qualifications = widget.application.qualifications;
    _submissionDate = widget.application.submissionDate;
    _bio = widget.application.bio;
    _phone = widget.application.phone;
    _documents = List<String>.from(widget.application.documents);
    _documentUrls = List<String>.from(widget.application.documentUrls);
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleBack() {
    Navigator.of(context).maybePop();
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  void _handleApprove() {
    Navigator.of(context).pop(TherapistApplicationAction.approve);
  }

  void _handleReject() {
    Navigator.of(context).pop(TherapistApplicationAction.reject);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(lang),
              const SizedBox(height: 18),
              Text(
                lang.therapistApplication,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 18),
              _buildDetailsCard(lang),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  lang.allActionsAffectAccounts,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations lang) {
    return Row(
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
        const Spacer(),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(
            Icons.logout_rounded,
            color: _primaryGreen,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(AppLocalizations lang) {
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
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizedSpecialties(_specialty, lang),
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: _textMuted),
              const SizedBox(width: 8),
              Text(
                _phone,
                style: const TextStyle(fontSize: 15, color: _textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildIconLabel(
            icon: Icons.verified_outlined,
            label: lang.licenseNumber,
          ),
          const SizedBox(height: 6),
          Text(
            _licenseNumber,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 18),
          _buildSectionLabel(lang.qualifications),
          const SizedBox(height: 6),
          Text(
            _qualifications,
            style: const TextStyle(
              fontSize: 17,
              height: 1.35,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 18,
                color: _textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                lang.documentsSubmitted(_documents.length),
                style: const TextStyle(
                  fontSize: 16,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._documents.map(_buildDocumentRow),
          const SizedBox(height: 18),
          _buildIconLabel(
            icon: Icons.calendar_today_outlined,
            label: lang.submittedOn(''),
          ),
          const SizedBox(height: 6),
          Text(
            _submissionDate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 18),
          _buildSectionLabel(lang.bioAbout),
          const SizedBox(height: 8),
          Text(
            _bio,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            label: lang.approveApplication,
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            icon: Icons.check_circle_outline_rounded,
            onTap: _handleApprove,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: lang.rejectApplication,
            backgroundColor: Colors.white,
            foregroundColor: _rejectRed,
            borderColor: _rejectRed,
            icon: Icons.close_rounded,
            onTap: _handleReject,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _textMuted,
      ),
    );
  }

  Widget _buildIconLabel({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: _textMuted,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentRow(String fileName) {
    final index = _documents.indexOf(fileName);
    final hasUrl = index >= 0 && index < _documentUrls.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: hasUrl ? () => _openDocument(_documentUrls[index]) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _softTile,
            borderRadius: BorderRadius.circular(18),
            border: hasUrl ? Border.all(color: _primaryGreen.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 18, color: _textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontSize: 14, color: _textSecondary),
                ),
              ),
              if (hasUrl)
                const Icon(Icons.open_in_new_rounded, size: 16, color: _primaryGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    final hasBorder = borderColor != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: hasBorder
              ? BorderSide(color: borderColor, width: 1.2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(label),
      ),
    );
  }
}
