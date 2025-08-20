class AppConfig {
  static const String appName = 'Lef Chat';
  static const bool showLogs = true;
  
  // Server configuration defaults
  static const String defaultServerHost = '192.168.24.21';
  static const int defaultServerPort = 1234;
  static const String defaultApiKey = 'lm-studio';
  static const String defaultProtocol = 'http';
  
  // API Endpoints
  static const String modelsEndpoint = '/v1/models';
  static const String chatCompletionsEndpoint = '/v1/chat/completions';
  static const String completionsEndpoint = '/v1/completions';
  static const String embeddingsEndpoint = '/v1/embeddings';
  
  static const String defaultSystemPrompt = 
      'You are a helpful, smart, kind, and efficient AI assistant. '
      'You always fulfill the user\'s requests to the best of your ability.';
      
  static const double temperature = 0.8;
  static const int maxTokens = -1;
  
  static const List<String> blockedWords = [
    'hack',
    'malware', 
    'virus',
    'exploit',
    'attack'
  ];
  
  // Utility method to build base URL
  static String buildBaseUrl(String protocol, String host, int port) {
    return '$protocol://$host:$port';
  }
  
  // Default base URL
  static String get defaultBaseUrl => buildBaseUrl(defaultProtocol, defaultServerHost, defaultServerPort);
}