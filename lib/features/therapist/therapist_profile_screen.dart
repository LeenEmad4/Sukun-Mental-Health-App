import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';
import 'therapist_bottom_nav_bar.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({
    super.key,
    required this.isLoggedIn,
    required this.hasTherapistAccess,
  });

  final bool isLoggedIn;
  final bool hasTherapistAccess;

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA6A69F);
  static const Color _fieldFill = Color(0xFFF2EEE8);
  static const Color _fieldBorder = Color(0xFFD9D5CE);
  static const Color _deleteRed = Color(0xFFE57373);

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _licenseController;
  late final TextEditingController _experienceController;
  late final TextEditingController _sessionRateController;
  late final TextEditingController _bioController;

  final List<String> _specialtyOptions = [
    'Anxiety',
    'Depression',
    'Trauma',
    'Stress & Burnout',
    'Relationship Counseling',
    'Family Therapy',
    'Grief & Loss',
    'Addiction',
    'Self-Esteem',
    'Life Transitions',
  ];

  final List<String> _selectedSpecialties = [
    'Anxiety',
    'Depression',
    'Trauma',
  ];

  String _therapistName = '';
  late String _email;
  String _yearsOfExperience = '';
  bool _hasRedirected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseController = TextEditingController();
    _experienceController = TextEditingController();
    _sessionRateController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final therapist = await supabase
          .from('therapists')
          .select('full_name, phone, license_number, years_of_experience, session_rate, bio, specialties, qualifications')
          .eq('id', userId)
          .single();

      final profile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .single();

      if (!mounted) return;
      setState(() {
        _fullNameController.text = therapist['full_name'] ?? '';
        _phoneController.text = therapist['phone'] ?? '';
        _licenseController.text = therapist['license_number'] ?? '';
        _experienceController.text = therapist['years_of_experience']?.toString() ?? '';
        _sessionRateController.text = therapist['session_rate']?.toString() ?? '';
        _bioController.text = therapist['bio'] ?? '';
        _therapistName = therapist['full_name'] ?? profile['full_name'] ?? '';
        _email = supabase.auth.currentUser!.email ?? '';

        final specialties = therapist['specialties'];
        if (specialties is List) {
          _selectedSpecialties.clear();
          _selectedSpecialties.addAll(List<String>.from(specialties));
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _sessionRateController.dispose();
    _bioController.dispose();
    super.dispose();
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
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
      });
    }
    if (_yearsOfExperience.isEmpty) {
      final lang = AppLocalizations.of(context)!;
      _yearsOfExperience = lang.yearsExperience('8');
    }
  }

  void _handleBack() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.therapistDashboard,
      arguments: {'isLoggedIn': widget.isLoggedIn, 'hasTherapistAccess': widget.hasTherapistAccess, 'therapistName': 'Leila'},
    );
  }

  Future<void> _handleSaveChanges() async {
    final lang = AppLocalizations.of(context)!;
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('therapists').update({
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'years_of_experience': int.tryParse(_experienceController.text.trim()) ?? 0,
        'session_rate': double.tryParse(_sessionRateController.text.trim()) ?? 0,
        'bio': _bioController.text.trim(),
        'specialties': _selectedSpecialties,
      }).eq('id', userId);

      await supabase.from('profiles').update({
        'full_name': _fullNameController.text.trim(),
      }).eq('id', userId);

      if (!mounted) return;
      setState(() {
        _therapistName = _fullNameController.text.trim();
        _yearsOfExperience = lang.yearsExperience(_experienceController.text.trim());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.changesSaved)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    }
  }

  void _handleUploadDocuments() {
    final lang = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.documentUploadLater),
      ),
    );
  }

  Future<void> _handleLogOut() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  void _handleDeleteAccount() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  void _handleTabChange(TherapistNavTab tab) {
    final args = {'isLoggedIn': widget.isLoggedIn, 'hasTherapistAccess': widget.hasTherapistAccess, 'therapistName': 'Leila'};
    switch (tab) {
      case TherapistNavTab.dashboard:
        Navigator.of(context).pushReplacementNamed(AppRoutes.therapistDashboard, arguments: args);
        return;
      case TherapistNavTab.availability:
        Navigator.of(context).pushReplacementNamed(AppRoutes.therapistAvailability, arguments: args);
        return;
      case TherapistNavTab.requests:
        Navigator.of(context).pushReplacementNamed(AppRoutes.therapistRequests, arguments: args);
        return;
      case TherapistNavTab.profile:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    if (!widget.isLoggedIn || !widget.hasTherapistAccess) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: SizedBox.shrink(),
      );
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
                      lang.profileAndSettings,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lang.manageProfessionalInfo,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: _cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 38,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _therapistName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _yearsOfExperience,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildInfoCard(lang),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E1D8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  lang.profileVisibleToPatients,
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
        currentTab: TherapistNavTab.profile,
        onTabSelected: _handleTabChange,
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations lang) {
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
            lang.professionalInformation,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.fullName),
          const SizedBox(height: 8),
          _buildInputField(controller: _fullNameController),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.phoneNumber),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.licenseQualifications),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _licenseController,
            readOnly: true,
          ),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.yearsOfExperience),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.sessionRate),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _sessionRateController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.specialties),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _specialtyOptions.map((specialty) {
              final isSelected = _selectedSpecialties.contains(specialty);
              return FilterChip(
                label: Text(localizedSpecialty(specialty, lang)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecialties.add(specialty);
                    } else {
                      _selectedSpecialties.remove(specialty);
                    }
                  });
                },
                backgroundColor: _fieldFill,
                selectedColor: const Color(0xFF98A58F),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : _textSecondary,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF98A58F) : _fieldBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          _buildFieldLabel(lang.bioAboutMe),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _bioController,
            maxLines: 5,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _handleUploadDocuments,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _textSecondary,
                side: BorderSide(color: _fieldBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: Text(
                lang.uploadUpdateDocuments,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleSaveChanges,
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
              child: Text(lang.saveChanges),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _handleLogOut,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _textSecondary,
                side: BorderSide(color: _fieldBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(
                lang.logOut,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _handleDeleteAccount,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _deleteRed,
                side: const BorderSide(color: _deleteRed, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(
                lang.deleteAccount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _textMuted,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: 14,
        color: readOnly ? _textMuted : _textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? const Color(0xFFE8E3DC) : _fieldFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _primaryGreen,
            width: 1.1,
          ),
        ),
      ),
    );
  }
}
