import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import '../../main.dart';
import 'chatbot_screen.dart';

class ChatSessionsScreen extends StatefulWidget {
  const ChatSessionsScreen({super.key});

  @override
  State<ChatSessionsScreen> createState() => _ChatSessionsScreenState();
}

class _ChatSessionsScreenState extends State<ChatSessionsScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _dividerColor = Color(0xFFE4DDD4);

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final data = await supabase
          .from('chat_sessions')
          .select('id, title, created_at, started_at')
          .eq('patient_id', userId)
          .order('started_at', ascending: false);

      if (mounted) {
        setState(() {
          _sessions = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startNewChat() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChatbotScreen(),
      ),
    ).then((_) => _loadSessions());
  }

  Future<void> _openSession(Map<String, dynamic> session) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatbotScreen(sessionId: session['id']),
      ),
    ).then((_) => _loadSessions());
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await supabase
          .from('chat_messages')
          .delete()
          .eq('session_id', sessionId);

      await supabase
          .from('chat_sessions')
          .delete()
          .eq('id', sessionId);

      setState(() {
        _sessions.removeWhere((s) => s['id'] == sessionId);
      });
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
  }

  String _formatDate(String createdAt) {
    final lang = AppLocalizations.of(context)!;
    try {
    final date = DateTime.parse(createdAt).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return lang.today;
    if (diff == 1) return lang.yesterday;
    if (diff < 7) return lang.daysAgo(diff);
    return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return lang.recent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B7E67),
                      ),
                    )
                  : _sessions.isEmpty
                      ? _buildEmptyState()
                      : _buildSessionsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          lang.newChat,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final lang = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
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
                    size: 28,
                    color: _textPrimary,
                  ),
                  padding: const EdgeInsetsDirectional.only(start: 16),
                ),
              ),
              Center(
                child: Text(
                  lang.chatTitle,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _dividerColor),
      ],
    );
  }

  Widget _buildEmptyState() {
    final lang = AppLocalizations.of(context)!;
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
              Icons.favorite_border_rounded,
              size: 38,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lang.noConversationsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lang.tapToStartChat,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    final lang = AppLocalizations.of(context)!;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return Dismissible(
          key: Key(session['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE57373),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (_) => _deleteSession(session['id']),
          child: GestureDetector(
            onTap: () => _openSession(session),
            child: Container(
              padding: const EdgeInsets.all(18),
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
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAE3D9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 22,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['title'] ?? lang.chatSession,
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
                          _formatDate(session['created_at'] ?? session['started_at'] ?? DateTime.now().toIso8601String()),
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
