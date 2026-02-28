/// Vocabulary book data model
///
/// Represents a collection of words for learning (e.g., CET4, CET6, TOEFL, etc.)

class VocabularyBook {
  final String id;
  final String name;
  final String description;
  final String language; // e.g., 'en-US', 'en-GB'
  final String targetLanguage; // e.g., 'zh-CN'
  final int wordCount;
  final int level; // 1-5: difficulty level
  final String category; // e.g., 'exam', 'business', 'daily'
  final String? iconUrl;
  final bool isDownloaded;
  final String? filePath;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VocabularyBook({
    required this.id,
    required this.name,
    required this.description,
    required this.language,
    required this.targetLanguage,
    required this.wordCount,
    required this.level,
    required this.category,
    this.iconUrl,
    this.isDownloaded = false,
    this.filePath,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  VocabularyBook copyWith({
    String? id,
    String? name,
    String? description,
    String? language,
    String? targetLanguage,
    int? wordCount,
    int? level,
    String? category,
    String? iconUrl,
    bool? isDownloaded,
    String? filePath,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabularyBook(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      wordCount: wordCount ?? this.wordCount,
      level: level ?? this.level,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      filePath: filePath ?? this.filePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'language': language,
      'targetLanguage': targetLanguage,
      'wordCount': wordCount,
      'level': level,
      'category': category,
      'iconUrl': iconUrl,
      'isDownloaded': isDownloaded,
      'filePath': filePath,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory VocabularyBook.fromJson(Map<String, dynamic> json) {
    return VocabularyBook(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      targetLanguage: json['targetLanguage'] as String,
      wordCount: json['wordCount'] as int,
      level: json['level'] as int,
      category: json['category'] as String,
      iconUrl: json['iconUrl'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      filePath: json['filePath'] as String?,
      tags: List<String>.from(json['tags'] as List),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyBook &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
