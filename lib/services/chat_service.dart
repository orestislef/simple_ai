import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final List<Chat> _chats = [];
  Chat? _currentChat;

  List<Chat> get chats => List.unmodifiable(_chats);
  Chat? get currentChat => _currentChat;

  Future<void> initialize() async {
    await _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = prefs.getStringList('chats') ?? [];
      
      _chats.clear();
      for (final chatJson in chatsJson) {
        final chat = Chat.fromJson(jsonDecode(chatJson));
        _chats.add(chat);
      }
      
      _chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading chats: $e');
    }
  }

  Future<void> _saveChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = _chats.map((chat) => jsonEncode(chat.toJson())).toList();
      await prefs.setStringList('chats', chatsJson);
    } catch (e) {
      if (kDebugMode) print('Error saving chats: $e');
    }
  }

  Chat createNewChat({String? modelId}) {
    final now = DateTime.now();
    final chat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
      modelId: modelId,
    );
    
    _chats.insert(0, chat);
    _currentChat = chat;
    _saveChats();
    notifyListeners();
    return chat;
  }

  void selectChat(Chat chat) {
    _currentChat = chat;
    notifyListeners();
  }

  Future<void> addMessageToCurrentChat(Message message) async {
    if (_currentChat == null) {
      createNewChat();
    }

    final updatedMessages = List<Message>.from(_currentChat!.messages)..add(message);
    
    String title = _currentChat!.title;
    if (title == 'New Chat' && message.role.isUser) {
      title = message.text.length > 30 
          ? '${message.text.substring(0, 30)}...'
          : message.text;
    }

    _currentChat = _currentChat!.copyWith(
      messages: updatedMessages,
      title: title,
      updatedAt: DateTime.now(),
    );

    final index = _chats.indexWhere((c) => c.id == _currentChat!.id);
    if (index >= 0) {
      _chats[index] = _currentChat!;
      
      if (index != 0) {
        _chats.removeAt(index);
        _chats.insert(0, _currentChat!);
      }
    }

    await _saveChats();
    notifyListeners();
  }

  Future<void> updateLastMessage(String content) async {
    if (_currentChat == null || _currentChat!.messages.isEmpty) return;

    final messages = List<Message>.from(_currentChat!.messages);
    final lastMessage = messages.last;
    
    messages[messages.length - 1] = Message(
      text: content,
      role: lastMessage.role,
      timestamp: lastMessage.timestamp,
      id: lastMessage.id,
      isFavorite: lastMessage.isFavorite,
      reactions: lastMessage.reactions,
      metadata: lastMessage.metadata,
    );

    _currentChat = _currentChat!.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );

    final index = _chats.indexWhere((c) => c.id == _currentChat!.id);
    if (index >= 0) {
      _chats[index] = _currentChat!;
    }

    await _saveChats();
    notifyListeners();
  }

  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((chat) => chat.id == chatId);
    
    if (_currentChat?.id == chatId) {
      _currentChat = _chats.isNotEmpty ? _chats.first : null;
    }

    await _saveChats();
    notifyListeners();
  }

  Future<void> clearAllChats() async {
    _chats.clear();
    _currentChat = null;
    await _saveChats();
    notifyListeners();
  }

  Future<void> updateChatModel(String chatId, String modelId) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index >= 0) {
      _chats[index] = _chats[index].copyWith(modelId: modelId);
      
      if (_currentChat?.id == chatId) {
        _currentChat = _chats[index];
      }
      
      await _saveChats();
      notifyListeners();
    }
  }

  Future<void> updateMessage(Message updatedMessage) async {
    if (_currentChat == null) return;

    final messageIndex = _currentChat!.messages.indexWhere(
      (m) => m.id == updatedMessage.id,
    );
    
    if (messageIndex >= 0) {
      final updatedMessages = List<Message>.from(_currentChat!.messages);
      updatedMessages[messageIndex] = updatedMessage;
      
      _currentChat = _currentChat!.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      final chatIndex = _chats.indexWhere((c) => c.id == _currentChat!.id);
      if (chatIndex >= 0) {
        _chats[chatIndex] = _currentChat!;
      }

      await _saveChats();
      notifyListeners();
    }
  }
}