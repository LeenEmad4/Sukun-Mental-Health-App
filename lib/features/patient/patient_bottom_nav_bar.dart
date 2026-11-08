import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';

import '../../main.dart';

enum PatientNavTab {
  home,
  chat,
  sessions,
  profile,
}

class PatientBottomNavBar extends StatelessWidget {
  const PatientBottomNavBar({
    super.key,
    required this.currentTab,
    this.onToggleLanguage,
  });

  final PatientNavTab currentTab;
  final VoidCallback? onToggleLanguage;

  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _activeNav = Color(0xFF6E7F68);
  static const Color _inactiveNav = Color(0xFF7F857B);

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      decoration: const BoxDecoration(
        color: _backgroundColor,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE6DED6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home_outlined,
            label: lang.home,
            isActive: currentTab == PatientNavTab.home,
            onTap: () => _handleTabTap(context, PatientNavTab.home),
          ),
          _BottomNavItem(
            icon: Icons.access_time_rounded,
            label: lang.sessions,
            isActive: currentTab == PatientNavTab.sessions,
            onTap: () => _handleTabTap(context, PatientNavTab.sessions),
          ),
          _BottomNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: lang.chat,
            isActive: currentTab == PatientNavTab.chat,
            onTap: () => _handleTabTap(context, PatientNavTab.chat),
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: lang.profile,
            isActive: currentTab == PatientNavTab.profile,
            onTap: () => _handleTabTap(context, PatientNavTab.profile),
          ),
        ],
      ),
    );
  }

  void _handleTabTap(BuildContext context, PatientNavTab destination) {
    if (destination == currentTab) return;

    if (destination == PatientNavTab.chat) {
      Navigator.of(context)
        ..pushReplacementNamed(AppRoutes.patientHome)
        ..pushNamed(AppRoutes.chatSessions);
      return;
    }

    final routes = {
      PatientNavTab.home:     AppRoutes.patientHome,
      PatientNavTab.sessions: AppRoutes.browseTherapists,
      PatientNavTab.profile:  AppRoutes.patientProfile,
    };

    Navigator.of(context).pushReplacementNamed(routes[destination]!);
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? PatientBottomNavBar._activeNav
        : PatientBottomNavBar._inactiveNav;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: color,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
