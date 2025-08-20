import '../models/app_config.dart';

class SafetyService {
  static final SafetyService _instance = SafetyService._internal();
  factory SafetyService() => _instance;
  SafetyService._internal();

  final List<String> _blockedWords = List.from(AppConfig.blockedWords);

  bool isSafeMessage(String message) {
    final lowerMessage = message.toLowerCase();
    return !_blockedWords.any((word) => lowerMessage.contains(word.toLowerCase()));
  }

  List<String> get blockedWords => List.unmodifiable(_blockedWords);

  void addBlockedWord(String word) {
    if (!_blockedWords.contains(word.toLowerCase())) {
      _blockedWords.add(word.toLowerCase());
    }
  }

  void removeBlockedWord(String word) {
    _blockedWords.remove(word.toLowerCase());
  }

  String? getBlockedReason(String message) {
    final lowerMessage = message.toLowerCase();
    for (final word in _blockedWords) {
      if (lowerMessage.contains(word)) {
        return 'Message contains blocked word: "$word"';
      }
    }
    return null;
  }
}