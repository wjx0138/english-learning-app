import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/vocabulary_book.dart';
import '../../shared/services/vocabulary_service.dart';

/// Page for selecting and loading vocabulary books
class VocabularySelectionPage extends StatefulWidget {
  const VocabularySelectionPage({super.key});

  @override
  State<VocabularySelectionPage> createState() => _VocabularySelectionPageState();
}

class _VocabularySelectionPageState extends State<VocabularySelectionPage> {
  final VocabularyService _vocabularyService = VocabularyService();
  bool _isLoading = false;
  String? _selectedBookId;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _vocabularyService.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化失败: $e')),
        );
      }
    }
  }

  Future<void> _loadVocabularyBook(String bookId) async {
    setState(() {
      _isLoading = true;
      _selectedBookId = bookId;
    });

    try {
      final book = _vocabularyService.availableBooks.firstWhere(
        (b) => b.id == bookId,
      );

      final words = await _vocabularyService.loadVocabularyBook(book);

      // Update app provider with loaded words
      if (mounted) {
        final appProvider = context.read<AppProvider>();
        await appProvider.loadVocabularyWords(words);

        // Navigate to flashcard learning page (instead of home page)
        context.pushReplacement('/flashcard');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功加载 ${words.length} 个单词'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _selectedBookId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择词库'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading && _vocabularyService.availableBooks.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _vocabularyService.availableBooks.isEmpty
              ? _buildEmptyState()
              : _buildBookList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无可用词库',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '请稍后再试或联系开发者',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vocabularyService.availableBooks.length,
      itemBuilder: (context, index) {
        final book = _vocabularyService.availableBooks[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(VocabularyBook book) {
    final isSelected = _selectedBookId == book.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: _isLoading ? null : () => _loadVocabularyBook(book.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Book icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getBookIcon(book.category),
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Book info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Loading indicator
                  if (isSelected && _isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Book details
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDetailChip(
                    Icons.format_list_numbered,
                    '${book.wordCount} 词',
                  ),
                  _buildDetailChip(
                    Icons.bar_chart,
                    '难度 ${book.level}',
                  ),
                  if (book.isDownloaded)
                    _buildDetailChip(
                      Icons.check_circle,
                      '已下载',
                      color: Colors.green,
                    ),
                  ...book.tags.take(3).map((tag) => _buildTagChip(tag)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[200])?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  IconData _getBookIcon(String category) {
    switch (category) {
      case 'exam':
        return Icons.school;
      case 'business':
        return Icons.business_center;
      case 'daily':
        return Icons.chat;
      default:
        return Icons.menu_book;
    }
  }
}
