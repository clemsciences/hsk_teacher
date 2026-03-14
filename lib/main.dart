import 'package:flutter/material.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'url_strategy_noop.dart'
    if (dart.library.js_interop) 'url_strategy_web.dart'
    if (dart.library.js) 'url_strategy_web.dart'
    if (dart.library.html) 'url_strategy_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  setupUrlStrategy();
  runApp(MyApp(storageService: storageService));
}
