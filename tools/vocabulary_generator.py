#!/usr/bin/env python3
"""
词库生成工具 - 从ECDICT或其他数据源生成Flutter词库JSON文件
使用方法: python vocabulary_generator.py
"""

import json
import urllib.request
from typing import List, Dict
import os

# ECDICT 星级词库来源
ECDICT_STARS_URLS = {
    1: "https://github.com/skywind3000/ECDICT/raw/master/stardict.csv/ecdict-gui-stardict-1.csv",
    2: "https://github.com/skywind3000/ECDICT/raw/master/stardict.csv/ecdict-gui-stardict-2.csv",
    3: "https://github.com/skywind3000/ECDICT/raw/master/stardict.csv/ecdict-gui-stardict-3.csv",
}

# CET 词表
CET_VOCABULARY = {
    "cet4": {
        "name": "CET-4",
        "description": "大学英语四级词汇",
        "difficulty_range": (1, 3),
        "word_count": 4500
    },
    "cet6": {
        "name": "CET-6",
        "description": "大学英语六级词汇",
        "difficulty_range": (2, 4),
        "word_count": 6000
    },
    "toefl": {
        "name": "TOEFL",
        "description": "托福词汇",
        "difficulty_range": (3, 5),
        "word_count": 8000
    },
    "ielts": {
        "name": "IELTS",
        "description": "雅思词汇",
        "difficulty_range": (3, 5),
        "word_count": 7500
    },
    "gre": {
        "name": "GRE",
        "description": "GRE词汇",
        "difficulty_range": (4, 5),
        "word_count": 12000
    }
}

class VocabularyGenerator:
    """词库生成器"""

    def __init__(self, output_dir: str = "assets/vocabularies"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)

    def generate_word_entry(
        self,
        word: str,
        phonetic: str,
        definition: str,
        index: int,
        level: str = "cet4",
        difficulty: int = 2
    ) -> Dict:
        """生成单个词汇条目"""

        # 根据首字母生成同义词和反义词（简化版）
        synonyms = self._generate_synonyms(word)
        antonyms = self._generate_antonyms(word)

        return {
            "id": f"{level}_{index:04d}",
            "word": word,
            "phonetic": f"/{phonetic}/",
            "definition": definition,
            "examples": [
                f"This is an example sentence for the word '{word}'.",
            ],
            "synonyms": synonyms[:3],  # 最多3个同义词
            "antonyms": antonyms[:2],  # 最多2个反义词
            "difficulty": difficulty,
            "tags": [level, self._get_pos_from_definition(definition)],
            "etymology": f"Etymology information for {word}"
        }

    def _generate_synonyms(self, word: str) -> List[str]:
        """生成同义词（简化版）"""
        # 这里使用简单的映射，实际应用中应该从词库数据获取
        synonym_map = {
            "good": ["excellent", "fine", "great"],
            "bad": ["terrible", "poor", "awful"],
            "big": ["large", "huge", "enormous"],
            "small": ["tiny", "little", "minute"],
            "happy": ["joyful", "glad", "cheerful"],
            "sad": ["unhappy", "sorrowful", "depressed"],
            "fast": ["quick", "rapid", "swift"],
            "slow": ["sluggish", "leisurely", "unhurried"],
        }
        return synonym_map.get(word.lower(), [])

    def _generate_antonyms(self, word: str) -> List[str]:
        """生成反义词（简化版）"""
        antonym_map = {
            "good": ["bad", "poor"],
            "bad": ["good", "excellent"],
            "big": ["small", "tiny"],
            "small": ["big", "huge"],
            "happy": ["sad", "unhappy"],
            "sad": ["happy", "joyful"],
            "fast": ["slow", "sluggish"],
            "slow": ["fast", "quick"],
        }
        return antonym_map.get(word.lower(), [])

    def _get_pos_from_definition(self, definition: str) -> str:
        """从定义中推断词性"""
        if definition.startswith("v."):
            return "verb"
        elif definition.startswith("n."):
            return "noun"
        elif definition.startswith("adj."):
            return "adjective"
        elif definition.startswith("adv."):
            return "adverb"
        elif definition.startswith("prep."):
            return "preposition"
        else:
            return "noun"

    def create_sample_vocabulary(
        self,
        level: str = "cet4",
        count: int = 100
    ) -> List[Dict]:
        """创建示例词库"""

        sample_words = [
            ("ability", "əˈbɪləti", "n. 能力；本领"),
            ("abroad", "əˈbrɔːd", "adv. 在国外；到国外"),
            ("absence", "ˈæbsəns", "n. 缺席；不在"),
            ("absolute", "ˈæbsəluːt", "adj. 绝对的；完全的"),
            ("absorb", "əbˈzɔːb", "v. 吸收；同化"),
            ("abstract", "ˈæbstrækt", "adj. 抽象的 n. 摘要"),
            ("academic", "ˌækəˈdemɪk", "adj. 学术的"),
            ("accept", "əkˈsept", "v. 接受；同意"),
            ("access", "ˈækses", "n. 接近；通道"),
            ("accident", "ˈæksɪdənt", "n. 事故；意外"),
            ("accompany", "əˈkʌmpəni", "v. 陪伴；伴奏"),
            ("accomplish", "əˈkʌmplɪʃ", "v. 完成；实现"),
            ("account", "əˈkaʊnt", "n. 账户；解释"),
            ("accurate", "ˈækjərət", "adj. 准确的；精确的"),
            ("achieve", "əˈtʃiːv", "v. 实现；达到"),
            ("acknowledge", "əkˈnɒlɪdʒ", "v. 承认；致谢"),
            ("acquire", "əˈkwaɪər", "v. 获得；取得"),
            ("across", "əˈkrɒs", "adv./prep. 横过"),
            ("action", "ˈækʃn", "n. 行动；作用"),
            ("active", "ˈæktɪv", "adj. 活跃的；积极的"),
            ("activity", "ækˈtɪvəti", "n. 活动；活跃"),
            ("actual", "ˈæktʃuəl", "adj. 实际的；真实的"),
            ("adapt", "əˈdæpt", "v. 适应；改编"),
            ("addition", "əˈdɪʃn", "n. 加；增加"),
            ("additional", "əˈdɪʃənl", "adj. 额外的；附加的"),
            ("address", "əˈdres", "n. 地址 v. 致辞"),
            ("adequate", "ˈædɪkwət", "adj. 足够的；适当的"),
            ("adjust", "əˈdʒʌst", "v. 调整；适应"),
            ("administration", "ədˌmɪnɪˈstreɪʃn", "n. 管理；行政"),
            ("admire", "ədˈmaɪər", "v. 钦佩；羡慕"),
            ("admit", "ədˈmɪt", "v. 承认；准许进入"),
            ("adopt", "əˈdɒpt", "v. 收养；采用"),
            ("adult", "ˈædʌlt", "n. 成年人 adj. 成年的"),
            ("advance", "ədˈvɑːns", "v. 前进 n. 进展"),
            ("advanced", "ədˈvɑːnst", "adj. 先进的；高级的"),
            ("advantage", "ədˈvɑːntɪdʒ", "n. 优势；利益"),
            ("adventure", "ədˈventʃər", "n. 冒险；奇遇"),
            ("advertise", "ˈædvətaɪz", "v. 做广告；宣传"),
            ("advice", "ədˈvaɪs", "n. 建议；忠告"),
            ("advocate", "ˈædvəkət", "v. 提倡 n. 拥护者"),
            ("affair", "əˈfeər", "n. 事情；事务"),
            ("affect", "əˈfekt", "v. 影响；感动"),
            ("affection", "əˈfekʃn", "n. 喜爱；感情"),
            ("afford", "əˈfɔːd", "v. 买得起；承担"),
            ("afraid", "əˈfreɪd", "adj. 害怕的；担心的"),
            ("agency", "ˈeɪdʒənsi", "n. 代理处；机构"),
            ("aggressive", "əˈɡresɪv", "adj. 侵略的；进取的"),
        ]

        vocabulary = []
        for i, (word, phonetic, definition) in enumerate(sample_words[:count], 1):
            entry = self.generate_word_entry(
                word=word,
                phonetic=phonetic,
                definition=definition,
                index=i,
                level=level,
                difficulty=min(3, i // 30 + 1)
            )
            vocabulary.append(entry)

        return vocabulary

    def save_vocabulary(
        self,
        vocabulary: List[Dict],
        filename: str
    ) -> None:
        """保存词库到JSON文件"""

        filepath = os.path.join(self.output_dir, filename)
        with open(filepath, 'w', encoding='utf-8') as File:
            json.dump(vocabulary, File, ensure_ascii=False, indent=2)

        print(f"✅ 词库已保存到: {filepath}")
        print(f"📊 词汇数量: {len(vocabulary)}")
        print(f"📁 文件大小: {os.path.getsize(filepath) / 1024:.2f} KB")

    def generate_cet4(self, count: int = 500) -> None:
        """生成CET4词库"""

        print(f"🔄 开始生成CET4词库 ({count}词)...")

        # 从示例词库生成
        vocabulary = self.create_sample_vocabulary("cet4", count)

        self.save_vocabulary(vocabulary, "cet4_extended.json")

    def generate_cet6(self, count: int = 500) -> None:
        """生成CET6词库"""

        print(f"🔄 开始生成CET6词库 ({count}词)...")

        # CET6在CET4基础上增加更难的词汇
        vocabulary = []

        advanced_words = [
            ("abnormal", "æbˈnɔːml", "adj. 反常的；变态的"),
            ("abolish", "əˈbɒlɪʃ", "v. 废除；取消"),
            ("abortion", "əˈbɔːʃn", "n. 流产；堕胎"),
            ("abridge", "əˈbrɪdʒ", "v. 删节；缩短"),
            ("abroad", "əˈbrɔːd", "adv. 在国外；到国外"),
            ("abrupt", "əˈbrʌpt", "adj. 突然的；生硬的"),
            ("absence", "ˈæbsəns", "n. 缺席；不在"),
            ("absolute", "ˈæbsəluːt", "adj. 绝对的；完全的"),
            ("absorb", "əbˈzɔːb", "v. 吸收；同化"),
            ("abstract", "ˈæbstrækt", "adj. 抽象的 n. 摘要"),
            ("absurd", "əbˈsɜːd", "adj. 荒谬的；可笑的"),
            ("abundance", "əˈbʌndəns", "n. 丰富；充裕"),
            ("abuse", "əˈbjuːz", "v. 滥用 n. 虐待"),
            ("academic", "ˌækəˈdemɪk", "adj. 学术的"),
            ("academy", "əˈkædəmi", "n. 学院；学会"),
            ("accelerate", "əkˈseləreɪt", "v. 加速；促进"),
            ("accept", "əkˈsept", "v. 接受；同意"),
            ("acceptable", "əkˈseptəbl", "adj. 可接受的"),
            ("access", "ˈækses", "n. 接近；通道"),
            ("accessible", "əkˈsesəbl", "adj. 易达到的"),
        ]

        for i, (word, phonetic, definition) in enumerate(advanced_words[:count], 1):
            entry = self.generate_word_entry(
                word=word,
                phonetic=phonetic,
                definition=definition,
                index=i,
                level="cet6",
                difficulty=3 + (i // 50)
            )
            vocabulary.append(entry)

        self.save_vocabulary(vocabulary, "cet6.json")

    def merge_vocabularies(
        self,
        input_files: List[str],
        output_file: str
    ) -> None:
        """合并多个词库文件"""

        print(f"🔄 开始合并词库...")

        merged_vocabulary = []
        word_ids = set()

        for input_file in input_files:
            filepath = os.path.join(self.output_dir, input_file)
            if not os.path.exists(filepath):
                print(f"⚠️  文件不存在: {filepath}")
                continue

            with open(filepath, 'r', encoding='utf-8') as f:
                vocabulary = json.load(f)
                for word in vocabulary:
                    if word['id'] not in word_ids:
                        merged_vocabulary.append(word)
                        word_ids.add(word['id'])

            print(f"✅ 已加载: {input_file} ({len(vocabulary)} 词)")

        # 按ID排序
        merged_vocabulary.sort(key=lambda x: x['id'])

        self.save_vocabulary(merged_vocabulary, output_file)

    def generate_statistics(self, filename: str) -> None:
        """生成词库统计信息"""

        filepath = os.path.join(self.output_dir, filename)
        if not os.path.exists(filepath):
            print(f"❌ 文件不存在: {filepath}")
            return

        with open(filepath, 'r', encoding='utf-8') as f:
            vocabulary = json.load(f)

        # 统计信息
        total_words = len(vocabulary)
        difficulty_distribution = {}
        tag_distribution = {}

        for word in vocabulary:
            # 难度分布
            difficulty = word.get('difficulty', 0)
            difficulty_distribution[difficulty] = difficulty_distribution.get(difficulty, 0) + 1

            # 标签分布
            for tag in word.get('tags', []):
                tag_distribution[tag] = tag_distribution.get(tag, 0) + 1

        print(f"\n📊 词库统计信息 - {filename}")
        print("=" * 50)
        print(f"总词汇数: {total_words}")
        print(f"\n难度分布:")
        for difficulty in sorted(difficulty_distribution.keys()):
            count = difficulty_distribution[difficulty]
            percentage = (count / total_words) * 100
            print(f"  难度 {difficulty}: {count} 词 ({percentage:.1f}%)")

        print(f"\n标签分布:")
        for tag, count in sorted(tag_distribution.items(), key=lambda x: x[1], reverse=True):
            percentage = (count / total_words) * 100
            print(f"  {tag}: {count} 词 ({percentage:.1f}%)")


def main():
    """主函数"""

    print("╔" + "═" * 58 + "╗")
    print("║" + " " * 10 + "词库生成工具" + " " * 36 + "║")
    print("║" + " " * 58 + "║")
    print("║" + "  用于生成Flutter英语学习应用的词库JSON文件" + " " * 22 + "║")
    print("╚" + "═" * 58 + "╝")
    print()

    generator = VocabularyGenerator()

    # 生成词库选项
    print("请选择操作:")
    print("1. 生成CET4词库 (500词)")
    print("2. 生成CET6词库 (500词)")
    print("3. 合并词库文件")
    print("4. 查看词库统计")
    print("5. 批量生成所有词库")
    print()

    try:
        choice = input("请输入选项 (1-5): ").strip()

        if choice == "1":
            generator.generate_cet4(count=500)

        elif choice == "2":
            generator.generate_cet6(count=500)

        elif choice == "3":
            print("可用的词库文件:")
            for file in os.listdir(generator.output_dir):
                if file.endswith('.json'):
                    print(f"  - {file}")

            input_files = input("\n请输入要合并的文件名 (用逗号分隔): ").strip()
            file_list = [f.strip() for f in input_files.split(',')]
            output_file = input("请输入输出文件名: ").strip()

            generator.merge_vocabularies(file_list, output_file)

        elif choice == "4":
            print("可用的词库文件:")
            for file in os.listdir(generator.output_dir):
                if file.endswith('.json'):
                    print(f"  - {file}")

            filename = input("\n请输入文件名: ").strip()
            generator.generate_statistics(filename)

        elif choice == "5":
            print("\n🚀 开始批量生成所有词库...")
            print("-" * 50)
            generator.generate_cet4(count=500)
            print()
            generator.generate_cet6(count=500)
            print()
            print("✅ 所有词库生成完成！")

        else:
            print("❌ 无效的选项")

    except KeyboardInterrupt:
        print("\n\n👋 操作已取消")
    except Exception as e:
        print(f"\n❌ 错误: {e}")


if __name__ == "__main__":
    main()
