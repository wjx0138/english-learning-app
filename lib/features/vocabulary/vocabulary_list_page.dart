import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/word.dart';
import '../../../shared/services/tts_service.dart';
import '../word_detail/word_detail_page.dart';

class VocabularyListPage extends StatefulWidget {
  const VocabularyListPage({super.key});

  @override
  State<VocabularyListPage> createState() => _VocabularyListPageState();
}

class _VocabularyListPageState extends State<VocabularyListPage> {
  final TTSService _ttsService = TTSService();
  List<Word> _vocabulary = [];
  List<Word> _filteredVocabulary = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteWordIds = {};

  // Filter options
  String _selectedDifficulty = 'all'; // all, 1, 2, 3, 4, 5
  SortOption _sortOption = SortOption.alphabetical;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVocabulary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/vocabularies/cet4_sample.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _vocabulary = jsonList.map((json) => Word.fromJson(json)).toList();
        _filteredVocabulary = List.from(_vocabulary);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVocabulary = _vocabulary.where((word) {
        final matchesSearch = query.isEmpty ||
            word.word.toLowerCase().contains(query) ||
            word.definition.toLowerCase().contains(query);
        final matchesDifficulty = _selectedDifficulty == 'all' ||
            word.difficulty.toString() == _selectedDifficulty;
        return matchesSearch && matchesDifficulty;
      }).toList();
      _applySort();
    });
  }

  void _filterByDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      _onSearchChanged();
    });
  }

  void _applySort() {
    setState(() {
      switch (_sortOption) {
        case SortOption.alphabetical:
          _filteredVocabulary.sort((a, b) => a.word.compareTo(b.word));
          break;
        case SortOption.difficulty:
          _filteredVocabulary.sort((a, b) => a.difficulty.compareTo(b.difficulty));
          break;
        case SortOption.recent:
          // Keep original order (loaded order)
          break;
      }
    });
  }

  void _toggleFavorite(String wordId) {
    setState(() {
      if (_favoriteWordIds.contains(wordId)) {
        _favoriteWordIds.remove(wordId);
      } else {
        _favoriteWordIds.add(wordId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('词汇列表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Search and filter section
          _buildSearchAndFilterSection(),
          // Word list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVocabulary.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('没有找到匹配的单词', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredVocabulary.length,
                        itemBuilder: (context, index) {
                          return _buildWordCard(_filteredVocabulary[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索单词或释义...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', 'all', _selectedDifficulty == 'all'),
                _buildFilterChip('难度1', '1', _selectedDifficulty == '1'),
                _buildFilterChip('难度2', '2', _selectedDifficulty == '2'),
                _buildFilterChip('难度3', '3', _selectedDifficulty == '3'),
                _buildFilterChip('难度4', '4', _selectedDifficulty == '4'),
                _buildFilterChip('难度5', '5', _selectedDifficulty == '5'),
                const SizedBox(width: 8),
                // Sort dropdown
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: '排序',
                  initialValue: _sortOption,
                  onSelected: (SortOption option) {
                    setState(() {
                      _sortOption = option;
                      _applySort();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: SortOption.alphabetical,
                      child: Text('按字母排序'),
                    ),
                    const PopupMenuItem(
                      value: SortOption.difficulty,
                      child: Text('按难度排序'),
                    ),
                    const PopupMenuItem(
                      value: SortOption.recent,
                      child: Text('默认顺序'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _filterByDifficulty(value),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    final isFavorite = _favoriteWordIds.contains(word.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WordDetailPage(
                wordId: word.id,
                showBack: false,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: word, difficulty, favorite
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (word.phonetic != null)
                          Text(
                            word.phonetic!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  // Difficulty badge
                  Chip(
                    label: Text('难度${word.difficulty}'),
                    backgroundColor: _getDifficultyColor(word.difficulty),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(word.id),
                    tooltip: isFavorite ? '取消收藏' : '收藏',
                  ),
                  // Speaker button
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => _ttsService.speakWord(word.word),
                    tooltip: '播放发音',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Definition
              Text(
                word.definition,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Tags
              if (word.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: word.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag,
                          style: const TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showWordDetailDialog(Word word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.word,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                  if (word.phonetic != null)
                    Text(
                      word.phonetic!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => _ttsService.speakWord(word.word),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Difficulty
              Row(
                children: [
                  const Text('难度：', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < word.difficulty ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Definition
              const Text(
                '释义',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                word.definition,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Examples
              if (word.examples.isNotEmpty) ...[
                const Text(
                  '例句',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...word.examples.map((example) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $example',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              // Synonyms & Antonyms
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (word.synonyms != null &&
                            word.synonyms!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('同义词：',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(word.synonyms!.join(', ')),
                              const SizedBox(height: 8),
                            ],
                          ),
                        if (word.antonyms != null &&
                            word.antonyms!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('反义词：',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(word.antonyms!.join(', ')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tags
              if (word.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: word.tags.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

enum SortOption {
  alphabetical,
  difficulty,
  recent,
}
