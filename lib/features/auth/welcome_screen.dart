import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';

import '../../main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onToggleLanguage = _defaultOnToggleLanguage,
  });

  static void _defaultOnToggleLanguage() {}

  final VoidCallback onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFEA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        onPressed: onToggleLanguage,
                        icon: const Icon(Icons.language_rounded),
                        label: Text(lang.changeLanguage),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5E6F5C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'sukun',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3E4A3F),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.self_improvement_rounded,
                          size: 110,
                          color: Color(0xFF5E6F5C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      lang.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4A3F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lang.welcome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E4A3F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lang.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E6F5C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.login);
                        },
                        child: Text(
                          lang.login,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5E6F5C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.register);
                        },
                        child: Text(
                          lang.signup,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5E6F5C),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
