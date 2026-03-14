import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';
import 'services/storage_service.dart';

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return StorageServiceProvider(
      storageService: storageService,
      child: MaterialApp.router(
        title: 'HSK Teacher',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
      ),
    );
  }
}

class StorageServiceProvider extends InheritedWidget {
  final StorageService storageService;

  const StorageServiceProvider({
    super.key,
    required this.storageService,
    required super.child,
  });

  static StorageService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StorageServiceProvider>();
    return provider!.storageService;
  }

  @override
  bool updateShouldNotify(StorageServiceProvider oldWidget) =>
      storageService != oldWidget.storageService;
}
