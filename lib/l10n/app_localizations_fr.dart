// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Professeur HSK';

  @override
  String get chooseLevel => 'Choisir un niveau';

  @override
  String hskLevel(int level) {
    return 'Niveau HSK $level';
  }

  @override
  String get randomWord => 'Mot au hasard';

  @override
  String get anotherRandomWord => 'Un autre mot au hasard';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get linkCopied => 'Lien copié dans le presse-papier !';

  @override
  String get home => 'Accueil';

  @override
  String get character => 'Caractère';

  @override
  String get pinyin => 'Pinyin';

  @override
  String get meanings => 'Significations';

  @override
  String pageOf(int page, int total) {
    return 'Page $page sur $total';
  }

  @override
  String loadingLevel(int level) {
    return 'Chargement du niveau HSK $level...';
  }

  @override
  String error(String message) {
    return 'Erreur : $message';
  }

  @override
  String get noDataFound => 'Aucune donnée trouvée';

  @override
  String wordDetail(String hanzi) {
    return 'Détail du mot : $hanzi';
  }

  @override
  String get back => 'Retour';

  @override
  String get errorTitle => 'Oups !';

  @override
  String get errorMessage => 'Une erreur est survenue.';

  @override
  String get goHome => 'Retourner à l\'accueil';

  @override
  String get markAsLearned => 'Marquer comme appris';

  @override
  String get learned => 'Appris';

  @override
  String get clearHistory => 'Oublier l\'historique';

  @override
  String get historyCleared => 'Historique effacé';

  @override
  String get visited => 'Consulté';

  @override
  String resumeLastSession(String path) {
    return 'Reprendre là où vous vous étiez arrêté : $path';
  }

  @override
  String get quizTitle => 'Quiz';

  @override
  String get startQuiz => 'Démarrer le quiz';

  @override
  String get numberOfQuestions => 'Nombre de questions';

  @override
  String get selectLevel => 'Niveau';

  @override
  String get allLevels => 'Tous les niveaux';

  @override
  String get quizType => 'Type de quiz';

  @override
  String get quizTypePinyinToHanzi => 'Pinyin → Caractère';

  @override
  String get quizTypeHanziToPinyin => 'Caractère → Pinyin';

  @override
  String get quizTypeHanziToMeaning => 'Caractère → Signification';

  @override
  String get quizGenerating => 'Génération du quiz...';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get quizFindHanziForPinyin =>
      'Quel caractère correspond à ce pinyin ?';

  @override
  String get quizFindPinyinForHanzi =>
      'Quel pinyin correspond à ce caractère ?';

  @override
  String get quizFindMeaningForHanzi =>
      'Quelle signification correspond à ce caractère ?';

  @override
  String get nextQuestion => 'Suivant';

  @override
  String get quizSeeResults => 'Voir les résultats';

  @override
  String get quizFinished => 'Quiz terminé !';

  @override
  String quizScore(int score, int total) {
    return 'Votre score : $score / $total';
  }

  @override
  String get restartQuiz => 'Recommencer';
}
