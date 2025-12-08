import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifly_frontend/api/api_manager.dart';
import 'package:notifly_frontend/colors.dart';
import 'package:notifly_frontend/models/message_model.dart';
import 'package:notifly_frontend/widgets/background.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, @PathParam('chatId') required this.chatId});

  final String chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  late final String _currentUserId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = (Hive.box('userData').get('id') ?? '').toString();
    _loadMessages();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollMessages(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await ApiManager().getChatMessages(widget.chatId);
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(jump: true);
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pollMessages() async {
    if (_isLoading) return;
    try {
      final msgs = await ApiManager().getChatMessages(widget.chatId);
      if (!mounted) return;
      if (msgs.length <= _messages.length) return;
      final newOnes = msgs.sublist(_messages.length);
      for (final m in newOnes) {
        _insertMessage(m);
      }
    } catch (_) {}
  }

  void _insertMessage(MessageModel msg) {
    final index = _messages.length;
    _messages.add(msg);
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 650),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(jump: true);
    });
  }

  Future<void> _handleSend() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    try {
      final sent = await ApiManager().sendMessage(
        chatId: widget.chatId,
        senderId: _currentUserId,
        kind: TypeMessage.text,
        text: text,
      );
      _insertMessage(sent);
    } catch (_) {}
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position.maxScrollExtent;
    if (jump) {
      _scrollController.jumpTo(pos);
    } else {
      _scrollController.animateTo(
        pos,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildBubble(MessageModel msg, bool isMe, bool isDark) {
    final text = msg.text ?? '';
    final bg = isMe
        ? lightPurple
        : isDark
        ? darkPurple.withOpacity(0.6)
        : pastelPeach;
    final fg = isDark
        ? Colors.white
        : isMe
        ? Colors.white
        : Colors.black87;
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(text, style: TextStyle(color: fg, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _animatedItem(
    BuildContext context,
    int index,
    Animation<double> animation,
    bool isDark,
  ) {
    final msg = _messages[index];
    final isMe = msg.senderId == _currentUserId;
    final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 1,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isMe ? 0.40 : -0.40, 0.15),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: animation,
          child: _buildBubble(msg, isMe, isDark),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settBox.listenable(keys: ['darkMode']),
      builder: (context, Box box, _) {
        final isDark = box.get('darkMode', defaultValue: false) as bool;
        final bgColor = isDark ? darkBg : lightBg;
        final headerColor = isDark ? Colors.white : darkPurple;
        final headerSub = isDark ? Colors.white70 : Colors.black54;
        final h = MediaQuery.of(context).size.height;

        return AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey<bool>(isDark),
            child: Container(
              color: bgColor,
              child: SizedBox(
                height: h,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: AnimatedSwitcher(
                            duration: const Duration(seconds: 1),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Opacity(
                              key: ValueKey<bool>(isDark),
                              opacity: 0.22,
                              child: isDark
                                  ? const DarkBackground()
                                  : const LightBackground(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: headerSub,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chat',
                                style: TextStyle(
                                  color: headerColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '#${widget.chatId.substring(0, 6)}',
                                style: TextStyle(
                                  color: headerSub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.black.withOpacity(0.06),
                        ),
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: isDark ? pastelPeach : lightPurple,
                                  ),
                                )
                              : AnimatedList(
                                  key: _listKey,
                                  controller: _scrollController,
                                  initialItemCount: _messages.length,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 4,
                                  ),
                                  itemBuilder: (context, index, animation) =>
                                      _animatedItem(
                                        context,
                                        index,
                                        animation,
                                        isDark,
                                      ),
                                ),
                        ),
                        SafeArea(
                          top: false,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.18)
                                  : Colors.black.withOpacity(0.03),
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.12)
                                      : Colors.black.withOpacity(0.06),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _msgController,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText: 'Mensagem...',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.black.withOpacity(0.4),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.black.withOpacity(0.03),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _handleSend,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [lightPurple, pastelPeach]
                                            : [lightPurple, pastelPurple],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isDark ? 0.4 : 0.2,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
