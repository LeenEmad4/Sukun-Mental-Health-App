import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/perf.dart';
import '../../main.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key, this.sessionId});
  final String? sessionId;

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _dividerColor = Color(0xFFE4DDD4);
  static const Color _primaryGreen = Color(0xFF6B7E67);
  static const Color _softGreen = Color(0xFFC4CBBC);
  static const Color _softCircle = Color(0xFFEAE3D9);
  static const Color _inputBorder = Color(0xFFBAC3B2);
  static const Color _inputFill = Color(0xFFFFFCF8);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _botBubble = Color(0xFFECE5DB);
  static const Color _userBubble = Color(0xFF6B7E67);

  late final TextEditingController _messageController;
  late final ScrollController _scrollController;

  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, String>> _conversationHistory = [];
  bool _isTyping = false;
  bool _isCrisisMode = false;
  bool _isPatientBlocked = false;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _initSession();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Check if patient is crisis blocked
      final patientProfile = await supabase
          .from('patient_profiles')
          .select('is_crisis_blocked')
          .eq('id', userId)
          .maybeSingle();

      if (patientProfile?['is_crisis_blocked'] == true) {
        if (mounted) setState(() => _isPatientBlocked = true);
        return;
      }

      // If sessionId passed, load existing session
      if (widget.sessionId != null) {
        _sessionId = widget.sessionId;
        await _loadExistingMessages();
        return;
      }

    } catch (e) {
      debugPrint('Error initializing session: $e');
    }
  }

  Future<void> _loadExistingMessages() async {
    try {
      final data = await supabase
          .from('chat_messages')
          .select('role, content')
          .eq('session_id', _sessionId!)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> messages = [];
      final List<Map<String, String>> history = [];

      for (final msg in data) {
        messages.add({
          'text': msg['content'],
          'isUser': msg['role'] == 'user',
        });
        history.add({
          'role': msg['role'] == 'user' ? 'user' : 'assistant',
          'content': msg['content'],
        });
      }

      if (mounted) {
        setState(() {
          _messages.addAll(messages);
          _conversationHistory = history;
        });
        _scrollToBottom();
      }
      // Check if session was previously marked as crisis
      // by checking if chat_sessions has crisis_detected = true
      try {
        final session = await supabase
            .from('chat_sessions')
            .select('crisis_detected')
            .eq('id', _sessionId!)
            .single();
        if (session['crisis_detected'] == true && mounted) {
          setState(() => _isCrisisMode = true);
        }
      } catch (e) {
        debugPrint('Error checking crisis flag: $e');
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _saveMessage(String role, String content) async {
    try {
      if (_sessionId == null) return;
      await supabase.from('chat_messages').insert({
        'session_id': _sessionId,
        'role': role,
        'content': content,
      });
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;
    final lang = Localizations.localeOf(context).languageCode;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Create session on first message if not exists
    if (_sessionId == null) {
      try {
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          final title = text.length > 40
              ? '${text.substring(0, 40)}...'
              : text;
          final session = await supabase
              .from('chat_sessions')
              .insert({
                'patient_id': userId,
                'title': title,
              })
              .select()
              .single();
          _sessionId = session['id'];
        }
      } catch (e) {
        debugPrint('Error creating session: $e');
      }
    }
    await _saveMessage('user', text);

    try {
      final response = await timeAsync('chatbot_response', () => http.post(
        Uri.parse(
          'https://yyxsvadjinfnrbxvczzp.supabase.co/functions/v1/chat-with-ai',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
        },
        body: jsonEncode({
          'message': text,
          'history': _conversationHistory,
          'lang': lang,
        }),
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] as String;
        final isFirstMessage = _conversationHistory.isEmpty;

        _conversationHistory.add({'role': 'user', 'content': text});
        _conversationHistory.add({'role': 'assistant', 'content': reply});

        // Update session title with first message (only once)
        if (isFirstMessage && _sessionId != null) {
          final suggestedTitle = text.length > 40
              ? '${text.substring(0, 40)}...'
              : text;
          await supabase
              .from('chat_sessions')
              .update({'title': suggestedTitle})
              .eq('id', _sessionId!);
        }
        final isCrisis = data['isCrisis'] as bool? ?? false;

        // Keep last 20 messages for context
        if (_conversationHistory.length > 20) {
          _conversationHistory = _conversationHistory.sublist(
            _conversationHistory.length - 20,
          );
        }

        await _saveMessage('assistant', reply);

        // Save crisis to DB BEFORE setState
        if (isCrisis) {
          try {
            final userId = supabase.auth.currentUser?.id;
            if (userId != null) {
              await supabase
                  .from('patient_profiles')
                  .update({'is_crisis_blocked': true})
                  .eq('id', userId);
            }
            if (_sessionId != null) {
              await supabase
                  .from('chat_sessions')
                  .update({'crisis_detected': true})
                  .eq('id', _sessionId!);
            }
          } catch (e) {
            debugPrint('Error saving crisis to DB: $e');
          }
        }

        if (mounted) {
          setState(() {
            _messages.add({'text': reply, 'isUser': false});
            _isTyping = false;
            if (isCrisis) {
              _isCrisisMode = true;
              _isPatientBlocked = true;
            }
          });
          _scrollToBottom();
        }
      } else {
        debugPrint('Chatbot error: ${response.statusCode} ${response.body}');
        _handleError();
      }
    } catch (e) {
      debugPrint('Chatbot error: $e');
      _handleError();
    }
  }

  void _handleError() {
    if (mounted) {
      final lang = AppLocalizations.of(context)!;
      setState(() {
        _messages.add({
          'text': lang.chatConnectionError,
          'isUser': false,
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(lang),
            Expanded(
              child: _isPatientBlocked && _messages.isEmpty
                  ? _buildBlockedState(lang)
                  : _messages.isEmpty
                      ? _buildEmptyState(lang)
                      : _buildMessagesList(),
            ),
            if (_isTyping) _buildTypingIndicator(),
            if (_isPatientBlocked || _isCrisisMode) _buildCrisisInputBlock(lang) else _buildInputArea(context, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations lang) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment:
                    isRtl ? Alignment.centerRight : Alignment.centerLeft,
                child: IconButton(
                  onPressed: _handleBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 28,
                    color: _textPrimary,
                  ),
                  padding: EdgeInsets.only(
                    left: isRtl ? 0 : 16,
                    right: isRtl ? 16 : 0,
                  ),
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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: _botBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DotIndicator(delay: 0),
            const SizedBox(width: 4),
            _DotIndicator(delay: 200),
            const SizedBox(width: 4),
            _DotIndicator(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedState(AppLocalizations lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 38,
                color: Color(0xFFE57373),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              lang.crisisYouAreNotAlone,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE57373),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang.crisisChatDisabled,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8D8E87),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: _softCircle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 38,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              lang.chatStart,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: _textPrimary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              lang.chatSafe,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _MessageBubble(
          text: message['text'] as String,
          isUser: message['isUser'] as bool,
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context, AppLocalizations lang) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 14 : 18,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _inputBorder, width: 1.4),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                enabled: !_isTyping,
                style: const TextStyle(fontSize: 17, color: _textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: lang.typeMessage,
                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFFAAA99F),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Material(
            color: _isTyping ? const Color(0xFFCCCCC5) : _softGreen,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _isTyping ? null : _sendMessage,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 58,
                height: 58,
                child: Icon(
                  Icons.send_outlined,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisInputBlock(AppLocalizations lang) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE57373).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_rounded,
            color: Color(0xFFE57373),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            lang.crisisYouAreNotAlone,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE57373),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang.crisisContactProfessionals,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8D8E87),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CrisisButton(
                      label: lang.crisisJordanEmergency,
                      number: '110',
                      color: const Color(0xFFE57373),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CrisisButton(
                      label: lang.crisisNationalMentalHealth,
                      number: '06-4729018',
                      color: const Color(0xFF5E6F5C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _CrisisButton(
                  label: lang.crisisFamilyProtection,
                  number: '110',
                  color: const Color(0xFF8D8E87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatefulWidget {
  const _DotIndicator({required this.delay});
  final int delay;

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xFF8D8E87),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CrisisButton extends StatelessWidget {
  const _CrisisButton({
    required this.label,
    required this.number,
    required this.color,
  });

  final String label;
  final String number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser
        ? _ChatbotScreenState._userBubble
        : _ChatbotScreenState._botBubble;
    final textColor =
        isUser ? Colors.white : _ChatbotScreenState._textPrimary;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.5, color: textColor),
            ),
          ),
        ),
      ],
    );
  }
}
