import json

print("=== 考研词库详细检查 ===\n")

with open('kaoyan_complete.json', 'r', encoding='utf-8') as f:
    words = json.load(f)

print(f"总词汇数: {len(words):,}\n")

# 检查没有ky标签的词汇
no_ky = [w for w in words if 'ky' not in w['tags']]
print(f"❌ 没有'ky'标签的词汇: {len(no_ky)}")

if no_ky:
    print("\n前20个缺失'ky'标签的词汇:")
    for w in no_ky[:20]:
        print(f"  {w['word']:20s} {w['tags']}")
    
    # 分析这些词汇的实际标签
    print("\n这些词汇的标签分布:")
    tag_count = {}
    for w in no_ky:
        for tag in w['tags']:
            tag_count[tag] = tag_count.get(tag, 0) + 1
    
    for tag, count in sorted(tag_count.items(), key=lambda x: -x[1]):
        print(f"  {tag}: {count}")

# 检查ky标签是否在第一位
not_first = [w for w in words if w['tags'][0] != 'ky']
print(f"\n⚠️  'ky'标签不在第一位的词汇: {len(not_first)}")

if not_first:
    print("\n前10个ky标签不在第一位的词汇:")
    for w in not_first[:10]:
        print(f"  {w['word']:20s} {w['tags']}")

# 显示前10个词汇示例
print("\n前10个词汇示例:")
for w in words[:10]:
    print(f"  {w['word']:20s} {w['tags']}")
