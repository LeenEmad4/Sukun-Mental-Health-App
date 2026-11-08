import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'my_appointements_screen.dart';
import 'patient_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _softGreen = Color(0xFFC7CEBF);
  static const Color _softPink = Color(0xFFF3E6DE);
  static const Color _textPrimary = Color(0xFF4C5049);
  static const Color _textSecondary = Color(0xFF8F9189);
  static const Color _fieldFill = Color(0xFFF6F0E9);
  static const Color _fieldBorder = Color(0xFFA8B29F);
  static const Color _dividerColor = Color(0xFFD8D0C8);

  late final TextEditingController _publicUsernameController;
  late final TextEditingController _realNameController;
  late final TextEditingController _emailController;

  bool _isPrivacyModeEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _publicUsernameController = TextEditingController();
    _realNameController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final profile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .single();

      final patientProfile = await supabase
          .from('patient_profiles')
          .select('username, is_anonymous')
          .eq('id', userId)
          .single();

      if (!mounted) return;
      setState(() {
        _realNameController.text = profile['full_name'] ?? '';
        _emailController.text = supabase.auth.currentUser!.email ?? '';
        _publicUsernameController.text = patientProfile['username'] ?? '';
        _isPrivacyModeEnabled = patientProfile['is_anonymous'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _publicUsernameController.dispose();
    _realNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    final lang = AppLocalizations.of(context)!;
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('patient_profiles').update({
        'username': _publicUsernameController.text.trim(),
        'is_anonymous': _isPrivacyModeEnabled,
      }).eq('id', userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.changesSaved)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    }
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  void _showHotlinesSheet(AppLocalizations lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EFEA),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE57373),
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  lang.crisisYouAreNotAlone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE57373),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lang.crisisContactProfessionals,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D8E87),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                _HotlineButton(
                  label: lang.crisisJordanEmergency,
                  number: '0795440416',
                  color: const Color(0xFFE57373),
                ),
                const SizedBox(height: 10),
                _HotlineButton(
                  label: lang.crisisNationalMentalHealth,
                  number: '06-4729018',
                  color: const Color(0xFF5E6F5C),
                ),
                const SizedBox(height: 10),
                _HotlineButton(
                  label: lang.crisisFamilyProtection,
                  number: '065815846',
                  color: const Color(0xFF8D8E87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMyAppointmentsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyAppointmentsScreen(),
      ),
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
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            children: [
              Center(
                child: Text(
                  lang.profile,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: _textPrimary,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: _dividerColor,
              ),
              const SizedBox(height: 18),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildSectionCard(
                backgroundColor: _softGreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.profileInformation,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildLabeledTextField(
                      label: lang.publicUsername,
                      controller: _publicUsernameController,
                    ),
                    const SizedBox(height: 14),
                    _buildLabeledTextField(
                      label: lang.realName,
                      controller: _realNameController,
                    ),
                    const SizedBox(height: 14),
                    _buildLabeledTextField(
                      label: lang.emailAddress,
                      controller: _emailController,
                      readOnly: true,
                      enabled: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                backgroundColor: _softPink,
                borderColor: const Color(0xFFE8D1C4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.publicPrivacyMode,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      lang.privacyModeDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _textSecondary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Transform.translate(
                      offset: const Offset(-8, 0),
                      child: Switch(
                        value: _isPrivacyModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isPrivacyModeEnabled = value;
                          });
                        },
                        activeThumbColor: Colors.white,
                        activeTrackColor: _primaryGreen,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFCBD2C4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildActionCard(
                title: lang.myAppointments,
                subtitle: lang.myAppointmentsSubtitle,
                icon: Icons.calendar_month_rounded,
                onTap: _handleMyAppointmentsTap,
              ),
              const SizedBox(height: 18),
              _buildHotlinesCard(lang),
              const SizedBox(height: 18),
              _buildLanguageCard(lang),
              const SizedBox(height: 18),
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
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(lang.saveChanges),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _softGreen,
                    foregroundColor: _textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                  ),
                  label: Text(lang.logOut),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PatientBottomNavBar(
        currentTab: PatientNavTab.profile,
        onToggleLanguage: widget.onToggleLanguage,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: _softGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 36,
            color: _primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isLoading ? '' : _realNameController.text,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w400,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isLoading ? '' : _emailController.text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required Color backgroundColor,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _softGreen,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: _primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: _primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(AppLocalizations lang) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: _primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.language,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang.languageSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LanguageChip(
                  label: lang.english,
                  isSelected: !isArabic,
                  onTap: () {
                    if (isArabic) widget.onToggleLanguage?.call();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LanguageChip(
                  label: lang.arabic,
                  isSelected: isArabic,
                  onTap: () {
                    if (!isArabic) widget.onToggleLanguage?.call();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            enabled: enabled,
            style: TextStyle(
              fontSize: 15,
              color: enabled ? _textPrimary : const Color(0xFF9E9E95),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? _fieldFill : const Color(0xFFE6E5DB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _fieldBorder,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _fieldBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _primaryGreen,
                  width: 1.3,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotlinesCard(AppLocalizations lang) {
    return Material(
      color: const Color(0xFFFBECEC),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => _showHotlinesSheet(lang),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE57373),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.crisisHotlines,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4C5049),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang.crisisTapToView,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFE57373).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFFE57373),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _textPrimary = Color(0xFF4C5049);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryGreen
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _textPrimary,
          ),
        ),
      ),
    );
  }
}

class _HotlineButton extends StatelessWidget {
  const _HotlineButton({
    required this.label,
    required this.number,
    required this.color,
  });

  final String label;
  final String number;
  final Color color;

  Future<void> _dial() async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll('-', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dial,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
