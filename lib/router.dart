import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'level_selection_page.dart';
import 'words_list_page.dart';
import 'word_detail_page.dart';
import 'error_page.dart';
import 'main_layout.dart';
import 'l10n/app_localizations.dart';

import 'services/storage_service.dart';
import 'app.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.toString();
      // On sauvegarde le chemin actuel s'il ne s'agit pas de l'accueil
      if (path != '/') {
        StorageServiceProvider.of(context).saveLastPath(path);
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final l10n = AppLocalizations.of(context)!;
          
          String title = l10n.appTitle;
          List<Widget>? actions;
          bool showHomeButton = true;

          final name = state.fullPath;
          if (name == '/') {
            title = '${l10n.appTitle} - ${l10n.chooseLevel}';
            showHomeButton = false;
          } else if (name == '/level/:level/page/:page') {
            final level = state.pathParameters['level'];
            title = l10n.hskLevel(int.tryParse(level ?? '') ?? 0);
          } else if (name == '/level/:level/word/:index') {
            final level = state.pathParameters['level'];
            final extra = state.extra as Map<String, dynamic>?;
            final hanzi = extra?['hanzi'] as String?;
            title = l10n.wordDetail(hanzi ?? ''); 
          }

          return MainLayout(
            title: title,
            actions: actions,
            showHomeButton: showHomeButton,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const LevelSelectionPage(),
          ),
          GoRoute(
            path: '/level/:level/page/:page',
            name: 'words_list',
            builder: (context, state) {
              final levelStr = state.pathParameters['level'];
              final pageStr = state.pathParameters['page'];

              final level = int.tryParse(levelStr ?? '');
              final page = int.tryParse(pageStr ?? '');

              if (level != null && page != null && level >= 1 && level <= 6 && page >= 0) {
                return WordsListPage(level: level, page: page);
              }

              return const LevelSelectionPage();
            },
          ),
          GoRoute(
            path: '/level/:level/word/:index',
            name: 'word_detail',
            builder: (context, state) {
              final levelStr = state.pathParameters['level'];
              final indexStr = state.pathParameters['index'];
              final level = int.tryParse(levelStr ?? '');
              final index = int.tryParse(indexStr ?? '');

              // On peut passer pinyin et meanings via extra si on vient de la liste
              final extra = state.extra as Map<String, dynamic>?;
              final hanzi = extra?['hanzi'] as String?;
              final pinyin = extra?['pinyin'] as String?;
              final meanings = extra?['meanings'] as String?;

              if (level != null && index != null) {
                return WordDetailPage(
                  level: level,
                  index: index,
                  hanzi: hanzi,
                  pinyin: pinyin,
                  meanings: meanings,
                );
              }
              return const LevelSelectionPage();
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error?.toString()),
  );
}
