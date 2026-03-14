import 'package:flutter_test/flutter_test.dart';
import 'package:hsk_teacher/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('markWordAsLearned stores and retrieves correctly', () async {
    final storage = await StorageService.init();
    const level = 1;
    const hanzi = '我';

    expect(storage.isWordLearned(level, hanzi), isFalse);

    await storage.markWordAsLearned(level, hanzi, true);
    expect(storage.isWordLearned(level, hanzi), isTrue);

    await storage.markWordAsLearned(level, hanzi, false);
    expect(storage.isWordLearned(level, hanzi), isFalse);
  });

  test('markWordAsLearned persists between different StorageService instances', () async {
    const level = 2;
    const hanzi = '你';

    {
      final storage1 = await StorageService.init();
      await storage1.markWordAsLearned(level, hanzi, true);
    }

    {
      final storage2 = await StorageService.init();
      expect(storage2.isWordLearned(level, hanzi), isTrue);
    }
  });
}
