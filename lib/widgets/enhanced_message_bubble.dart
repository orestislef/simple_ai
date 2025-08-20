import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import '../utils/snackbar_utils.dart';
import '../utils/responsive_layout.dart';
import '../services/chat_service.dart';

class EnhancedMessageBubble extends StatefulWidget {
  final Message message;
  final bool isCompact;
  final bool showAnimations;

  const EnhancedMessageBubble({
    super.key,
    required this.message,
    this.isCompact = false,
    this.showAnimations = true,
  });

  @override
  State<EnhancedMessageBubble> createState() => _EnhancedMessageBubbleState();
}

class _EnhancedMessageBubbleState extends State<EnhancedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final ChatService _chatService = ChatService();
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    if (widget.showAnimations) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAnimations) {
      return _buildMessageContent(context);
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: _buildMessageContent(context),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: widget.isCompact ? 2 : 4,
        ),
        child: Row(
          mainAxisAlignment: widget.message.role.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.message.role.isUser) ...[
              _buildAvatar(context),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveLayout.getMessageMaxWidth(context),
                ),
                decoration: BoxDecoration(
                  color: _getMessageColor(isDark),
                  borderRadius: BorderRadius.circular(widget.isCompact ? 12 : 18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: widget.isCompact ? 2 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isCompact ? 12 : 16,
                        vertical: widget.isCompact ? 8 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  widget.message.text,
                                  style: AppTextStyles.messageText.copyWith(
                                    color: widget.message.role.isUser
                                        ? Colors.white
                                        : (isDark ? Colors.white : Colors.black87),
                                    fontSize: widget.isCompact ? 14 : 16,
                                  ),
                                ),
                              ),
                              if (widget.message.isFavorite)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber[600],
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.message.timestamp,
                                style: AppTextStyles.timestamp.copyWith(
                                  color: widget.message.role.isUser
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontSize: widget.isCompact ? 10 : 12,
                                ),
                              ),
                              if (_isHovered || isMobile) ...[
                                const Spacer(),
                                _buildActionButtons(context),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.message.reactions.isNotEmpty)
                      _buildReactions(context),
                  ],
                ),
              ),
            ),
            if (widget.message.role.isUser) ...[
              const SizedBox(width: 8),
              _buildAvatar(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: widget.isCompact ? 28 : 32,
      height: widget.isCompact ? 28 : 32,
      decoration: BoxDecoration(
        color: widget.message.role.isUser
            ? Colors.blue[600]
            : (widget.message.role.isError ? Colors.red[600] : Colors.grey[600]),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getMessageIcon(),
        color: Colors.white,
        size: widget.isCompact ? 14 : 18,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.message.role.isError) ...[
          InkWell(
            onTap: _toggleFavorite,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                widget.message.isFavorite ? Icons.star : Icons.star_border,
                size: 16,
                color: widget.message.isFavorite
                    ? Colors.amber[600]
                    : Colors.grey[600],
              ),
            ),
          ),
          InkWell(
            onTap: _showReactionPicker,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.add_reaction_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          InkWell(
            onTap: () => _copyToClipboard(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReactions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.message.reactions.map((reaction) {
          return InkWell(
            onTap: () => _removeReaction(reaction),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reaction,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getMessageIcon() {
    switch (widget.message.role) {
      case MessageRole.user:
        return Icons.person;
      case MessageRole.assistant:
        return Icons.smart_toy;
      case MessageRole.error:
        return Icons.error;
      case MessageRole.system:
        return Icons.settings;
    }
  }

  Color _getMessageColor(bool isDark) {
    if (widget.message.role.isUser) {
      return Colors.blue[600]!;
    } else if (widget.message.role.isError) {
      return isDark ? Colors.red[900]! : Colors.red[100]!;
    } else {
      return isDark ? Colors.grey[800]! : Colors.grey[100]!;
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.message.text));
    SnackBarUtils.showCopiedToClipboard(context);
  }

  void _toggleFavorite() {
    final updatedMessage = widget.message.copyWith(
      isFavorite: !widget.message.isFavorite,
    );
    _chatService.updateMessage(updatedMessage);
  }

  void _showReactionPicker() {
    const reactions = ['👍', '❤️', '😂', '😮', '😢', '😡', '🎉', '🤔'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reaction'),
        content: Wrap(
          children: reactions.map((reaction) {
            return InkWell(
              onTap: () {
                _addReaction(reaction);
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(reaction, style: const TextStyle(fontSize: 24)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addReaction(String reaction) {
    if (widget.message.reactions.contains(reaction)) return;
    
    final updatedReactions = List<String>.from(widget.message.reactions)
      ..add(reaction);
    
    final updatedMessage = widget.message.copyWith(reactions: updatedReactions);
    _chatService.updateMessage(updatedMessage);
  }

  void _removeReaction(String reaction) {
    final updatedReactions = List<String>.from(widget.message.reactions)
      ..remove(reaction);
    
    final updatedMessage = widget.message.copyWith(reactions: updatedReactions);
    _chatService.updateMessage(updatedMessage);
  }
}