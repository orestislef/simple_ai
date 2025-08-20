import 'package:dart_openai/dart_openai.dart';
import '../models/app_config.dart';
import 'settings_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final SettingsService _settingsService = SettingsService();

  static void initialize() {
    // Initial setup with default values
    OpenAI.baseUrl = AppConfig.defaultBaseUrl;
    OpenAI.apiKey = AppConfig.defaultApiKey;
    OpenAI.showLogs = AppConfig.showLogs;
  }

  void updateConfiguration() {
    OpenAI.baseUrl = _settingsService.baseUrl;
    OpenAI.apiKey = _settingsService.apiKey;
    OpenAI.showLogs = AppConfig.showLogs;
  }

  Future<List<OpenAIModelModel>> getAvailableModels() async {
    try {
      final models = await OpenAI.instance.model.list();
      return models;
    } catch (e) {
      throw Exception('Failed to fetch models: $e');
    }
  }

  Stream<OpenAIStreamChatCompletionModel> createChatStream({
    required String modelId,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    double temperature = AppConfig.temperature,
    int maxTokens = AppConfig.maxTokens,
  }) {
    return OpenAI.instance.chat.createStream(
      model: modelId,
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  OpenAIChatCompletionChoiceMessageModel createMessage({
    required String content,
    required OpenAIChatMessageRole role,
  }) {
    return OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(content),
      ],
      role: role,
    );
  }

  OpenAIChatCompletionChoiceMessageModel createSystemMessage(String content) {
    return createMessage(
      content: content,
      role: OpenAIChatMessageRole.system,
    );
  }

  OpenAIChatCompletionChoiceMessageModel createUserMessage(String content) {
    return createMessage(
      content: content,
      role: OpenAIChatMessageRole.user,
    );
  }

  OpenAIChatCompletionChoiceMessageModel createAssistantMessage(String content) {
    return createMessage(
      content: content,
      role: OpenAIChatMessageRole.assistant,
    );
  }
}