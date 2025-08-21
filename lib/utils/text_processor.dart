class TextProcessor {
  // Cache for compiled regex patterns (performance optimization)
  static final RegExp _thinkTagRegex = RegExp(r'<think>[\s\S]*?</think>', multiLine: true, caseSensitive: false);
  static final RegExp _incompleteThinkRegex = RegExp(r'^<think>[\s\S]*?(?=\n\n|\n[A-Z]|$)', multiLine: true, caseSensitive: false);
  static final RegExp _whitespaceRegex = RegExp(r'\n\s*\n\s*\n');
  static final RegExp _trimRegex = RegExp(r'^\s+|\s+$');
  static final RegExp _codeBlockRegex = RegExp(r'```(\w+)?\n([\s\S]*?)```');
  
  // Cache for processed results
  static final Map<String, String> _processedCache = <String, String>{};
  static const int _maxCacheSize = 50;

  static String stripThinkTags(String text) {
    // Check cache first
    final cacheKey = 'think_$text';
    if (_processedCache.containsKey(cacheKey)) {
      return _processedCache[cacheKey]!;
    }
    
    // Remove complete <think>...</think> tags and their content
    String cleaned = text.replaceAll(_thinkTagRegex, '');
    
    // Remove incomplete think tags at the start
    cleaned = cleaned.replaceAll(_incompleteThinkRegex, '');
    cleaned = cleaned.trim();
    
    // Cache the result (with size limit)
    if (_processedCache.length >= _maxCacheSize) {
      _processedCache.clear();
    }
    _processedCache[cacheKey] = cleaned;
    
    return cleaned;
  }

  static String cleanResponse(String text) {
    // Check cache first
    final cacheKey = 'clean_$text';
    if (_processedCache.containsKey(cacheKey)) {
      return _processedCache[cacheKey]!;
    }
    
    // Apply all text cleaning operations
    String cleaned = stripThinkTags(text);
    
    // Remove excessive whitespace using cached regex
    cleaned = cleaned.replaceAll(_whitespaceRegex, '\n\n');
    cleaned = cleaned.replaceAll(_trimRegex, '');
    
    // Cache the result
    if (_processedCache.length >= _maxCacheSize) {
      _processedCache.clear();
    }
    _processedCache[cacheKey] = cleaned;
    
    return cleaned;
  }

  static bool containsThinkTags(String text) {
    return _thinkTagRegex.hasMatch(text);
  }

  static String extractThinkContent(String text) {
    final match = _thinkTagRegex.firstMatch(text);
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
    // Ensure proper spacing around code blocks using cached regex
    return text.replaceAllMapped(
      _codeBlockRegex,
      (match) => '\n```${match.group(1) ?? ''}\n${match.group(2)}```\n',
    );
  }

  static String highlightSearchTerms(String text, String searchTerm) {
    if (searchTerm.isEmpty) return text;
    
    // Use a simple cache for search term highlighting
    final cacheKey = 'search_${searchTerm}_$text';
    if (_processedCache.containsKey(cacheKey)) {
      return _processedCache[cacheKey]!;
    }
    
    final result = text.replaceAllMapped(
      RegExp(RegExp.escape(searchTerm), caseSensitive: false),
      (match) => '**${match.group(0)}**',
    );
    
    // Cache if reasonable size
    if (text.length < 1000 && _processedCache.length < _maxCacheSize) {
      _processedCache[cacheKey] = result;
    }
    
    return result;
  }
  
  // Method to clear cache when needed
  static void clearCache() {
    _processedCache.clear();
  }
}