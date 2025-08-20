import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Settings keys
  static const String _autoSaveKey = 'auto_save';
  static const String _sendOnEnterKey = 'send_on_enter';
  static const String _showTypingIndicatorKey = 'show_typing_indicator';
  static const String _messageAnimationsKey = 'message_animations';
  static const String _soundEffectsKey = 'sound_effects';
  static const String _temperatureKey = 'temperature';
  static const String _maxTokensKey = 'max_tokens';
  static const String _systemPromptKey = 'system_prompt';
  static const String _autoScrollKey = 'auto_scroll';
  static const String _compactModeKey = 'compact_mode';
  
  // Server configuration keys
  static const String _serverHostKey = 'server_host';
  static const String _serverPortKey = 'server_port';
  static const String _serverProtocolKey = 'server_protocol';
  static const String _apiKeyKey = 'api_key';
  static const String _selectedModelIdKey = 'selected_model_id';

  // Default values
  bool _autoSave = true;
  bool _sendOnEnter = true;
  bool _showTypingIndicator = true;
  bool _messageAnimations = true;
  bool _soundEffects = false;
  double _temperature = AppConfig.temperature;
  int _maxTokens = AppConfig.maxTokens;
  String _systemPrompt = AppConfig.defaultSystemPrompt;
  bool _autoScroll = true;
  bool _compactMode = false;
  
  // Server configuration defaults
  String _serverHost = AppConfig.defaultServerHost;
  int _serverPort = AppConfig.defaultServerPort;
  String _serverProtocol = AppConfig.defaultProtocol;
  String _apiKey = AppConfig.defaultApiKey;
  String? _selectedModelId;

  // Getters
  bool get autoSave => _autoSave;
  bool get sendOnEnter => _sendOnEnter;
  bool get showTypingIndicator => _showTypingIndicator;
  bool get messageAnimations => _messageAnimations;
  bool get soundEffects => _soundEffects;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  String get systemPrompt => _systemPrompt;
  bool get autoScroll => _autoScroll;
  bool get compactMode => _compactMode;
  
  // Server configuration getters
  String get serverHost => _serverHost;
  int get serverPort => _serverPort;
  String get serverProtocol => _serverProtocol;
  String get apiKey => _apiKey;
  String? get selectedModelId => _selectedModelId;
  String get baseUrl => AppConfig.buildBaseUrl(_serverProtocol, _serverHost, _serverPort);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    _autoSave = prefs.getBool(_autoSaveKey) ?? _autoSave;
    _sendOnEnter = prefs.getBool(_sendOnEnterKey) ?? _sendOnEnter;
    _showTypingIndicator = prefs.getBool(_showTypingIndicatorKey) ?? _showTypingIndicator;
    _messageAnimations = prefs.getBool(_messageAnimationsKey) ?? _messageAnimations;
    _soundEffects = prefs.getBool(_soundEffectsKey) ?? _soundEffects;
    _temperature = prefs.getDouble(_temperatureKey) ?? _temperature;
    _maxTokens = prefs.getInt(_maxTokensKey) ?? _maxTokens;
    _systemPrompt = prefs.getString(_systemPromptKey) ?? _systemPrompt;
    _autoScroll = prefs.getBool(_autoScrollKey) ?? _autoScroll;
    _compactMode = prefs.getBool(_compactModeKey) ?? _compactMode;
    
    // Server configuration
    _serverHost = prefs.getString(_serverHostKey) ?? _serverHost;
    _serverPort = prefs.getInt(_serverPortKey) ?? _serverPort;
    _serverProtocol = prefs.getString(_serverProtocolKey) ?? _serverProtocol;
    _apiKey = prefs.getString(_apiKeyKey) ?? _apiKey;
    _selectedModelId = prefs.getString(_selectedModelIdKey);

    notifyListeners();
  }

  Future<void> setAutoSave(bool value) async {
    _autoSave = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, value);
    notifyListeners();
  }

  Future<void> setSendOnEnter(bool value) async {
    _sendOnEnter = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sendOnEnterKey, value);
    notifyListeners();
  }

  Future<void> setShowTypingIndicator(bool value) async {
    _showTypingIndicator = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTypingIndicatorKey, value);
    notifyListeners();
  }

  Future<void> setMessageAnimations(bool value) async {
    _messageAnimations = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_messageAnimationsKey, value);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) async {
    _soundEffects = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEffectsKey, value);
    notifyListeners();
  }

  Future<void> setTemperature(double value) async {
    _temperature = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_temperatureKey, value);
    notifyListeners();
  }

  Future<void> setMaxTokens(int value) async {
    _maxTokens = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxTokensKey, value);
    notifyListeners();
  }

  Future<void> setSystemPrompt(String value) async {
    _systemPrompt = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_systemPromptKey, value);
    notifyListeners();
  }

  Future<void> setAutoScroll(bool value) async {
    _autoScroll = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoScrollKey, value);
    notifyListeners();
  }

  Future<void> setCompactMode(bool value) async {
    _compactMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_compactModeKey, value);
    notifyListeners();
  }

  // Server configuration setters
  Future<void> setServerHost(String value) async {
    _serverHost = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverHostKey, value);
    notifyListeners();
  }

  Future<void> setServerPort(int value) async {
    _serverPort = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_serverPortKey, value);
    notifyListeners();
  }

  Future<void> setServerProtocol(String value) async {
    _serverProtocol = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverProtocolKey, value);
    notifyListeners();
  }

  Future<void> setApiKey(String value) async {
    _apiKey = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, value);
    notifyListeners();
  }

  Future<void> setSelectedModelId(String? value) async {
    _selectedModelId = value;
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_selectedModelIdKey, value);
    } else {
      await prefs.remove(_selectedModelIdKey);
    }
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_autoSaveKey);
    await prefs.remove(_sendOnEnterKey);
    await prefs.remove(_showTypingIndicatorKey);
    await prefs.remove(_messageAnimationsKey);
    await prefs.remove(_soundEffectsKey);
    await prefs.remove(_temperatureKey);
    await prefs.remove(_maxTokensKey);
    await prefs.remove(_systemPromptKey);
    await prefs.remove(_autoScrollKey);
    await prefs.remove(_compactModeKey);
    
    // Server configuration
    await prefs.remove(_serverHostKey);
    await prefs.remove(_serverPortKey);
    await prefs.remove(_serverProtocolKey);
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_selectedModelIdKey);

    await initialize();
  }
}