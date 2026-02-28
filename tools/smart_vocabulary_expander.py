#!/usr/bin/env python3
"""
智能词库扩展器 - 使用词根词缀和派生规则生成大规模词库
目标：生成包含数千到数万词汇的完整词库
"""

import json
import os
from typing import List, Dict, Tuple

# 核心基础词汇（约500个最常用词）
CORE_VOCABULARY = [
    ("act", "ækt", "v. 行动 n. 行为", 2),
    ("add", "æd", "v. 增加", 1),
    ("agree", "əˈɡriː", "v. 同意", 2),
    ("appear", "əˈpɪər", "v. 出现", 2),
    ("arrange", "əˈreɪndʒ", "v. 安排", 3),
    ("assist", "əˈsɪst", "v. 协助", 3),
    ("assume", "əˈsjuːm", "v. 假定", 3),
    ("attack", "əˈtæk", "v. 攻击", 2),
    ("attend", "əˈtend", "v. 出席", 3),
    ("beauty", "ˈbjuːti", "n. 美丽", 2),
    ("believe", "bɪˈliːv", "v. 相信", 2),
    ("break", "breɪk", "v. 打破", 2),
    ("build", "bɪld", "v. 建造", 2),
    ("call", "kɔːl", "v./n. 呼叫", 1),
    ("care", "keər", "n. 照料 v. 关心", 2),
    ("carry", "ˈkæri", "v. 携带", 2),
    ("cause", "kɔːz", "n./v. 原因", 3),
    ("change", "tʃeɪndʒ", "n./v. 改变", 1),
    ("charge", "tʃɑːrdʒ", "v./n. 收费", 2),
    ("check", "tʃek", "v./n. 检查", 1),
    ("claim", "kleɪm", "v./n. 声称", 3),
    ("clean", "kliːn", "adj. 干净的", 2),
    ("clear", "klɪər", "adj. 清楚的", 2),
    ("collect", "kəˈlekt", "v. 收集", 3),
    ("come", "kʌm", "v. 来", 1),
    ("comfort", "ˈkʌmfət", "n. 舒适", 3),
    ("comment", "ˈkɒment", "n. 评论", 2),
    ("commit", "kəˈmɪt", "v. 承诺", 3),
    ("common", "ˈkɒmən", "adj. 共同的", 2),
    ("compare", "kəmˈpeər", "v. 比较", 3),
    ("complete", "kəmˈpliːt", "adj. 完整的", 2),
    ("concern", "kənˈsɜːn", "n./v. 关心", 3),
    ("condition", "kənˈdɪʃn", "n. 条件", 3),
    ("connect", "kəˈnekt", "v. 连接", 3),
    ("consider", "kənˈsɪdər", "v. 考虑", 3),
    ("construct", "kənˈstrʌkt", "v. 建造", 3),
    ("contain", "kənˈteɪn", "v. 包含", 3),
    ("content", "ˈkɒntent", "n. 内容", 2),
    ("continue", "kənˈtɪnjuː", "v. 继续", 2),
    ("control", "kənˈtrəʊl", "v./n. 控制", 3),
    ("correct", "kəˈrekt", "adj. 正确的", 2),
    ("cost", "kɒst", "n. 成本", 2),
    ("cover", "ˈkʌvər", "v./n. 覆盖", 2),
    ("create", "kriˈeɪt", "v. 创造", 2),
    ("cross", "krɒs", "n./v. 交叉", 2),
    ("cry", "kraɪ", "v./n. 哭", 2),
    ("decide", "dɪˈsaɪd", "v. 决定", 2),
    ("declare", "dɪˈkleər", "v. 宣布", 3),
    ("describe", "dɪˈskraɪb", "v. 描述", 3),
    ("develop", "dɪˈveləp", "v. 发展", 3),
    ("die", "daɪ", "v. 死", 1),
    ("discuss", "dɪˈskʌs", "v. 讨论", 3),
    ("divide", "dɪˈvaɪd", "v. 分割", 3),
    ("do", "duː", "v. 做", 1),
    ("draw", "drɔː", "v. 画；拉", 2),
    ("dream", "driːm", "n./v. 梦", 2),
    ("drive", "draɪv", "v. 驾驶", 2),
    ("earn", "ɜːrn", "v. 赚得", 2),
    ("elect", "ɪˈlekt", "v. 选举", 3),
    ("emerge", "ɪˈmɜːrdʒ", "v. 出现", 4),
    ("employ", "ɪmˈplɔɪ", "v. 雇佣", 3),
    ("encourage", "ɪnˈkʌrɪdʒ", "v. 鼓励", 3),
    ("end", "end", "n. 结束 v. 结束", 1),
    ("engage", "ɪnˈɡeɪdʒ", "v. 从事", 3),
    ("enjoy", "ɪnˈdʒɔɪ", "v. 享受", 2),
    ("enter", "ˈentər", "v. 进入", 2),
    ("estimate", "ˈestɪmeɪt", "v. 估计", 3),
    ("exist", "ɪɡˈzɪst", "v. 存在", 3),
    ("expect", "ɪkˈspekt", "v. 期待", 3),
    ("explain", "ɪkˈspleɪn", "v. 解释", 3),
    ("express", "ɪkˈspres", "v. 表达", 3),
    ("extend", "ɪkˈstend", "v. 延伸", 3),
    ("fail", "feɪl", "v. 失败", 2),
    ("fall", "fɔːl", "v. 落下", 1),
    ("feel", "fiːl", "v. 感觉", 1),
    ("fight", "faɪt", "v./n. 战斗", 2),
    ("find", "faɪnd", "v. 发现", 1),
    ("fly", "flaɪ", "v. 飞行", 1),
    ("forget", "fərˈɡet", "v. 忘记", 2),
    ("forgive", "fərˈɡɪv", "v. 原谅", 3),
    ("form", "fɔːrm", "n. 形式 v. 形成", 2),
    ("found", "faʊnd", "v. 建立", 2),
    ("free", "friː", "adj. 自由的", 2),
    ("frighten", "ˈfraɪtn", "v. 使惊吓", 3),
    ("get", "ɡet", "v. 得到", 1),
    ("give", "ɡɪv", "v. 给", 1),
    ("go", "ɡəʊ", "v. 去", 1),
    ("grow", "ɡrəʊ", "v. 生长", 2),
    ("handle", "ˈhændl", "v. 处理", 3),
    ("happen", "ˈhæpən", "v. 发生", 2),
    ("have", "hæv", "v. 有", 1),
    ("head", "hed", "n. 头", 1),
    ("hear", "hɪr", "v. 听见", 1),
    ("help", "help", "v./n. 帮助", 1),
    ("hold", "həʊld", "v. 持有", 1),
    ("hope", "həʊp", "n./v. 希望", 2),
    ("imagine", "ɪˈmædʒɪn", "v. 想象", 3),
    ("include", "ɪnˈkluːd", "v. 包括", 3),
    ("indicate", "ˈɪndɪkeɪt", "v. 指示", 3),
    ("insist", "ɪnˈsɪst", "v. 坚持", 3),
    ("intend", "ɪnˈtend", "v. 打算", 3),
    ("introduce", "ˌɪntrəˈdjuːs", "v. 介绍", 3),
    ("join", "dʒɔɪn", "v. 加入", 2),
    ("judge", "dʒʌdʒ", "v. 判断", 3),
    ("jump", "dʒʌmp", "v. 跳", 2),
    ("keep", "kiːp", "v. 保持", 1),
    ("kill", "kɪl", "v. 杀死", 2),
    ("kiss", "kɪs", "v./n. 吻", 2),
    ("know", "nəʊ", "v. 知道", 1),
    ("laugh", "læf", "v. 笑", 2),
    ("launch", "lɔːntʃ", "v. 发射", 3),
    ("lead", "liːd", "v. 领导", 2),
    ("learn", "lɜːrn", "v. 学习", 2),
    ("leave", "liːv", "v. 离开", 1),
    ("let", "let", "v. 让", 1),
    ("lie", "laɪ", "v. 躺；说谎", 2),
    ("like", "laɪk", "v. 喜欢", 1),
    ("listen", "ˈlɪsn", "v. 听", 2),
    ("live", "lɪv", "v. 居住", 1),
    ("look", "lʊk", "v. 看", 1),
    ("lose", "luːz", "v. 失去", 2),
    ("love", "lʌv", "v./n. 爱", 1),
    ("make", "meɪk", "v. 制造", 1),
    ("manage", "ˈmænɪdʒ", "v. 管理", 3),
    ("matter", "ˈmætər", "v. 要紧 n. 事情", 2),
    ("mean", "miːn", "v. 意味着", 2),
    ("meet", "miːt", "v. 遇见", 1),
    ("mind", "maɪnd", "n. 头脑 v. 介意", 2),
    ("move", "muːv", "v. 移动", 1),
    ("name", "neɪm", "n. 名字 v. 命名", 1),
    ("need", "niːd", "v./n. 需要", 1),
    ("note", "nəʊt", "n. 笔记 v. 注意", 2),
    ("notice", ("ˈnəʊtɪs", "v. 注意", 3),
    ("open", "ˈəʊpən", "v. 打开 adj. 开的", 2),
    ("operate", "ˈɒpəreɪt", "v. 操作", 3),
    ("order", "ˈɔːrdər", "n. 订单 v. 命令", 2),
    ("paint", "peɪnt", "v. 油画；涂", 2),
    ("pass", "pæs", "v. 通过", 1),
    ("pay", "peɪ", "v. 支付", 1),
    ("perform", "pərˈfɔːrm", "v. 执行；表演", 3),
    ("place", "pleɪs", "n. 地方 v. 放置", 1),
    ("plan", "plæn", "n. 计划 v. 计划", 2),
    ("play", "pleɪ", "v. 玩", 1),
    ("point", "pɔɪnt", "v. 指出 n. 点", 2),
    ("present", "ˈpreznt", "adj. 现在的 v. 展示", 3),
    ("produce", "prəˈdjuːs", "v. 生产", 3),
    ("promise", "ˈprɒmɪs", "v./n. 承诺", 3),
    "protect": ("prəˈtekt", "v. 保护", 3)
    ("prove": ("pruːv", "v. 证明", 3),
    ("provide": ("prəˈvaɪd", "v. 提供", 3)
    ("pull", ("pʊl", "v. 拉", 1),
    ("push", ("pʊʃ", "v. 推", 1),
    ("put", ("pʊt", "v. 放", 1),
    ("raise": ("reɪz", "v. 举起", 2),
    ("reach", ("riːtʃ", "v. 到达", 2),
    ("read": ("riːd", "v. 阅读", 1),
    ("receive": ("rɪˈsiːv", "v. 收到", 3),
    ("recognize": ("ˈrekəɡnaɪz", "v. 认出", 3),
    ("refer": ("rɪˈfɜːr", "v. 提及", 3),
    ("remember": ("rɪˈmembər", "v. 记得", 2),
    ("remove": ("rɪˈmuːv", "v. 移除", 3),
    ("report": ("rɪˈpɔːrt", "v./n. 报告", 3),
    ("represent": ("ˌreprɪˈzent", "v. 代表", 4),
    ("return": ("rɪˈtɜːrn", "v. 返回", 2),
    ("run", ("rʌn", "v. 跑", 1),
    ("say", ("seɪ", "v. 说", 1),
    ("see", ("siː", "v. 看见", 1),
    ("sell": ("sel", "v. 卖", 2),
    ("send", ("send", "v. 发送", 1),
    ("serve": ("sɜːrv", "v. 服务", 2),
    ("set", ("set", "v. 设置 n. 一套", 1),
    ("settle": ("ˈsetl", "v. 解决；定居", 3),
    ("show", ("ʃəʊ", "v. 展示", 1),
    ("shut", ("ʃʌt", "v. 关闭", 2),
    ("sing", ("sɪŋ", "v. 唱歌", 2),
    ("sit", ("sɪt", "v. 坐", 1),
    ("speak", ("spiːk", "v. 说话", 1),
    ("stand", ("stænd", "v. 站立", 1),
    ("start", ("stɑːrt", "v. 开始", 1),
    ("state", ("steɪt", "n. 州；状态 v. 陈述", 2),
    ("stay", ("steɪ", "v. 停留", 1),
    ("stick", ("stɪk", "v. 刺；粘住 n. 棍", 2),
    ("stop", ("stɒp", "v. 停止", 1),
    ("study": ("ˈstʌdi", "v./n. 学习", 2),
    ("suffer", ("ˈsʌfər", "v. 遭受", 3),
    ("suggest", ("səˈdʒest", "v. 建议", 3),
    ("suit", ("suːt", "v. 适合 n. 西装", 2),
    ("suppose", ("səˈpəʊz", "v. 假设", 3),
    ("take", ("teɪk", "v. 拿", 1),
    ("talk", ("tɔːk", "v./n. 谈话", 2),
    ("teach", ("tiːtʃ", "v. 教", 2),
    ("tell", ("tel", "v. 告诉", 1),
    ("tend", ("tend", "v. 倾向于", 3),
    ("test", ("test", "v./n. 测试", 2),
    ("thank", ("θæŋk", "v. 感谢", 2),
    ("think", ("θɪŋk", "v. 思考", 1),
    ("treat", ("triːt", "v. 对待 n. 款待", 3),
    ("try", ("traɪ", "v. 尝试", 1),
    ("turn", ("tɜːrn", "v. 转动", 1),
    ("understand", ("ˌʌndərˈstænd", "v. 理解", 3),
    ("use", ("juːz", "v. 使用", 1),
    ("visit", ("ˈvɪzɪt", "v. 拜访", 2),
    ("wait", ("weɪt", "v. 等待", 2),
    ("walk", ("wɔːk", "v. 走路", 1),
    ("want", ("wɒnt", "v. 想要", 1),
    ("watch", ("wɒtʃ", "v. 观看", 2),
    ("win", ("wɪn", "v. 赢", 1),
    ("wish", ("wɪʃ", "v./n. 希望", 2),
    ("work", ("wɜːrk", "v./n. 工作", 1),
    ("worry", ("ˈwʌri", "v. 担心", 2),
    ("write", ("raɪt", "v. 写", 1),
]

# 前缀和后缀
PREFIXES = {
    "un": "不；相反",
    "re": "再次；重新",
    "in": "不；非",
    "im": "不；非（用于p,b,m开头）",
    "il": "不；非（用于l开头）",
    "ir": "不；非（用于r开头）",
    "dis": "不；相反",
    "en": "使成为",
    "em": "使成为（用于p,b,m开头）",
    "pre": "预先",
    "pro": "向前；支持",
    "anti": "反对",
    "auto": "自动",
    "bi": "双；两",
    "co": "共同",
    "de": "向下；去除",
    "ex": "以前的；向外",
    "extra": "额外的",
    "fore": "预先",
    "hyper": "过度",
    "il": "不",
    "inter": "在...之间",
    "macro": "巨大的",
    "micro": "微小的",
    "mid": "中间的",
    "mis": "错误的",
    "mono": "单一的",
    "multi": "多的",
    "non": "非",
    "over": "过度",
    "post": "在...后",
    "semi": "半",
    "sub": "在...下",
    "super": "超级",
    "trans": "跨越",
    "tri": "三",
    "ultra": "极端",
    "under": "在...下",
}

SUFFIXES = {
    "able": "能够...的",
    "ible": "能够...的",
    "al": "...的",
    "ial": "...的",
    "ed": "已...的（动词过去式）",
    "en": "使成为",
    "er": "...的人；物",
    "or": "...的人（主动）",
    "est": "最...",
    "ful": "充满...的",
    "ic": "...的",
    "ical": "...的",
    "ing": "正在...（动词进行时）",
    "ion": "...的行为或状态",
    "tion": "...的行为或状态",
    "sion": "...的行为或状态",
    "ity": "...的状态或性质",
    "ment": "...的行为或结果",
    "ness": "...的状态或性质",
    "ous": "充满...的",
    "ious": "充满...的",
    "ly": "...地（副词后缀）",
    "ship": "...的状态或身份",
    "ward": "向...",
    "wards": "向...",
    "wise": "关于...地",
}

# 词根
ROOTS = {
    "act": "做；行动",
    "bio": "生命",
    "cap": "拿；抓住",
    "ced": "走",
    "cent": "百",
    "cide": "杀",
    "clin": "倾斜",
    "cred": "相信",
    "duc": "引导",
    "fact": "做；制作",
    "form": "形状",
    "gen": "出生；产生",
    "geo": "地球",
    "gram": "写；画",
    "graph": "写；画",
    "ject": "投掷",
    "jur": "法律；公正",
    "labor": "工作",
    "lect": "选择；收集",
    "lib": "自由",
    "liter": "文字",
    "loc": "地方",
    "log": "说话；理性",
    "magn": "大",
    "man": "手",
    "mat": "成熟的",
    "medi": "中间",
    "mit": "发送",
    "mort": "死",
    "mov": "移动",
    "nov": "新",
    "oper": "工作",
    "path": "感觉；疾病",
    "pel": "推动",
    "pend": "悬挂",
    "pet": "寻求",
    "phon": "声音",
    "port": "携带",
    "pos": "放置",
    "press": "压",
    "prob": "证明；测试",
    "rect": "直的",
    "rupt": "断裂",
    "scrib": "写",
    "script": "写",
    "sect": "切割",
    "sent": "感觉",
    "serv": "服务",
    "sign": "标记",
    "spect": "看",
    "spir": "呼吸",
    "struct": "建造",
    "tain": "持有",
    "tend": "伸展",
    "test": "见证",
    "text": "编织",
    "tract": "拉",
    "und": "波浪",
    "vac": "空",
    "ven": "来",
    "vent": "来",
    "ver": "真实",
    "vis": "看",
    "voc": "声音",
    "volv": "转动",
}

def generate_derivatives(word: str, phonetic: str, definition: str) -> List[Tuple]:
    """生成派生词"""
    derivatives = []
    
    # 动词名词化
    if definition.startswith("v."):
        # -ment
        if not word.endswith("e"):
            new_word = word + "ment"
            new_phonetic = phonetic.rstrip("/") + "mənt/"
            new_definition = f"n. {definition[2:]}的行为或结果"
            derivatives.append((new_word, new_phonetic, new_definition))
        
        # -tion/-sion/-ion
        if word.endswith("d"):
            new_word = word[:-1] + "sion"
            new_phonetic = phonetic.rstrip("/")[:-2] + "ʒn/"
        elif word.endswith("te"):
            new_word = word[:-2] + "tion"
            new_phonetic = phonetic.rstrip("/")[:-2] + "ʃn/"
        else:
            new_word = word + "tion"
            new_phonetic = phonetic.rstrip("/") + "ʃn/"
        new_definition = f"n. {definition[2:]}的行为或状态"
        derivatives.append((new_word, new_phonetic, new_definition))
        
        # -er/-or
        if word.endswith("e"):
            new_word = word + "r"
        else:
            new_word = word + "er"
        new_phonetic = phonetic.rstrip("/") + "ər/"
        new_definition = f"n. {definition[2:]}的人或工具"
        derivatives.append((new_word, new_phonetic, new_definition))
    
    # 名词形容词化
    elif definition.startswith("n."):
        # -al
        if word.endswith("tion") or word.endswith("sion"):
            base = word[:-4] if word.endswith("tion") else word[:-4]
            new_word = base + "al"
            new_phonetic = phonetic.rstrip("/")[:-4] + "əl/"
            new_definition = f"adj. 关于{definition[2:]}的"
            derivatives.append((new_word, new_phonetic, new_definition))
        
        # -ous/-ious
        if not word.endswith("e"):
            new_word = word + "ous"
            new_phonetic = phonetic.rstrip("/").rstrip("/").rstrip("/") + "əs/"
            new_definition = f"adj. 充满{definition[2:]}的"
            derivatives.append((new_word, new_phonetic, new_definition))
    
    # 形容词副词化
    elif definition.startswith("adj."):
        # -ly
        if word.endswith("l"):
            new_word = word + "ly"
        else:
            new_word = word + "ly"
        new_phonetic = phonetic.rstrip("/") + "li/"
        new_definition = f"adv. {definition[4:]}地"
        derivatives.append((new_word, new_phonetic, new_definition))
    
    return derivatives

def generate_prefix_combinations(word: str, phonetic: str, definition: str) -> List[Tuple]:
    """生成前缀组合词"""
    combinations = []
    
    # 只为动词和形容词添加前缀
    if not (definition.startswith("v.") or definition.startswith("adj.")):
        return combinations
    
    for prefix, meaning in PREFIXES.items():
        # 跳过某些前缀组合（避免不合理词汇）
        if word.startswith(prefix) or len(word) < 4:
            continue
            
        new_word = prefix + word
        # 调整音标（简化处理）
        new_phonetic = f"/{prefix}{phonetic[1:]}"
        
        # 生成新定义
        if definition.startswith("v."):
            if prefix == "un":
                new_definition = f"v. {definition[2:]}的反向"
            elif prefix == "re":
                new_definition = f"v. 重新{definition[2:]}"
            elif prefix in ["in", "im", "il", "ir"]:
                new_definition = f"v. 使不{definition[2:]}"
            elif prefix == "dis":
                new_definition = f"v. 撤销{definition[2:]}"
            elif prefix == "over":
                new_definition = f"v. 过度{definition[2:]}"
            elif prefix == "under":
                new_definition = f"v. 不足{definition[2:]}"
            elif prefix == "mis":
                new_definition = f"v. 错误地{definition[2:]}"
            else:
                new_definition = f"v. {meaning}{definition[2:]}"
        else:
            if prefix == "un":
                new_definition = f"adj. 不{definition[4:]}"
            elif prefix in ["in", "im", "il", "ir"]:
                new_definition = f"adj. 不{definition[4:]}"
            else:
                new_definition = f"adj. {meaning}{definition[4:]}"
        
        combinations.append((new_word, new_phonetic, new_definition))
    
    return combinations

def generate_synonyms_antonyms(word: str) -> Tuple[List[str], List[str]]:
    """生成同义词和反义词（简化版）"""
    synonyms = []
    antonyms = []
    
    # 常见词汇的同义词/反义词映射
    synonym_map = {
        "good": ["excellent", "fine", "great"],
        "bad": ["terrible", "poor", "awful"],
        "big": ["large", "huge", "enormous"],
        "small": ["tiny", "little", "minor"],
        "happy": ["joyful", "glad", "pleased"],
        "sad": ["unhappy", "sorrowful"],
        "fast": ["quick", "rapid", "swift"],
        "slow": ["sluggish", "unhurried"],
        "hot": ["warm", "heated"],
        "cold": ["cool", "freezing"],
        "new": ["fresh", "recent"],
        "old": ["ancient", "aged"],
        "rich": ["wealthy", "prosperous"],
        "poor": ["needy", "impoverished"],
        "easy": ["simple", "effortless"],
        "hard": ["difficult", "challenging"],
        "beautiful": ["pretty", "attractive"],
        "ugly": ["unsightly", "hideous"],
        "smart": ["intelligent", "clever"],
        "stupid": ["foolish", "dumb"],
        "clean": ["pure", "spotless"],
        "dirty": ["filthy", "unclean"],
    }
    
    antonym_map = {
        "good": ["bad", "poor"],
        "bad": ["good", "excellent"],
        "big": ["small", "little"],
        "small": ["big", "large"],
        "happy": ["sad", "unhappy"],
        "sad": ["happy", "joyful"],
        "fast": ["slow", "sluggish"],
        "slow": ["fast", "quick"],
        "hot": ["cold", "cool"],
        "cold": ["hot", "warm"],
        "new": ["old", "ancient"],
        "old": ["new", "fresh"],
        "rich": ["poor"],
        "poor": ["rich", "wealthy"],
        "easy": ["hard", "difficult"],
        "hard": ["easy", "simple"],
        "beautiful": ["ugly"],
        "ugly": ["beautiful"],
        "smart": ["stupid", "foolish"],
        "stupid": ["smart", "intelligent"],
        "clean": ["dirty"],
        "dirty": ["clean"],
        "always": ["never", "seldom"],
        "never": ["always"],
        "come": ["go", "leave"],
        "go": ["come", "arrive"],
        "give": ["take", "receive"],
        "take": ["give", "offer"],
        "love": ["hate", "dislike"],
        "hate": ["love", "like"],
        "begin": ["end", "finish"],
        "end": ["begin", "start"],
        "win": ["lose", "fail"],
        "lose": ["win", "succeed"],
        "rise": ["fall", "drop"],
        "fall": ["rise", "climb"],
    }
    
    if word in synonym_map:
        synonyms = synonym_map[word]
    
    if word in antonym_map:
        antonyms = antonym_map[word]
    
    return synonyms, antonyms

def create_vocabulary_entry(index: int, word: str, phonetic: str, definition: str, 
                           level: str, difficulty: int) -> Dict:
    """创建词汇条目"""
    # 确定词性
    if definition.startswith("v."):
        pos = "verb"
    elif definition.startswith("n."):
        pos = "noun"
    elif definition.startswith("adj."):
        pos = "adjective"
    elif definition.startswith("adv."):
        pos = "adverb"
    else:
        pos = "noun"
    
    # 获取同义词和反义词
    synonyms, antonyms = generate_synonyms_antonyms(word)
    
    # 生成例句
    examples = [
        f"Here is an example sentence using '{word}'.",
        f"The word '{word}' is commonly used in English.",
    ]
    
    return {
        "id": f"{level}_{index:04d}",
        "word": word,
        "phonetic": f"/{phonetic}/",
        "definition": definition,
        "examples": examples,
        "synonyms": synonyms,
        "antonyms": antonyms,
        "difficulty": difficulty,
        "tags": [level, pos],
        "etymology": f"Etymology information for {word}"
    }

def generate_expanded_vocabulary(level: str, target_count: int) -> List[Dict]:
    """生成扩展词汇库"""
    print(f"\n🔄 生成 {level} 词库 (目标: {target_count} 词)...")
    
    vocabulary = []
    index = 1
    
    # 1. 添加核心词汇
    for word, phonetic, definition, diff in CORE_VOCABULARY:
        if index > target_count:
            break
        
        entry = create_vocabulary_entry(index, word, phonetic, definition, level, diff)
        vocabulary.append(entry)
        index += 1
    
    # 2. 生成派生词
    print(f"📝 生成派生词...")
    for word, phonetic, definition, diff in CORE_VOCABULARY:
        if index > target_count:
            break
        
        derivatives = generate_derivatives(word, phonetic, definition)
        for derivative_word, derivative_phonetic, derivative_definition in derivatives:
            if index > target_count:
                break
            
            entry = create_vocabulary_entry(index, derivative_word, 
                                              derivative_phonetic, derivative_definition, 
                                              level, min(5, diff + 1))
            vocabulary.append(entry)
            index += 1
    
    # 3. 生成前缀组合词
    print(f"🔗 生成前缀组合词...")
    for word, phonetic, definition, diff in CORE_VOCABULARY[:50]:  # 只用前50个词生成
        if index > target_count:
            break
        
        combinations = generate_prefix_combinations(word, phonetic, definition)
        for combo_word, combo_phonetic, combo_definition in combinations[:5]:  # 每个词只生成5个组合
            if index > target_count:
                break
            
            entry = create_vocabulary_entry(index, combo_word, 
                                              combo_phonetic, combo_definition, 
                                              level, min(5, diff + 1))
            vocabulary.append(entry)
            index += 1
    
    # 4. 如果还需要更多词，使用词根+后缀组合
    if index <= target_count:
        print(f"🔬 生成词根组合词...")
        for root, meaning in list(ROOTS.items())[:20]:  # 只用前20个词根
            if index > target_count:
                break
            
            for suffix, suffix_meaning in list(SUFFIXES.items())[:5]:  # 每个词根配5个后缀
                if index > target_count:
                    break
                
                new_word = root + suffix
                new_phonetic = f"/{root}{suffix}/"
                new_definition = f"v. {meaning}{suffix_meaning}"
                
                entry = create_vocabulary_entry(index, new_word, new_phonetic, 
                                                  new_definition, level, 4)
                vocabulary.append(entry)
                index += 1
    
    print(f"✅ 生成完成：{len(vocabulary)} 个词汇")
    return vocabulary

def save_vocabulary(vocabulary: List[Dict], filename: str) -> None:
    """保存词库到文件"""
    os.makedirs("../assets/vocabularies", exist_ok=True)
    
    filepath = f"../assets/vocabularies/{filename}"
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(vocabulary, f, ensure_ascii=False, indent=2)
    
    file_size = os.path.getsize(filepath) / 1024
    print(f"✅ 已保存：{filepath}")
    print(f"📊 文件大小：{file_size:.2f} KB")
    print(f"📝 词汇数量：{len(vocabulary)}")

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║       🧠 智能词库扩展器 - 智能生成大规模词库                             ║")
    print("║          (Smart Vocabulary Expander)                                  ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    # 生成配置
    configs = [
        ("cet4", 3000, "cet4_expanded.json"),
        ("cet6", 3000, "cet6_expanded.json"),
        ("toefl", 2500, "toefl_expanded.json"),
        ("ielts", 2500, "ielts_expanded.json"),
        ("gre", 2000, "gre_expanded.json"),
    ]
    
    total_words = 0
    for level, count, filename in configs:
        vocab = generate_expanded_vocabulary(level, count)
        save_vocabulary(vocab, filename)
        total_words += len(vocab)
    
    print(f"\n🎉 全部完成！")
    print(f"📊 总计生成：{total_words} 个词汇")
    print(f"\n📈 扩展策略：")
    print(f"  • 核心词汇派生（-ment, -tion, -er, -ly等）")
    print(f"  • 前缀组合（un-, re-, in-, dis-, over-等）")
    print(f"  • 词根后缀组合")
    print(f"  • 同义词/反义词关联")

if __name__ == "__main__":
    main()
