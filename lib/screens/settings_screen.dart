import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart' as theme_service;
import '../services/export_service.dart';
import '../services/chat_service.dart';
import '../services/ai_service.dart';
import '../utils/snackbar_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final theme_service.ThemeService _themeService = theme_service.ThemeService();
  final ExportService _exportService = ExportService();
  final ChatService _chatService = ChatService();
  final AIService _aiService = AIService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_settingsService, _themeService]),
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('Appearance', [
                _buildThemeSelector(),
                _buildSwitchTile(
                  'Compact Mode',
                  'Use smaller message bubbles',
                  Icons.compress,
                  _settingsService.compactMode,
                  _settingsService.setCompactMode,
                ),
                _buildSwitchTile(
                  'Message Animations',
                  'Enable smooth animations for messages',
                  Icons.animation,
                  _settingsService.messageAnimations,
                  _settingsService.setMessageAnimations,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              _buildSection('Behavior', [
                _buildSwitchTile(
                  'Send on Enter',
                  'Press Enter to send messages',
                  Icons.keyboard_return,
                  _settingsService.sendOnEnter,
                  _settingsService.setSendOnEnter,
                ),
                _buildSwitchTile(
                  'Auto Scroll',
                  'Automatically scroll to new messages',
                  Icons.vertical_align_bottom,
                  _settingsService.autoScroll,
                  _settingsService.setAutoScroll,
                ),
                _buildSwitchTile(
                  'Auto Save',
                  'Automatically save conversations',
                  Icons.save,
                  _settingsService.autoSave,
                  _settingsService.setAutoSave,
                ),
                _buildSwitchTile(
                  'Typing Indicator',
                  'Show typing indicator when AI is responding',
                  Icons.more_horiz,
                  _settingsService.showTypingIndicator,
                  _settingsService.setShowTypingIndicator,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              _buildSection('Server Configuration', [
                _buildServerConfigTile(),
                _buildActionTile(
                  'Test Connection',
                  'Test connection to AI server',
                  Icons.wifi_protected_setup,
                  _testConnection,
                ),
              ]),
              
              const SizedBox(height: 24),
              
              _buildSection('AI Settings', [
                _buildSliderTile(
                  'Temperature',
                  'Controls randomness of responses (0.0 - 2.0)',
                  Icons.thermostat,
                  _settingsService.temperature,
                  0.0,
                  2.0,
                  _settingsService.setTemperature,
                ),
                _buildSystemPromptTile(),
              ]),
              
              const SizedBox(height: 24),
              
              _buildSection('Data Management', [
                _buildActionTile(
                  'Export All Chats',
                  'Export all conversations to file',
                  Icons.download,
                  _showExportDialog,
                ),
                _buildActionTile(
                  'Clear All Chats',
                  'Delete all conversation history',
                  Icons.delete_sweep,
                  _showClearChatsDialog,
                  isDestructive: true,
                ),
                _buildActionTile(
                  'Reset Settings',
                  'Reset all settings to default values',
                  Icons.restore,
                  _showResetSettingsDialog,
                  isDestructive: true,
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return ListTile(
      leading: Icon(_themeService.currentThemeIcon),
      title: const Text('Theme'),
      subtitle: Text(_themeService.currentThemeDisplayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showThemeDialog,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPromptTile() {
    return ListTile(
      leading: const Icon(Icons.psychology),
      title: const Text('System Prompt'),
      subtitle: Text(
        _settingsService.systemPrompt,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showSystemPromptDialog,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animation, child) {
                return Transform.scale(
                  scale: animation,
                  child: Opacity(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light'),
                subtitle: const Text('Light theme'),
                trailing: Radio<theme_service.ThemeMode>(
                  value: theme_service.ThemeMode.light,
                  groupValue: _themeService.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      _themeService.setThemeMode(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  _themeService.setThemeMode(theme_service.ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animation, child) {
                return Transform.scale(
                  scale: animation,
                  child: Opacity(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark'),
                subtitle: const Text('Dark theme'),
                trailing: Radio<theme_service.ThemeMode>(
                  value: theme_service.ThemeMode.dark,
                  groupValue: _themeService.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      _themeService.setThemeMode(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  _themeService.setThemeMode(theme_service.ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animation, child) {
                return Transform.scale(
                  scale: animation,
                  child: Opacity(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('System'),
                subtitle: const Text('Follow system theme'),
                trailing: Radio<theme_service.ThemeMode>(
                  value: theme_service.ThemeMode.system,
                  groupValue: _themeService.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      _themeService.setThemeMode(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  _themeService.setThemeMode(theme_service.ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemPromptDialog() {
    final controller = TextEditingController(text: _settingsService.systemPrompt);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Prompt'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter system prompt...',
            ),
            maxLines: 5,
            minLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _settingsService.setSystemPrompt(controller.text);
              Navigator.of(context).pop();
              SnackBarUtils.showSuccess(context, 'System prompt updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Chats'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _exportService.exportAllChats(_chatService.chats, ExportFormat.json);
              Navigator.of(context).pop();
              SnackBarUtils.showSuccess(context, 'Chats exported as JSON');
            },
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () {
              _exportService.exportAllChats(_chatService.chats, ExportFormat.txt);
              Navigator.of(context).pop();
              SnackBarUtils.showSuccess(context, 'Chats exported as TXT');
            },
            child: const Text('TXT'),
          ),
          TextButton(
            onPressed: () {
              _exportService.exportAllChats(_chatService.chats, ExportFormat.markdown);
              Navigator.of(context).pop();
              SnackBarUtils.showSuccess(context, 'Chats exported as Markdown');
            },
            child: const Text('Markdown'),
          ),
        ],
      ),
    );
  }

  void _showClearChatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Chats'),
        content: const Text('This will permanently delete all conversation history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _chatService.clearAllChats();
              Navigator.of(context).pop();
              SnackBarUtils.showInfo(context, 'All chats cleared');
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('This will reset all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _settingsService.resetToDefaults();
              Navigator.of(context).pop();
              SnackBarUtils.showInfo(context, 'Settings reset to defaults');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildServerConfigTile() {
    return ListTile(
      leading: const Icon(Icons.dns),
      title: const Text('Server Configuration'),
      subtitle: Text(_settingsService.baseUrl),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showServerConfigDialog,
    );
  }

  void _showServerConfigDialog() {
    final hostController = TextEditingController(text: _settingsService.serverHost);
    final portController = TextEditingController(text: _settingsService.serverPort.toString());
    final apiKeyController = TextEditingController(text: _settingsService.apiKey);
    String selectedProtocol = _settingsService.serverProtocol;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Server Configuration'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedProtocol,
                  decoration: const InputDecoration(labelText: 'Protocol'),
                  dropdownColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Colors.white,
                  items: [
                    DropdownMenuItem(
                      value: 'http', 
                      child: Text(
                        'HTTP',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'https', 
                      child: Text(
                        'HTTPS',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedProtocol = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(
                    labelText: 'Server Host',
                    hintText: '192.168.1.100',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: '1234',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: 'lm-studio',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Available Endpoints:\n• /v1/models\n• /v1/chat/completions\n• /v1/completions\n• /v1/embeddings',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final port = int.tryParse(portController.text) ?? 1234;
                
                await _settingsService.setServerProtocol(selectedProtocol);
                await _settingsService.setServerHost(hostController.text);
                await _settingsService.setServerPort(port);
                await _settingsService.setApiKey(apiKeyController.text);
                
                // Update AI service configuration
                _aiService.updateConfiguration();
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  SnackBarUtils.showSuccess(context, 'Server configuration updated');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _testConnection() async {
    try {
      // Update configuration and test connection
      _aiService.updateConfiguration();
      
      if (mounted) {
        SnackBarUtils.showInfo(context, 'Testing connection...');
      }
      
      final models = await _aiService.getAvailableModels();
      
      if (mounted) {
        if (models.isNotEmpty) {
          SnackBarUtils.showSuccess(
            context, 
            'Connection successful! Found ${models.length} model(s)',
          );
        } else {
          SnackBarUtils.showWarning(context, 'Connected but no models found');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Connection failed: $e');
      }
    }
  }
}