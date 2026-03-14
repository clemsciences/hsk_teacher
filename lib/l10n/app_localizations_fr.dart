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
}
