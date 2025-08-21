import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../utils/date_formatter.dart';

class ChatSidebar extends StatefulWidget {
  final double width;
  final Function(Chat) onChatSelected;
  final VoidCallback onNewChat;

  const ChatSidebar({
    super.key,
    this.width = 300,
    required this.onChatSelected,
    required this.onNewChat,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildChatList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: _AnimatedElevatedButton(
          onPressed: widget.onNewChat,
          icon: const Icon(Icons.add),
          label: const Text('New Chat'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListenableBuilder(
      listenable: _chatService,
      builder: (context, child) {
        final chats = _chatService.chats;
        final currentChat = _chatService.currentChat;

        if (chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No chats yet',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Start a new conversation',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final isSelected = currentChat?.id == chat.id;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (index * 50)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animation, child) {
                return Transform.translate(
                  offset: Offset(-50 * (1 - animation), 0),
                  child: Opacity(
                    opacity: animation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              )
                            : null,
                      ),
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Text(
                  chat.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormatter.formatMessageTime(chat.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[850] 
                          : Colors.white,
                      textStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black87,
                      ),
                    ),
                  ),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(chat);
                      }
                    },
                  ),
                ),
                onTap: () => widget.onChatSelected(chat),
              ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "${chat.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _chatService.deleteChat(chat.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;
  final ButtonStyle? style;

  const _AnimatedElevatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.style,
  });

  @override
  State<_AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<_AnimatedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton.icon(
            onPressed: () {
              _controller.forward().then((_) => _controller.reverse());
              widget.onPressed();
            },
            icon: widget.icon,
            label: widget.label,
            style: widget.style,
          ),
        );
      },
    );
  }
}