import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _isPatientSelected = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureTherapistPassword = true;
  bool _obscureTherapistConfirmPassword = true;
  bool _isAnonymous = false;
  bool _isLoading = false;

  final List<PlatformFile> _uploadedFiles = [];
 //q bool _isUploading = false;

  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _brandGreen = Color(0xFF5E6F5C);
  static const Color _brandGreenLight = Color(0xFFC2C7B7);
  static const Color _textPrimary = Color(0xFF4B5048);
  static const Color _textMuted = Color(0xFF919388);
  static const Color _fieldFill = Color(0xFFF0F0F0);
  static const Color _fieldBorder = Color(0xFFD6D7D1);

  late final TextEditingController _patientFullNameController;
  late final TextEditingController _patientEmailController;
  late final TextEditingController _patientPasswordController;
  late final TextEditingController _patientConfirmPasswordController;

  late final TextEditingController _therapistFullNameController;
  late final TextEditingController _therapistEmailController;
  late final TextEditingController _therapistPasswordController;
  late final TextEditingController _therapistConfirmPasswordController;
  late final TextEditingController _therapistQualificationsController;
  late final TextEditingController _therapistPhoneController;
  late final TextEditingController _therapistLicenseController;

  final List<String> _specialtyOptions = [
    'Anxiety',
    'Depression',
    'Trauma',
    'Stress Management',
    'Family Therapy',
    'CBT',
  ];

  final List<String> _selectedSpecialties = [];

  @override
  void initState() {
    super.initState();
    _patientFullNameController = TextEditingController();
    _patientEmailController = TextEditingController();
    _patientPasswordController = TextEditingController();
    _patientConfirmPasswordController = TextEditingController();
    _therapistFullNameController = TextEditingController();
    _therapistEmailController = TextEditingController();
    _therapistPasswordController = TextEditingController();
    _therapistConfirmPasswordController = TextEditingController();
    _therapistQualificationsController = TextEditingController();
    _therapistPhoneController = TextEditingController();
    _therapistLicenseController = TextEditingController();
  }

  @override
  void dispose() {
    _patientFullNameController.dispose();
    _patientEmailController.dispose();
    _patientPasswordController.dispose();
    _patientConfirmPasswordController.dispose();
    _therapistFullNameController.dispose();
    _therapistEmailController.dispose();
    _therapistPasswordController.dispose();
    _therapistConfirmPasswordController.dispose();
    _therapistQualificationsController.dispose();
    _therapistPhoneController.dispose();
    _therapistLicenseController.dispose();
    super.dispose();
  }

  bool _isValidPatientForm() {
    final lang = AppLocalizations.of(context)!;
    final fullName = _patientFullNameController.text.trim();
    final email = _patientEmailController.text.trim();
    final password = _patientPasswordController.text;
    final confirmPassword = _patientConfirmPasswordController.text;

    if (fullName.isEmpty) {
      _showMessage(lang.enterFullName);
      return false;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showMessage(lang.invalidEmail);
      return false;
    }

    if (!_passwordMeetsRequirements(password)) {
      _showMessage('Password must be at least 8 characters, include an uppercase letter, a number, and a special character.');
      return false;
    }

    if (password != confirmPassword) {
      _showMessage(lang.passwordMismatch);
      return false;
    }

    return true;
  }

  bool _isValidTherapistForm() {
    final lang = AppLocalizations.of(context)!;
    if (_therapistFullNameController.text.trim().isEmpty) {
      _showMessage(lang.enterFullName);
      return false;
    }

    final email = _therapistEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage(lang.invalidEmail);
      return false;
    }

    if (!_passwordMeetsRequirements(_therapistPasswordController.text)) {
      _showMessage('Password must be at least 8 characters, include an uppercase letter, a number, and a special character.');
      return false;
    }

    if (_therapistPasswordController.text != _therapistConfirmPasswordController.text) {
      _showMessage(lang.passwordMismatch);
      return false;
    }

    if (_therapistPhoneController.text.trim().isEmpty) {
      _showMessage(lang.pleaseEnterPhone);
      return false;
    }

    if (_therapistLicenseController.text.trim().isEmpty) {
      _showMessage(lang.pleaseEnterLicense);
      return false;
    }

    final licenseDigits = _therapistLicenseController.text.trim();
    if (licenseDigits.length < 4 || licenseDigits.length > 5) {
      _showMessage('License number must be 4 or 5 digits.');
      return false;
    }

    if (_selectedSpecialties.isEmpty) {
      _showMessage(lang.selectSpecialty);
      return false;
    }

    if (_therapistQualificationsController.text.trim().isEmpty) {
      _showMessage(lang.enterQualifications);
      return false;
    }

    return true;
  }

  bool _passwordMeetsRequirements(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]'));
  }

  Widget _buildPasswordRequirements(TextEditingController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final pw = controller.text;
        final hasLength = pw.length >= 8;
        final hasUpper = pw.contains(RegExp(r'[A-Z]'));
        final hasNumber = pw.contains(RegExp(r'[0-9]'));
        final hasSpecial = pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]'));
        if (pw.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PasswordRuleRow(met: hasLength, label: 'At least 8 characters'),
              const SizedBox(height: 5),
              _PasswordRuleRow(met: hasUpper, label: 'At least one uppercase letter'),
              const SizedBox(height: 5),
              _PasswordRuleRow(met: hasNumber, label: 'At least one number'),
              const SizedBox(height: 5),
              _PasswordRuleRow(met: hasSpecial, label: 'At least one special character'),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleCreateAccount() async {
    final lang = AppLocalizations.of(context)!;
    if (!_isValidPatientForm()) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: _patientEmailController.text.trim(),
        password: _patientPasswordController.text,
        data: {
          'full_name': _patientFullNameController.text.trim(),
          'role': 'patient',
        },
      );

      await supabase.from('patient_profiles').insert({
        'id': response.user!.id,
        'username': _patientFullNameController.text.trim(),
        'is_anonymous': _isAnonymous,
      });

      if (!mounted) return;
      _showMessage(lang.accountCreated);
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);

    } catch (e) {
      _showMessage(friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _uploadedFiles.addAll(result.files);
      });
    }
  }

  Future<void> _uploadDocumentsToSupabase(String therapistId) async {
    for (final file in _uploadedFiles) {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final fileName = '$therapistId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      await supabase.storage
          .from('therapist-documents')
          .uploadBinary(fileName, bytes);

      final url = supabase.storage
          .from('therapist-documents')
          .getPublicUrl(fileName);

      await supabase.from('therapist_documents').insert({
        'therapist_id': therapistId,
        'file_name': file.name,
        'file_url': url,
      });
    }
  }

  Future<void> _handleTherapistSubmit() async {
    final lang = AppLocalizations.of(context)!;
    if (!_isValidTherapistForm()) return;

    if (_uploadedFiles.isEmpty) {
      _showMessage(lang.pleaseUploadDocument);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: _therapistEmailController.text.trim(),
        password: _therapistPasswordController.text,
        data: {
          'full_name': _therapistFullNameController.text.trim(),
          'role': 'therapist',
        },
      );

      final therapistId = response.user!.id;

      await supabase.from('therapists').insert({
        'id': therapistId,
        'full_name': _therapistFullNameController.text.trim(),
        'phone': _therapistPhoneController.text.trim(),
        'specialties': _selectedSpecialties,
        'qualifications': _therapistQualificationsController.text.trim(),
        'license_number': _therapistLicenseController.text.trim(),
        'status': 'pending',
      });

      await _uploadDocumentsToSupabase(therapistId);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.applicationPending);

    } catch (e) {
      _showMessage(friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 420 ? 392.0 : double.infinity;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildLogoSection(),
                  const SizedBox(height: 18),
                  _buildRoleToggle(lang),
                  const SizedBox(height: 16),
                  _buildFormCard(lang),
                  const SizedBox(height: 20),
                  _buildBottomText(lang),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return SizedBox(
      height: 190,
      child: Center(
        child: SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.self_improvement_rounded,
                  size: 92,
                  color: _brandGreen,
                ),
              ),
              const Text(
                'sukun',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle(AppLocalizations lang) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleTab(
              label: lang.patient,
              isSelected: _isPatientSelected,
              onTap: () => setState(() => _isPatientSelected = true),
            ),
          ),
          Expanded(
            child: _RoleTab(
              label: lang.therapist,
              isSelected: !_isPatientSelected,
              onTap: () => setState(() => _isPatientSelected = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isPatientSelected)
            ..._buildPatientFields(lang)
          else
            ..._buildTherapistFields(lang),
        ],
      ),
    );
  }

  List<Widget> _buildPatientFields(AppLocalizations lang) {
    return [
      _buildFieldLabel(lang.fullName),
      const SizedBox(height: 10),
      _buildInputField(
        hintText: lang.fullNameHint,
        controller: _patientFullNameController,
      ),
      const SizedBox(height: 15),
      _buildFieldLabel(lang.email),
      const SizedBox(height: 10),
      _buildInputField(
        hintText: lang.emailHint,
        keyboardType: TextInputType.emailAddress,
        controller: _patientEmailController,
      ),
      const SizedBox(height: 15),
      _buildFieldLabel(lang.password),
      const SizedBox(height: 10),
      _buildInputField(
        hintText: lang.createPassword,
        controller: _patientPasswordController,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: _textMuted,
          ),
        ),
      ),
      _buildPasswordRequirements(_patientPasswordController),
      const SizedBox(height: 10),
      _buildFieldLabel(lang.confirmPassword),
      const SizedBox(height: 10),
      _buildInputField(
        hintText: lang.confirmPasswordHint,
        controller: _patientConfirmPasswordController,
        obscureText: _obscureConfirmPassword,
        suffixIcon: IconButton(
          onPressed: () {
            setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            );
          },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: _textMuted,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-6, 0),
            child: Checkbox(
              value: _isAnonymous,
              onChanged: (value) {
                setState(() => _isAnonymous = value ?? false);
              },
              activeColor: _brandGreen,
              side: const BorderSide(color: _fieldBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              lang.anonymousSignup,
              style: const TextStyle(
                fontSize: 14,
                color: _textMuted,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _buildPrimaryButton(
        label: lang.createAccount,
        onTap: _handleCreateAccount,
      ),
      const SizedBox(height: 14),
      Text(
        lang.privacyText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: _textMuted,
          height: 1.45,
        ),
      ),
    ];
  }

  List<Widget> _buildTherapistFields(AppLocalizations lang) {
    return [
      Text(
        lang.therapistApplicationTitle,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
      ),
      const SizedBox(height: 6),
      Text(
        lang.therapistApplicationSubtitle,
        style: TextStyle(fontSize: 13, color: _textMuted),
      ),
      const SizedBox(height: 24),

      _buildSectionHeader(lang.personalInformation),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.fullName),
      const SizedBox(height: 8),
      _buildInputField(hintText: lang.fullNameHint, controller: _therapistFullNameController),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.email),
      const SizedBox(height: 8),
      _buildInputField(hintText: lang.emailHint, keyboardType: TextInputType.emailAddress, controller: _therapistEmailController),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.phoneNumber),
      const SizedBox(height: 8),
      _buildInputField(hintText: lang.phoneNumberHint, keyboardType: TextInputType.phone, controller: _therapistPhoneController),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.password),
      const SizedBox(height: 8),
      _buildInputField(
        hintText: lang.createPassword,
        controller: _therapistPasswordController,
        obscureText: _obscureTherapistPassword,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureTherapistPassword = !_obscureTherapistPassword),
          icon: Icon(_obscureTherapistPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: _textMuted),
        ),
      ),
      _buildPasswordRequirements(_therapistPasswordController),
      const SizedBox(height: 10),
      _buildFieldLabel(lang.confirmPassword),
      const SizedBox(height: 8),
      _buildInputField(
        hintText: lang.confirmPasswordHint,
        controller: _therapistConfirmPasswordController,
        obscureText: _obscureTherapistConfirmPassword,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureTherapistConfirmPassword = !_obscureTherapistConfirmPassword),
          icon: Icon(_obscureTherapistConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: _textMuted),
        ),
      ),
      const SizedBox(height: 24),

      _buildSectionHeader(lang.professionalInformation),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.licenseNumber),
      const SizedBox(height: 8),
      _buildInputField(
        hintText: '12345',
        controller: _therapistLicenseController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
        ],
      ),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.qualifications),
      const SizedBox(height: 8),
      _buildInputField(hintText: lang.qualificationsHint2, controller: _therapistQualificationsController),
      const SizedBox(height: 14),
      _buildFieldLabel(lang.specialties),
      const SizedBox(height: 8),
      _buildSpecialtiesSelector(),
      const SizedBox(height: 24),

      _buildSectionHeader(lang.documents),
      const SizedBox(height: 6),
      Text(lang.documentsSubtitle, style: TextStyle(fontSize: 13, color: _textMuted)),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          onPressed: _pickDocuments,
          style: OutlinedButton.styleFrom(
            backgroundColor: _fieldFill,
            foregroundColor: _brandGreen,
            side: const BorderSide(color: _fieldBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          icon: const Icon(Icons.upload_file_rounded, size: 20),
          label: Text(lang.uploadDocuments, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
      if (_uploadedFiles.isNotEmpty) ...[
        const SizedBox(height: 12),
        ..._uploadedFiles.map((file) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _fieldFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _fieldBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 18, color: _brandGreen),
              const SizedBox(width: 10),
              Expanded(child: Text(file.name, style: const TextStyle(fontSize: 13, color: _textPrimary))),
              GestureDetector(
                onTap: () => setState(() => _uploadedFiles.remove(file)),
                child: const Icon(Icons.close, size: 18, color: _textMuted),
              ),
            ],
          ),
        )),
      ],
      const SizedBox(height: 24),

      _buildPrimaryButton(label: lang.submitApplication, onTap: _handleTherapistSubmit),
    ];
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _brandGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isMultiline = maxLines > 1;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 15,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Color(0xFFB0AEA6),
        ),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMultiline ? 16 : 14,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _fieldBorder, width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _fieldBorder, width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _brandGreen, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSelector() {
    final lang = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _fieldBorder,
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                backgroundColor: Colors.white,
                selectedColor: _brandGreenLight,
                checkmarkColor: _brandGreen,
                labelStyle: TextStyle(
                  color: isSelected ? _textPrimary : _textMuted,
                  fontSize: 13,
                ),
                side: const BorderSide(color: _fieldBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          if (_selectedSpecialties.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${lang.selected}: ${_selectedSpecialties.map((s) => localizedSpecialty(s, lang)).join(', ')}',
              style: const TextStyle(
                fontSize: 13,
                color: _textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _brandGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label),
      ),
    );
  }

  Widget _buildBottomText(AppLocalizations lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${lang.haveAccount} ',
          style: const TextStyle(
            fontSize: 14,
            color: _textMuted,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.login);
          },
          child: Text(
            lang.login,
            style: const TextStyle(
              color: _brandGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordRuleRow extends StatelessWidget {
  const _PasswordRuleRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF5E6F5C) : const Color(0xFFD45C5C);
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            key: ValueKey(met),
            size: 15,
            color: color,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: color),
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? _CreateAccountScreenState._brandGreenLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isSelected
                ? _CreateAccountScreenState._textPrimary
                : _CreateAccountScreenState._textMuted,
          ),
        ),
      ),
    );
  }
}
