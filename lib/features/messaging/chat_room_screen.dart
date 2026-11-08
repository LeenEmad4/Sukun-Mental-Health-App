import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sukun/l10n/app_localizations.dart';
import 'package:sukun/utils/error_handler.dart';
import '../../main.dart';
import '../../services/push_notification_service.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.otherPersonId,
    required this.otherPersonName,
    required this.isTherapist,
  });

  final String conversationId;
  final String otherPersonId;
  final String otherPersonName;
  final bool isTherapist;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  static const Color _backgroundColor = Color(0xFFF4EFEA);
  static const Color _primaryGreen = Color(0xFF5E6F5C);
  static const Color _textPrimary = Color(0xFF4D514A);
  static const Color _textSecondary = Color(0xFF8D8E87);
  static const Color _dividerColor = Color(0xFFE4DDD4);

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  String _senderName = '';

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
    _loadSenderName();
  }

  Future<void> _loadSenderName() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      if (widget.isTherapist) {
        final row = await supabase
            .from('therapists')
            .select('full_name')
            .eq('id', userId)
            .maybeSingle();
        if (mounted && row != null) {
          setState(() => _senderName = row['full_name'] as String? ?? '');
        }
      } else {
        final row = await supabase
            .from('patient_profiles')
            .select('username')
            .eq('id', userId)
            .maybeSingle();
        if (mounted && row != null) {
          setState(() => _senderName = row['username'] as String? ?? '');
        }
      }
    } catch (_) {}
  }

  Future<void> _sendNotification(String content) async {
    final name = _senderName.isNotEmpty ? _senderName : 'Someone';
    final preview = content.length > 80 ? '${content.substring(0, 80)}…' : content;
    final title = 'New message from $name';

    // In-app notification row (non-blocking)
    try {
      await supabase.from('notifications').insert({
        'user_id': widget.otherPersonId,
        'title': title,
        'body': preview,
        'type': 'new_message',
      });
    } catch (_) {}

    // Push notification (non-blocking)
    await PushNotificationService.sendPushToUser(
      userId: widget.otherPersonId,
      title: title,
      body: preview,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToMessages() {
    _sub = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', widget.conversationId)
        .order('created_at', ascending: true)
        .listen((data) {
          if (!mounted) return;
          setState(() {
            _messages
              ..clear()
              ..addAll(data);
            _isLoading = false;
          });
          _scrollToBottom();
        });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isSending) return;

    final senderId = supabase.auth.currentUser?.id;
    if (senderId == null) return;

    setState(() => _isSending = true);
    _inputController.clear();

    try {
      await supabase.from('messages').insert({
        'conversation_id': widget.conversationId,
        'sender_id': senderId,
        'receiver_id': widget.otherPersonId,
        'content': content,
      });

      await supabase.from('conversations').update({
        'last_message': content,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.conversationId);

      // Fire-and-forget — never block the send on notification delivery
      _sendNotification(content);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
        _inputController.text = content;
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildHeader(),
              Container(height: 1, color: _dividerColor),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryGreen),
                      )
                    : _buildMessagesList(),
              ),
              _buildInputBar(lang),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            widget.otherPersonName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final myId = supabase.auth.currentUser?.id ?? '';

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 52,
              color: Color(0xFFD0C9C0),
            ),
            const SizedBox(height: 16),
            Text(
              'Say hello to ${widget.otherPersonName}',
              style: const TextStyle(fontSize: 15, color: _textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final msg = _messages[i];
        final isMine = (msg['sender_id'] as String?) == myId;
        // Show sender label only when sender changes
        final prevSenderId = i > 0 ? _messages[i - 1]['sender_id'] as String? : null;
        final showLabel = prevSenderId != msg['sender_id'];
        return _MessageBubble(
          content: msg['content'] as String? ?? '',
          isMine: isMine,
          createdAt: msg['created_at'] as String?,
          senderLabel: showLabel
              ? (isMine ? 'You' : widget.otherPersonName)
              : null,
        );
      },
    );
  }

  Widget _buildInputBar(AppLocalizations lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF4EFEA),
        border: Border(top: BorderSide(color: _dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0D9D0)),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: lang.typeAMessage,
                  hintStyle: const TextStyle(
                    color: Color(0xFFA6A69F),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _primaryGreen,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.content,
    required this.isMine,
    this.createdAt,
    this.senderLabel,
  });

  final String content;
  final bool isMine;
  final String? createdAt;
  final String? senderLabel;

  String _time() {
    if (createdAt == null) return '';
    try {
      final d = DateTime.parse(createdAt!).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (senderLabel != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
              child: Text(
                senderLabel!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isMine
                      ? const Color(0xFF5E6F5C)
                      : const Color(0xFF8D8E87),
                ),
              ),
            ),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMine ? const Color(0xFF5E6F5C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: isMine ? Colors.white : const Color(0xFF4D514A),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _time(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine
                        ? const Color(0xFFCCD4C9)
                        : const Color(0xFFA6A69F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
