import 'dart:ui';

import 'package:flutter/material.dart';

import '../../main.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  Future<void> _returnHome(BuildContext context) async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.welcome,
          (_) => false,
        );
      }
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select('role, full_name')
          .eq('id', session.user.id)
          .single();

      if (!context.mounted) return;

      final role = profile['role'] as String;
      if (role == 'admin') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.adminDashboard,
          (_) => false,
        );
      } else if (role == 'therapist') {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.therapistDashboard,
          (_) => false,
          arguments: {
            'isLoggedIn': true,
            'hasTherapistAccess': true,
            'therapistName': profile['full_name'] ?? 'Therapist',
          },
        );
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.patientHome, (_) => false);
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
      }
    }
  }

  void _refresh(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFEA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CirclesGraphic(),
              const SizedBox(height: 44),
              const Text(
                'Take a deep breath.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C5049),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "We couldn't find the page you're looking for, or something went wrong on our end. Don't worry, we can help you find your way back to your safe space.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: Color(0xFF8F9189),
                ),
              ),
              const SizedBox(height: 44),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _returnHome(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF6B7E67),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Return to Home'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _refresh(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8F9189),
                    side: const BorderSide(color: Color(0xFFD0CCC6), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Refresh Page'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CirclesGraphic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8FA688).withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8909A).withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
