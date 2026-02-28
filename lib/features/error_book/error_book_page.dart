import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/error_book.dart';
import '../../data/models/quiz.dart';
import '../../shared/services/error_book_service.dart';
import '../quiz/widgets/quiz_option_card.dart';

/// 错题本页面
class ErrorBookPage extends StatefulWidget {
  const ErrorBookPage({super.key});

  @override
  State<ErrorBookPage> createState() => _ErrorBookPageState();
}

class _ErrorBookPageState extends State<ErrorBookPage> {
  ErrorBook? _errorBook;
  ErrorBookFilter _filter = ErrorBookFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadErrorBook();
  }

  Future<void> _loadErrorBook() async {
    setState(() {
      _isLoading = true;
    });
    final errorBook = await ErrorBookService.getErrorBook();
    setState(() {
      _errorBook = errorBook;
      _isLoading = false;
    });
  }

  List<ErrorRecord> get _filteredErrors {
    if (_errorBook == null) return [];

    switch (_filter) {
      case ErrorBookFilter.unmastered:
        return _errorBook!.unmasteredErrors;
      case ErrorBookFilter.mastered:
        return _errorBook!.masteredErrors;
      case ErrorBookFilter.all:
      default:
        return _errorBook!.errors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        actions: [
          if (_errorBook != null && _errorBook!.masteredErrors.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: _confirmClearMastered,
              tooltip: '清除已掌握',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorBook == null || _errorBook!.errors.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '错题本是空的',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '答错的题目会自动添加到这里',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Statistics card
        _buildStatsCard(),

        const SizedBox(height: 16),

        // Filter chips
        _buildFilterChips(),

        const SizedBox(height: 16),

        // Error list
        Expanded(
          child: _filteredErrors.isEmpty
              ? _buildNoFilteredResults()
              : _buildErrorList(),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final stats = _errorBook!.stats;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '错题统计',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总错题', '${stats.totalErrors}', Icons.book),
              _buildStatItem('未掌握', '${stats.unmasteredCount}', Icons.pending),
              _buildStatItem('已掌握', '${stats.masteredCount}', Icons.check_circle),
              _buildStatItem('单词数', '${stats.wordCount}', Icons.text_fields),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  '掌握率',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.masteryRatePercentage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ErrorBookFilter.values.map((filter) {
          final isSelected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filter = filter;
                });
              },
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoFilteredResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filter == ErrorBookFilter.mastered
                ? '还没有掌握的错题'
                : '没有符合条件的错题',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredErrors.length,
      itemBuilder: (context, index) {
        return _buildErrorCard(_filteredErrors[index], index);
      },
    );
  }

  Widget _buildErrorCard(ErrorRecord error, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showErrorDetail(error),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: error.isMastered
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.isMastered ? '已掌握' : '未掌握',
                      style: TextStyle(
                        color: error.isMastered
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.type.label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '复习${error.reviewCount}次',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Question
              Text(
                error.question.question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              // Wrong answer info
              Row(
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '你选了: ${error.question.options[error.wrongOptionIndex ?? 0].text}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '正确答案: ${error.question.options[error.question.correctOptionIndex].text}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Actions
              Row(
                children: [
                  if (!error.isMastered)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _markAsMastered(error),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('标记掌握'),
                      ),
                    ),
                  if (!error.isMastered)
                    const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showErrorDetail(error),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('查看详情'),
                    ),
                  ),
                  if (error.isMastered)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _removeError(error.id),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('删除'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDetail(ErrorRecord error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.question.question,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word
              Text(
                '单词: ${error.word}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Options
              const Text(
                '选项:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...error.question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isCorrect = index == error.question.correctOptionIndex;
                final isWrongSelected = index == error.wrongOptionIndex && !isCorrect;

                Color? bgColor;
                Color? textColor;

                if (isCorrect) {
                  bgColor = Colors.green.shade100;
                  textColor = Colors.green.shade800;
                } else if (isWrongSelected) {
                  bgColor = Colors.red.shade100;
                  textColor = Colors.red.shade800;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${String.fromCharCode(65 + index)}. ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor ?? Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            color: textColor ?? Colors.black,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        const Icon(Icons.check, color: Colors.green),
                      if (isWrongSelected)
                        const Icon(Icons.close, color: Colors.red),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Explanation
              if (error.question.explanation != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '解析:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        error.question.explanation!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Wrong options history
              if (error.wrongOptionsHistory.length > 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '历史错误选项:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: error.wrongOptionsHistory.map((idx) {
                        return Chip(
                          label: Text(
                            error.question.options[idx].text,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.red.shade100,
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (!error.isMastered)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _markAsMastered(error);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('标记为已掌握'),
            ),
        ],
      ),
    );
  }

  void _markAsMastered(ErrorRecord error) async {
    await ErrorBookService.markAsMastered(error.id);
    await _loadErrorBook();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已标记为已掌握'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeError(String errorId) async {
    await ErrorBookService.removeError(errorId);
    await _loadErrorBook();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已删除错题'),
        ),
      );
    }
  }

  void _confirmClearMastered() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除已掌握的错题'),
        content: const Text('确定要清除所有已掌握的错题吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ErrorBookService.clearMastered();
              await _loadErrorBook();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已清除已掌握的错题'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

enum ErrorBookFilter {
  all(label: '全部'),
  unmastered(label: '未掌握'),
  mastered(label: '已掌握');

  final String label;
  const ErrorBookFilter({required this.label});
}

extension QuizQuestionTypeExtension on QuizQuestionType {
  String get label {
    switch (this) {
      case QuizQuestionType.definition:
        return '释义';
      case QuizQuestionType.reverseDefinition:
        return '单词';
      case QuizQuestionType.synonym:
        return '同义词';
      case QuizQuestionType.antonym:
        return '反义词';
      case QuizQuestionType.fillBlank:
        return '填空';
    }
  }
}
