import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/specialty_labels.dart';

import '../../main.dart';

class TherapistDetailsScreen extends StatefulWidget {
  const TherapistDetailsScreen({
    super.key,
    this.therapist,
  });

  final Map<String, dynamic>? therapist;

  @override
  State<TherapistDetailsScreen> createState() => _TherapistDetailsScreenState();
}

class _TherapistDetailsScreenState extends State<TherapistDetailsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _softGreen = Color(0xFFC6CDBF);
  static const Color _avatarCircle = Color(0xFFAFB7A9);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _textPrimary = Color(0xFF4C5149);
  static const Color _textSecondary = Color(0xFF7F847B);
  static const Color _textMuted = Color(0xFF92958D);
  static const Color _dividerColor = Color(0xFFE2D9D0);
  static const Color _priceBoxColor = Color(0xFFF2ECE5);
  static const Color _priceBorderColor = Color(0xFFD6CEC4);

  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0;
  bool _reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final therapistId = widget.therapist?['id'] as String?;
    if (therapistId == null) {
      if (mounted) setState(() => _reviewsLoading = false);
      return;
    }
    try {
      final data = await supabase
          .from('reviews')
          .select('rating, comment, created_at, patient_profiles(username, is_anonymous), profiles(full_name)')
          .eq('therapist_id', therapistId)
          .order('created_at', ascending: false)
          .limit(10);
      if (!mounted) return;
      final reviews = List<Map<String, dynamic>>.from(data);
      double avg = 0;
      if (reviews.isNotEmpty) {
        avg = reviews.fold<double>(0, (sum, r) => sum + (r['rating'] as int)) /
            reviews.length;
      }
      setState(() {
        _reviews = reviews;
        _averageRating = avg;
        _reviewsLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  void _handleBookSession() {
    final lang = AppLocalizations.of(context)!;
    Navigator.of(context).pushNamed(
      AppRoutes.bookSession,
      arguments: widget.therapist ?? _buildDummyTherapist(lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final therapistData = widget.therapist ?? _buildDummyTherapist(lang);

    // Handle qualifications - can be String or List
    List<String> qualifications;
    final rawQualifications = therapistData['qualifications'];
    if (rawQualifications is List) {
      qualifications = List<String>.from(rawQualifications);
    } else if (rawQualifications is String && rawQualifications.isNotEmpty) {
      qualifications = [rawQualifications];
    } else {
      qualifications = [];
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: _handleBack,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: _textPrimary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      Center(
                        child: Text(
                          lang.therapistDetails,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: _dividerColor,
                ),
                const SizedBox(height: 18),
                _buildHeaderCard(therapistData),
                const SizedBox(height: 20),
                _buildSectionTitle(lang.about),
                const SizedBox(height: 10),
                Text(
                  (therapistData['about'] as String?) ??
                  (therapistData['description'] as String?) ??
                  '',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                _buildIconSectionTitle(
                  icon: Icons.verified_user_outlined,
                  title: lang.qualifications,
                ),
                const SizedBox(height: 12),
                ...qualifications.map(_buildBulletItem),
                const SizedBox(height: 22),
                _buildIconSectionTitle(
                  icon: Icons.calendar_today_outlined,
                  title: lang.availability,
                ),
                const SizedBox(height: 10),
                Text(
                  (therapistData['availability'] as String?) ?? lang.contactForAvailability,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                _buildPriceBox(locale),
                const SizedBox(height: 22),
                _buildReviewsSection(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleBookSession,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(lang.bookSession),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> therapistData) {
    final lang = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: _avatarCircle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 42,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            therapistData['name'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizedSpecialties(therapistData['specialty'] as String, lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildIconSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: _primaryGreen,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.circle,
              size: 6,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String locale) {
    final lang = AppLocalizations.of(context)!;
    final therapistData = widget.therapist ?? _buildDummyTherapist(lang);
    final localizedPrice = lang.pricePerSession((therapistData['session_rate'] as num?) ?? 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _priceBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _priceBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            lang.sessionPrice,
            style: const TextStyle(
              fontSize: 14,
              color: _textMuted,
            ),
          ),
          const Spacer(),
          Text(
            localizedPrice,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18, color: _primaryGreen),
            const SizedBox(width: 8),
            Text(
              _reviews.isEmpty ? 'Reviews' : 'Reviews (${_reviews.length})',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary),
            ),
            if (_reviews.isNotEmpty) ...[
              const Spacer(),
              Text(
                '${_averageRating.toStringAsFixed(1)} / 5',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryGreen),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (_reviewsLoading)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No reviews yet.',
              style: TextStyle(fontSize: 14, color: _textMuted),
            ),
          )
        else
          ...(_reviews.take(5).map((review) {
            final rating = review['rating'] as int;
            final comment = review['comment'] as String?;
            final patient = review['patient_profiles'] as Map?;
            final profileData = review['profiles'] as Map?;
            final isAnon = patient?['is_anonymous'] as bool? ?? false;
            final String displayName;
            if (isAnon) {
              displayName = (patient?['username'] as String?)?.isNotEmpty == true
                  ? patient!['username'] as String
                  : 'Anonymous';
            } else {
              displayName = (profileData?['full_name'] as String?)?.isNotEmpty == true
                  ? profileData!['full_name'] as String
                  : (patient?['username'] as String? ?? 'Patient');
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: _primaryGreen,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontSize: 12, color: _textMuted),
                      ),
                    ],
                  ),
                  if (comment != null && comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      comment,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: _textSecondary),
                    ),
                  ],
                ],
              ),
            );
          }).toList()),
      ],
    );
  }

  Map<String, dynamic> _buildDummyTherapist(AppLocalizations lang) {
    return {
      'name': 'Dr. Leila Ahmed',
      'specialty': lang.anxietyDepression,
      'about': lang.leilaAbout,
      'qualifications': [
        lang.leilaQualification1,
        lang.leilaQualification2,
      ],
      'availability': lang.leilaAvailability,
      'price': lang.sessionPriceValue,
    };
  }

}
