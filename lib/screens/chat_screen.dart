import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/chat.dart';
import '../models/app_config.dart';
import '../services/ai_service.dart';
import '../services/safety_service.dart';
import '../services/prompt_service.dart';
import '../services/chat_service.dart';
import '../services/settings_service.dart';
import '../utils/date_formatter.dart';
import '../utils/snackbar_utils.dart';
import '../utils/responsive_layout.dart';
import '../utils/text_processor.dart';
import '../widgets/enhanced_message_bubble.dart';
import '../widgets/prompt_management_dialog.dart';
import '../widgets/message_input.dart';
import '../widgets/model_selector.dart';
import '../widgets/chat_sidebar.dart';
import '../screens/settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final SafetyService _safetyService = SafetyService();
  final PromptService _promptService = PromptService();
  final ChatService _chatService = ChatService();
  final SettingsService _settingsService = SettingsService();

  final String _systemContext = AppConfig.defaultSystemPrompt;
  bool _isGenerating = false;
  List<OpenAIModelModel> _availableModels = [];
  OpenAIModelModel? _selectedModel;
  Stream<OpenAIStreamChatCompletionModel>? _currentStream;
  final List<OpenAIChatCompletionChoiceMessageModel> _chatContext = [];
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _chatService.initialize();
    
    // Update AI service configuration with current settings
    _aiService.updateConfiguration();
    
    await _loadModels();
    _handleSystemContext();
    
    // Load previously selected model
    final savedModelId = _settingsService.selectedModelId;
    if (savedModelId != null && _availableModels.isNotEmpty) {
      final savedModel = _availableModels.firstWhere(
        (model) => model.id == savedModelId,
        orElse: () => _availableModels.first,
      );
      _selectedModel = savedModel;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final showSidebar = ResponsiveLayout.shouldShowSidebar(context);

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          if (showSidebar)
            ChatSidebar(
              onChatSelected: _selectChat,
              onNewChat: _createNewChat,
            ),
          Expanded(
            child: _buildChatContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isMobile = ResponsiveLayout.isMobile(context);
    
    return AppBar(
      title: ListenableBuilder(
        listenable: _chatService,
        builder: (context, child) {
          final currentChat = _chatService.currentChat;
          return Text(
            currentChat?.title ?? AppConfig.appName,
            style: const TextStyle(fontSize: 18),
          );
        },
      ),
      actions: [
        ModelSelector(
          selectedModel: _selectedModel,
          availableModels: _availableModels,
          onModelSelected: _selectModel,
          onRefreshModels: _loadModels,
          isLoading: _isLoadingModels,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
        IconButton(
          onPressed: _showPromptManagement,
          icon: const Icon(Icons.bookmark_outline),
          tooltip: 'Manage Prompts',
        ),
        if (!isMobile) ...[
          FilledButton.tonal(
            onPressed: _isGenerating ? null : _createNewChat,
            child: const Text('New Chat'),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ChatSidebar(
        onChatSelected: (chat) {
          _selectChat(chat);
          Navigator.of(context).pop();
        },
        onNewChat: () {
          _createNewChat();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        if (_isGenerating)
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.getMaxWidth(context),
            ),
            child: _buildMessages(),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxWidth(context),
          ),
          child: MessageInput(
            controller: _messageController,
            isGenerating: _isGenerating,
            onSend: _sendMessage,
            onStop: _stopGeneration,
          ),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return ListenableBuilder(
      listenable: _chatService,
      builder: (context, child) {
        final currentChat = _chatService.currentChat;
        final messages = currentChat?.messages ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: ResponsiveLayout.isMobile(context) ? 0 : 16,
          ),
          itemCount: messages.length,
          // Performance optimizations
          cacheExtent: 1000, // Cache more items for smoother scrolling
          addAutomaticKeepAlives: false, // Don't keep all widgets alive
          addRepaintBoundaries: true, // Isolate repaints
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCompact = _settingsService.compactMode;
            final showAnimations = _settingsService.messageAnimations;
            
            return RepaintBoundary( // Isolate each message for better performance
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveLayout.getMessageMaxWidth(context),
                ),
                child: EnhancedMessageBubble(
                  key: ValueKey(message.id), // Stable key for widget recycling
                  message: message,
                  isCompact: isCompact,
                  showAnimations: showAnimations,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.getMaxWidth(context),
        ),
        padding: ResponsiveLayout.getHorizontalPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ${AppConfig.appName}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with your AI assistant',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_promptService.hasPrompts())
              FilledButton.icon(
                onPressed: _showPromptManagement,
                icon: const Icon(Icons.bookmark),
                label: const Text('Use Saved Prompt'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoadingModels = true;
    });

    try {
      // Update configuration before loading models
      _aiService.updateConfiguration();
      
      final models = await _aiService.getAvailableModels();
      setState(() {
        _availableModels = models;
        if (_selectedModel == null && models.isNotEmpty) {
          // Try to load saved model first, otherwise use first available
          final savedModelId = _settingsService.selectedModelId;
          if (savedModelId != null) {
            final savedModel = models.firstWhere(
              (model) => model.id == savedModelId,
              orElse: () => models.first,
            );
            _selectedModel = savedModel;
          } else {
            _selectedModel = models.first;
            _settingsService.setSelectedModelId(models.first.id);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to load models: $e');
      }
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  void _selectModel(OpenAIModelModel model) {
    setState(() {
      _selectedModel = model;
    });
    
    // Save selected model in settings
    _settingsService.setSelectedModelId(model.id);
    
    final currentChat = _chatService.currentChat;
    if (currentChat != null) {
      _chatService.updateChatModel(currentChat.id, model.id);
    }
    
    SnackBarUtils.showInfo(context, 'Selected model: ${model.id}');
  }

  void _selectChat(Chat chat) {
    _chatService.selectChat(chat);
    _buildChatContext();
    _scrollToBottom();
  }

  void _createNewChat() {
    if (_isGenerating) return;
    
    _chatService.createNewChat(modelId: _selectedModel?.id);
    _buildChatContext();
    SnackBarUtils.showInfo(context, 'New chat started');
  }

  void _buildChatContext() {
    _chatContext.clear();
    _handleSystemContext();
    
    final currentChat = _chatService.currentChat;
    if (currentChat != null) {
      for (final message in currentChat.messages) {
        if (message.role.isUser) {
          _chatContext.add(_aiService.createUserMessage(message.text));
        } else if (message.role.isAssistant) {
          _chatContext.add(_aiService.createAssistantMessage(message.text));
        }
      }
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (!_safetyService.isSafeMessage(message)) {
      SnackBarUtils.showWarning(
        context,
        'Message contains potentially harmful content and was blocked.',
      );
      return;
    }

    if (_availableModels.isEmpty) {
      await _loadModels();
      if (_availableModels.isEmpty) {
        if (mounted) {
          SnackBarUtils.showError(context, 'No models available. Please check your server.');
        }
        return;
      }
    }

    _selectedModel ??= _availableModels.first;

    final userMessage = Message(
      text: message,
      role: MessageRole.user,
      timestamp: DateFormatter.getCurrentTimestamp(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await _chatService.addMessageToCurrentChat(userMessage);
    _chatContext.add(_aiService.createUserMessage(message));
    _messageController.clear();

    setState(() {
      _isGenerating = true;
    });

    try {
      _currentStream = _aiService.createChatStream(
        modelId: _selectedModel!.id,
        messages: _chatContext,
      );

      String assistantResponse = '';
      bool hasStartedResponse = false;

      await for (final completion in _currentStream!) {
        if (!_isGenerating) break;

        final choice = completion.choices.first;
        
        if (choice.finishReason == "stop") {
          _chatContext.add(_aiService.createAssistantMessage(assistantResponse));
          setState(() {
            _isGenerating = false;
          });
          break;
        }

        final deltaContent = choice.delta.content?.first?.text;
        if (deltaContent != null) {
          assistantResponse += deltaContent;
          
          // Clean the response by removing <think> tags
          final cleanedResponse = TextProcessor.cleanResponse(assistantResponse);
          
          if (!hasStartedResponse) {
            final assistantMessage = Message(
              text: cleanedResponse,
              role: MessageRole.assistant,
              timestamp: DateFormatter.getCurrentTimestamp(),
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            );
            await _chatService.addMessageToCurrentChat(assistantMessage);
            hasStartedResponse = true;
          } else {
            await _chatService.updateLastMessage(cleanedResponse);
          }
          
          _scrollToBottom();
        }
      }
    } catch (e) {
      _handleError('Connection error: Please check if the AI server is running and accessible.');
      if (mounted) {
        SnackBarUtils.showError(context, 'Error: $e');
      }
    }
  }

  void _stopGeneration() {
    setState(() {
      _isGenerating = false;
    });
    _currentStream = null;
    SnackBarUtils.showWarning(context, 'Generation stopped');
  }

  void _handleError(String message) {
    setState(() {
      _isGenerating = false;
    });
    
    final errorMessage = Message(
      text: message,
      role: MessageRole.error,
      timestamp: DateFormatter.getCurrentTimestamp(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    
    _chatService.addMessageToCurrentChat(errorMessage);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSystemContext() {
    if (_systemContext.isEmpty) return;

    final systemMessage = _aiService.createSystemMessage(_systemContext);
    if (_chatContext.isEmpty) {
      _chatContext.add(systemMessage);
    } else {
      _chatContext.removeWhere((msg) => msg.role == OpenAIChatMessageRole.system);
      _chatContext.insert(0, systemMessage);
    }
  }


  void _showPromptManagement() {
    showDialog(
      context: context,
      builder: (context) => PromptManagementDialog(
        onPromptSelected: (prompt) {
          _messageController.text = prompt;
        },
      ),
    );
  }
}