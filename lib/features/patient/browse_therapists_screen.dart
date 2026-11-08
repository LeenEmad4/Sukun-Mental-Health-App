import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/specialty_labels.dart';
import 'package:sukun/utils/perf.dart';

import '../../main.dart';
import 'patient_bottom_nav_bar.dart';

class BrowseTherapistsScreen extends StatefulWidget {
  const BrowseTherapistsScreen({super.key});

  @override
  State<BrowseTherapistsScreen> createState() => _BrowseTherapistsScreenState();
}

class _BrowseTherapistsScreenState extends State<BrowseTherapistsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _cardColor = Color(0xFFFFFCF8);
  static const Color _textPrimary = Color(0xFF4B5048);
  static const Color _textSecondary = Color(0xFF7D8278);
  static const Color _textMuted = Color(0xFF9B9A94);
  static const Color _fieldBorder = Color(0xFFD8D1C8);

  late final TextEditingController _searchController;

  List<Map<String, dynamic>> _allTherapists = [];
  List<Map<String, dynamic>> _filteredTherapists = [];
  bool _isLoading = true;

  String? _selectedSpecialty;
  String _selectedSort = 'none';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadTherapists();
  }

  Future<void> _loadTherapists() async {
    try {
      final therapists = await timeAsync('browse_therapists_load', () async {
        final data = await supabase
            .from('therapists')
            .select('id, full_name, specialties, bio, qualifications, session_rate, years_of_experience')
            .eq('status', 'approved');

        final List<Map<String, dynamic>> therapists = (data as List).map((t) {
          return {
            'id': t['id'],
            'name': t['full_name'] ?? '',
            'specialty': (t['specialties'] as List).join(', '),
            'description': t['bio'] ?? '',
            'qualifications': t['qualifications'] ?? '',
            'price': '${t['session_rate'] ?? 0} JD per session',
            'session_rate': t['session_rate'] ?? 0,
            'years_of_experience': t['years_of_experience'] ?? 0,
            'avg_rating': 0.0,
            'review_count': 0,
          };
        }).toList();

        // Fetch ratings for all therapists in one query
        if (therapists.isNotEmpty) {
          final ids = therapists.map((t) => t['id'] as String).toList();
          final reviews = await supabase
              .from('reviews')
              .select('therapist_id, rating')
              .inFilter('therapist_id', ids);

          final Map<String, List<int>> ratingMap = {};
          for (final r in (reviews as List)) {
            final tid = r['therapist_id'] as String;
            final rating = r['rating'] as int;
            ratingMap.putIfAbsent(tid, () => []).add(rating);
          }

          for (final t in therapists) {
            final ratings = ratingMap[t['id']] ?? [];
            if (ratings.isNotEmpty) {
              t['avg_rating'] = ratings.reduce((a, b) => a + b) / ratings.length;
              t['review_count'] = ratings.length;
            }
          }
        }

        return therapists;
      });

      if (!mounted) return;
      setState(() {
        _allTherapists = therapists;
        _filteredTherapists = therapists;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _applyFilters();
  }

  void _handleFilterTap() {
    final lang = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EFEA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.filterTherapists,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5048),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lang.specialty,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF7D8278)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Anxiety', 'Depression', 'Trauma',
                      'Stress Management', 'Family Therapy', 'CBT',
                    ].map((specialty) {
                      final isSelected = _selectedSpecialty == specialty;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedSpecialty = isSelected ? null : specialty;
                          });
                          setState(() {
                            _selectedSpecialty = isSelected ? null : specialty;
                          });
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6B7E67) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFD8D1C8)),
                          ),
                          child: Text(
                            localizedSpecialty(specialty, lang),
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : const Color(0xFF4B5048),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lang.sortByPrice,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF7D8278)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SortChip(
                        label: lang.lowToHigh,
                        isSelected: _selectedSort == 'low',
                        onTap: () {
                          final newSort = _selectedSort == 'low' ? 'none' : 'low';
                          setModalState(() => _selectedSort = newSort);
                          setState(() => _selectedSort = newSort);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: lang.highToLow,
                        isSelected: _selectedSort == 'high',
                        onTap: () {
                          final newSort = _selectedSort == 'high' ? 'none' : 'high';
                          setModalState(() => _selectedSort = newSort);
                          setState(() => _selectedSort = newSort);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSpecialty = null;
                          _selectedSort = 'none';
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF6B7E67),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(lang.clearFilters),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(_allTherapists);

    if (_selectedSpecialty != null) {
      result = result.where((t) {
        final specialty = (t['specialty'] as String).toLowerCase();
        return specialty.contains(_selectedSpecialty!.toLowerCase());
      }).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      final lang = AppLocalizations.of(context)!;
      result = result.where((t) {
        final name = (t['name'] as String).toLowerCase();
        final specialtyEn = (t['specialty'] as String).toLowerCase();
        final specialtyLocalized =
            localizedSpecialties(t['specialty'] as String, lang).toLowerCase();
        return name.contains(query) ||
            specialtyEn.contains(query) ||
            specialtyLocalized.contains(query);
      }).toList();
    }

    if (_selectedSort == 'low') {
      result.sort((a, b) {
        final aRate = (a['session_rate'] ?? 0) as num;
        final bRate = (b['session_rate'] ?? 0) as num;
        return aRate.compareTo(bRate);
      });
    } else if (_selectedSort == 'high') {
      result.sort((a, b) {
        final aRate = (a['session_rate'] ?? 0) as num;
        final bRate = (b['session_rate'] ?? 0) as num;
        return bRate.compareTo(aRate);
      });
    }

    setState(() => _filteredTherapists = result);
  }

  void _openTherapistProfile(Map<String, dynamic> therapist) {
    Navigator.of(context).pushNamed(AppRoutes.therapistDetails, arguments: therapist);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.browseTherapists,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: _textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _fieldBorder, width: 1),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _handleSearch,
                              style: const TextStyle(fontSize: 14, color: _textPrimary),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.search_rounded, color: _textMuted, size: 20),
                                hintText: lang.searchTherapists,
                                hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
                                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _handleFilterTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _fieldBorder, width: 1),
                              ),
                              child: const Icon(Icons.tune_rounded, size: 20, color: _textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _filteredTherapists.isEmpty
                          ? Center(
                              child: Text(
                                lang.noTherapistsFound,
                                style: const TextStyle(color: _textMuted),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredTherapists.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final therapist = _filteredTherapists[index];
                                return _TherapistCard(
                                  therapist: therapist,
                                  onViewProfile: () => _openTherapistProfile(therapist),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const PatientBottomNavBar(
        currentTab: PatientNavTab.sessions,
      ),
    );
  }

}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
    required this.therapist,
    required this.onViewProfile,
  });

  final Map<String, dynamic> therapist;
  final VoidCallback onViewProfile;

  static const Color _cardColor = Color(0xFFFFFCF8);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _textPrimary = Color(0xFF4B5048);
  static const Color _textSecondary = Color(0xFF7D8278);
  static const Color _textMuted = Color(0xFF9B9A94);

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            therapist['name'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: _textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizedSpecialties(therapist['specialty'] as String, lang),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
              height: 1.25,
            ),
          ),
          if ((therapist['review_count'] as int) > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final avg = (therapist['avg_rating'] as double);
                  return Icon(
                    i < avg.floor()
                        ? Icons.star_rounded
                        : (i < avg && avg - i >= 0.5)
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                    size: 15,
                    color: const Color(0xFFD4A843),
                  );
                }),
                const SizedBox(width: 5),
                Text(
                  '${(therapist['avg_rating'] as double).toStringAsFixed(1)}  (${therapist['review_count']})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            therapist['description'] as String,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: _textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang.pricePerSession((therapist['session_rate'] as num?) ?? 0),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: onViewProfile,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text(lang.viewProfile),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B7E67) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD8D1C8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF4B5048),
          ),
        ),
      ),
    );
  }
}
