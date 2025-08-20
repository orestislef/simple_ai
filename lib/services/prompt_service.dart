import 'package:flutter/foundation.dart';

class PromptService extends ChangeNotifier {
  static final PromptService _instance = PromptService._internal();
  factory PromptService() => _instance;
  PromptService._internal();

  final List<String> _savedPrompts = [];

  List<String> get savedPrompts => List.unmodifiable(_savedPrompts);

  void addPrompt(String prompt) {
    if (prompt.trim().isNotEmpty && !_savedPrompts.contains(prompt)) {
      _savedPrompts.add(prompt.trim());
      notifyListeners();
    }
  }

  void removePrompt(String prompt) {
    _savedPrompts.remove(prompt);
    notifyListeners();
  }

  void removePromptAt(int index) {
    if (index >= 0 && index < _savedPrompts.length) {
      _savedPrompts.removeAt(index);
      notifyListeners();
    }
  }

  void clearPrompts() {
    _savedPrompts.clear();
    notifyListeners();
  }

  bool hasPrompts() => _savedPrompts.isNotEmpty;

  int get promptCount => _savedPrompts.length;
}