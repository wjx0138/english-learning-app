#!/usr/bin/env python3
"""
大规模词库生成器 - 生成完整规模的词库
目标: CET4(4500), CET6(6000), TOEFL(8000), IELTS(7500), GRE(12000)
"""

import json
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from comprehensive_vocabulary_database import COMPREHENSIVE_VOCABULARY

# 扩展词汇库 - 添加更多高级词汇
EXTENDED_VOCABULARY = {
    # C字母词汇（部分示例，实际应该更多）
    "cabbage": ("ˈkæbɪdʒ", "n. 卷心菜", 2, "cet4"),
    "cabin": ("ˈkæbɪn", "n. 小屋", 3, "cet4"),
    "cabinet": ("ˈkæbɪnət", "n. 内阁；储藏柜", 3, "cet4"),
    "cable": ("ˈkeɪbl", "n. 电缆", 3, "cet4"),
    "cafe": ("kæˈfeɪ", "n. 咖啡馆", 2, "cet4"),
    "cafeteria": ("ˌkæfəˈtɪəriə", "n. 自助餐厅", 3, "cet4"),
    "cage": ("keɪdʒ", "n. 笼子", 2, "cet4"),
    "cake": ("keɪk", "n. 蛋糕", 1, "cet4"),
    "calculate": ("ˈkælkjʊleɪt", "v. 计算", 3, "cet4"),
    "calculator": ("ˈkælkjʊleɪtər", "n. 计算器", 3, "cet4"),
    "calendar": ("ˈkælɪndər", "n. 日历", 2, "cet4"),
    "calf": ("kɑːf", "n. 小牛；小腿", 2, "cet4"),
    "call": ("kɔːl", "v./n. 打电话；呼叫", 1, "cet4"),
    "calm": ("kɑːm", "adj. 冷静的 v. 使平静", 2, "cet4"),
    "camera": ("ˈkæmərə", "n. 照相机", 2, "cet4"),
    "camp": ("kæmp", "n./v. 露营", 2, "cet4"),
    "campaign": ("kæmˈpeɪn", "n. 运动；战役", 3, "cet4"),
    "campus": ("ˈkæmpəs", "n. 校园", 3, "cet4"),
    "can": ("kæn", "aux./v. 能；可以", 1, "cet4"),
    "canal": ("kəˈnæl", "n. 运河", 2, "cet4"),
    "cancel": ("ˈkænsəl", "v. ��消", 3, "cet4"),
    "cancer": ("ˈkænsər", "n. 癌症", 3, "cet4"),
    "candidate": ("ˈkændɪdeɪt", "n. 候选人", 3, "cet4"),
    "candle": ("ˈkændl", "n. 蜡烛", 2, "cet4"),
    "candy": ("ˈkændi", "n. 糖果", 2, "cet4"),
    "cap": ("kæp", "n. 帽子", 1, "cet4"),
    "capable": ("ˈkeɪpəbl", "adj. 有能力的", 3, "cet4"),
    "capacity": ("kəˈpæsəti", "n. 容量；能力", 3, "cet4"),
    "capital": ("ˈkæpɪtl", "n./adj. 首都；资本的", 3, "cet4"),
    "captain": ("ˈkæptɪn", "n. 船长；队长", 2, "cet4"),
    "capture": ("ˈkæptʃər", "v. 捕获", 3, "cet4"),
    "car": ("kɑːr", "n. 汽车", 1, "cet4"),
    "carbon": ("ˈkɑːrbən", "n. 碳", 3, "cet4"),
    "card": ("kɑːrd", "n. 卡片", 2, "cet4"),
    "care": ("keər", "n. 照料 v. 关心", 2, "cet4"),
    "career": ("kəˈrɪər", "n. 职业", 3, "cet4"),
    "careful": ("ˈkeərfl", "adj. 小心的", 2, "cet4"),
    "careless": ("ˈkeərləs", "adj. 粗心的", 3, "cet4"),
    "cargo": ("ˈkɑːrɡəʊ", "n. 货物", 3, "cet4"),
    "carpenter": ("ˈkɑːrpəntər", "n. 木匠", 3, "cet4"),
    "carpet": ("ˈkɑːrpɪt", "n. 地毯", 2, "cet4"),
    "carriage": ("ˈkærɪdʒ", "n. 马车；车厢", 3, "cet4"),
    "carry": ("ˈkæri", "v. 携带", 2, "cet4"),
    "cart": ("kɑːrt", "n. 手推车", 2, "cet4"),
    "cartoon": ("kɑːrˈtuːn", "n. 卡通", 2, "cet4"),
    "carve": ("kɑːrv", "v. 雕刻", 3, "cet4"),
    "case": ("keɪs", "n. 情况；箱子", 2, "cet4"),
    "cash": ("kæʃ", "n. 现金", 2, "cet4"),
    "cashier": ("kæˈʃɪr", "n. 收银员", 3, "cet4"),
    "cast": ("kæst", "v. 投掷", 3, "cet4"),
    "castle": ("ˈkæsl", "n. 城堡", 2, "cet4"),
    "casual": ("ˈkæʒuəl", "adj. 随意的", 3, "cet4"),
    "cat": ("kæt", "n. 猫", 1, "cet4"),
    "catalog": ("ˈkætəlɔːɡ", "n. 目录", 3, "cet4"),
    "catch": ("kætʃ", "v. 抓住", 2, "cet4"),
    "category": ("ˈkætəɡri", "n. 类别", 3, "cet4"),
    "catholic": ("ˈkæθlɪk", "adj. 天主教的", 3, "cet4"),
    "cattle": ("ˈkætl", "n. 牲口", 3, "cet4"),
    "cause": ("kɔːz", "n./v. 原因；导致", 3, "cet4"),
    "caution": ("ˈkɔːʃn", "n. 小心", 3, "cet4"),
    "cautious": ("ˈkɔːʃəs", "adj. 谨慎的", 4, "cet6"),
    "cave": ("keɪv", "n. 洞穴", 2, "cet4"),
    "cease": ("siːs", "v. 停止", 4, "cet6"),
    "ceiling": ("ˈsiːlɪŋ", "n. 天花板", 2, "cet4"),
    "celebrate": ("ˈselɪbreɪt", "v. 庆祝", 3, "cet4"),
    "celebration": ("ˌselɪˈbreɪʃn", "n. 庆祝", 3, "cet4"),
    "cell": ("sel", "n. 细胞；牢房", 2, "cet4"),
    "cellar": ("ˈselər", "n. 地窖", 3, "cet4"),
    "cement": ("sɪˈment", "n. 水泥", 3, "cet4"),
    "cemetery": ("ˈseməteri", "n. 墓地", 3, "cet4"),
    "census": ("ˈsensəs", "n. 人口普查", 4, "cet6"),
    "cent": ("sent", "n. 分", 1, "cet4"),
    "center": ("ˈsentər", "n. 中心 v. 集中", 2, "cet4"),
    "central": ("ˈsentrəl", "adj. 中心的", 3, "cet4"),
    "century": ("ˈsentʃri", "n. 世纪", 2, "cet4"),
    "ceremony": ("ˈserəməni", "n. 仪式", 4, "cet6"),
    "certain": ("ˈsɜːrtn", "adj. 确定的", 2, "cet4"),
    "certainly": ("ˈsɜːrtnli", "adv. 当然", 2, "cet4"),
    "certificate": ("sərˈtɪfɪkət", "n. 证书", 3, "cet4"),
    "chain": ("tʃeɪn", "n. 链条", 2, "cet4"),
    "chair": ("tʃeər", "n. 椅子", 2, "cet4"),
    "chairman": ("ˈtʃeərmən", "n. 主席", 3, "cet4"),
    "chalk": ("tʃɔːk", "n. 粉笔", 2, "cet4"),
    "challenge": ("ˈtʃælɪndʒ", "n./v. 挑战", 3, "cet4"),
    "chamber": ("ˈtʃeɪmbər", "n. 房间；室", 3, "cet4"),
    "champion": ("ˈtʃæmpiən", "n. 冠军", 3, "cet4"),
    "chance": ("tʃæns", "n. 机会", 2, "cet4"),
    "change": ("tʃeɪndʒ", "n./v. 改变", 1, "cet4"),
    "changeable": ("ˈtʃeɪndʒəbl", "adj. 可变的", 3, "cet4"),
    "channel": ("ˈtʃænəl", "n. 频道；海峡", 2, "cet4"),
    "chapter": ("ˈtʃæptər", "n. 章节", 3, "cet4"),
    "character": ("ˈkærəktər", "n. 性格；角色", 3, "cet4"),
    "characteristic": ("ˌkærəktəˈrɪstɪk", "n. 特征", 4, "cet6"),
    "charge": ("tʃɑːrdʒ", "n./v. 费用；控告；充电", 2, "cet4"),
    "charity": ("ˈtʃærəti", "n. 慈善", 3, "cet4"),
    "charm": ("tʃɑːrm", "n. 魅力", 3, "cet4"),
    "chart": ("tʃɑːrt", "n. 图表", 2, "cet4"),
    "charter": ("ˈtʃɑːrtər", "n. 宪章 v. 包租", 4, "cet6"),
    "chase": ("tʃeɪs", "v./n. 追赶", 3, "cet4"),
    "chat": ("tʃæt", "v./n. 聊天", 2, "cet4"),
    "cheap": ("tʃiːp", "adj. 便宜的", 2, "cet4"),
    "cheat": ("tʃiːt", "v./n. 欺骗", 3, "cet4"),
    "check": ("tʃek", "v./n. 检查", 1, "cet4"),
    "cheek": ("tʃiːk", "n. 脸颊", 2, "cet4"),
    "cheer": ("tʃɪər", "v. 欢呼", 2, "cet4"),
    "cheese": ("tʃiːz", "n. 奶酪", 2, "cet4"),
    "chef": ("ʃef", "n. 厨师", 2, "cet4"),
    "chemical": ("ˈkemɪkl", "adj. 化学的", 4, "cet6"),
    "chemist": ("ˈkemɪst", "n. 化学家；药剂师", 3, "cet4"),
    "chemistry": ("ˈkemɪstri", "n. 化学", 4, "cet6"),
    "cheque": ("tʃek", "n. 支票", 2, "cet4"),
    "cherish": ("ˈtʃerɪʃ", "v. 珍爱", 4, "cet6"),
    "cherry": ("ˈtʃeri", "n. 樱桃", 2, "cet4"),
    "chess": ("tʃes", "n. 国际象棋", 2, "cet4"),
    "chest": ("tʃest", "n. 胸腔", 2, "cet4"),
    "chew": ("tʃuː", "v. 咀嚼", 2, "cet4"),
    "chicken": ("ˈtʃɪkɪn", "n. 鸡肉", 2, "cet4"),
    "chief": ("tʃiːf", "n./adj. 首领；主要的", 3, "cet4"),
    "child": ("tʃaɪld", "n. 孩子", 1, "cet4"),
    "childhood": ("ˈtʃaɪldhʊd", "n. 童年", 2, "cet4"),
    "chocolate": ("ˈtʃɒklət", "n. 巧克力", 2, "cet4"),
    "choice": ("tʃɔɪs", "n. 选择", 2, "cet4"),
    "choose": ("tʃuːz", "v. 选择", 2, "cet4"),
    "choke": ("tʃəʊk", "v. 窒息", 3, "cet4"),
    "choose": ("tʃuːz", "v. 选择", 2, "cet4"),
    "church": ("tʃɜːtʃ", "n. 教堂", 2, "cet4"),
    "cigarette": ("ˌsɪɡəˈret", "n. 香烟", 2, "cet4"),
    "cinema": ("ˈsɪnəmə", "n. 电影院", 2, "cet4"),
    "circle": ("ˈsɜːrkl", "n. 圆圈", 2, "cet4"),
    "circumstance": ("ˈsɜːmkənstæns", "n. 环境；情况", 4, "cet6"),
    "circus": ("ˈsɜːrkəs", "n. 马戏团", 2, "cet4"),
    "cite": ("saɪt", "v. 引用", 3, "cet4"),
    "citizen": ("ˈsɪtɪzn", "n. 公民", 3, "cet4"),
    "city": ("ˈsɪti", "n. 城市", 2, "cet4"),
    "civil": ("ˈsɪvl", "adj. 文明的；民用的", 3, "cet4"),
    "civilian": ("səˈvɪliən", "n. 平民", 3, "cet4"),
    "civilization": ("ˌsɪvəlaɪˈzeɪʃn", "n. 文明", 4, "cet6"),
    "claim": ("kleɪm", "v./n. 声称；索赔", 3, "cet4"),
    "clap": ("klæp", "v./n. 拍手", 2, "cet4"),
    "clarify": ("ˈklærəfaɪ", "v. 澄清", 4, "cet6"),
    "clash": ("klæʃ", "v./n. 冲突", 3, "cet4"),
    "class": ("klæs", "n. 班级；阶级", 1, "cet4"),
    "classic": ("ˈklæsɪk", "adj. 经典的", 3, "cet4"),
    "classical": ("ˈklæsɪkl", "adj. 古典的", 3, "cet4"),
    "classification": ("ˌklæsɪfɪˈkeɪʃn", "n. 分类", 4, "cet6"),
    "classify": ("ˈklæsɪfaɪ", "v. 分类", 4, "cet6"),
    "classmate": ("ˈklæsmeɪt", "n. 同班同学", 2, "cet4"),
    "classroom": ("ˈklæsruːm", "n. 教室", 2, "cet4"),
    "clean": ("kliːn", "adj. 干净的 v. 打扫", 2, "cet4"),
    "clear": ("klɪər", "adj. 清楚的 v. 清除", 2, "cet4"),
    "clerk": ("klɜːrk", "n. 店员；办事员", 2, "cet4"),
    "clever": ("ˈklevər", "adj. 聪明的", 2, "cet4"),
    "click": ("klɪk", "v./n. 点击", 2, "cet4"),
    "client": ("ˈklaɪənt", "n. 客户", 3, "cet4"),
    "cliff": ("klɪf", "n. 悬崖", 2, "cet4"),
    "climate": ("ˈklaɪmət", "n. 气候", 3, "cet4"),
    "climb": ("klaɪm", "v. 爬", 2, "cet4"),
    "clock": ("klɒk", "n. 时钟", 2, "cet4"),
    "close": ("kləʊz", "adj./v. 关闭的；靠近", 1, "cet4"),
    "closet": ("ˈklɒzɪt", "n. 壁橱", 2, "cet4"),
    "cloth": ("klɒθ", "n. 布料", 2, "cet4"),
    "clothes": ("kləʊðz", "n. 衣服", 2, "cet4"),
    "clothing": ("ˈkləʊðɪŋ", "n. 衣服（总称）", 2, "cet4"),
    "cloud": ("klaʊd", "n. 云", 2, "cet4"),
    "cloudy": ("ˈklaʊdi", "adj. 多云的", 2, "cet4"),
    "club": ("klʌb", "n. 俱乐部", 2, "cet4"),
    "clue": ("kluː", "n. 线索", 2, "cet4"),
    "coach": ("kəʊtʃ", "n. 教练；长途车", 2, "cet4"),
    "coal": ("kəʊl", "n. 煤", 2, "cet4"),
    "coast": ("kəʊst", "n. 海岸", 2, "cet4"),
    "coat": ("kəʊt", "n. 外套", 2, "cet4"),
    "cock": ("kɒk", "n. 公鸡", 2, "cet4"),
    "code": ("kəʊd", "n. 代码；准则", 2, "cet4"),
    "coffee": ("ˈkɒfi", "n. 咖啡", 2, "cet4"),
    "coil": ("kɔɪl", "n. 线圈", 3, "cet4"),
    "coin": ("kɔɪn", "n. 硬币", 2, "cet4"),
    "cold": ("kəʊld", "adj. 冷的", 1, "cet4"),
    "collar": ("ˈkɒlər", "n. 衣领", 3, "cet4"),
    "colleague": ("ˈkɒliːɡ", "n. 同事", 3, "cet4"),
    "collect": ("kəˈlekt", "v. 收集", 3, "cet4"),
    "collection": ("kəˈlekʃn", "n. 收集；收藏", 3, "cet4"),
    "collective": ("kəˈlektɪv", "adj. 集体的", 4, "cet6"),
    "college": ("ˈkɒlɪdʒ", "n. 大学", 2, "cet4"),
    "collision": ("kəˈlɪʒn", "n. 碰撞", 4, "cet6"),
    "color": ("ˈkʌlər", "n. 颜色", 2, "cet4"),
    "column": ("ˈkɒləm", "n. 柱；专栏", 2, "cet4"),
    "comb": ("kəʊm", "n. 梳子 v. 梳", 2, "cet4"),
    "combat": ("ˈkɒmbæt", "n./v. 战斗", 4, "cet6"),
    "combine": ("kəmˈbaɪn", "v. 结合", 3, "cet4"),
    "combination": ("ˌkɒmbɪˈneɪʃn", "n. 结合", 4, "cet6"),
    "combine": ("kəmˈbaɪn", "v. 结合", 3, "cet4"),
    "comfort": ("ˈkʌmfət", "n. 舒适 v. 安慰", 3, "cet4"),
    "comfortable": ("ˈkʌmfətəbl", "adj. 舒适的", 3, "cet4"),
    "command": ("kəˈmɑːnd", "n./v. 命令；指挥", 3, "cet4"),
    "commander": ("kəˈmændər", "n. 指挥官", 3, "cet4"),
    "comment": ("ˈkɒment", "n./v. 评论", 2, "cet4"),
    "commercial": ("kəˈmɜːʃl", "adj. 商业的", 4, "cet6"),
    "common": ("ˈkɒmən", "adj. 共同的；普通的", 2, "cet4"),
    "communicate": ("kəˈmjuːnɪkeɪt", "v. 交流", 4, "cet6"),
    "communication": ("kəˌmjuːnɪˈkeɪʃn", "n. 交流", 4, "cet6"),
    "communism": ("ˈkɒmjʊnɪzəm", "n. 共产主义", 3, "cet4"),
    "community": ("kəˈmjuːnəti", "n. 社区", 3, "cet4"),
    "company": ("ˈkʌmpəni", "n. 公司；陪伴", 2, "cet4"),
    "compare": ("kəmˈpeər", "v. 比较", 3, "cet4"),
    "comparison": ("kəmˈpærɪsn", "n. 比较", 4, "cet6"),
    "compete": ("kəmˈpiːt", "v. 竞争", 3, "cet4"),
    "competition": ("ˌkɒmpəˈtɪʃn", "n. 竞争", 4, "cet6"),
    "complete": ("kəmˈpliːt", "adj./v. 完整的", 2, "cet4"),
    "complex": ("ˈkɒmpleks", "adj. 复杂的", 4, "cet6"),
    "complicated": ("ˈkɒmplɪkeɪtɪd", "adj. 复杂的", 4, "cet6"),
    "component": ("kəmˈpəʊnənt", "n. 成分", 4, "cet6"),
    "compose": ("kəmˈpəʊz", "v. 组成；作曲", 3, "cet4"),
    "composition": ("ˌkɒmpəˈzɪʃn", "n. 作文；作品", 4, "cet6"),
    "compound": ("ˈkɒmpaʊnd", "n. 化合物 adj. 复合的", 4, "cet6"),
    "comprehension": ("ˌkɒmprɪˈhenʃn", "n. 理解", 4, "cet6"),
    "comprehensive": ("ˌkɒmprɪˈhensɪv", "adj. 综合的", 5, "gre"),
    "compress": ("kəmˈpres", "v. 压缩", 4, "cet6"),
    "comprise": ("kəmˈpraɪz", "v. 包含", 4, "cet6"),
    "compromise": ("ˈkɒmprəmaɪz", "n./v. 妥协", 4, "cet6"),
    "compute": ("kəmˈpjuːt", "v. 计算", 3, "cet4"),
    "computer": ("kəmˈpjuːtər", "n. 计算机", 3, "cet4"),
    "comrade": ("ˈkɒmreɪd", "n. 同志", 3, "cet4"),
    "concentrate": ("ˈkɒnsntreɪt", "v. 集中", 3, "cet4"),
    "concept": ("ˈkɒnsept", "n. 概念", 3, "cet4"),
    "concern": ("kənˈsɜːn", "n./v. 关心；担心", 3, "cet4"),
    "concert": ("ˈkɒnsət", "n. 音乐会", 3, "cet4"),
    "conclude": ("kənˈkluːd", "v. 推断；结束", 4, "cet6"),
    "conclusion": ("kənˈkluːʒn", "n. 结论", 4, "cet6"),
    "concrete": ("ˈkɒnkriːt", "n. 混凝土 adj. 具体的", 3, "cet4"),
    "condemn": ("kənˈdem", "v. 谴责", 4, "cet6"),
    "condition": ("kənˈdɪʃn", "n. 条件", 3, "cet4"),
    "conduct": ("kənˈdʌkt", "v./n. 行为；指挥", 3, "cet4"),
    "conductor": ("kənˈdʌktər", "n. 售票员；指挥", 3, "cet4"),
    "conference": ("ˈkɒnfərəns", "n. 会议", 3, "cet4"),
    "confess": ("kənˈfes", "v. 忏悔；承认", 3, "cet4"),
    "confidence": ("ˈkɒnfɪdəns", "n. 自信；信任", 3, "cet4"),
    "confident": ("ˈkɒnfɪdənt", "adj. 自信的", 3, "cet4"),
    "confine": ("kənˈfaɪn", "v. 限制", 4, "cet6"),
    "confirm": ("kənˈfɜːm", "v. 确认", 3, "cet4"),
    "conflict": ("ˈkɒnflɪkt", "n. 冲突", 3, "cet4"),
    "confuse": ("kənˈfjuːz", "v. 使困惑", 3, "cet4"),
    "congratulate": ("kənˈɡrætjʊleɪt", "v. 祝贺", 4, "cet6"),
    "congratulation": ("kənˌɡrætjʊˈleɪʃn", "n. 祝贺", 4, "cet6"),
    "congress": ("ˈkɒŋɡres", "n. 国会；代表大会", 3, "cet4"),
    "connect": ("kəˈnekt", "v. 连接", 3, "cet4"),
    "connection": ("kəˈnekʃn", "n. 连接", 3, "cet4"),
    "conquer": ("ˈkɒŋkər", "v. 征服", 3, "cet4"),
    "conquest": ("ˈkɒŋkwest", "n. 征服", 3, "cet4"),
    "conscience": ("ˈkɒnʃəns", "n. 良心", 4, "cet6"),
    "conscious": ("ˈkɒnʃəs", "adj. 有意识的", 4, "cet6"),
    "consent": ("kənˈsent", "n./v. 同意", 3, "cet4"),
    "consequence": ("ˈkɒnsɪkwens", "n. 结果", 4, "cet6"),
    "consequently": ("ˈkɒnsɪkwəntli", "adv. 因此", 4, "cet6"),
    "conservation": ("ˌkɒnsəˈveɪʃn", "n. 保存", 4, "cet6"),
    "conservative": ("kənˈsɜːvətɪv", "adj. 保守的", 4, "cet6"),
    "consider": ("kənˈsɪdər", "v. 考虑", 3, "cet4"),
    "considerable": ("kənˈsɪdərəbl", "adj. 相当大的", 4, "cet6"),
    "considerate": ("kənˈsɪdərət", "adj. 体贴的", 4, "cet6"),
    "consideration": ("kənˌsɪdəˈreɪʃn", "n. 考虑", 4, "cet6"),
    "consist": ("kənˈsɪst", "v. 由...组成", 3, "cet4"),
    "consistent": ("kənˈsɪstənt", "adj. 一致的", 4, "cet6"),
    "constant": ("ˈkɒnstənt", "adj. 持续的", 3, "cet4"),
    "constitution": ("ˌkɒnstɪˈtjuːʃn", "n. 宪法；构成", 4, "cet6"),
    "construct": ("kənˈstrʌkt", "v. 建造 n. 构造物", 3, "cet4"),
    "construction": ("kənˈstrʌkʃn", "n. 建设", 4, "cet6"),
    "consult": ("kənˈsʌlt", "v. 咨询", 4, "cet6"),
    "consultant": ("kənˈsʌltənt", "n. 顾问", 4, "cet6"),
    "consume": ("kənˈsjuːm", "v. 消费", 3, "cet4"),
    "consumer": ("kənˈsjuːmər", "n. 消费者", 3, "cet4"),
    "contact": ("ˈkɒntækt", "n./v. 接触", 3, "cet4"),
    "contain": ("kənˈteɪn", "v. 包含", 3, "cet4"),
    "container": ("kənˈteɪnər", "n. 容器", 3, "cet4"),
    "contemporary": ("kənˈtempəreri", "adj. 当代的", 5, "gre"),
    "content": ("ˈkɒntent", "n. 内容", 2, "cet4"),
    "contest": ("ˈkɒntest", "n./v. 竞赛", 3, "cet4"),
    "context": ("ˈkɒntekst", "n. 上下文", 4, "cet6"),
    "continent": ("ˈkɒntɪnənt", "n. 大陆", 3, "cet4"),
    "continue": ("kənˈtɪnjuː", "v. 继续", 2, "cet4"),
    "continuous": ("kənˈtɪnjuəs", "adj. 连续的", 4, "cet6"),
    "contract": ("ˈkɒntrækt", "n. 合同 v. 收缩", 3, "cet4"),
    "contradiction": ("ˌkɒntrəˈdɪkʃn", "n. 矛盾", 4, "cet6"),
    "contrary": ("ˈkɒntrəri", "adj./n. 相反", 4, "cet6"),
    "contrast": ("ˈkɒntræst", "n./v. 对比", 4, "cet6"),
    "contribute": ("kənˈtrɪbjuːt", "v. 贡献", 4, "cet6"),
    "control": ("kənˈtrəʊl", "v./n. 控制", 3, "cet4"),
    "convenience": ("kənˈviːniəns", "n. 便利", 4, "cet6"),
    "convenient": ("kənˈviːniənt", "adj. 方便的", 4, "cet6"),
    "convention": ("kənˈvenʃn", "n. 习俗；会议", 4, "cet6"),
    "conventional": ("kənˈvenʃənl", "adj. 传统的", 4, "cet6"),
    "conversation": ("ˌkɒnvəˈseɪʃn", "n. 对话", 4, "cet6"),
    "conversely": ("ˈkɒnvɜːsli", "adv. 相反地", 4, "cet6"),
    "convert": ("kənˈvɜːt", "v. 转变", 3, "cet4"),
    "conversion": ("kənˈvɜːʃn", "n. 转变", 4, "cet6"),
    "convey": ("kənˈveɪ", "v. 传达", 4, "cet6"),
    "convince": ("kənˈvɪns", "v. 说服", 4, "cet6"),
    "cook": ("kʊk", "v. 烹饪", 2, "cet4"),
    "cooker": ("ˈkʊkər", "n. 炊具", 2, "cet4"),
    "cookie": ("ˈkʊki", "n. 饼干", 2, "cet4"),
    "cool": ("kuːl", "adj. 凉的", 2, "cet4"),
    "cooperate": ("kəʊˈɒpəreɪt", "v. 合作", 4, "cet6"),
    "cooperation": ("kəʊˌɒpəˈreɪʃn", "n. 合作", 4, "cet6"),
    "coordinate": ("kəʊˈɔːdɪneɪt", "v. 协调", 4, "cet6"),
    "cope": ("kəʊp", "v. 应付", 3, "cet4"),
    "copy": ("ˈkɒpi", "n./v. 复制", 2, "cet4"),
    "core": ("kɔːr", "n. 核心", 2, "cet4"),
    "corn": ("kɔːrn", "n. 玉米", 2, "cet4"),
    "corner": ("ˈkɔːrnər", "n. 角落", 2, "cet4"),
    "corporation": ("ˌkɔːrpəˈreɪʃn", "n. 公司；法人", 4, "cet6"),
    "correct": ("kəˈrekt", "adj./v. 正确的；改正", 2, "cet4"),
    "correction": ("kəˈrekʃn", "n. 改正", 3, "cet4"),
    "correspond": ("ˌkɒrɪˈspɒnd", "v. 符合；通信", 4, "cet6"),
    "corresponding": ("ˌkɒrɪˈspɒndɪŋ", "adj. 相应的", 4, "cet6"),
    "cost": ("kɒst", "n. 成本 v. 花费", 2, "cet4"),
    "costly": ("ˈkɒstli", "adj. 昂贵的", 3, "cet4"),
    "cottage": ("ˈkɒtɪdʒ", "n. 小屋", 3, "cet4"),
    "cotton": ("ˈkɒtn", "n. 棉花", 2, "cet4"),
    "cough": ("kɒf", "n./v. 咳嗽", 2, "cet4"),
    "could": ("kʊd", "aux./v. 能", 1, "cet4"),
    "council": ("ˈkaʊnsɪl", "n. 委员会", 4, "cet6"),
    "counsel": ("ˈkaʊnsəl", "n./v. 建议；辅导", 4, "cet6"),
    "count": ("kaʊnt", "n./v. 计数", 2, "cet4"),
    "counter": ("ˈkaʊntər", "n. 柜台 adv. 相反", 3, "cet4"),
    "country": ("ˈkʌntri", "n. 国家", 2, "cet4"),
    "countryside": ("ˈkʌntrisaɪd", "n. 乡村", 3, "cet4"),
    "county": ("ˈkaʊnti", "n. 县", 3, "cet4"),
    "couple": ("ˈkʌpl", "n. 夫妇；一对", 2, "cet4"),
    "courage": ("ˈkʌrɪdʒ", "n. 勇气", 3, "cet4"),
    "course": ("kɔːs", "n. 课程；过程", 2, "cet4"),
    "court": ("kɔːrt", "n. 法庭；球场", 2, "cet4"),
    "cousin": ("ˈkʌzn", "n. 堂(表)兄弟", 3, "cet4"),
    "cover": ("ˈkʌvər", "v./n. 覆盖", 2, "cet4"),
    "cow": ("kaʊ", "n. 奶牛", 2, "cet4"),
    "coward": ("ˈkaʊərd", "n. 懦夫", 3, "cet4"),
    "crack": ("kræk", "n./v. 裂缝；破裂", 3, "cet4"),
    "craft": ("kræft", "n. 工艺；飞机", 3, "cet4"),
    "crane": ("kreɪn", "n. 鹤；起重机", 3, "cet4"),
    "crash": ("kræʃ", "v./n. 碰撞；崩溃", 3, "cet4"),
    "crazy": ("ˈkreɪzi", "adj. 疯狂的", 2, "cet4"),
    "cream": ("kriːm", "n. 奶油", 2, "cet4"),
    "create": ("kriˈeɪt", "v. 创造", 2, "cet4"),
    "creative": ("kriˈeɪtɪv", "adj. 有创造力的", 3, "cet4"),
    "creature": ("ˈkriːtʃər", "n. 生物", 3, "cet4"),
    "credit": ("ˈkredɪt", "n./v. 信用；学分", 3, "cet4"),
    "creep": ("kriːp", "v. 爬行", 3, "cet4"),
    "crew": ("kruː", "n. 全体船员", 3, "cet4"),
    "crime": ("kraɪm", "n. 罪行", 3, "cet4"),
    "criminal": ("ˈkrɪmɪnl", "adj. 刑事的 n. 罪犯", 3, "cet4"),
    "crisis": ("ˈkraɪsɪs", "n. 危机", 4, "cet6"),
    "critic": ("ˈkrɪtɪk", "n. 批评家 adj. 批评的", 4, "cet6"),
    "critical": ("ˈkrɪtɪkl", "adj. 批评的；关键的", 4, "cet6"),
    "criticism": ("ˈkrɪtɪsɪzəm", "n. 批评", 4, "cet6"),
    "criticize": ("ˈkrɪtɪsaɪz", "v. 批评", 3, "cet4"),
    "crop": ("krɒp", "n. 作物；收成", 3, "cet4"),
    "cross": ("krɒs", "n./v. 交叉；十字架", 2, "cet4"),
    "crowd": ("kraʊd", "n. 人群", 2, "cet4"),
    "crown": ("kraʊn", "n. 王冠", 2, "cet4"),
    "crucial": ("ˈkruːʃl", "adj. 至关重要的", 4, "cet6"),
    "cruel": ("ˈkruːəl", "adj. 残酷的", 3, "cet4"),
    "cruelty": ("ˈkruːəlti", "n. 残酷", 3, "cet4"),
    "crush": ("krʌʃ", "v. 压碎", 3, "cet4"),
    "crust": ("krʌst", "n. 地壳；面包皮", 3, "cet4"),
    "cry": ("kraɪ", "v./n. 哭泣", 2, "cet4"),
    "crystal": ("ˈkrɪstl", "n. 水晶", 3, "cet4"),
    "cube": ("kjuːb", "n. 立方体", 3, "cet4"),
    "cubic": ("ˈkjuːbɪk", "adj. 立方的", 3, "cet4"),
    "cultivate": ("ˈkʌltɪveɪt", "v. 耕作；培养", 4, "cet6"),
    "culture": ("ˈkʌltʃər", "n. 文化", 3, "cet4"),
    "cupboard": ("ˈkʌbərd", "n. 碗柜", 2, "cet4"),
    "cure": ("kjʊər", "v./n. 治愈", 2, "cet4"),
    "curiosity": ("ˌkjʊəriˈɒsəti", "n. 好奇心", 4, "cet6"),
    "curious": ("ˈkjʊəriəs", "adj. 好奇的", 3, "cet4"),
    "curl": ("kɜːrl", "n. 卷发 v. 卷曲", 3, "cet4"),
    "current": ("ˈkʌrənt", "adj. 当前的", 2, "cet4"),
    "currently": ("ˈkʌrəntli", "adv. 目前", 3, "cet4"),
    "curse": ("kɜːs", "n./v. 诅咒", 3, "cet4"),
    "curtain": ("ˈkɜːrtn", "n. 窗帘", 2, "cet4"),
    "curve": ("kɜːrv", "n. 曲线 v. 弯曲", 3, "cet4"),
    "cushion": ("ˈkʊʃn", "n. 垫子", 3, "cet4"),
    "custom": ("ˈkʌstəm", "n. 习俗；海关 adj. 定制的", 3, "cet4"),
    "customer": ("ˈkʌstəmər", "n. 顾客", 2, "cet4"),
    "customs": ("ˈkʌstəmz", "n. 海关", 3, "cet4"),
    "cut": ("kʌt", "v. 切", 1, "cet4"),
    "cycle": ("ˈsaɪkl", "n. 循环；自行车", 3, "cet4"),
}

# 合并所有词汇库
ALL_VOCABULARY = {**COMPREHENSIVE_VOCABULARY, **EXTENDED_VOCABULARY}

def get_words_by_level(level: str) -> List[tuple]:
    """根据级别获取词汇"""
    return [(word, data) for word, data in ALL_VOCABULARY.items() if data[3] == level]

def get_words_by_difficulty(min_diff: int, max_diff: int) -> List[tuple]:
    """根据难度获取词汇"""
    return [(word, data) for word, data in ALL_VOCABULARY.items() if min_diff <= data[2] <= max_diff]

def generate_vocabulary_file(level: str, count: int, output_file: str):
    """生成词库文件"""
    print(f"\n🔄 生成 {level} 词库 ({count} 词)...")
    
    # 获取适合该级别的词汇
    if level == "cet4":
        # CET4: difficulty 1-3
        words = get_words_by_difficulty(1, 3)
    elif level == "cet6":
        # CET6: difficulty 2-4
        words = get_words_by_difficulty(2, 4)
    elif level in ["toefl", "ielts"]:
        # TOEFL/IELTS: difficulty 2-5
        words = get_words_by_difficulty(2, 5)
    elif level == "gre":
        # GRE: difficulty 3-5
        words = get_words_by_difficulty(3, 5)
    else:
        words = list(ALL_VOCABULARY.items())
    
    # 限制数量
    if len(words) > count:
        words = words[:count]
    
    vocabulary = []
    for index, (word, (phonetic, definition, difficulty, vocab_level)) in enumerate(words, 1):
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
        
        entry = {
            "id": f"{level}_{index:04d}",
            "word": word,
            "phonetic": f"/{phonetic}/",
            "definition": definition,
            "examples": [f"Example sentence for '{word}'."],
            "synonyms": [],
            "antonyms": [],
            "difficulty": difficulty,
            "tags": [level, pos],
            "etymology": f"Etymology for {word}"
        }
        vocabulary.append(entry)
    
    # 保存文件
    os.makedirs("../assets/vocabularies", exist_ok=True)
    filepath = f"../assets/vocabularies/{output_file}"
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(vocabulary, f, ensure_ascii=False, indent=2)
    
    file_size = os.path.getsize(filepath) / 1024
    print(f"✅ 已保存：{filepath}")
    print(f"📊 文件大小：{file_size:.2f} KB")
    print(f"📝 词汇数量：{len(vocabulary)}")
    
    return vocabulary

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║          📚 大规模词库生成器 📚                                        ║")
    print("║              (Mega Vocabulary Generator)                                 ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    print(f"\n📖 词汇库总数: {len(ALL_VOCABULARY)}")
    print(f"📊 CET4词汇数: {len(get_words_by_level('cet4'))}")
    print(f"📊 CET6词汇数: {len(get_words_by_level('cet6'))}")
    print(f"📊 TOEFL词汇数: {len(get_words_by_level('toefl'))}")
    print(f"📊 GRE词汇数: {len(get_words_by_level('gre'))}")
    
    # 生成配置
    configs = [
        ("cet4", 2000, "cet4_massive.json"),
        ("cet6", 2000, "cet6_massive.json"),
        ("toefl", 1500, "toefl_massive.json"),
        ("ielts", 1500, "ielts_massive.json"),
        ("gre", 1000, "gre_massive.json"),
    ]
    
    total_words = 0
    for level, count, filename in configs:
        vocab = generate_vocabulary_file(level, count, filename)
        total_words += len(vocab)
    
    print(f"\n🎉 全部完成！")
    print(f"📊 总计生成：{total_words} 个词汇")

if __name__ == "__main__":
    main()
