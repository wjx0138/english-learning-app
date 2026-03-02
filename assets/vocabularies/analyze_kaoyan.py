import json
from collections import Counter

with open('kaoyan_complete.json', 'r', encoding='utf-8') as f:
    words = json.load(f)

print("=== 考研词库深度分析 ===\n")

# 分析标签分布
all_tags = []
for w in words:
    all_tags.extend(w['tags'])

tag_counter = Counter(all_tags)
print("=== 标签分布 ===")
for tag, count in tag_counter.most_common():
    percentage = (count / len(words)) * 100
    print(f"{tag:10s}: {count:4d} ({percentage:5.1f}%)")

print("\n=== 问题词汇分析 ===")

# 找出太简单的词汇（只包含基础标签）
simple_words = []
for w in words:
    # 如果只包含基础标签（zk, gk, cet4）而没有高级标签
    tags_set = set(w['tags'])
    if tags_set <= {'zk', 'gk', 'cet4', 'ky'}:
        if 'cet6' not in w['tags'] and 'toefl' not in w['tags'] and 'ielts' not in w['tags'] and 'gre' not in w['tags']:
            simple_words.append(w)

print(f"⚠️  只包含基础标签的简单词汇: {len(simple_words)} ({len(simple_words)/len(words)*100:.1f}%)")
print("\n前30个简单词汇示例:")
for w in simple_words[:30]:
    print(f"  {w['word']:20s} {w['tags']}")

# 分析专有名词和特殊词汇
print("\n=== 专有名词/特殊词汇 ===")
special_categories = {
    '宗教': ['Christ', 'Buddhist', 'Catholic', 'Christian', 'Jesus'],
    '地名': ['Latin', 'Atlantic', 'Arab', 'Asian', 'Canada'],
    '历史': ['B.C.', 'Marxist'],
}

found_special = []
for w in words:
    word_lower = w['word'].lower()
    for category, keywords in special_categories.items():
        if w['word'] in keywords:
            found_special.append((category, w['word'], w['tags']))
            break

if found_special:
    print("找到的专有名词/特殊词汇:")
    for category, word, tags in found_special[:20]:
        print(f"  [{category}] {word:15s} {tags}")

# 检查是否包含太多非英语词汇
print("\n=== 大写缩写词/特殊词 ===")
uppercase_words = [w for w in words if w['word'].isupper() and len(w['word']) <= 5]
print(f"大写缩写词: {len(uppercase_words)}")
if uppercase_words:
    print("前20个:")
    for w in uppercase_words[:20]:
        print(f"  {w['word']:10s} {w['definition'][:50]}")
