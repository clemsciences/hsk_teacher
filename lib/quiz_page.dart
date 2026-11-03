import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hsk_teacher/l10n/app_localizations.dart';
import 'package:hsk_teacher/theme.dart';
import 'package:hsk_teacher/word_detail_content.dart';

/// The kind of question the quiz can generate on the fly.
enum QuizType {
  /// Show a pinyin, pick the matching hanzi among four characters.
  pinyinToHanzi,

  /// Show a hanzi, pick the matching pinyin among four pinyins.
  hanziToPinyin,

  /// Show a hanzi, pick the matching definition among four meanings.
  hanziToMeaning,
}

/// A single generated question with four options and the index of the answer.
class QuizQuestion {
  final QuizType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final Map<String, dynamic> word;

  const QuizQuestion({
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.word,
  });
}

/// The phases the quiz page goes through.
enum _QuizPhase { setup, loading, playing, finished }

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const int minQuestions = 5;
  static const int maxQuestions = 30;

  /// Above this width we show the word detail beside the question (desktop/web);
  /// below it we show the detail in a popup (mobile).
  static const double wideBreakpoint = 800;

  final Random _random = Random();

  _QuizPhase _phase = _QuizPhase.setup;
  double _questionCount = 10;
  int? _selectedLevel; // null means all levels
  QuizType _selectedType = QuizType.pinyinToHanzi;

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;
  String? _errorMessage;

  Future<void> _startQuiz() async {
    setState(() {
      _phase = _QuizPhase.loading;
      _errorMessage = null;
    });

    try {
      final levels = _selectedLevel == null
          ? List<int>.generate(6, (i) => i + 1)
          : [_selectedLevel!];
      final pool = await _loadPool(levels);
      final questions = _generateQuestions(pool, _questionCount.round());

      if (!mounted) return;
      if (questions.isEmpty) {
        setState(() {
          _phase = _QuizPhase.setup;
          _errorMessage = AppLocalizations.of(context)!.noDataFound;
        });
        return;
      }

      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _selectedOptionIndex = null;
        _score = 0;
        _phase = _QuizPhase.playing;
      });
    } catch (e) {
      debugPrint('Error starting quiz: $e');
      if (!mounted) return;
      setState(() {
        _phase = _QuizPhase.setup;
        _errorMessage = e.toString();
      });
    }
  }

  /// Loads every word of the requested levels into a flat in-memory pool.
  Future<List<Map<String, dynamic>>> _loadPool(List<int> levels) async {
    final List<Map<String, dynamic>> pool = [];

    for (final level in levels) {
      try {
        final metadata = json.decode(
          await rootBundle.loadString(
            'assets/data/levels/level_$level/metadata.json',
          ),
        );
        final int totalChunks = metadata['total_chunks'];

        final chunkStrings = await Future.wait(
          List.generate(
            totalChunks,
            (c) => rootBundle.loadString(
              'assets/data/levels/level_$level/chunk_$c.json',
            ),
          ),
        );

        for (final chunkString in chunkStrings) {
          final List data = json.decode(chunkString);
          for (final word in data) {
            final entry = Map<String, dynamic>.from(word);
            // Chunks don't carry the level; keep it so the detail view can show it.
            entry['level'] = level;
            pool.add(entry);
          }
        }
      } catch (e) {
        debugPrint('Error loading level $level: $e');
      }
    }

    return pool;
  }

  List<QuizQuestion> _generateQuestions(
    List<Map<String, dynamic>> pool,
    int count,
  ) {
    final questions = <QuizQuestion>[];
    int attempts = 0;
    final int maxAttempts = count * 50 + 50;

    while (questions.length < count && attempts < maxAttempts) {
      attempts++;
      final question = _buildQuestion(pool, _selectedType);
      if (question != null) {
        questions.add(question);
      }
    }

    return questions;
  }

  /// Builds a single question of the given type, or null if the pool lacks
  /// enough distinct words to fill four options.
  QuizQuestion? _buildQuestion(List<Map<String, dynamic>> pool, QuizType type) {
    final String promptField;
    final String optionField;
    switch (type) {
      case QuizType.pinyinToHanzi:
        promptField = 'pinyin';
        optionField = 'hanzi';
        break;
      case QuizType.hanziToPinyin:
        promptField = 'hanzi';
        optionField = 'pinyin';
        break;
      case QuizType.hanziToMeaning:
        promptField = 'hanzi';
        optionField = 'meanings';
        break;
    }

    bool hasField(Map<String, dynamic> w, String field) =>
        (w[field]?.toString().trim().isNotEmpty) ?? false;

    final valid = pool
        .where((w) => hasField(w, promptField) && hasField(w, optionField))
        .toList();
    if (valid.length < 4) return null;

    final answer = valid[_random.nextInt(valid.length)];
    final correctOption = answer[optionField].toString();
    final promptText = answer[promptField].toString();

    final options = <String>{correctOption};
    int guard = 0;
    while (options.length < 4 && guard < 200) {
      guard++;
      options.add(valid[_random.nextInt(valid.length)][optionField].toString());
    }
    if (options.length < 4) return null;

    final optionList = options.toList()..shuffle(_random);
    return QuizQuestion(
      type: type,
      prompt: promptText,
      options: optionList,
      correctIndex: optionList.indexOf(correctOption),
      word: answer,
    );
  }

  void _answer(int index) {
    if (_selectedOptionIndex != null) return;
    final question = _questions[_currentIndex];
    setState(() {
      _selectedOptionIndex = index;
      if (index == question.correctIndex) {
        _score++;
      }
    });
    // On wide screens the detail shows in a side panel (rendered by build);
    // on mobile we surface the full word page in a popup.
    if (MediaQuery.of(context).size.width <= wideBreakpoint) {
      _showWordDialog(question);
    }
  }

  void _showWordDialog(QuizQuestion question) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.largePadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _wordDetail(question),
                    const SizedBox(height: AppTheme.largePadding),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.back),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The full word page content for the answered question.
  Widget _wordDetail(QuizQuestion question) {
    final word = question.word;
    return WordDetailContent(
      level: (word['level'] as int?) ?? _selectedLevel ?? 1,
      hanzi: (word['hanzi'] ?? '').toString(),
      pinyin: word['pinyin']?.toString(),
      meanings: word['meanings']?.toString(),
    );
  }

  void _next() {
    if (_currentIndex >= _questions.length - 1) {
      setState(() => _phase = _QuizPhase.finished);
    } else {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
      });
    }
  }

  void _reset() {
    setState(() {
      _phase = _QuizPhase.setup;
      _questions = [];
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _score = 0;
    });
  }

  String _typeLabel(AppLocalizations l10n, QuizType type) {
    switch (type) {
      case QuizType.pinyinToHanzi:
        return l10n.quizTypePinyinToHanzi;
      case QuizType.hanziToPinyin:
        return l10n.quizTypeHanziToPinyin;
      case QuizType.hanziToMeaning:
        return l10n.quizTypeHanziToMeaning;
    }
  }

  String _instruction(AppLocalizations l10n, QuizType type) {
    switch (type) {
      case QuizType.pinyinToHanzi:
        return l10n.quizFindHanziForPinyin;
      case QuizType.hanziToPinyin:
        return l10n.quizFindPinyinForHanzi;
      case QuizType.hanziToMeaning:
        return l10n.quizFindMeaningForHanzi;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // The playing phase manages its own (responsive) layout so it can show the
    // word detail in a side panel on wide screens.
    if (_phase == _QuizPhase.playing) {
      return Material(child: _buildQuestionView(l10n));
    }

    final Widget content;
    switch (_phase) {
      case _QuizPhase.loading:
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.quizGenerating),
            ],
          ),
        );
        break;
      case _QuizPhase.finished:
        content = _buildResult(l10n);
        break;
      case _QuizPhase.setup:
      case _QuizPhase.playing:
        content = _buildSetup(l10n);
        break;
    }

    return Material(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Icon(Icons.quiz, size: 64, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        Text(
          l10n.quizTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        Text(
          '${l10n.numberOfQuestions}: ${_questionCount.round()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _questionCount,
          min: minQuestions.toDouble(),
          max: maxQuestions.toDouble(),
          divisions: (maxQuestions - minQuestions) ~/ 5,
          label: _questionCount.round().toString(),
          onChanged: (value) => setState(() => _questionCount = value),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.quizType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<QuizType>(
          value: _selectedType,
          isExpanded: true,
          items: [
            for (final type in QuizType.values)
              DropdownMenuItem<QuizType>(
                value: type,
                child: Text(_typeLabel(l10n, type)),
              ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedType = value);
          },
        ),
        const SizedBox(height: 16),
        Text(
          l10n.selectLevel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<int?>(
          value: _selectedLevel,
          isExpanded: true,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(l10n.allLevels),
            ),
            for (int level = 1; level <= 6; level++)
              DropdownMenuItem<int?>(
                value: level,
                child: Text(l10n.hskLevel(level)),
              ),
          ],
          onChanged: (value) => setState(() => _selectedLevel = value),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n.error(_errorMessage!),
            style: const TextStyle(color: AppTheme.errorColor),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _startQuiz,
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.startQuiz),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionView(AppLocalizations l10n) {
    final question = _questions[_currentIndex];
    final answered = _selectedOptionIndex != null;
    final isHanziPrompt = question.type != QuizType.pinyinToHanzi;

    final questionColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _questions.length,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.quizQuestionProgress(_currentIndex + 1, _questions.length),
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 24),
        Text(
          _instruction(l10n, question.type),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.largePadding),
            child: Center(
              child: SelectableText(
                question.prompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isHanziPrompt
                      ? AppTheme.hanziFontSizeCompact
                      : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < question.options.length; i++)
          _buildOption(i, question),
        const SizedBox(height: 24),
        if (answered)
          ElevatedButton.icon(
            onPressed: _next,
            icon: Icon(
              _currentIndex >= _questions.length - 1
                  ? Icons.flag
                  : Icons.arrow_forward,
            ),
            label: Text(
              _currentIndex >= _questions.length - 1
                  ? l10n.quizSeeResults
                  : l10n.nextQuestion,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > wideBreakpoint;

        final questionPane = SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: questionColumn,
              ),
            ),
          ),
        );

        if (!isWide) {
          // Mobile: the detail is surfaced in a popup from _answer().
          return questionPane;
        }

        // Desktop / web: show the detail beside the question once answered.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: questionPane),
            if (answered)
              SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.defaultPadding),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.largePadding),
                        child: _wordDetail(question),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOption(int index, QuizQuestion question) {
    final answered = _selectedOptionIndex != null;
    final isCorrect = index == question.correctIndex;
    final isSelected = index == _selectedOptionIndex;
    final isHanziOption = question.type == QuizType.pinyinToHanzi;

    Color borderColor = AppTheme.secondaryColor;
    Color? backgroundColor;
    if (answered) {
      if (isCorrect) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.12);
      } else if (isSelected) {
        borderColor = AppTheme.errorColor;
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.12);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: answered ? null : () => _answer(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(fontSize: isHanziOption ? 28 : 18),
                ),
              ),
              if (answered && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (answered && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: AppTheme.errorColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppLocalizations l10n) {
    final total = _questions.length;
    final ratio = total == 0 ? 0.0 : _score / total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Icon(
          ratio >= 0.5 ? Icons.emoji_events : Icons.school,
          size: 72,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.quizFinished,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.quizScore(_score, total),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.restartQuiz),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home),
          label: Text(l10n.goHome),
        ),
      ],
    );
  }
}
