import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/services/push_notification_service.dart';
import 'package:sukun/utils/error_handler.dart';
import 'package:sukun/utils/perf.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPatientSelected = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _brandGreen = Color(0xFF6B7E67);
  static const Color _brandGreenLight = Color(0xFFC2C7B7);
  static const Color _textPrimary = Color(0xFF4B5048);
  static const Color _textMuted = Color(0xFF919388);
  static const Color _fieldFill = Color(0xFFF1EBE3);
  static const Color _fieldBorder = Color(0xFFC6CCBB);

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogin() async {
    final lang = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) { _showMessage(lang.enterEmail); return; }
    if (password.isEmpty) { _showMessage(lang.enterPassword); return; }

    setState(() => _isLoading = true);

    try {
      final response = await timeAsync('auth_login', () => supabase.auth.signInWithPassword(
        email: email,
        password: password,
      ));

      final profile = await supabase
          .from('profiles')
          .select('role, full_name')
          .eq('id', response.user!.id)
          .single();

      final role = profile['role'] as String;

      // Save this device's push token for the logged-in user (non-blocking).
      // Done before the mounted check because it does not use context.
      await PushNotificationService.saveTokenForUser(response.user!.id);

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else if (role == 'therapist') {
        final therapist = await supabase
            .from('therapists')
            .select('status')
            .eq('id', response.user!.id)
            .single();

        final status = therapist['status'] as String;

        if (!mounted) return;

        if (status == 'pending') {
          Navigator.of(context).pushReplacementNamed(AppRoutes.applicationPending);
        } else if (status == 'approved') {
          if (!_isPatientSelected) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.therapistDashboard,
              arguments: {
                'isLoggedIn': true,
                'hasTherapistAccess': true,
                'therapistName': profile['full_name'] ?? 'Therapist',
              },
            );
          } else {
            _showMessage(lang.invalidCredentials);
          }
        } else {
          _showMessage(lang.applicationRejectedSupport);
        }
      } else {
        if (_isPatientSelected) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.patientHome);
        } else {
          _showMessage(lang.invalidCredentials);
        }
      }

    } catch (e) {
      _showMessage(friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final cardWidth = screenWidth > 420 ? 382.0 : double.infinity;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildLogoSection(),
                  const SizedBox(height: 18),
                  _buildRoleToggle(),
                  const SizedBox(height: 14),
                  _buildFormCard(lang),
                  const SizedBox(height: 22),
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

  Widget _buildRoleToggle() {
    final lang = AppLocalizations.of(context)!;

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
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(lang.email),
          const SizedBox(height: 10),
          _buildInputField(
            hintText: lang.emailHint,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 18),
          _buildFieldLabel(lang.password),
          const SizedBox(height: 10),
          _buildInputField(
            hintText: lang.passwordHint,
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: _textMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.resetPassword);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: _textMuted,
              ),
              child: Text(
                lang.forgotPassword,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(lang.login),
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
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _fieldBorder, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _fieldBorder, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _brandGreen, width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomText(AppLocalizations lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${lang.noAccount} ',
          style: const TextStyle(
            fontSize: 14,
            color: _textMuted,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.register);
          },
          child: Text(
            lang.signup,
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
          color: isSelected ? _LoginScreenState._brandGreenLight : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isSelected ? _LoginScreenState._textPrimary : _LoginScreenState._textMuted,
          ),
        ),
      ),
    );
  }
}
