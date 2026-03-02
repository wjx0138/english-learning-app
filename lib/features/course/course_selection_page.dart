import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/course.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/services/course_service.dart';
import 'course_detail_page.dart';

/// 课程选择页面
class CourseSelectionPage extends StatefulWidget {
  const CourseSelectionPage({super.key});

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  CourseDifficulty? _selectedDifficulty;
  CourseTheme? _selectedTheme;
  String? _selectedTag; // 标签筛选
  bool _showRecommended = false;
  bool _showNew = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCourses() {
    setState(() {
      _allCourses = CourseService.getAllCourses();
      _filteredCourses = _allCourses;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      // 先进行搜索
      var result = CourseService.searchCourses(query);
      // 再应用其他筛选条件
      if (_selectedDifficulty != null) {
        result = result.where((c) => c.difficulty == _selectedDifficulty).toList();
      }
      if (_selectedTheme != null) {
        result = result.where((c) => c.theme == _selectedTheme).toList();
      }
      if (_selectedTag != null) {
        result = result.where((c) => c.tags.contains(_selectedTag)).toList();
      }
      if (_showRecommended) {
        final recommended = CourseService.getRecommendedCourses();
        result = result.where((c) => recommended.contains(c)).toList();
      }
      if (_showNew) {
        final newCourses = CourseService.getNewCourses();
        result = result.where((c) => newCourses.contains(c)).toList();
      }
      _filteredCourses = result;
    });
  }

  void _applyFilters() {
    var result = _allCourses;

    if (_selectedDifficulty != null) {
      result = result.where((c) => c.difficulty == _selectedDifficulty).toList();
    }

    if (_selectedTheme != null) {
      result = result.where((c) => c.theme == _selectedTheme).toList();
    }

    if (_selectedTag != null) {
      result = result.where((c) => c.tags.contains(_selectedTag)).toList();
    }

    if (_showRecommended) {
      final recommended = CourseService.getRecommendedCourses();
      result = result.where((c) => recommended.contains(c)).toList();
    }

    if (_showNew) {
      final newCourses = CourseService.getNewCourses();
      result = result.where((c) => newCourses.contains(c)).toList();
    }

    setState(() {
      _filteredCourses = result;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDifficulty = null;
      _selectedTheme = null;
      _selectedTag = null;
      _showRecommended = false;
      _showNew = false;
      _filteredCourses = _allCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: '筛选',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          const SizedBox(height: 8),

          // Filter chips
          _buildFilterChips(),

          const SizedBox(height: 16),

          // Course list
          Expanded(
            child: _filteredCourses.isEmpty
                ? _buildEmptyState()
                : _buildCourseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索课程...',
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
    );
  }

  Widget _buildFilterChips() {
    final hasActiveFilters =
        _selectedDifficulty != null ||
        _selectedTheme != null ||
        _selectedTag != null ||
        _showRecommended ||
        _showNew;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (hasActiveFilters)
            FilterChip(
              label: const Text('清除筛选'),
              selected: false,
              onSelected: (_) => _clearFilters(),
              avatar: const Icon(Icons.clear_all),
              backgroundColor: Colors.red.shade100,
            ),
          FilterChip(
            label: const Text('考试'),
            selected: _selectedTag == '考试',
            onSelected: (_) {
              setState(() {
                _selectedTag = _selectedTag == '考试' ? null : '考试';
                _applyFilters();
              });
            },
            avatar: const Icon(Icons.school),
            backgroundColor:
                _selectedTag == '考试' ? Colors.orange.shade100 : null,
          ),
          FilterChip(
            label: const Text('推荐'),
            selected: _showRecommended,
            onSelected: (_) {
              setState(() {
                _showRecommended = !_showRecommended;
                _showNew = false;
                _applyFilters();
              });
            },
            avatar: const Icon(Icons.star),
            backgroundColor:
                _showRecommended ? Colors.amber.shade100 : null,
          ),
          FilterChip(
            label: const Text('最新'),
            selected: _showNew,
            onSelected: (_) {
              setState(() {
                _showNew = !_showNew;
                _showRecommended = false;
                _applyFilters();
              });
            },
            avatar: const Icon(Icons.new_releases),
            backgroundColor:
                _showNew ? Colors.blue.shade100 : null,
          ),
          const SizedBox(width: 8),
          ...CourseDifficulty.values.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(difficulty.label),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedDifficulty = isSelected ? null : difficulty;
                    _applyFilters();
                  });
                },
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到匹配的课程',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试清除筛选或使用不同的关键词',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(_filteredCourses[index]);
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCourseDetail(course),
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
                      color: _getDifficultyColor(course.difficulty),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.difficulty.label,
                      style: const TextStyle(
                        color: Colors.white,
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
                      course.theme.label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (course.isPremium)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                course.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                course.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Info row
              Row(
                children: [
                  Icon(
                    Icons.book,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.wordCount} 词',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(course.estimatedTime),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              // Tags
              if (course.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: course.tags.take(3).map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.grey.shade200,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseDetail(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailPage(course: course),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选课程'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme filter
                  const Text(
                    '主题分类',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CourseTheme.values.map((theme) {
                      final isSelected = _selectedTheme == theme;
                      return FilterChip(
                        label: Text(theme.label),
                        selected: isSelected,
                        onSelected: (_) {
                          Navigator.of(context).pop();
                          setState(() {
                            this._selectedTheme = isSelected ? null : theme;
                            _applyFilters();
                          });
                        },
                        avatar: Icon(theme.icon, size: 16),
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Difficulty filter
                  const Text(
                    '难度等级',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CourseDifficulty.values.map((difficulty) {
                      final isSelected = _selectedDifficulty == difficulty;
                      return FilterChip(
                        label: Text(difficulty.label),
                        selected: isSelected,
                        onSelected: (_) {
                          Navigator.of(context).pop();
                          setState(() {
                            this._selectedDifficulty =
                                isSelected ? null : difficulty;
                            _applyFilters();
                          });
                        },
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearFilters();
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(CourseDifficulty difficulty) {
    switch (difficulty.level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen.shade600;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
    }
    return '$minutes分钟';
  }
}

class StatefulBuilder extends StatefulWidget {
  final Widget Function(BuildContext, StateSetter) builder;

  const StatefulBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<StatefulBuilder> createState() => _StatefulBuilderState();
}

class _StatefulBuilderState extends State<StatefulBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, setState);
  }
}
