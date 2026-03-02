import json
from collections import Counter

vocabularies = [
    ('cet4_ultra.json', 'CET-4'),
    ('cet6_ultra.json', 'CET-6'),
    ('toefl_ultra.json', 'TOEFL'),
    ('ielts_ultra.json', 'IELTS'),
    ('gre_ultra.json', 'GRE'),
    ('kaoyan_complete.json', '考研'),
]

print("=== 词库难度分布分析 ===\n")

for filename, name in vocabularies:
    with open(filename, 'r', encoding='utf-8') as f:
        words = json.load(f)
    
    # 统计难度
    difficulty_dist = Counter(w['difficulty'] for w in words)
    
    print(f"━━━ {name} ({filename}) ━━━")
    print(f"总词汇数: {len(words):,}")
    print("难度分布:")
    for level in sorted(difficulty_dist.keys()):
        count = difficulty_dist[level]
        percentage = (count / len(words)) * 100
        bar = '█' * int(percentage / 2)
        print(f"  难度{level}: {count:5d} ({percentage:5.1f}%) {bar}")
    
    # 计算平均难度
    avg_difficulty = sum(w['difficulty'] for w in words) / len(words)
    print(f"  平均难度: {avg_difficulty:.2f}")
    
    # 检查简单词汇（难度1-2）
    simple = [w for w in words if w['difficulty'] <= 2]
    print(f"  简单词汇(难度1-2): {len(simple)} ({len(simple)/len(words)*100:.1f}%)")
    
    print()
