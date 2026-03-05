import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/vocabulary_book.dart';
import '../../shared/services/vocabulary_service.dart';

/// 首次使用引导页面 - 帮助用户选择词库并开始学习
class FirstTimeSetupPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const FirstTimeSetupPage({super.key, this.onComplete});

  @override
  State<FirstTimeSetupPage> createState() => _FirstTimeSetupPageState();
}

class _FirstTimeSetupPageState extends State<FirstTimeSetupPage> {
  final VocabularyService _vocabularyService = VocabularyService();
  bool _isLoading = false;
  String? _selectedBookId;
  List<VocabularyBook> _availableBooks = [];

  @override
  void initState() {
    super.initState();
    _initializeBooks();
  }

  Future<void> _initializeBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _vocabularyService.initialize();
      setState(() {
        _availableBooks = _vocabularyService.availableBooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  Future<void> _selectVocabulary(String bookId) async {
    setState(() {
      _isLoading = true;
      _selectedBookId = bookId;
    });

    try {
      final book = _availableBooks.firstWhere((b) => b.id == bookId);

      debugPrint('📚 Loading vocabulary: ${book.name} from ${book.filePath}');

      final words = await _vocabularyService.loadVocabularyBook(book);

      debugPrint('✅ Loaded ${words.length} words successfully');

      // Save the selected book ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_vocabulary_book_id', bookId);
      await prefs.setBool('first_time_setup_complete', true);

      debugPrint('💾 Saved preferences');

      // Update app provider
      if (mounted) {
        final appProvider = context.read<AppProvider>();
        await appProvider.loadVocabularyWords(words);

        debugPrint('🔄 Calling onComplete callback');

        // Call onComplete callback to trigger app rebuild
        widget.onComplete?.call();
      }
    } catch (e) {
      debugPrint('❌ Error loading vocabulary: $e');

      setState(() {
        _isLoading = false;
        _selectedBookId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: () {
                _selectVocabulary(bookId);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading && _availableBooks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Content
                  Expanded(
                    child: _availableBooks.isEmpty
                        ? _buildEmptyState()
                        : _buildBookSelection(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '欢迎使用英语学习',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '选择一个词库开始你的学习之旅',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('暂无可用词库'),
    );
  }

  Widget _buildBookSelection() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _availableBooks.length,
      itemBuilder: (context, index) {
        final book = _availableBooks[index];
        final isSelected = _selectedBookId == book.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isSelected ? 4 : 2,
          child: InkWell(
            onTap: _isLoading ? null : () => _selectVocabulary(book.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                    const SizedBox(height: 16),
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
                        if (book.level <= 2)
                          _buildDetailChip(
                            Icons.recommend,
                            '推荐新手',
                            color: Colors.green,
                          ),
                      ],
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

  Widget _buildDetailChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[200])?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

/// 检查是否是首次使用
Future<bool> isFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('first_time_setup_complete') ?? true;
}
