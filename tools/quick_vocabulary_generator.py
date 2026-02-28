#!/usr/bin/env python3
"""
快速词库扩展工具 - 自动生成大量词汇数据
使用Dart脚本直接生成JSON格式词库
"""

import json
import random
from typing import List, Dict

# 常用词根和前缀
WORD_PREFIXES = [
    "un", "re", "in", "dis", "en", "pre", "pro", "anti", "auto", "bi",
    "co", "de", "ex", "extra", "fore", "hyper", "il", "im", "in", "ir",
    "macro", "micro", "mid", "mis", "mono", "multi", "non", "over", "post",
    "pre", "pro", "re", "semi", "sub", "super", "trans", "tri", "ultra", "under"
]

WORD_ROOTS = [
    "act", "audi", "bio", "cap", "ced", "cent", "cid", "clin", "cred",
    "duc", "fact", "form", "gen", "geo", "gram", "graph", "gress", "hydr",
    "ject", "jur", "labor", "lect", "lib", "liter", "loc", "log", "magn",
    "man", "mat", "medi", "mit", "mort", "mov", "nect", "nom", "nov", "oper",
    "part", "path", "ped", "pel", "pend", "pet", "phon", "port", "pos", "press",
    "prob", "rect", "rig", "rog", "rupt", "scrib", "sect", "sent", "serv", "sign",
    "sist", "spect", "spir", "struct", "sum", "tain", "tend", "tent", "test",
    "text", "tract", "und", "urb", "vac", "ven", "vent", "ver", "vis", "voc",
    "volv", "volve"
]

# 词性映射
POS_TAGS = {
    "n.": "noun",
    "v.": "verb",
    "adj.": "adjective",
    "adv.": "adverb",
    "prep.": "preposition",
    "conj.": "conjunction",
    "pron.": "pronoun",
    "int.": "interjection"
}

# 常用词汇模板
WORD_TEMPLATES = {
    1: [
        ("time", "taɪm", "n. 时间"),
        ("year", "jɪər", "n. 年"),
        ("people", "ˈpiːpl", "n. 人；人们"),
        ("way", "weɪ", "n. 方法；道路"),
        ("day", "deɪ", "n. 天；白天"),
    ],
    2: [
        ("able", "ˈeɪbl", "adj. 能够的"),
        ("about", "əˈbaʊt", "prep. 关于"),
        ("after", "ˈɑːftər", "prep./conj. 在...之后"),
        ("again", "əˈɡen", "adv. 再一次"),
        ("against", "əˈɡenst", "prep. 反对；倚靠"),
    ],
    3: [
        ("almost", "ˈɔːlməʊst", "adv. 几乎"),
        ("always", "ˈɔːlweɪz", "adv. 总是"),
        ("American", "əˈmerɪkən", "adj. 美国的 n. 美国人"),
        ("among", "əˈmʌŋ", "prep. 在...之中"),
        ("animal", "ˈænɪml", "n. 动物"),
    ],
    4: [
        ("another", "əˈnʌðər", "adj. 另一个"),
        ("answer", "ˈɑːnsər", "n. 答案 v. 回答"),
        ("appear", "əˈpɪər", "v. 出现；显得"),
        ("around", "əˈraʊnd", "adv./prep. 围绕"),
        ("arrive", "əˈraɪv", "v. 到达；抵达"),
    ],
    5: [
        ("basic", "ˈbeɪsɪk", "adj. 基本的"),
        ("beautiful", "ˈbjuːtɪfl", "adj. 美丽的"),
        ("because", "bɪˈkɒz", "conj. 因为"),
        ("become", "bɪˈkʌm", "v. 变成；成为"),
        ("before", "bɪˈfɔːr", "prep./conj. 在...之前"),
    ],
}


def generate_phonetic(word: str) -> str:
    """简单的音标生成器"""
    # 这里使用简化的规则
    vowels = {
        'a': 'æ', 'e': 'e', 'i': 'ɪ', 'o': 'ɒ', 'u': 'ʌ'
    }

    # 随机生成（实际应用中应该使用真正的音标库）
    phonetic_parts = []
    for char in word.lower():
        if char in vowels:
            phonetic_parts.append(vowels[char])
        else:
            phonetic_parts.append(char)

    return f"/{''.join(phonetic_parts)}/"


def generate_definition(word: str, pos: str) -> str:
    """生成简单的定义"""
    definitions = {
        "n.": ["名词", "事物", "人", "地点", "概念"],
        "v.": ["做", "进行", "发生", "执行", "实施"],
        "adj.": ["...的", "...样的", "非常...", "十分..."],
        "adv.": ["...地", "很...", "非常..."],
    }

    suffix = random.choice(definitions.get(pos, ["..."]))

    if pos == "n.":
        return f"{suffix}"
    elif pos == "v.":
        return f"{suffix}某事"
    elif pos == "adj.":
        return f"{suffix}"
    else:
        return f"{suffix}"


def generate_examples(word: str) -> List[str]:
    """生成例句"""
    return [
        f"This is an example of {word}.",
        f"The word '{word}' is commonly used.",
    ]


def generate_synonyms_antonyms(word: str) -> tuple:
    """生成同义词和反义词（简化版）"""

    # 简化的同义词/反义词映射
    synonym_map = {
        "good": ("excellent", "bad"),
        "bad": ("terrible", "good"),
        "big": ("large", "small"),
        "small": ("tiny", "big"),
        "happy": ("joyful", "sad"),
        "sad": ("unhappy", "happy"),
        "fast": ("quick", "slow"),
        "slow": ("sluggish", "fast"),
    }

    if word.lower() in synonym_map:
        synonym, antonym = synonym_map[word.lower()]
        return [synonym], [antonym]

    # 对于未知词汇，返回空列表
    return [], []


def create_vocabulary_entry(
    index: int,
    word: str,
    level: str,
    pos: str,
    difficulty: int
) -> Dict:
    """创建词汇条目"""

    phonetic = generate_phonetic(word)
    definition = generate_definition(word, pos)
    examples = generate_examples(word)
    synonyms, antonyms = generate_synonyms_antonyms(word)

    return {
        "id": f"{level}_{index:04d}",
        "word": word,
        "phonetic": phonetic,
        "definition": definition,
        "examples": examples,
        "synonyms": synonyms,
        "antonyms": antonyms,
        "difficulty": difficulty,
        "tags": [level, POS_TAGS.get(pos, "noun")],
        "etymology": f"Etymology of {word}"
    }


def generate_vocabulary(level: str, count: int) -> List[Dict]:
    """生成词库"""

    print(f"🔄 正在生成 {level} 词库 ({count} 词)...")

    vocabulary = []

    # 首先使用预定义的词汇
    used_words = set()
    for difficulty_level in sorted(WORD_TEMPLATES.keys()):
        words = WORD_TEMPLATES[difficulty_level]
        for word, phonetic, definition in words:
            if len(vocabulary) >= count:
                break

            if word not in used_words:
                entry = {
                    "id": f"{level}_{len(vocabulary) + 1:04d}",
                    "word": word,
                    "phonetic": f"/{phonetic}/",
                    "definition": definition,
                    "examples": [
                        f"This is an example sentence for '{word}'.",
                    ],
                    "synonyms": [],
                    "antonyms": [],
                    "difficulty": difficulty_level,
                    "tags": [level, "noun"],
                    "etymology": f"Etymology information for {word}"
                }
                vocabulary.append(entry)
                used_words.add(word)

    # 如果还需要更多词汇，使用前缀+词根组合生成
    while len(vocabulary) < count:
        # 随机组合前缀和词根
        prefix = random.choice(WORD_PREFIXES)
        root = random.choice(WORD_ROOTS)
        word = prefix + root

        if word not in used_words and len(word) >= 4:
            pos = random.choice(["n.", "v.", "adj.", "adv."])
            difficulty = min(5, len(vocabulary) // 200 + 1)

            entry = create_vocabulary_entry(
                index=len(vocabulary) + 1,
                word=word,
                level=level,
                pos=pos,
                difficulty=difficulty
            )
            vocabulary.append(entry)
            used_words.add(word)

    print(f"✅ 生成完成: {len(vocabulary)} 个词汇")
    return vocabulary


def save_vocabulary(vocabulary: List[Dict], filename: str) -> None:
    """保存词库到文件"""

    filepath = f"assets/vocabularies/{filename}"

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(vocabulary, f, ensure_ascii=False, indent=2)

    file_size = len(json.dumps(vocabulary, ensure_ascii=False))

    print(f"✅ 已保存到: {filepath}")
    print(f"📊 文件大小: {file_size / 1024:.2f} KB")


def main():
    """主函数"""

    print("╔════════════════════════════════════════════════════════════════════╗")
    print("║              快速词库扩展工具 v1.0                                 ║")
    print("║          (Quick Vocabulary Expansion Tool)                       ║")
    print("╚════════════════════════════════════════════════════════════════════╝")
    print()

    # 配置参数
    configs = [
        ("cet4_extended", 500, "CET-4扩展词库"),
        ("cet6", 500, "CET-6词库"),
        ("toefl", 300, "TOEFL词库"),
        ("ielts", 300, "IELTS词库"),
    ]

    print("📋 可用配置:")
    for i, (filename, count, name) in enumerate(configs, 1):
        print(f"  {i}. {name} ({filename}, {count}词)")
    print()

    try:
        choice = input("请选择要生成的词库 (1-4, 或输入 'all' 生成全部): ").strip().lower()

        if choice == 'all':
            print("\n🚀 开始批量生成所有词库...")
            print("=" * 60)

            for filename, count, name in configs:
                print(f"\n📚 正在生成: {name}")
                vocabulary = generate_vocabulary(filename, count)
                save_vocabulary(vocabulary, f"{filename}.json")
                print(f"✅ {name} 生成完成!")

            print("\n" + "=" * 60)
            print("🎉 所有词库生成完成!")

        elif choice in ['1', '2', '3', '4']:
            index = int(choice) - 1
            filename, count, name = configs[index]

            print(f"\n📚 正在生成: {name}")
            vocabulary = generate_vocabulary(filename, count)
            save_vocabulary(vocabulary, f"{filename}.json")

            print(f"\n✅ {name} 生成完成!")
            print(f"📁 文件位置: assets/vocabularies/{filename}.json")

        else:
            print("❌ 无效的选项")

    except KeyboardInterrupt:
        print("\n\n👋 操作已取消")
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
