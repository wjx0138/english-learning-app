/// Word data model for vocabulary learning

class Word {
  final String id;
  final String word;
  final String? phonetic;
  final String definition;
  final List<String> examples;
  final List<String>? synonyms;
  final List<String>? antonyms;
  final String? etymology;
  final int difficulty; // 1-5 scale
  final List<String> tags;

  Word({
    required this.id,
    required this.word,
    this.phonetic,
    required this.definition,
    required this.examples,
    this.synonyms,
    this.antonyms,
    this.etymology,
    required this.difficulty,
    required this.tags,
  });

  Word copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? definition,
    List<String>? examples,
    List<String>? synonyms,
    List<String>? antonyms,
    String? etymology,
    int? difficulty,
    List<String>? tags,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      examples: examples ?? this.examples,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      etymology: etymology ?? this.etymology,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'definition': definition,
      'examples': examples,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'etymology': etymology,
      'difficulty': difficulty,
      'tags': tags,
    };
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      definition: json['definition'] as String,
      examples: List<String>.from(json['examples'] as List),
      synonyms: json['synonyms'] != null
          ? List<String>.from(json['synonyms'] as List)
          : null,
      antonyms: json['antonyms'] != null
          ? List<String>.from(json['antonyms'] as List)
          : null,
      etymology: json['etymology'] as String?,
      difficulty: json['difficulty'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  @override
  String toString() => word;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
