// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HSK Teacher';

  @override
  String get chooseLevel => 'Choose a level';

  @override
  String hskLevel(int level) {
    return 'HSK Level $level';
  }

  @override
  String get randomWord => 'Random word';

  @override
  String get anotherRandomWord => 'Another random word';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard!';

  @override
  String get home => 'Home';

  @override
  String get character => 'Character';

  @override
  String get pinyin => 'Pinyin';

  @override
  String get meanings => 'Meanings';

  @override
  String pageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String loadingLevel(int level) {
    return 'Loading HSK Level $level...';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get noDataFound => 'No data found';

  @override
  String wordDetail(String hanzi) {
    return 'Word detail: $hanzi';
  }

  @override
  String get back => 'Back';

  @override
  String get errorTitle => 'Oops!';

  @override
  String get errorMessage => 'An error occurred.';

  @override
  String get goHome => 'Go back home';

  @override
  String get markAsLearned => 'Mark as learned';

  @override
  String get learned => 'Learned';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get visited => 'Visited';

  @override
  String resumeLastSession(String path) {
    return 'Resume where you left off: $path';
  }

  @override
  String get quizTitle => 'Quiz';

  @override
  String get startQuiz => 'Start quiz';

  @override
  String get numberOfQuestions => 'Number of questions';

  @override
  String get selectLevel => 'Level';

  @override
  String get allLevels => 'All levels';

  @override
  String get quizType => 'Quiz type';

  @override
  String get quizTypePinyinToHanzi => 'Pinyin → Character';

  @override
  String get quizTypeHanziToPinyin => 'Character → Pinyin';

  @override
  String get quizTypeHanziToMeaning => 'Character → Meaning';

  @override
  String get quizGenerating => 'Generating quiz...';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizFindHanziForPinyin => 'Which character matches this pinyin?';

  @override
  String get quizFindPinyinForHanzi => 'Which pinyin matches this character?';

  @override
  String get quizFindMeaningForHanzi => 'Which meaning matches this character?';

  @override
  String get nextQuestion => 'Next';

  @override
  String get quizSeeResults => 'See results';

  @override
  String get quizFinished => 'Quiz finished!';

  @override
  String quizScore(int score, int total) {
    return 'Your score: $score / $total';
  }

  @override
  String get restartQuiz => 'Restart';
}
