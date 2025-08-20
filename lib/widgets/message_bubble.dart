import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import '../utils/snackbar_utils.dart';
import '../utils/responsive_layout.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16, 
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: message.role.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.role.isUser) ...[
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
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: AppTextStyles.messageText.copyWith(
                      color: message.role.isUser 
                          ? Colors.white 
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timestamp,
                        style: AppTextStyles.timestamp.copyWith(
                          color: message.role.isUser 
                              ? Colors.white70 
                              : Colors.grey[600],
                        ),
                      ),
                      if (!message.role.isUser && !message.role.isError) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _copyToClipboard(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.role.isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: message.role.isUser 
            ? Colors.blue[600] 
            : (message.role.isError ? Colors.red[600] : Colors.grey[600]),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getMessageIcon(),
        color: Colors.white,
        size: 18,
      ),
    );
  }

  IconData _getMessageIcon() {
    switch (message.role) {
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
    if (message.role.isUser) {
      return Colors.blue[600]!;
    } else if (message.role.isError) {
      return isDark ? Colors.red[900]! : Colors.red[100]!;
    } else {
      return isDark ? Colors.grey[800]! : Colors.grey[100]!;
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    SnackBarUtils.showCopiedToClipboard(context);
  }
}