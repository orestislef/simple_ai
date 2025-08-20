class TextProcessor {
  static String stripThinkTags(String text) {
    // Remove <think>...</think> tags and their content
    return text.replaceAll(RegExp(r'<think>[\s\S]*?</think>', multiLine: true), '').trim();
  }

  static String cleanResponse(String text) {
    // Apply all text cleaning operations
    String cleaned = stripThinkTags(text);
    
    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    cleaned = cleaned.replaceAll(RegExp(r'^\s+|\s+$'), '');
    
    return cleaned;
  }

  static bool containsThinkTags(String text) {
    return RegExp(r'<think>[\s\S]*?</think>', multiLine: true).hasMatch(text);
  }

  static String extractThinkContent(String text) {
    final match = RegExp(r'<think>([\s\S]*?)</think>', multiLine: true).firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }

  static Map<String, String> separateThinkAndResponse(String text) {
    final thinkContent = extractThinkContent(text);
    final responseContent = stripThinkTags(text);
    
    return {
      'think': thinkContent,
      'response': responseContent,
    };
  }

  static String formatCodeBlocks(String text) {
    // Ensure proper spacing around code blocks
    return text.replaceAllMapped(
      RegExp(r'```(\w+)?\n([\s\S]*?)```'),
      (match) => '\n```${match.group(1) ?? ''}\n${match.group(2)}```\n',
    );
  }

  static String highlightSearchTerms(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;
    
    return text.replaceAllMapped(
      RegExp(RegExp.escape(searchTerm), caseSensitive: false),
      (match) => '**${match.group(0)}**',
    );
  }
}