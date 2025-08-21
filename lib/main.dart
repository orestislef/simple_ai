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
          onGenerateRoute: (settings) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) {
                switch (settings.name) {
                  case '/chat':
                    return const ChatScreen();
                  default:
                    return const ChatScreen();
                }
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          },
        );
      },
    );
  }
}