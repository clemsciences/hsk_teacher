import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hsk_teacher/app.dart';
import 'package:hsk_teacher/l10n/app_localizations.dart';
import 'package:hsk_teacher/theme.dart';
import 'package:hsk_teacher/word_detail_content.dart';

class LevelSelectionPage extends StatefulWidget {
  const LevelSelectionPage({super.key});

  @override
  State<LevelSelectionPage> createState() => _LevelSelectionPageState();
}

class _LevelSelectionPageState extends State<LevelSelectionPage> {
  Map<String, dynamic>? _randomWord;
  int? _randomWordGlobalIndex;
  int? _randomWordLevel;

  @override
  void initState() {
    super.initState();
    _loadInitialRandomWord();
  }

  Future<void> _loadInitialRandomWord() async {
    await _showRandomWord(navigateTo: false);
  }

  Future<void> _showRandomWord({int? level, bool navigateTo = true}) async {
    final random = Random();
    final selectedLevel = level ?? (random.nextInt(6) + 1);

    try {
      final String metadataResponse = await rootBundle.loadString(
        'assets/data/levels/level_$selectedLevel/metadata.json',
      );
      final metadata = json.decode(metadataResponse);
      final int totalChunks = metadata['total_chunks'];
      final int chunkSize = metadata['chunk_size'];

      final int randomChunk = random.nextInt(totalChunks);
      final String chunkResponse = await rootBundle.loadString(
        'assets/data/levels/level_$selectedLevel/chunk_$randomChunk.json',
      );
      final List data = json.decode(chunkResponse);

      if (data.isNotEmpty) {
        final int indexInChunk = random.nextInt(data.length);
        final randomWord = data[indexInChunk];
        final int globalIndex = randomChunk * chunkSize + indexInChunk;
        if (mounted) {
          if (navigateTo) {
            context.push(
              '/level/$selectedLevel/word/$globalIndex',
              extra: randomWord,
            );
          } else {
            setState(() {
              _randomWord = Map<String, dynamic>.from(randomWord);
              _randomWordGlobalIndex = globalIndex;
              _randomWordLevel = selectedLevel;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading random word: $e');
    }
  }

  void _copyWordLink() {
    if (_randomWordGlobalIndex != null && _randomWordLevel != null) {
      final String fullUrl =
          "${Uri.base.origin}/level/$_randomWordLevel/word/$_randomWordGlobalIndex";

      Clipboard.setData(ClipboardData(text: fullUrl)).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.linkCopied)),
          );
        }
      });
    }
  }

  void _clearHistory() async {
    final storage = StorageServiceProvider.of(context);
    await storage.clearHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.historyCleared)),
      );
    }
  }

  Widget _makeRandomWordCard() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                WordDetailContent(
                  level: _randomWordLevel!,
                  hanzi: _randomWord!['hanzi'] ?? '',
                  pinyin: _randomWord!['pinyin'],
                  meanings: _randomWord!['meanings'],
                  compact: true,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;

                    final anotherButton = ElevatedButton.icon(
                      onPressed: () => _showRandomWord(navigateTo: false),
                      icon: const Icon(Icons.shuffle),
                      label: Text(l10n.anotherRandomWord),
                    );

                    final copyButton = ElevatedButton.icon(
                      onPressed: _copyWordLink,
                      icon: const Icon(Icons.copy),
                      label: Text(l10n.copyLink),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.white,
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          anotherButton,
                          const SizedBox(height: 12),
                          copyButton,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        anotherButton,
                        const SizedBox(width: 16),
                        copyButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storage = StorageServiceProvider.of(context);
    final lastLevel = storage.getLastLevel();
    final lastPath = storage.getLastPath();

    return Material(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (lastPath != null && lastPath != '/')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: InkWell(
                    onTap: () => context.go(lastPath),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.restore,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              l10n.resumeLastSession(lastPath),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (lastLevel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final levelButton = OutlinedButton.icon(
                        onPressed: () => context.go('/level/$lastLevel/page/0'),
                        icon: const Icon(Icons.history),
                        label: Text(
                          '${l10n.hskLevel(lastLevel)} (Dernier visité)',
                        ),
                      );
                      final clearButton = OutlinedButton.icon(
                        onPressed: _clearHistory,
                        icon: const Icon(Icons.delete_sweep),
                        label: Text(l10n.clearHistory),
                      );

                      if (constraints.maxWidth < 600) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            levelButton,
                            const SizedBox(height: 12),
                            clearButton,
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          levelButton,
                          const SizedBox(width: 16),
                          clearButton,
                        ],
                      );
                    },
                  ),
                ),
              if (_randomWord != null) _makeRandomWordCard(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/quiz'),
                icon: const Icon(Icons.quiz),
                label: Text(l10n.startQuiz),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: List.generate(6, (index) {
                  final level = index + 1;
                  return InkWell(
                    onTap: () {
                      StorageServiceProvider.of(context).saveLastLevel(level);
                      context.go('/level/$level/page/0');
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColorLight,
                        border: Border.all(
                          color: AppTheme.secondaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 50,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'HSK $level',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
