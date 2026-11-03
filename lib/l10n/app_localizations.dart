import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HSK Teacher'**
  String get appTitle;

  /// No description provided for @chooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose a level'**
  String get chooseLevel;

  /// No description provided for @hskLevel.
  ///
  /// In en, this message translates to:
  /// **'HSK Level {level}'**
  String hskLevel(int level);

  /// No description provided for @randomWord.
  ///
  /// In en, this message translates to:
  /// **'Random word'**
  String get randomWord;

  /// No description provided for @anotherRandomWord.
  ///
  /// In en, this message translates to:
  /// **'Another random word'**
  String get anotherRandomWord;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get linkCopied;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @character.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get character;

  /// No description provided for @pinyin.
  ///
  /// In en, this message translates to:
  /// **'Pinyin'**
  String get pinyin;

  /// No description provided for @meanings.
  ///
  /// In en, this message translates to:
  /// **'Meanings'**
  String get meanings;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageOf(int page, int total);

  /// No description provided for @loadingLevel.
  ///
  /// In en, this message translates to:
  /// **'Loading HSK Level {level}...'**
  String loadingLevel(int level);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @wordDetail.
  ///
  /// In en, this message translates to:
  /// **'Word detail: {hanzi}'**
  String wordDetail(String hanzi);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get errorTitle;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorMessage;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go back home'**
  String get goHome;

  /// No description provided for @markAsLearned.
  ///
  /// In en, this message translates to:
  /// **'Mark as learned'**
  String get markAsLearned;

  /// No description provided for @learned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get learned;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// No description provided for @resumeLastSession.
  ///
  /// In en, this message translates to:
  /// **'Resume where you left off: {path}'**
  String resumeLastSession(String path);

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizTitle;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get startQuiz;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get numberOfQuestions;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get selectLevel;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get allLevels;

  /// No description provided for @quizType.
  ///
  /// In en, this message translates to:
  /// **'Quiz type'**
  String get quizType;

  /// No description provided for @quizTypePinyinToHanzi.
  ///
  /// In en, this message translates to:
  /// **'Pinyin → Character'**
  String get quizTypePinyinToHanzi;

  /// No description provided for @quizTypeHanziToPinyin.
  ///
  /// In en, this message translates to:
  /// **'Character → Pinyin'**
  String get quizTypeHanziToPinyin;

  /// No description provided for @quizTypeHanziToMeaning.
  ///
  /// In en, this message translates to:
  /// **'Character → Meaning'**
  String get quizTypeHanziToMeaning;

  /// No description provided for @quizGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating quiz...'**
  String get quizGenerating;

  /// No description provided for @quizQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionProgress(int current, int total);

  /// No description provided for @quizFindHanziForPinyin.
  ///
  /// In en, this message translates to:
  /// **'Which character matches this pinyin?'**
  String get quizFindHanziForPinyin;

  /// No description provided for @quizFindPinyinForHanzi.
  ///
  /// In en, this message translates to:
  /// **'Which pinyin matches this character?'**
  String get quizFindPinyinForHanzi;

  /// No description provided for @quizFindMeaningForHanzi.
  ///
  /// In en, this message translates to:
  /// **'Which meaning matches this character?'**
  String get quizFindMeaningForHanzi;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextQuestion;

  /// No description provided for @quizSeeResults.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get quizSeeResults;

  /// No description provided for @quizFinished.
  ///
  /// In en, this message translates to:
  /// **'Quiz finished!'**
  String get quizFinished;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'Your score: {score} / {total}'**
  String quizScore(int score, int total);

  /// No description provided for @restartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartQuiz;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
