import 'dart:convert';
import 'dart:html' as html show window, document, AnchorElement, Url, Blob;
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/message.dart';

enum ExportFormat { json, txt, markdown, csv }

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<void> exportChat(Chat chat, ExportFormat format) async {
    String content;
    String filename;
    String mimeType;

    switch (format) {
      case ExportFormat.json:
        content = _exportAsJson(chat);
        filename = '${_sanitizeFilename(chat.title)}.json';
        mimeType = 'application/json';
        break;
      case ExportFormat.txt:
        content = _exportAsText(chat);
        filename = '${_sanitizeFilename(chat.title)}.txt';
        mimeType = 'text/plain';
        break;
      case ExportFormat.markdown:
        content = _exportAsMarkdown(chat);
        filename = '${_sanitizeFilename(chat.title)}.md';
        mimeType = 'text/markdown';
        break;
      case ExportFormat.csv:
        content = _exportAsCSV(chat);
        filename = '${_sanitizeFilename(chat.title)}.csv';
        mimeType = 'text/csv';
        break;
    }

    if (kIsWeb) {
      _downloadWebFile(content, filename, mimeType);
    } else {
      // For mobile/desktop, you would use different file saving methods
      if (kDebugMode) {
        print('Export content:\n$content');
      }
    }
  }

  Future<void> exportAllChats(List<Chat> chats, ExportFormat format) async {
    String content;
    String filename;
    String mimeType;

    switch (format) {
      case ExportFormat.json:
        content = jsonEncode({
          'export_date': DateTime.now().toIso8601String(),
          'chats': chats.map((chat) => chat.toJson()).toList(),
        });
        filename = 'all_chats_export.json';
        mimeType = 'application/json';
        break;
      case ExportFormat.txt:
        content = chats.map((chat) => _exportAsText(chat)).join('\n\n${'=' * 50}\n\n');
        filename = 'all_chats_export.txt';
        mimeType = 'text/plain';
        break;
      case ExportFormat.markdown:
        content = chats.map((chat) => _exportAsMarkdown(chat)).join('\n\n---\n\n');
        filename = 'all_chats_export.md';
        mimeType = 'text/markdown';
        break;
      case ExportFormat.csv:
        content = _exportAllChatsAsCSV(chats);
        filename = 'all_chats_export.csv';
        mimeType = 'text/csv';
        break;
    }

    if (kIsWeb) {
      _downloadWebFile(content, filename, mimeType);
    } else {
      if (kDebugMode) {
        print('Export content:\n$content');
      }
    }
  }

  String _exportAsJson(Chat chat) {
    return const JsonEncoder.withIndent('  ').convert(chat.toJson());
  }

  String _exportAsText(Chat chat) {
    final buffer = StringBuffer();
    buffer.writeln('Chat: ${chat.title}');
    buffer.writeln('Created: ${chat.createdAt}');
    buffer.writeln('Updated: ${chat.updatedAt}');
    if (chat.modelId != null) {
      buffer.writeln('Model: ${chat.modelId}');
    }
    buffer.writeln('=' * 40);
    buffer.writeln();

    for (final message in chat.messages) {
      buffer.writeln('[${message.timestamp}] ${_getRoleName(message.role)}:');
      buffer.writeln(message.text);
      if (message.isFavorite) {
        buffer.writeln('⭐ Favorite');
      }
      if (message.reactions.isNotEmpty) {
        buffer.writeln('Reactions: ${message.reactions.join(', ')}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _exportAsMarkdown(Chat chat) {
    final buffer = StringBuffer();
    buffer.writeln('# ${chat.title}');
    buffer.writeln();
    buffer.writeln('**Created:** ${chat.createdAt}');
    buffer.writeln('**Updated:** ${chat.updatedAt}');
    if (chat.modelId != null) {
      buffer.writeln('**Model:** ${chat.modelId}');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    for (final message in chat.messages) {
      final roleName = _getRoleName(message.role);
      buffer.writeln('## $roleName');
      buffer.writeln('*${message.timestamp}*');
      buffer.writeln();
      buffer.writeln(message.text);
      
      if (message.isFavorite || message.reactions.isNotEmpty) {
        buffer.writeln();
        if (message.isFavorite) {
          buffer.writeln('⭐ **Favorite**');
        }
        if (message.reactions.isNotEmpty) {
          buffer.writeln('**Reactions:** ${message.reactions.join(', ')}');
        }
      }
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _exportAsCSV(Chat chat) {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Role,Message,Is Favorite,Reactions');

    for (final message in chat.messages) {
      final csvMessage = message.text.replaceAll('"', '""');
      final reactions = message.reactions.join('; ');
      buffer.writeln('"${message.timestamp}","${message.role.value}","$csvMessage","${message.isFavorite}","$reactions"');
    }

    return buffer.toString();
  }

  String _exportAllChatsAsCSV(List<Chat> chats) {
    final buffer = StringBuffer();
    buffer.writeln('Chat Title,Timestamp,Role,Message,Is Favorite,Reactions,Model');

    for (final chat in chats) {
      for (final message in chat.messages) {
        final csvTitle = chat.title.replaceAll('"', '""');
        final csvMessage = message.text.replaceAll('"', '""');
        final reactions = message.reactions.join('; ');
        buffer.writeln('"$csvTitle","${message.timestamp}","${message.role.value}","$csvMessage","${message.isFavorite}","$reactions","${chat.modelId ?? ''}"');
      }
    }

    return buffer.toString();
  }

  String _getRoleName(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return 'User';
      case MessageRole.assistant:
        return 'Assistant';
      case MessageRole.system:
        return 'System';
      case MessageRole.error:
        return 'Error';
    }
  }

  String _sanitizeFilename(String filename) {
    return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  void _downloadWebFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
  }
}