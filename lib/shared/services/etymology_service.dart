/// 词根词缀数据服务 - 提供单词的词根、词缀信息
class EtymologyService {
  /// 获取单词的词根词缀信息
  static EtymologyInfo? getEtymology(String word) {
    return etymologyDatabase[word.toLowerCase()];
  }

  /// 获取所有词根数据库
  static Map<String, EtymologyInfo> get database => etymologyDatabase;

  /// 获取词根说明
  static String getRootDescription(String root) {
    final descriptions = {
      'act': '行动、做',
      'bio': '生命、生活',
      'chron': '时间',
      'cred': '相信',
      'dict': '说话、措辞',
      'duc': '引导、教导',
      'fac': '做、制造',
      'graph': '写、画',
      'ject': '投掷',
      'port': '携带、拿',
      'spec': '看',
      'struct': '建造、安排',
      'tract': '拉、拖',
      'ven': '来',
      'vert': '转',
      'vis': '看',
      'voc': '声音、喊',
    };
    return descriptions[root] ?? '词根';
  }

  /// 获取词缀说明
  static String getAffixDescription(String affix) {
    final descriptions = {
      'un-': '不、相反',
      're-': '重新、再、回',
      'pre-': '在...之前、前',
      'post-': '在...之后、后',
      'dis-': '分离、分开',
      'mis-': '错误、错误地',
      'anti-': '反对、对抗',
      'co-': '共同、一起',
      'ex-': '向外、以前的、前任',
      'inter-': '在...之间',
      'trans-': '跨越、转移',
      'sub-': '下面、次要',
      'super-': '超级、上层',
      'auto-': '自己、自动',
    };
    return descriptions[affix] ?? '词缀';
  }
}

/// 词根词缀信息模型
class EtymologyInfo {
  final String root;
  final String? meaning;
  final List<EtymologyExample> examples;
  final List<WordAffix> affixes;

  const EtymologyInfo({
    required this.root,
    this.meaning,
    this.examples = const [],
    this.affixes = const [],
  });

  /// 获取词根含义
  String get rootMeaning => meaning ?? EtymologyService.getRootDescription(root);

  /// 获取衍生词
  List<String> get derivedWords =>
      examples.map((e) => e.word).toList();
}

/// 词根示例
class EtymologyExample {
  final String word;
  final String meaning;
  final String? breakdown;

  const EtymologyExample({
    required this.word,
    required this.meaning,
    this.breakdown,
  });
}

/// 词缀
class WordAffix {
  final String affix;
  final String type; // 'prefix' | 'suffix' | 'infix'
  final String meaning;

  const WordAffix({
    required this.affix,
    required this.type,
    required this.meaning,
  });
}

/// 词根词缀数据库
final etymologyDatabase = <String, EtymologyInfo>{
  // 常见词根
  'act': EtymologyInfo(
    root: 'act',
    meaning: '行动、做',
    examples: [
      EtymologyExample(
        word: 'action',
        meaning: 'n. 行动、活动',
        breakdown: 'act + ion = action',
      ),
      EtymologyExample(
        word: 'actor',
        meaning: 'n. 演员',
        breakdown: 'act + or = actor',
      ),
      EtymologyExample(
        word: 'active',
        meaning: 'adj. 积极的、主动的',
        breakdown: 'act + ive = active',
      ),
    ],
  ),
  'bio': EtymologyInfo(
    root: 'bio',
    meaning: '生命、生活',
    examples: [
      EtymologyExample(
        word: 'biology',
        meaning: 'n. 生物学',
        breakdown: 'bio + logy = biology',
      ),
      EtymologyExample(
        word: 'biography',
        meaning: 'n. 传记',
        breakdown: 'bio + graphy = biography',
      ),
    ],
  ),
  'chron': EtymologyInfo(
    root: 'chron',
    meaning: '时间',
    examples: [
      EtymologyExample(
        word: 'chronology',
        meaning: 'n. 年代学、编年史',
        breakdown: 'chron + ology = chronology',
      ),
      EtymologyExample(
        word: 'synchronize',
        meaning: 'v. 同步',
        breakdown: 'syn + chron + ize = synchronize',
      ),
    ],
  ),
  'cred': EtymologyInfo(
    root: 'cred',
    meaning: '相信',
    examples: [
      EtymologyExample(
        word: 'credit',
        meaning: 'n. 信用、学分',
        breakdown: 'cred + it = credit',
      ),
      EtymologyExample(
        word: 'credible',
        meaning: 'adj. 可信的',
        breakdown: 'cred + ible = credible',
      ),
    ],
  ),
  'dict': EtymologyInfo(
    root: 'dict',
    meaning: '说话、措辞',
    examples: [
      EtymologyExample(
        word: 'dictionary',
        meaning: 'n. 词典',
        breakdown: 'dict + ionary = dictionary',
      ),
      EtymologyExample(
        word: 'dictate',
        meaning: 'v. 口述、命令',
        breakdown: 'dict + ate = dictate',
      ),
    ],
  ),
  'duc': EtymologyInfo(
    root: 'duc',
    meaning: '引导、教导',
    examples: [
      EtymologyExample(
        word: 'education',
        meaning: 'n. 教育',
        breakdown: 'e + duc + ation = education',
      ),
      EtymologyExample(
        word: 'deduce',
        meaning: 'v. 推断',
        breakdown: 'de + duc + e = deduce',
      ),
    ],
  ),
  'fac': EtymologyInfo(
    root: 'fac',
    meaning: '做、制造',
    examples: [
      EtymologyExample(
        word: 'factory',
        meaning: 'n. 工厂',
        breakdown: 'fact + ory = factory',
      ),
      EtymologyExample(
        word: 'manufacture',
        meaning: 'v. 制造、生产',
        breakdown: 'manu + fact + ure = manufacture',
      ),
      EtymologyExample(
        word: 'facile',
        meaning: 'adj. 容易的、熟练的',
        breakdown: 'fac + ile = facile',
      ),
    ],
  ),
  'graph': EtymologyInfo(
    root: 'graph',
    meaning: '写、画',
    examples: [
      EtymologyExample(
        word: 'graphic',
        meaning: 'adj. 图形的、生动的',
        breakdown: 'graph + ic = graphic',
      ),
      EtymologyExample(
        word: 'photograph',
        meaning: 'n. 照片',
        breakdown: 'photo + graph = photograph',
      ),
      EtymologyExample(
        word: 'autograph',
        meaning: 'n. 亲笔签名',
        breakdown: 'auto + graph = autograph',
      ),
    ],
  ),
  'ject': EtymologyInfo(
    root: 'ject',
    meaning: '投掷',
    examples: [
      EtymologyExample(
        word: 'project',
        meaning: 'n. 项目、计划',
        breakdown: 'pro + ject = project',
      ),
      EtymologyExample(
        word: 'inject',
        meaning: 'v. 注入',
        breakdown: 'in + ject = inject',
      ),
      EtymologyExample(
        word: 'reject',
        meaning: 'v. 拒绝',
        breakdown: 're + ject = reject',
      ),
      EtymologyExample(
        word: 'object',
        meaning: 'n. 物体、对象',
        breakdown: 'ob + ject = object',
      ),
    ],
  ),
  'port': EtymologyInfo(
    root: 'port',
    meaning: '携带、拿',
    examples: [
      EtymologyExample(
        word: 'portable',
        meaning: 'adj. 便携的',
        breakdown: 'port + able = portable',
      ),
      EtymologyExample(
        word: 'transport',
        meaning: 'v. 运输',
        breakdown: 'trans + port = transport',
      ),
      EtymologyExample(
        word: 'export',
        meaning: 'v. 出口',
        breakdown: 'ex + port = export',
      ),
      EtymologyExample(
        word: 'airport',
        meaning: 'n. 机场',
        breakdown: 'air + port = airport',
      ),
    ],
  ),
  'spec': EtymologyInfo(
    root: 'spec',
    meaning: '看',
    examples: [
      EtymologyExample(
        word: 'spectator',
        meaning: 'n. 观众',
        breakdown: 'spec + ator = spectator',
      ),
      EtymologyExample(
        word: 'inspect',
        meaning: 'v. 检查、视察',
        breakdown: 'in + spect = inspect',
      ),
      EtymologyExample(
        word: 'aspect',
        meaning: 'n. 方面、外观',
        breakdown: 'a + spect = aspect',
      ),
    ],
  ),
  'struct': EtymologyInfo(
    root: 'struct',
    meaning: '建造、安排',
    examples: [
      EtymologyExample(
        word: 'structure',
        meaning: 'n. 结构',
        breakdown: 'struct + ure = structure',
      ),
      EtymologyExample(
        word: 'construct',
        meaning: 'v. 建造、构造',
        breakdown: 'con + struct = construct',
      ),
      EtymologyExample(
        word: 'instruction',
        meaning: 'n. 指导、说明',
        breakdown: 'in + struct + ion = instruction',
      ),
      EtymologyExample(
        word: 'destruction',
        meaning: 'n. 破坏',
        breakdown: 'de + struct + ion = destruction',
      ),
    ],
  ),
  'tract': EtymologyInfo(
    root: 'tract',
    meaning: '拉、拖',
    examples: [
      EtymologyExample(
        word: 'attract',
        meaning: 'v. 吸引',
        breakdown: 'at + tract = attract',
      ),
      EtymologyExample(
        word: 'distract',
        meaning: 'v. 分散',
        breakdown: 'dis + tract = distract',
      ),
      EtymologyExample(
        word: 'contract',
        meaning: 'n. 合同',
        breakdown: 'con + tract = contract',
      ),
      EtymologyExample(
        word: 'tractor',
        meaning: 'n. 拖拉机',
        breakdown: 'tract + or = tractor',
      ),
    ],
  ),
  'ven': EtymologyInfo(
    root: 'ven',
    meaning: '来',
    examples: [
      EtymologyExample(
        word: 'avenue',
        meaning: 'n. 大街、途径',
        breakdown: 'a + ven + ue = avenue',
      ),
      EtymologyExample(
        word: 'convene',
        meaning: 'v. 召集',
        breakdown: 'con + vene = convene',
      ),
      EtymologyExample(
        word: 'intervention',
        meaning: 'n. 干预',
        breakdown: 'inter + ven + tion = intervention',
      ),
    ],
  ),
  'vert': EtymologyInfo(
    root: 'vert',
    meaning: '转',
    examples: [
      EtymologyExample(
        word: 'vertical',
        meaning: 'adj. 垂直的',
        breakdown: 'vert + ical = vertical',
      ),
      EtymologyExample(
        word: 'convert',
        meaning: 'v. 转换',
        breakdown: 'con + vert = convert',
      ),
      EtymologyExample(
        word: 'divert',
        meaning: 'v. 转移、娱乐',
        breakdown: 'di + vert = divert',
      ),
      EtymologyExample(
        word: 'reverse',
        meaning: 'v. 相反、逆转',
        breakdown: 're + verse = reverse',
      ),
    ],
  ),
  'vis': EtymologyInfo(
    root: 'vis',
    meaning: '看',
    examples: [
      EtymologyExample(
        word: 'visible',
        meaning: 'adj. 可见的',
        breakdown: 'vis + ible = visible',
      ),
      EtymologyExample(
        word: 'vision',
        meaning: 'n. 视觉',
        breakdown: 'vis + ion = vision',
      ),
      EtymologyExample(
        word: 'visit',
        meaning: 'v. 参观、访问',
        breakdown: 'vis + it = visit',
      ),
      EtymologyExample(
        word: 'supervisor',
        meaning: 'n. 监督者',
        breakdown: 'super + vis + or = supervisor',
      ),
      EtymologyExample(
        word: 'revise',
        meaning: 'v. 修改、修订',
        breakdown: 're + vis + e = revise',
      ),
    ],
  ),
  'voc': EtymologyInfo(
    root: 'voc',
    meaning: '声音、喊',
    examples: [
      EtymologyExample(
        word: 'vocal',
        meaning: 'adj. 声音的',
        breakdown: 'voc + al = vocal',
      ),
      EtymologyExample(
        word: 'vocabulary',
        meaning: 'n. 词汇',
        breakdown: 'vocab + ulary = vocabulary',
      ),
      EtymologyExample(
        word: 'advocate',
        meaning: 'v. 倡导',
        breakdown: 'ad + voc + ate = advocate',
      ),
    ],
  ),
  // 复合词根
  'spect': EtymologyInfo(
    root: 'spect',
    meaning: '看',
    examples: [
      EtymologyExample(
        word: 'inspect',
        meaning: 'v. 检查',
        breakdown: 'in + spect = inspect',
      ),
    ],
  ),
  'vers': EtymologyInfo(
    root: 'vers',
    meaning: '转',
    examples: [
      EtymologyExample(
        word: 'diverse',
        meaning: 'adj. 多样的',
        breakdown: 'di + verse = diverse',
      ),
      EtymologyExample(
        word: 'reverse',
        meaning: 'v. 相反',
        breakdown: 're + verse = reverse',
      ),
      EtymologyExample(
        word: 'convert',
        meaning: 'v. 转换',
        breakdown: 'con + vert = convert',
      ),
      EtymologyExample(
        word: 'conversation',
        meaning: 'n. 会话',
        breakdown: 'con + vers + ation = conversation',
      ),
      EtymologyExample(
        word: 'version',
        meaning: 'n. 版本',
        breakdown: 'vers + ion = version',
      ),
    ],
  ),
};
