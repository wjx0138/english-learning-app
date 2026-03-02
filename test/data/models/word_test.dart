import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/data/models/word.dart';

void main() {
  group('Word Model Tests', () {
    group('Constructor and Factory', () {
      test('Should create Word with all required fields', () {
        final word = Word(
          id: 'word-001',
          word: 'abandon',
          definition: 'v. 遗弃；放弃',
          examples: ['The baby had been abandoned by its mother.'],
          difficulty: 3,
          tags: ['cet4', 'verb'],
        );

        expect(word.id, 'word-001');
        expect(word.word, 'abandon');
        expect(word.definition, 'v. 遗弃；放弃');
        expect(word.examples.length, 1);
        expect(word.difficulty, 3);
        expect(word.tags, ['cet4', 'verb']);
      });

      test('Should create Word with optional fields', () {
        final word = Word(
          id: 'word-002',
          word: 'ability',
          phonetic: '/əˈbɪləti/',
          definition: 'n. 能力；才能',
          examples: ['He has the ability to solve problems.'],
          synonyms: ['capability', 'capacity'],
          antonyms: ['inability'],
          etymology: 'From Latin habilis',
          difficulty: 2,
          tags: ['cet4', 'noun'],
        );

        expect(word.phonetic, '/əˈbɪləti/');
        expect(word.synonyms, ['capability', 'capacity']);
        expect(word.antonyms, ['inability']);
        expect(word.etymology, 'From Latin habilis');
      });

      test('Should create Word from JSON', () {
        final json = {
          'id': 'word-003',
          'word': 'test',
          'phonetic': '/test/',
          'definition': 'n. 测试',
          'examples': ['This is a test.', 'Another test.'],
          'synonyms': ['exam'],
          'antonyms': ['no-synonym'],
          'etymology': 'From Latin testum',
          'difficulty': 1,
          'tags': ['basic'],
        };

        final word = Word.fromJson(json);

        expect(word.id, 'word-003');
        expect(word.word, 'test');
        expect(word.phonetic, '/test/');
        expect(word.definition, 'n. 测试');
        expect(word.examples.length, 2);
        expect(word.synonyms, ['exam']);
        expect(word.antonyms, ['no-synonym']);
        expect(word.etymology, 'From Latin testum');
        expect(word.difficulty, 1);
        expect(word.tags, ['basic']);
      });

      test('Should create Word from JSON with null optional fields', () {
        final json = {
          'id': 'word-004',
          'word': 'minimal',
          'definition': 'adj. 最小的',
          'examples': ['Minimal example.'],
          'synonyms': null,
          'antonyms': null,
          'etymology': null,
          'phonetic': null,
          'difficulty': 1,
          'tags': ['basic'],
        };

        final word = Word.fromJson(json);

        expect(word.word, 'minimal');
        expect(word.synonyms, null);
        expect(word.antonyms, null);
        expect(word.etymology, null);
        expect(word.phonetic, null);
      });
    });

    group('Serialization Tests', () {
      test('Should serialize to JSON correctly', () {
        final word = Word(
          id: 'word-005',
          word: 'serialize',
          phonetic: '/ˈsɪəriəlaɪz/',
          definition: 'v. 序列化',
          examples: ['Serialize the object.'],
          synonyms: ['encode'],
          antonyms: ['deserialize'],
          etymology: 'From Latin series',
          difficulty: 4,
          tags: ['tech', 'verb'],
        );

        final json = word.toJson();

        expect(json['id'], 'word-005');
        expect(json['word'], 'serialize');
        expect(json['phonetic'], '/ˈsɪəriəlaɪz/');
        expect(json['definition'], 'v. 序列化');
        expect(json['examples'], ['Serialize the object.']);
        expect(json['synonyms'], ['encode']);
        expect(json['antonyms'], ['deserialize']);
        expect(json['etymology'], 'From Latin series');
        expect(json['difficulty'], 4);
        expect(json['tags'], ['tech', 'verb']);
      });

      test('Should serialize to JSON with null optional fields', () {
        final word = Word(
          id: 'word-006',
          word: 'nulltest',
          definition: 'n. 空值测试',
          examples: [],
          difficulty: 1,
          tags: ['test'],
        );

        final json = word.toJson();

        expect(json['phonetic'], null);
        expect(json['synonyms'], null);
        expect(json['antonyms'], null);
        expect(json['etymology'], null);
      });

      test('Should deserialize and serialize back to same JSON', () {
        final originalJson = {
          'id': 'word-007',
          'word': 'roundtrip',
          'phonetic': '/ˈraʊndtrɪp/',
          'definition': 'n. 往返旅程',
          'examples': ['A roundtrip ticket.'],
          'synonyms': ['return'],
          'antonyms': ['one-way'],
          'etymology': 'Compound word',
          'difficulty': 2,
          'tags': ['travel', 'noun'],
        };

        final word = Word.fromJson(originalJson);
        final serializedJson = word.toJson();

        expect(serializedJson['id'], originalJson['id']);
        expect(serializedJson['word'], originalJson['word']);
        expect(serializedJson['phonetic'], originalJson['phonetic']);
        expect(serializedJson['definition'], originalJson['definition']);
        expect(serializedJson['examples'], originalJson['examples']);
        expect(serializedJson['synonyms'], originalJson['synonyms']);
        expect(serializedJson['antonyms'], originalJson['antonyms']);
        expect(serializedJson['etymology'], originalJson['etymology']);
        expect(serializedJson['difficulty'], originalJson['difficulty']);
        expect(serializedJson['tags'], originalJson['tags']);
      });
    });

    group('copyWith Tests', () {
      test('Should create copy with updated id', () {
        final word = Word(
          id: 'word-008',
          word: 'original',
          definition: 'n. 原始',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        final updated = word.copyWith(id: 'word-008-updated');

        expect(updated.id, 'word-008-updated');
        expect(updated.word, 'original');
        expect(updated.definition, 'n. 原始');
      });

      test('Should create copy with multiple updated fields', () {
        final word = Word(
          id: 'word-009',
          word: 'before',
          definition: 'n. 之前',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        final updated = word.copyWith(
          word: 'after',
          definition: 'n. 之后',
          difficulty: 2,
        );

        expect(updated.id, 'word-009');
        expect(updated.word, 'after');
        expect(updated.definition, 'n. 之后');
        expect(updated.difficulty, 2);
      });

      test('Should keep original values when null is passed to copyWith', () {
        final word = Word(
          id: 'word-010',
          word: 'keep',
          phonetic: '/kiːp/',
          definition: 'v. 保持',
          examples: ['Keep going.'],
          difficulty: 1,
          tags: ['verb'],
        );

        final updated = word.copyWith(
          phonetic: null,
          difficulty: null,
        );

        expect(updated.word, 'keep');
        expect(updated.phonetic, '/kiːp/');
        expect(updated.difficulty, 1);
      });

      test('Should create independent copy (deep copy)', () {
        final originalExamples = ['Example 1', 'Example 2'];
        final originalTags = ['tag1', 'tag2'];

        final word = Word(
          id: 'word-011',
          word: 'deepcopy',
          definition: 'n. 深拷贝',
          examples: List.from(originalExamples),
          tags: List.from(originalTags),
          difficulty: 3,
        );

        final updated = word.copyWith(
          examples: ['Modified example'],
        );

        expect(updated.examples, ['Modified example']);
        expect(word.examples, originalExamples); // Original unchanged
      });
    });

    group('Equality and HashCode Tests', () {
      test('Should be equal when ids are same', () {
        final word1 = Word(
          id: 'same-id',
          word: 'word1',
          definition: 'n. 词汇1',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        final word2 = Word(
          id: 'same-id',
          word: 'word2',
          definition: 'n. 词汇2',
          examples: [],
          difficulty: 2,
          tags: [],
        );

        expect(word1, equals(word2));
        expect(word1 == word2, true);
      });

      test('Should not be equal when ids are different', () {
        final word1 = Word(
          id: 'id-1',
          word: 'same',
          definition: 'n. 相同',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        final word2 = Word(
          id: 'id-2',
          word: 'same',
          definition: 'n. 相同',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        expect(word1, isNot(equals(word2)));
        expect(word1 == word2, false);
      });

      test('Should have same hashCode when ids are same', () {
        final word1 = Word(
          id: 'same-id',
          word: 'word1',
          definition: 'n. 词汇1',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        final word2 = Word(
          id: 'same-id',
          word: 'word2',
          definition: 'n. 词汇2',
          examples: [],
          difficulty: 2,
          tags: [],
        );

        expect(word1.hashCode, word2.hashCode);
      });

      test('Should have different hashCode when ids are different', () {
        final word1 = Word(
          id: 'id-1',
          word: 'same',
          definition: 'n. 相同',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        final word2 = Word(
          id: 'id-2',
          word: 'same',
          definition: 'n. 相同',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        expect(word1.hashCode, isNot(word2.hashCode));
      });
    });

    group('toString Tests', () {
      test('toString should return the word text', () {
        final word = Word(
          id: 'word-012',
          word: 'hello',
          definition: 'interj. 你好',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        expect(word.toString(), 'hello');
        expect('$word', 'hello');
      });
    });

    group('Validation Tests', () {
      test('Should handle empty examples list', () {
        final word = Word(
          id: 'word-013',
          word: 'noexamples',
          definition: 'n. 无例句',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        expect(word.examples, isEmpty);
        expect(word.examples.length, 0);
      });

      test('Should handle multiple examples', () {
        final examples = [
          'Example 1',
          'Example 2',
          'Example 3',
        ];

        final word = Word(
          id: 'word-014',
          word: 'multiexamples',
          definition: 'adj. 多例句',
          examples: examples,
          difficulty: 2,
          tags: [],
        );

        expect(word.examples.length, 3);
        expect(word.examples, examples);
      });

      test('Should handle difficulty range (1-5)', () {
        for (int i = 1; i <= 5; i++) {
          final word = Word(
            id: 'word-$i',
            word: 'difficulty$i',
            definition: 'n. 难度$i',
            examples: [],
            difficulty: i,
            tags: [],
          );

          expect(word.difficulty, greaterThanOrEqualTo(1));
          expect(word.difficulty, lessThanOrEqualTo(5));
        }
      });

      test('Should handle multiple tags', () {
        final tags = ['cet4', 'noun', 'common', 'daily'];

        final word = Word(
          id: 'word-015',
          word: 'tags',
          definition: 'n. 标签',
          examples: [],
          difficulty: 1,
          tags: tags,
        );

        expect(word.tags.length, 4);
        expect(word.tags, contains('cet4'));
        expect(word.tags, contains('noun'));
      });
    });

    group('Edge Cases Tests', () {
      test('Should handle special characters in word', () {
        final word = Word(
          id: 'word-016',
          word: "don't",
          definition: 'v. 不',
          examples: ["Don't do that."],
          difficulty: 1,
          tags: [],
        );

        expect(word.word, "don't");
        expect(word.examples.first, contains("'"));
      });

      test('Should handle Unicode characters', () {
        final word = Word(
          id: 'word-017',
          word: 'café',
          definition: 'n. 咖啡馆',
          examples: ['Let\'s go to the café.'],
          difficulty: 2,
          tags: ['french'],
        );

        expect(word.word, contains('é'));
      });

      test('Should handle very long definition', () {
        final longDefinition = 'n. ' + 'very ' * 100 + 'long definition';

        final word = Word(
          id: 'word-018',
          word: 'longword',
          definition: longDefinition,
          examples: [],
          difficulty: 3,
          tags: [],
        );

        expect(word.definition.length, greaterThan(100));
      });

      test('Should handle empty tags list', () {
        final word = Word(
          id: 'word-019',
          word: 'notags',
          definition: 'n. 无标签',
          examples: [],
          difficulty: 1,
          tags: [],
        );

        expect(word.tags, isEmpty);
      });
    });
  });
}
