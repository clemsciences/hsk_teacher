import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'word_detail_content.dart';
import 'theme.dart';
import 'app.dart';

class WordDetailPage extends StatefulWidget {
  final int level;
  final int index;
  final String? hanzi;
  final String? pinyin;
  final String? meanings;

  const WordDetailPage({
    super.key,
    required this.level,
    required this.index,
    this.hanzi,
    this.pinyin,
    this.meanings,
  });

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  late Future<Map<String, String?>> _wordDataFuture;
  bool _isLearned = false;

  @override
  void initState() {
    super.initState();
    _wordDataFuture = _loadWordData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLearnedStatus();
    _addToHistory();
  }

  Future<void> _addToHistory() async {
    final storage = StorageServiceProvider.of(context);
    final hanzi = widget.hanzi;
    if (hanzi != null) {
      await storage.addToHistory(widget.level, hanzi);
    } else {
      final wordData = await _wordDataFuture;
      final loadedHanzi = wordData['hanzi'];
      if (loadedHanzi != null) {
        await storage.addToHistory(widget.level, loadedHanzi);
      }
    }
  }

  Future<void> _loadLearnedStatus() async {
    final storage = StorageServiceProvider.of(context);
    final hanzi = widget.hanzi;
    if (hanzi != null) {
      setState(() {
        _isLearned = storage.isWordLearned(widget.level, hanzi);
      });
    } else {
      final wordData = await _wordDataFuture;
      final loadedHanzi = wordData['hanzi'];
      if (loadedHanzi != null) {
        setState(() {
          _isLearned = storage.isWordLearned(widget.level, loadedHanzi);
        });
      }
    }
  }

  Future<void> _toggleLearned(String hanzi) async {
    final storage = StorageServiceProvider.of(context);
    final newStatus = !_isLearned;
    await storage.markWordAsLearned(widget.level, hanzi, newStatus);
    setState(() {
      _isLearned = newStatus;
    });
  }

  Future<Map<String, String?>> _loadWordData() async {
    if (widget.hanzi != null && widget.pinyin != null && widget.meanings != null) {
      return {
        'hanzi': widget.hanzi,
        'pinyin': widget.pinyin,
        'meanings': widget.meanings,
      };
    }

    try {
      final String metadataResponse = await rootBundle
          .loadString('assets/data/levels/level_${widget.level}/metadata.json');
      final metadata = json.decode(metadataResponse);
      final int chunkSize = metadata['chunk_size'];

      final int chunkIndex = widget.index ~/ chunkSize;
      final int localIndex = widget.index % chunkSize;

      final String response = await rootBundle.loadString(
          'assets/data/levels/level_${widget.level}/chunk_$chunkIndex.json');
      final List data = json.decode(response);

      if (localIndex < data.length) {
        final word = data[localIndex];
        return {
          'hanzi': word['hanzi'] as String?,
          'pinyin': word['pinyin'] as String?,
          'meanings': word['meanings'] as String?,
        };
      }
    } catch (e) {
      debugPrint('Error loading word data: $e');
    }

    return {
      'hanzi': widget.hanzi,
      'pinyin': widget.pinyin,
      'meanings': widget.meanings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      child: FutureBuilder<Map<String, String?>>(
        future: _wordDataFuture,
        builder: (context, snapshot) {
          final hanzi = snapshot.data?['hanzi'] ?? widget.hanzi ?? '';
          final pinyin = snapshot.data?['pinyin'] ?? widget.pinyin;
          final meanings = snapshot.data?['meanings'] ?? widget.meanings;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WordDetailContent(
                          level: widget.level,
                          hanzi: hanzi,
                          pinyin: pinyin,
                          meanings: meanings,
                          isLoading: snapshot.connectionState == ConnectionState.waiting,
                        ),
                        const SizedBox(height: 24),
                        if (hanzi.isNotEmpty)
                          SwitchListTile(
                            title: Text(l10n.markAsLearned),
                            subtitle: _isLearned ? Text(l10n.learned) : null,
                            value: _isLearned,
                            onChanged: (value) => _toggleLearned(hanzi),
                          ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              // If we can't pop, we try to go back to the words list for this level
                              context.go('/level/${widget.level}/page/0');
                            }
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.back),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
