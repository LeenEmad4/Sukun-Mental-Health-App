import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';

import '../../main.dart';

class ApplicationPendingScreen extends StatelessWidget {
  const ApplicationPendingScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen    = Color(0xFF6B7E67);
  static const Color _softGreen       = Color(0xFFC7CEBF);
  static const Color _cardColor       = Color(0xFFFFFFFF);
  static const Color _textPrimary     = Color(0xFF4D514A);
  static const Color _textSecondary   = Color(0xFF8B8E86);

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: _softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 52,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                lang.applicationSubmitted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  lang.applicationPendingMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: _textSecondary,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(lang.backToLogin),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
