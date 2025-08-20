import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && ResponsiveLayout.isWeb(context)) {
      return _buildWebLayout(context);
    }
    
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          if (appBar != null)
            Container(
              height: kToolbarHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor ??
                    Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: appBar,
            ),
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveLayout.getMaxWidth(context),
                ),
                child: body,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}