import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'chat_service.dart';

class SearchResult {
  final Chat chat;
  final Message message;
  final int messageIndex;
  final String searchTerm;

  const SearchResult({
    required this.chat,
    required this.message,
    required this.messageIndex,
    required this.searchTerm,
  });
}

class SearchService extends ChangeNotifier {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final ChatService _chatService = ChatService();
  List<SearchResult> _searchResults = [];
  String _currentQuery = '';
  bool _isSearching = false;

  List<SearchResult> get searchResults => List.unmodifiable(_searchResults);
  String get currentQuery => _currentQuery;
  bool get isSearching => _isSearching;
  bool get hasResults => _searchResults.isNotEmpty;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clear();
      return;
    }

    _isSearching = true;
    _currentQuery = query.trim();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100)); // Debounce

    final results = <SearchResult>[];
    final lowercaseQuery = query.toLowerCase();

    for (final chat in _chatService.chats) {
      for (int i = 0; i < chat.messages.length; i++) {
        final message = chat.messages[i];
        if (message.text.toLowerCase().contains(lowercaseQuery)) {
          results.add(SearchResult(
            chat: chat,
            message: message,
            messageIndex: i,
            searchTerm: query,
          ));
        }
      }
    }

    _searchResults = results;
    _isSearching = false;
    notifyListeners();
  }

  List<SearchResult> searchInChat(Chat chat, String query) {
    if (query.trim().isEmpty) return [];

    final results = <SearchResult>[];
    final lowercaseQuery = query.toLowerCase();

    for (int i = 0; i < chat.messages.length; i++) {
      final message = chat.messages[i];
      if (message.text.toLowerCase().contains(lowercaseQuery)) {
        results.add(SearchResult(
          chat: chat,
          message: message,
          messageIndex: i,
          searchTerm: query,
        ));
      }
    }

    return results;
  }

  List<Message> getFavoriteMessages() {
    final favoriteMessages = <Message>[];
    
    for (final chat in _chatService.chats) {
      for (final message in chat.messages) {
        if (message.isFavorite) {
          favoriteMessages.add(message);
        }
      }
    }

    return favoriteMessages;
  }

  void clear() {
    _searchResults.clear();
    _currentQuery = '';
    _isSearching = false;
    notifyListeners();
  }
}