import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/services/push_notification_service.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';
import 'pending_therapist_application_screen.dart';
import 'therapist_application.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA5A59D);

  late List<TherapistApplication> _pendingApplications;
  late List<String> _recentActivities;
  int _approvedTherapistsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _recentActivities = [];
    _pendingApplications = [];
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pending = await supabase
          .from('therapists')
          .select('id, full_name, specialties, license_number, qualifications, submitted_at, bio, phone')
          .eq('status', 'pending');

      final approved = await supabase
          .from('therapists')
          .select('id')
          .eq('status', 'approved');

      final List<TherapistApplication> applications = [];
      for (final t in pending) {
        final docs = await supabase
            .from('therapist_documents')
            .select('file_name, file_url')
            .eq('therapist_id', t['id']);

        applications.add(TherapistApplication(
          id: t['id'],
          name: t['full_name'] ?? '',
          specialty: (t['specialties'] as List).join(', '),
          licenseNumber: t['license_number'] ?? '',
          qualifications: t['qualifications'] ?? '',
          submissionDate: t['submitted_at']?.toString().substring(0, 10) ?? '',
          bio: t['bio'] ?? '',
          phone: t['phone'] ?? '',
          documents: (docs as List).map((d) => d['file_name'] as String).toList(),
          documentUrls: (docs as List).map((d) => d['file_url'] as String).toList(),
        ));
      }

      if (!mounted) return;
      setState(() {
        _pendingApplications = applications;
        _approvedTherapistsCount = (approved as List).length;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }

  Future<void> _handleApprove(String id, String name) async {
    final lang = AppLocalizations.of(context)!;
    try {
      await supabase
          .from('therapists')
          .update({'status': 'approved'})
          .eq('id', id);

      await supabase.from('admin_activity_log').insert({
        'admin_id': supabase.auth.currentUser!.id,
        'description': lang.approvedAsTherapist(name),
      });

      setState(() {
        _approvedTherapistsCount += 1;
        _recentActivities.insert(0, lang.approvedAsTherapist(name));
        _removeApplicationByName(name);
      });

      try {
        await supabase.from('notifications').insert({
          'user_id': id,
          'title': 'Application approved',
          'body': 'Congratulations! Your therapist application has been approved. You can now access your dashboard.',
          'type': 'application_approved',
        });
      } catch (e) {
        debugPrint('Notification insert failed (non-blocking): $e');
      }

      await PushNotificationService.sendPushToUser(
        userId: id,
        title: 'Application approved',
        body: 'Congratulations! Your therapist application has been approved.',
      );
    } catch (e) {
      debugPrint('Error approving: $e');
    }
  }

  Future<void> _handleReject(String id, String name) async {
    final lang = AppLocalizations.of(context)!;
    try {
      await supabase
          .from('therapists')
          .update({'status': 'rejected'})
          .eq('id', id);

      await supabase.from('admin_activity_log').insert({
        'admin_id': supabase.auth.currentUser!.id,
        'description': lang.applicationRejected(name),
      });

      setState(() {
        _recentActivities.insert(0, lang.applicationRejected(name));
        _removeApplicationByName(name);
      });

      try {
        await supabase.from('notifications').insert({
          'user_id': id,
          'title': 'Application not approved',
          'body': 'We are sorry to inform you that your therapist application was not approved at this time.',
          'type': 'application_rejected',
        });
      } catch (e) {
        debugPrint('Notification insert failed (non-blocking): $e');
      }
    } catch (e) {
      debugPrint('Error rejecting: $e');
    }
  }

  Future<void> _openPendingApplication(TherapistApplication application) async {
    final result = await Navigator.of(context).push<TherapistApplicationAction>(
      MaterialPageRoute(
        builder: (_) => PendingTherapistApplicationScreen(application: application),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    switch (result) {
      case TherapistApplicationAction.approve:
        _handleApprove(application.id, application.name);
        break;
      case TherapistApplicationAction.reject:
        _handleReject(application.id, application.name);
        break;
      default:
        break;
    }
  }

  void _removeApplicationByName(String name) {
    _pendingApplications = _pendingApplications
        .where((application) => application.name != name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final pendingCount = _pendingApplications.length;
    final approvedCount = _approvedTherapistsCount;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(lang),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      title: lang.pendingApplications,
                      count: '$pendingCount',
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFFE4A47E),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _OverviewCard(
                      title: lang.approvedTherapists,
                      count: '$approvedCount',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF9BAE98),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildRecentActivityCard(lang),
              const SizedBox(height: 18),
              Text(
                lang.pendingApplications,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 15),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingApplications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final application = _pendingApplications[index];
                  return _PendingApplicationCard(
                    therapistName: application.name,
                    specialty: localizedSpecialties(application.specialty, lang),
                    license: '${application.licenseNumber}, ${application.qualifications}',
                    documents: lang.documentsSubmittedCount(application.documents.length),
                    submissionDate: lang.submittedOn(application.submissionDate),
                    onTap: () => _openPendingApplication(application),
                    onApprove: () => _handleApprove(application.id, application.name),
                    onReject: () => _handleReject(application.id, application.name),
                    onViewDetails: () => _openPendingApplication(application),
                    approveLabel: lang.accept,
                    rejectLabel: lang.reject,
                    viewDetailsLabel: lang.viewDetails,
                  );
                },
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E1D8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  lang.allActionsAffectAccounts,
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
    );
  }

  Widget _buildTopBar(AppLocalizations lang) {
    return Row(
      children: [
        Expanded(
          child: Text(
            lang.adminDashboard,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(
            Icons.logout_rounded,
            color: _primaryGreen,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard(AppLocalizations lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD9DCD3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 18,
                color: _textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                lang.recentActivity,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._recentActivities.take(4).map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '- $activity',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            count,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              height: 1.25,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingApplicationCard extends StatelessWidget {
  const _PendingApplicationCard({
    required this.therapistName,
    required this.specialty,
    required this.license,
    required this.documents,
    required this.submissionDate,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetails,
    required this.approveLabel,
    required this.rejectLabel,
    required this.viewDetailsLabel,
  });

  final String therapistName;
  final String specialty;
  final String license;
  final String documents;
  final String submissionDate;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;
  final String approveLabel;
  final String rejectLabel;
  final String viewDetailsLabel;

  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _mutedGreen = Color(0xFFBFC5B9);
  static const Color _rejectRed = Color(0xFFE57373);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _textMuted = Color(0xFFA5A59D);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                therapistName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                specialty,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                license,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                documents,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                submissionDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: approveLabel,
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      icon: Icons.check_rounded,
                      onTap: onApprove,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: rejectLabel,
                      backgroundColor: const Color(0xFFFFF7F7),
                      foregroundColor: _rejectRed,
                      borderColor: _rejectRed,
                      icon: Icons.close_rounded,
                      onTap: onReject,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: viewDetailsLabel,
                  backgroundColor: _mutedGreen,
                  foregroundColor: _textPrimary,
                  icon: Icons.visibility_outlined,
                  onTap: onViewDetails,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
    this.borderColor,
  });
  

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final hasBorder = borderColor != null;

    return SizedBox(
      height: 40,
      
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side:
              hasBorder ? BorderSide(color: borderColor!, width: 1) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(label),
      ),
      
    );
    
  }
}
