import 'package:flutter/material.dart';
import 'services/ai_service.dart';
import 'services/chat_service.dart';
import 'services/theme_service.dart' as theme_service;
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'screens/chat_screen.dart';
import 'models/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  AIService.initialize();
  await ChatService().initialize();
  await theme_service.ThemeService().initialize();
  await SettingsService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme_service.ThemeService(),
      builder: (context, child) {
        final themeService = theme_service.ThemeService();
        
        ThemeMode flutterThemeMode;
        switch (themeService.themeMode) {
          case theme_service.ThemeMode.light:
            flutterThemeMode = ThemeMode.light;
            break;
          case theme_service.ThemeMode.dark:
            flutterThemeMode = ThemeMode.dark;
            break;
          case theme_service.ThemeMode.system:
            flutterThemeMode = ThemeMode.system;
            break;
        }
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: flutterThemeMode,
          home: const ChatScreen(),
        );
      },
    );
  }
}