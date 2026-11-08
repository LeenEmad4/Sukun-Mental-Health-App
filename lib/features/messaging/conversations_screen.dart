import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import '../../main.dart';
import 'chat_room_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key, required this.isTherapist});

  final bool isTherapist;

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _dividerColor = Color(0xFFE4DDD4);

  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final filterField = widget.isTherapist ? 'therapist_id' : 'patient_id';
      final joinTable = widget.isTherapist
          ? 'patient_profiles(id, username)'
          : 'therapists(id, full_name)';

      final data = await supabase
          .from('conversations')
          .select('id, last_message, last_message_at, $joinTable')
          .eq(filterField, userId)
          .order('last_message_at', ascending: false);

      if (mounted) {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Loads people the current user has appointments with (for new conversation picker)
  Future<List<Map<String, dynamic>>> _loadContacts() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      if (widget.isTherapist) {
        // Therapist: get unique patients from appointments
        final data = await supabase
            .from('appointments')
            .select('patient_id, patient_profiles(id, username, is_anonymous)')
            .eq('therapist_id', userId)
            .inFilter('status', ['confirmed', 'completed', 'pending']);

        final seen = <String>{};
        final contacts = <Map<String, dynamic>>[];
        for (final a in data) {
          final p = a['patient_profiles'] as Map?;
          final id = p?['id'] as String?;
          if (id == null || seen.contains(id)) continue;
          seen.add(id);
          final isAnon = p?['is_anonymous'] as bool? ?? false;
          contacts.add({
            'id': id,
            'name': isAnon ? 'Anonymous Patient' : (p?['username'] as String? ?? 'Patient'),
          });
        }
        return contacts;
      } else {
        // Patient: get unique therapists from appointments
        final data = await supabase
            .from('appointments')
            .select('therapist_id, therapists(id, full_name)')
            .eq('patient_id', userId)
            .inFilter('status', ['confirmed', 'completed', 'pending']);

        final seen = <String>{};
        final contacts = <Map<String, dynamic>>[];
        for (final a in data) {
          final t = a['therapists'] as Map?;
          final id = t?['id'] as String?;
          if (id == null || seen.contains(id)) continue;
          seen.add(id);
          contacts.add({
            'id': id,
            'name': t?['full_name'] as String? ?? 'Therapist',
          });
        }
        return contacts;
      }
    } catch (_) {
      return [];
    }
  }

  Future<void> _openOrCreate(String otherId, String otherName) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final patientId = widget.isTherapist ? otherId : userId;
    final therapistId = widget.isTherapist ? userId : otherId;

    try {
      final existing = await supabase
          .from('conversations')
          .select('id')
          .eq('patient_id', patientId)
          .eq('therapist_id', therapistId)
          .maybeSingle();

      String convId;
      if (existing != null) {
        convId = existing['id'] as String;
      } else {
        final created = await supabase
            .from('conversations')
            .insert({'patient_id': patientId, 'therapist_id': therapistId})
            .select('id')
            .single();
        convId = created['id'] as String;
      }

      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          conversationId: convId,
          otherPersonId: otherId,
          otherPersonName: otherName,
          isTherapist: widget.isTherapist,
        ),
      ));
      _loadConversations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    }
  }

  Future<void> _showNewMessageSheet() async {
    final contacts = await _loadContacts();

    if (!mounted) return;

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isTherapist
                ? 'You have no patients with appointments yet.'
                : 'Book a session first to message a therapist.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  widget.isTherapist ? 'Message a Patient' : 'Message a Therapist',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: _dividerColor),
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: contacts.length,
                itemBuilder: (_, i) {
                  final c = contacts[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAE3D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 22,
                        color: _primaryGreen,
                      ),
                    ),
                    title: Text(
                      c['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openOrCreate(c['id'] as String, c['name'] as String);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _otherName(Map<String, dynamic> conv) {
    if (widget.isTherapist) {
      final p = conv['patient_profiles'] as Map?;
      return (p?['username'] as String?) ?? 'Patient';
    }
    final t = conv['therapists'] as Map?;
    return (t?['full_name'] as String?) ?? 'Therapist';
  }

  String _otherId(Map<String, dynamic> conv) {
    if (widget.isTherapist) {
      final p = conv['patient_profiles'] as Map?;
      return (p?['id'] as String?) ?? '';
    }
    final t = conv['therapists'] as Map?;
    return (t?['id'] as String?) ?? '';
  }

  String _formatTime(String? ts) {
    if (ts == null) return '';
    try {
      final d = DateTime.parse(ts).toLocal();
      final diff = DateTime.now().difference(d).inDays;
      if (diff == 0) {
        return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      }
      if (diff == 1) return 'Yesterday';
      return '${d.day}/${d.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewMessageSheet,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text(
          'New',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildHeader(lang),
              Container(height: 1, color: _dividerColor),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryGreen),
                      )
                    : _conversations.isEmpty
                        ? _buildEmpty(lang)
                        : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations lang) {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 26,
                color: _textPrimary,
              ),
              padding: const EdgeInsetsDirectional.only(start: 16),
            ),
          ),
          Text(
            lang.messages,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFFEAE3D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 38,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lang.noMessages,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              lang.noMessagesSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _textSecondary),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _showNewMessageSheet,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              widget.isTherapist ? 'Message a Patient' : 'Message a Therapist',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final conv = _conversations[i];
        final name = _otherName(conv);
        final otherId = _otherId(conv);
        final lastMsg = (conv['last_message'] as String?) ?? '';
        final time = _formatTime(conv['last_message_at'] as String?);

        return GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    conversationId: conv['id'] as String,
                    otherPersonId: otherId,
                    otherPersonName: name,
                    isTherapist: widget.isTherapist,
                  ),
                ))
                .then((_) => _loadConversations());
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAE3D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 24,
                    color: _primaryGreen,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMsg.isEmpty ? '...' : lastMsg,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
