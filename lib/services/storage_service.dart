import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyLearnedWords = 'learned_words';
  static const String keyLastLevel = 'last_level';
  static const String keyVisitedWords = 'visited_words';
  static const String keyLastPath = 'last_path';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Learned words management
  Future<void> markWordAsLearned(int level, String hanzi, bool learned) async {
    final learnedWords = getLearnedWords();
    final wordKey = 'level_${level}_$hanzi';

    if (learned) {
      if (!learnedWords.contains(wordKey)) {
        learnedWords.add(wordKey);
      }
    } else {
      learnedWords.remove(wordKey);
    }

    await _prefs.setStringList(keyLearnedWords, learnedWords);
  }

  List<String> getLearnedWords() {
    return _prefs.getStringList(keyLearnedWords) ?? [];
  }

  bool isWordLearned(int level, String hanzi) {
    final learnedWords = getLearnedWords();
    return learnedWords.contains('level_${level}_$hanzi');
  }

  // Visited words management (history)
  Future<void> addToHistory(int level, String hanzi) async {
    final visitedWords = getVisitedWords();
    final wordKey = 'level_${level}_$hanzi';

    if (!visitedWords.contains(wordKey)) {
      visitedWords.add(wordKey);
      await _prefs.setStringList(keyVisitedWords, visitedWords);
    }
  }

  List<String> getVisitedWords() {
    return _prefs.getStringList(keyVisitedWords) ?? [];
  }

  bool isWordVisited(int level, String hanzi) {
    final visitedWords = getVisitedWords();
    return visitedWords.contains('level_${level}_$hanzi');
  }

  Future<void> clearHistory() async {
    await _prefs.remove(keyVisitedWords);
  }

  // Last visited level management
  Future<void> saveLastLevel(int level) async {
    await _prefs.setInt(keyLastLevel, level);
  }

  int? getLastLevel() {
    return _prefs.getInt(keyLastLevel);
  }

  // Last visited path management
  Future<void> saveLastPath(String path) async {
    await _prefs.setString(keyLastPath, path);
  }

  String? getLastPath() {
    return _prefs.getString(keyLastPath);
  }
}
