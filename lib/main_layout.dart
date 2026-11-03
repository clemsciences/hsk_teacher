import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showHomeButton;

  const MainLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? l10n.appTitle),
        actions: [
          ...?actions,
          if (showHomeButton)
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/'),
              tooltip: l10n.home,
            ),
        ],
      ),
      // Edge-to-edge is enabled by default on recent Android; without SafeArea
      // the body extends behind the system navigation bar and gets clipped.
      body: SafeArea(child: child),
    );
  }
}
