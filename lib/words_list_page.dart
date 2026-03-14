import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'l10n/app_localizations.dart';
import 'word_detail_content.dart';
import 'main_layout.dart';
import 'theme.dart';
import 'app.dart';

class WordsListPage extends StatefulWidget {
  final int level;
  final int page;

  const WordsListPage({super.key, required this.level, required this.page});

  @override
  State<WordsListPage> createState() => _WordsListPageState();
}

class _WordsListPageState extends State<WordsListPage> {
  int _totalChunks = 0;
  late Future<List<Map<String, dynamic>>> _hskDataFuture;
  Map<String, dynamic>? _randomWord;
  int? _randomWordGlobalIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
    _showRandomWord(navigateTo: false);
  }

  @override
  void didUpdateWidget(WordsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level || oldWidget.page != widget.page) {
      _loadData();
    }
  }

  void _loadData() {
    _hskDataFuture = _loadLevelData(widget.level, widget.page);
  }

  Future<List<Map<String, dynamic>>> _loadLevelData(int level, int page) async {
    try {
      final String metadataResponse =
          await rootBundle.loadString('assets/data/levels/level_$level/metadata.json');
      final metadata = json.decode(metadataResponse);
      _totalChunks = metadata['total_chunks'];

      final String response =
          await rootBundle.loadString('assets/data/levels/level_$level/chunk_$page.json');
      final data = json.decode(response) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      // If metadata or chunk doesn't exist, we might be in an inconsistent state
      debugPrint('Error loading data: $e');
      rethrow;
    }
  }

  void _showWordDetail(Map<String, dynamic> item, int indexInChunk) {
    final int globalIndex = widget.page * 10 + indexInChunk; // assuming chunk size 10
    context.push(
      '/level/${widget.level}/word/$globalIndex',
      extra: item,
    );
  }

  Future<void> _showRandomWord({bool navigateTo = true}) async {
    final random = Random();
    try {
      final String metadataResponse = await rootBundle
          .loadString('assets/data/levels/level_${widget.level}/metadata.json');
      final metadata = json.decode(metadataResponse);
      final int totalChunks = metadata['total_chunks'];
      final int chunkSize = metadata['chunk_size'];

      final int randomChunk = random.nextInt(totalChunks);
      final String chunkResponse = await rootBundle.loadString(
          'assets/data/levels/level_${widget.level}/chunk_$randomChunk.json');
      final List data = json.decode(chunkResponse);

      if (data.isNotEmpty) {
        final int indexInChunk = random.nextInt(data.length);
        final randomWord = data[indexInChunk];
        final int globalIndex = randomChunk * chunkSize + indexInChunk;
        
        if (mounted) {
          if (navigateTo) {
            context.push(
              '/level/${widget.level}/word/$globalIndex',
              extra: Map<String, dynamic>.from(randomWord),
            );
          } else {
            setState(() {
              _randomWord = Map<String, dynamic>.from(randomWord);
              _randomWordGlobalIndex = globalIndex;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading random word: $e');
    }
  }

  void _copyWordLink() {
    if (_randomWordGlobalIndex != null) {
      // Note: GoRouter usage might affect how base URL is formed if not using Hash strategy
      // but since we setup usePathUrlStrategy, it might be different.
      // Actually Uri.base should give the correct one.
      final String fullUrl = "${Uri.base.origin}/level/${widget.level}/word/$_randomWordGlobalIndex";
      
      Clipboard.setData(ClipboardData(text: fullUrl)).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.linkCopied)),
          );
        }
      });
    }
  }

  Widget _buildPagination(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.page > 0
                ? () {
                    context.go('/level/${widget.level}/page/${widget.page - 1}');
                  }
                : null,
          ),
          Text(l10n.pageOf(widget.page + 1, _totalChunks)),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: widget.page < _totalChunks - 1
                ? () {
                    context.go('/level/${widget.level}/page/${widget.page + 1}');
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _makeRandomWordCard(bool isWide) {
    final l10n = AppLocalizations.of(context)!;
    return _randomWord == null
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WordDetailContent(
                level: widget.level,
                hanzi: _randomWord!['hanzi'] ?? '',
                pinyin: _randomWord!['pinyin'],
                meanings: _randomWord!['meanings'],
                compact: true,
              ),
              const SizedBox(height: 16),
              isWide ?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showRandomWord(navigateTo: false),
                    icon: const Icon(Icons.shuffle),
                    label: Text(l10n.anotherRandomWord),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _copyWordLink,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copyLink),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.white,
                    ),
                  ),
                ],
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showRandomWord(navigateTo: false),
                    icon: const Icon(Icons.shuffle),
                    label: Text(l10n.anotherRandomWord),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _copyWordLink,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copyLink),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.white,
                    ),
                  ),
                ],
              )
              ,
            ],
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      child: LayoutBuilder(builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;

        Widget tableContent = FutureBuilder<List<Map<String, dynamic>>>(
          future: _hskDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.loadingLevel(widget.level)),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(l10n.error(snapshot.error.toString())));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l10n.noDataFound));
            }

            final data = snapshot.data!;
            return DataTable(
                dataRowMinHeight: 48,
                dataRowMaxHeight: double.infinity,
                showCheckboxColumn: false,
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(l10n.character),
                  ),
                  DataColumn(
                    label: Text(l10n.pinyin),
                  ),
                  DataColumn(
                    label: Text(l10n.meanings),
                  ),
                ],
                rows: data
                    .asMap()
                    .entries
                    .map(
                      (entry) {
                        final indexInChunk = entry.key;
                        final item = entry.value;
                        final hanzi = item['hanzi'] ?? '';
                        final storage = StorageServiceProvider.of(context);
                        final isVisited = storage.isWordVisited(widget.level, hanzi);
                        final isLearned = storage.isWordLearned(widget.level, hanzi);

                        return DataRow(
                          onSelectChanged: (bool? selected) {
                            if (selected != null) {
                              _showWordDetail(item, indexInChunk);
                            }
                          },
                          color: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return AppTheme.secondaryColorLight;
                              }
                              if (isLearned) {
                                return Colors.green.withOpacity(0.1);
                              }
                              if (isVisited) {
                                return AppTheme.secondaryColorLight.withOpacity(0.3);
                              }
                              return null;
                            },
                          ),
                          cells: <DataCell>[
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SelectableText(hanzi),
                                    if (isLearned) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                    ] else if (isVisited) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.visibility,
                                        size: 16,
                                        color: AppTheme.secondaryColor.withOpacity(0.5),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: SelectableText(item['pinyin'] ?? ''),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: SizedBox(
                                  width: 300,
                                  child: SelectableText(
                                    item['meanings'] ?? '',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                    .toList(),
              );
          },
        );

        Widget content;
        if (isWide) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_randomWord != null)
                SizedBox(
                  width: 500,
                  child: _makeRandomWordCard(isWide),
                ),
              Expanded(
                child: Column(
                  children: [
                    Center(child: tableContent),
                    _buildPagination(l10n),
                  ],
                ),
              ),
            ],
          );
        } else {
          content = Column(
            children: [
              if (_randomWord != null) _makeRandomWordCard(isWide),
              Center(child: tableContent),
              _buildPagination(l10n),
            ],
          );
        }

        return SingleChildScrollView(
          child: content,
        );
      }),
    );
  }
}
