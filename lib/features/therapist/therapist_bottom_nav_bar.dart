import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';

enum TherapistNavTab {
  dashboard,
  availability,
  requests,
  profile,
}

class TherapistBottomNavBar extends StatelessWidget {
  const TherapistBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final TherapistNavTab currentTab;
  final ValueChanged<TherapistNavTab> onTabSelected;

  static const Color backgroundColor = Color(0xFFF4EFEA);
  static const Color activeColor = Color(0xFF5E6F5C);
  static const Color inactiveColor = Color(0xFFBFC5B9);

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      decoration: const BoxDecoration(
        color: backgroundColor,
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
          _TherapistNavItem(
            icon: Icons.space_dashboard_outlined,
            label: lang.navDashboard,
            isActive: currentTab == TherapistNavTab.dashboard,
            onTap: () => onTabSelected(TherapistNavTab.dashboard),
          ),
          _TherapistNavItem(
            icon: Icons.calendar_month_outlined,
            label: lang.navAvailability,
            isActive: currentTab == TherapistNavTab.availability,
            onTap: () => onTabSelected(TherapistNavTab.availability),
          ),
          _TherapistNavItem(
            icon: Icons.mail_outline_rounded,
            label: lang.navRequests,
            isActive: currentTab == TherapistNavTab.requests,
            onTap: () => onTabSelected(TherapistNavTab.requests),
          ),
          _TherapistNavItem(
            icon: Icons.person_outline_rounded,
            label: lang.navProfile,
            isActive: currentTab == TherapistNavTab.profile,
            onTap: () => onTabSelected(TherapistNavTab.profile),
          ),
        ],
      ),
    );
  }
}

class _TherapistNavItem extends StatelessWidget {
  const _TherapistNavItem({
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
        ? TherapistBottomNavBar.activeColor
        : TherapistBottomNavBar.inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
