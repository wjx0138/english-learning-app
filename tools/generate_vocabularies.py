#!/usr/bin/env python3
"""
生成高质量的英语学习词库
为TOEFL、IELTS、GRE、商务、科技、日常等课程创建示例词库
"""

import json
import os

# 词库数据目录
VOCAB_DIR = "../assets/vocabularies"

def generate_toefl_vocabulary():
    """生成TOEFL词汇 - 高���度学术词汇"""
    words = [
        # A-B (难度3-5)
        {
            "id": "toefl_001",
            "word": "abandon",
            "phonetic": "/əˈbændən/",
            "definition": "v. 遗弃；放弃；n. 放任，狂热",
            "examples": [
                "The captain gave the order to abandon ship.",
                "She decided to abandon her career in law."
            ],
            "synonyms": ["desert", "forsake", "relinquish"],
            "antonyms": ["keep", "maintain", "retain"],
            "difficulty": 3,
            "tags": ["toefl", "verb"]
        },
        {
            "id": "toefl_002",
            "word": "abbreviate",
            "phonetic": "/əˈbriːvieɪt/",
            "definition": "v. 缩写，缩短",
            "examples": [
                "The word 'doctor' is often abbreviated to 'Dr'.",
                "We need to abbreviate the meeting to stay on schedule."
            ],
            "synonyms": ["shorten", "condense", "abridge"],
            "antonyms": ["expand", "elaborate", "extend"],
            "difficulty": 4,
            "tags": ["toefl", "verb", "academic"]
        },
        {
            "id": "toefl_003",
            "word": "abdicate",
            "phonetic": "/ˈæbdɪkeɪt/",
            "definition": "v. 退位，放弃（职位、权力等）",
            "examples": [
                "The king was forced to abdicate after the revolution.",
                "He chose to abdicate his responsibilities to his successor."
            ],
            "synonyms": ["renounce", "relinquish", "waive"],
            "antonyms": ["assume", "claim", "undertake"],
            "difficulty": 5,
            "tags": ["toefl", "verb", "formal"]
        },
        {
            "id": "toefl_004",
            "word": "aberrant",
            "phonetic": "/æˈberənt/",
            "definition": "adj. 异常的，偏离正道的",
            "examples": [
                "The scientist noticed aberrant behavior in the experiment.",
                "Such aberrant results require further investigation."
            ],
            "synonyms": ["abnormal", "atypical", "anomalous"],
            "antonyms": ["normal", "typical", "standard"],
            "difficulty": 5,
            "tags": ["toefl", "adjective", "academic"]
        },
        {
            "id": "toefl_005",
            "word": "abhor",
            "phonetic": "/əbˈhɔːr/",
            "definition": "v. 憎恶，厌恶",
            "examples": [
                "She abhors any form of discrimination or prejudice.",
                "Most civilized people abhor violence and cruelty."
            ],
            "synonyms": ["detest", "loathe", "despise"],
            "antonyms": ["love", "adore", "cherish"],
            "difficulty": 4,
            "tags": ["toefl", "verb", "formal"]
        },
        # C-E (难度4-5)
        {
            "id": "toefl_006",
            "word": "cacophony",
            "phonetic": "/kəˈkɒfəni/",
            "definition": "n. 刺耳的声音，嘈杂声",
            "examples": [
                "The cacophony of car horns filled the street.",
                "A cacophony of alarms woke everyone up."
            ],
            "synonyms": ["discord", "dissonance", "noise"],
            "antonyms": ["harmony", "melody", "silence"],
            "difficulty": 5,
            "tags": ["toefl", "noun", "academic"]
        },
        {
            "id": "toefl_007",
            "word": "capitulate",
            "phonetic": "/kəˈpɪtʃuleɪt/",
            "definition": "v. （有条件）投降，屈服",
            "examples": [
                "The company finally capitulated to the workers' demands.",
                "She refused to capitulate despite intense pressure."
            ],
            "synonyms": ["surrender", "yield", "submit"],
            "antonyms": ["resist", "fight", "defy"],
            "difficulty": 5,
            "tags": ["toefl", "verb", "formal"]
        },
        {
            "id": "toefl_008",
            "word": "diligence",
            "phonetic": "/ˈdɪlɪdʒəns/",
            "definition": "n. 勤奋，努力",
            "examples": [
                "Her diligence and dedication led to her success.",
                "The teacher rewarded the students for their diligence."
            ],
            "synonyms": ["industriousness", "hard work", "perseverance"],
            "antonyms": ["laziness", "idleness", "negligence"],
            "difficulty": 4,
            "tags": ["toefl", "noun"]
        },
        {
            "id": "toefl_009",
            "word": "elucidate",
            "phonetic": "/ɪˈluːsɪdeɪt/",
            "definition": "v. 阐明，说明",
            "examples": [
                "The professor elucidated the complex theory.",
                "Let me elucidate this point with an example."
            ],
            "synonyms": ["clarify", "explain", "illuminate"],
            "antonyms": ["confuse", "obscure", "complicate"],
            "difficulty": 5,
            "tags": ["toefl", "verb", "academic"]
        },
        {
            "id": "toefl_010",
            "word": "ephemeral",
            "phonetic": "/ɪˈfemərəl/",
            "definition": "adj. 短暂的，瞬息的",
            "examples": [
                "Fame can be ephemeral in the entertainment industry.",
                "The beauty of cherry blossoms is ephemeral."
            ],
            "synonyms": ["transient", "fleeting", "short-lived"],
            "antonyms": ["permanent", "lasting", "enduring"],
            "difficulty": 5,
            "tags": ["toefl", "adjective", "literary"]
        },
        # F-I (难度4-5)
        {
            "id": "toefl_011",
            "word": "fabricate",
            "phonetic": "/ˈfæbrɪkeɪt/",
            "definition": "v. 捏造，伪造；建造",
            "examples": [
                "He was accused of fabricating evidence.",
                "The story was completely fabricated by the media."
            ],
            "synonyms": ["invent", "forge", "construct"],
            "antonyms": ["destroy", "demolish", "verify"],
            "difficulty": 4,
            "tags": ["toefl", "verb"]
        },
        {
            "id": "toefl_012",
            "word": "gratitude",
            "phonetic": "/ˈɡrætɪtjuːd/",
            "definition": "n. 感激，感谢",
            "examples": [
                "She expressed her gratitude for their help.",
                "We should show gratitude to those who support us."
            ],
            "synonyms": ["thankfulness", "appreciation", "gratefulness"],
            "antonyms": ["ingratitude", "ungratefulness", "thanklessness"],
            "difficulty": 3,
            "tags": ["toefl", "noun"]
        },
        {
            "id": "toefl_013",
            "word": "hypothesis",
            "phonetic": "/haɪˈpɒθəsɪs/",
            "definition": "n. 假设，假说",
            "examples": [
                "The scientist tested her hypothesis through experiments.",
                "We need to develop a hypothesis to explain this phenomenon."
            ],
            "synonyms": ["theory", "premise", "assumption"],
            "antonyms": ["fact", "reality", "conclusion"],
            "difficulty": 4,
            "tags": ["toefl", "noun", "academic"]
        },
        {
            "id": "toefl_014",
            "word": "implement",
            "phonetic": "/ˈɪmplɪment/",
            "definition": "v. 实施，执行；n. 工具",
            "examples": [
                "The company plans to implement new policies.",
                "We need tools to implement the changes effectively."
            ],
            "synonyms": ["execute", "carry out", "instrument"],
            "antonyms": ["neglect", "ignore", "abandon"],
            "difficulty": 3,
            "tags": ["toefl", "verb", "noun"]
        },
        # M-O (难度4-5)
        {
            "id": "toefl_015",
            "word": "mitigate",
            "phonetic": "/ˈmɪtɪɡeɪt/",
            "definition": "v. 减轻，缓和",
            "examples": [
                "We need strategies to mitigate the effects of climate change.",
                "The government took steps to mitigate the crisis."
            ],
            "synonyms": ["alleviate", "reduce", "lessen"],
            "antonyms": ["aggravate", "intensify", "worsen"],
            "difficulty": 5,
            "tags": ["toefl", "verb", "formal"]
        },
        {
            "id": "toefl_016",
            "word": "nominal",
            "phonetic": "/ˈnɒmɪnl/",
            "definition": "adj. 名义上的，微不足道的",
            "examples": [
                "She is the nominal head of the organization.",
                "There was only a nominal fee for the service."
            ],
            "synonyms": ["titular", "minimal", "symbolic"],
            "antonyms": ["real", "actual", "significant"],
            "difficulty": 4,
            "tags": ["toefl", "adjective"]
        },
        {
            "id": "toefl_017",
            "word": "obscure",
            "phonetic": "/əbˈskjʊə(r)/",
            "definition": "adj. 模糊的；v. 使模糊",
            "examples": [
                "The poem's meaning is obscure and difficult to interpret.",
                "Clouds obscured the view of the mountains."
            ],
            "synonyms": ["unclear", "vague", "hide"],
            "antonyms": ["clear", "obvious", "reveal"],
            "difficulty": 4,
            "tags": ["toefl", "adjective", "verb"]
        },
        {
            "id": "toefl_018",
            "word": "optimistic",
            "phonetic": "/ˌɒptɪˈmɪstɪk/",
            "definition": "adj. 乐观的",
            "examples": [
                "She remains optimistic about the company's future.",
                "We should be optimistic but also realistic."
            ],
            "synonyms": ["hopeful", "positive", "confident"],
            "antonyms": ["pessimistic", "negative", "cynical"],
            "difficulty": 3,
            "tags": ["toefl", "adjective"]
        },
        # P-S (难度4-5)
        {
            "id": "toefl_019",
            "word": "pragmatic",
            "phonetic": "/præɡˈmætɪk/",
            "definition": "adj. 务实的，实用的",
            "examples": [
                "We need a pragmatic approach to solve this problem.",
                "Her pragmatic leadership helped the company grow."
            ],
            "synonyms": ["practical", "realistic", "sensible"],
            "antonyms": ["idealistic", "impractical", "unrealistic"],
            "difficulty": 4,
            "tags": ["toefl", "adjective"]
        },
        {
            "id": "toefl_020",
            "word": "scrutinize",
            "phonetic": "/ˈskruːtənaɪz/",
            "definition": "v. 详细检查，仔细审查",
            "examples": [
                "The committee will scrutinize the proposal carefully.",
                "We need to scrutinize the contract before signing."
            ],
            "synonyms": ["examine", "inspect", "analyze"],
            "antonyms": ["ignore", "neglect", "overlook"],
            "difficulty": 5,
            "tags": ["toefl", "verb", "formal"]
        }
    ]
    return words

def generate_ielts_vocabulary():
    """生成IELTS词汇 - 学术类和培训类词汇"""
    words = [
        {
            "id": "ielts_001",
            "word": "accumulate",
            "phonetic": "/əˈkjuːmjəleɪt/",
            "definition": "v. 积累，积聚",
            "examples": [
                "Dust accumulates in the room if not cleaned regularly.",
                "She accumulated valuable experience over the years."
            ],
            "synonyms": ["gather", "collect", "amass"],
            "antonyms": ["scatter", "disperse", "waste"],
            "difficulty": 3,
            "tags": ["ielts", "verb"]
        },
        {
            "id": "ielts_002",
            "word": "adequate",
            "phonetic": "/ˈædɪkwət/",
            "definition": "adj. 充分的，适当的",
            "examples": [
                "Is your salary adequate to support your family?",
                "We need adequate time to prepare for the exam."
            ],
            "synonyms": ["sufficient", "enough", "satisfactory"],
            "antonyms": ["inadequate", "insufficient", "deficient"],
            "difficulty": 3,
            "tags": ["ielts", "adjective"]
        },
        {
            "id": "ielts_003",
            "word": "advocate",
            "phonetic": "/ˈædvəkeɪt/",
            "definition": "v. 提倡，支持 n. 拥护者",
            "examples": [
                "Many doctors advocate a healthy diet and exercise.",
                "She is a strong advocate of education reform."
            ],
            "synonyms": ["support", "promote", "champion"],
            "antonyms": ["oppose", "criticize", "attack"],
            "difficulty": 4,
            "tags": ["ielts", "verb", "noun"]
        },
        {
            "id": "ielts_004",
            "word": "alter",
            "phonetic": "/ˈɔːltə(r)/",
            "definition": "v. 改变，变更",
            "examples": [
                "We need to alter our plans due to bad weather.",
                "The dress needs to be altered before the wedding."
            ],
            "synonyms": ["change", "modify", "adjust"],
            "antonyms": ["preserve", "maintain", "keep"],
            "difficulty": 3,
            "tags": ["ielts", "verb"]
        },
        {
            "id": "ielts_005",
            "word": "ambiguous",
            "phonetic": "/æmˈbɪɡjuəs/",
            "definition": "adj. 模糊的，模棱两可的",
            "examples": [
                "The instructions were ambiguous and confusing.",
                "His ambiguous response didn't help clarify the situation."
            ],
            "synonyms": ["unclear", "vague", "equivocal"],
            "antonyms": ["clear", "unambiguous", "definite"],
            "difficulty": 4,
            "tags": ["ielts", "adjective", "academic"]
        },
        {
            "id": "ielts_006",
            "word": "anticipate",
            "phonetic": "/ænˈtɪsɪpeɪt/",
            "definition": "v. 预期，预料",
            "examples": [
                "We anticipate a large crowd at the concert.",
                "She anticipated his questions and prepared answers."
            ],
            "synonyms": ["expect", "predict", "foresee"],
            "antonyms": ["surprise", "misjudge", "dread"],
            "difficulty": 4,
            "tags": ["ielts", "verb"]
        },
        {
            "id": "ielts_007",
            "word": "apparent",
            "phonetic": "/əˈpærənt/",
            "definition": "adj. 明显的；表面的",
            "examples": [
                "It became apparent that he was lying.",
                "The apparent cause of the accident was driver error."
            ],
            "synonyms": ["obvious", "evident", "clear"],
            "antonyms": ["hidden", "obscure", "unclear"],
            "difficulty": 3,
            "tags": ["ielts", "adjective"]
        },
        {
            "id": "ielts_008",
            "word": "arbitrary",
            "phonetic": "/ˈɑːbɪtrəri/",
            "definition": "adj. 任意的，随意的",
            "examples": [
                "The decision seemed completely arbitrary.",
                "There should be no arbitrary arrests in a democratic society."
            ],
            "synonyms": ["random", "capricious", "whimsical"],
            "antonyms": ["reasoned", "logical", "systematic"],
            "difficulty": 4,
            "tags": ["ielts", "adjective", "academic"]
        },
        {
            "id": "ielts_009",
            "word": "comply",
            "phonetic": "/kəmˈplaɪ/",
            "definition": "v. 遵守，顺从（with）",
            "examples": [
                "All students must comply with school regulations.",
                "The company failed to comply with safety standards."
            ],
            "synonyms": ["obey", "adhere to", "follow"],
            "antonyms": ["disobey", "violate", "defy"],
            "difficulty": 4,
            "tags": ["ielts", "verb", "formal"]
        },
        {
            "id": "ielts_010",
            "word": "conspicuous",
            "phonetic": "/kənˈspɪkjuəs/",
            "definition": "adj. 显著的，显而易见的",
            "examples": [
                "Her absence was conspicuous at the meeting.",
                "The mistake was conspicuous to everyone."
            ],
            "synonyms": ["noticeable", "obvious", "prominent"],
            "antonyms": ["inconspicuous", "hidden", "obscure"],
            "difficulty": 5,
            "tags": ["ielts", "adjective"]
        }
    ]
    return words

def generate_gre_vocabulary():
    """生成GRE词汇 - 高难度学术词汇"""
    words = [
        {
            "id": "gre_001",
            "word": "aberration",
            "phonetic": "/ˌæbəˈreɪʃn/",
            "definition": "n. 偏差，异常",
            "examples": [
                "The warm weather in December was an aberration.",
                "This result is merely an aberration, not a trend."
            ],
            "synonyms": ["deviation", "anomaly", "irregularity"],
            "antonyms": ["norm", "standard", "regularity"],
            "difficulty": 4,
            "tags": ["gre", "noun", "academic"]
        },
        {
            "id": "gre_002",
            "word": "abstruse",
            "phonetic": "/əbˈstruːs/",
            "definition": "adj. 深奥的，难以理解的",
            "examples": [
                "The professor's abstruse lecture confused the students.",
                "Philosophy can deal with abstruse concepts."
            ],
            "synonyms": ["obscure", "arcane", "esoteric"],
            "antonyms": ["clear", "simple", "understandable"],
            "difficulty": 5,
            "tags": ["gre", "adjective", "academic"]
        },
        {
            "id": "gre_003",
            "word": "acumen",
            "phonetic": "/ˈækjəmən/",
            "definition": "n. 敏锐，聪明",
            "examples": [
                "Her business acumen impressed the investors.",
                "Political acumen is essential for diplomacy."
            ],
            "synonyms": ["insight", "shrewdness", "astuteness"],
            "antonyms": ["ignorance", "dullness", "stupidity"],
            "difficulty": 5,
            "tags": ["gre", "noun"]
        },
        {
            "id": "gre_004",
            "word": "adamant",
            "phonetic": "/ˈædəmənt/",
            "definition": "adj. 坚定不移的",
            "examples": [
                "She remains adamant about her decision.",
                "He was adamant that he was right."
            ],
            "synonyms": ["unyielding", "inflexible", "stubborn"],
            "antonyms": ["flexible", "yielding", "accommodating"],
            "difficulty": 4,
            "tags": ["gre", "adjective"]
        },
        {
            "id": "gre_005",
            "word": "aesthetic",
            "phonetic": "/iːsˈθetɪk/",
            "definition": "adj. 美学的，审美的 n. 美学标准",
            "examples": [
                "The building has great aesthetic appeal.",
                "Different cultures have different aesthetic values."
            ],
            "synonyms": ["artistic", "visual", "tasteful"],
            "antonyms": ["unaesthetic", "ugly", "distasteful"],
            "difficulty": 4,
            "tags": ["gre", "adjective", "noun"]
        },
        {
            "id": "gre_006",
            "word": "anomaly",
            "phonetic": "/əˈnɒməli/",
            "definition": "n. 异常，反常现象",
            "examples": [
                "The scientist discovered an anomaly in the data.",
                "This weather pattern is quite an anomaly for this region."
            ],
            "synonyms": ["aberration", "irregularity", "deviation"],
            "antonyms": ["norm", "standard", "regularity"],
            "difficulty": 5,
            "tags": ["gre", "noun", "academic"]
        },
        {
            "id": "gre_007",
            "word": "antipathy",
            "phonetic": "/ænˈtɪpəθi/",
            "definition": "n. 憎恶，反感",
            "examples": [
                "She has a deep antipathy toward violence.",
                "His antipathy toward his rival was well known."
            ],
            "synonyms": ["hostility", "aversion", "dislike"],
            "antonyms": ["affection", "sympathy", "love"],
            "difficulty": 5,
            "tags": ["gre", "noun", "formal"]
        },
        {
            "id": "gre_008",
            "word": "apathy",
            "phonetic": "/ˈæpəθi/",
            "definition": "n. 冷漠，无动于衷",
            "examples": [
                "Voter apathy led to low turnout in the election.",
                "His apathy toward his work concerns his boss."
            ],
            "synonyms": ["indifference", "unconcern", "disinterest"],
            "antonyms": ["enthusiasm", "passion", "concern"],
            "difficulty": 4,
            "tags": ["gre", "noun"]
        },
        {
            "id": "gre_009",
            "word": "approbation",
            "phonetic": "/ˌæprəˈbeɪʃn/",
            "definition": "n. 认可，赞许",
            "examples": [
                "Her work received the committee's approbation.",
                "He sought his parents' approbation for his plans."
            ],
            "synonyms": ["approval", "endorsement", "praise"],
            "antonyms": ["disapproval", "condemnation", "criticism"],
            "difficulty": 5,
            "tags": ["gre", "noun", "formal"]
        },
        {
            "id": "gre_010",
            "word": "arcane",
            "phonetic": "/ɑːˈkeɪn/",
            "definition": "adj. 神秘的，晦涩难懂的",
            "examples": [
                "The book contains arcane knowledge about ancient rituals.",
                "Only specialists understand these arcane rules."
            ],
            "synonyms": ["mysterious", "obscure", "esoteric"],
            "antonyms": ["common", "well-known", "accessible"],
            "difficulty": 5,
            "tags": ["gre", "adjective", "literary"]
        }
    ]
    return words

def generate_business_vocabulary():
    """生成商务英语词汇"""
    words = [
        {
            "id": "business_001",
            "word": "acquisition",
            "phonetic": "/ˌækwɪˈzɪʃn/",
            "definition": "n. 收购，获得",
            "examples": [
                "The company announced the acquisition of a rival firm.",
                "Language acquisition is easier for young children."
            ],
            "synonyms": ["purchase", "takeover", "procurement"],
            "antonyms": ["sale", "disposal", "divestment"],
            "difficulty": 3,
            "tags": ["business", "noun"]
        },
        {
            "id": "business_002",
            "word": "aggregate",
            "phonetic": "/ˈæɡrɪɡət/",
            "definition": "adj. 总计的；n. 总数；v. 合计",
            "examples": [
                "The aggregate amount was higher than expected.",
                "We need to aggregate data from multiple sources."
            ],
            "synonyms": ["total", "sum", "combined"],
            "antonyms": ["individual", "separate", "partial"],
            "difficulty": 4,
            "tags": ["business", "adjective", "verb"]
        },
        {
            "id": "business_003",
            "word": "allocate",
            "phonetic": "/ˈæləkeɪt/",
            "definition": "v. 分配，拨给",
            "examples": [
                "The government allocated funds for education.",
                "We need to allocate resources efficiently."
            ],
            "synonyms": ["assign", "distribute", "allot"],
            "antonyms": ["withhold", "keep", "retain"],
            "difficulty": 3,
            "tags": ["business", "verb"]
        },
        {
            "id": "business_004",
            "word": "audit",
            "phonetic": "/ˈɔːdɪt/",
            "definition": "n. 审计；v. 查账",
            "examples": [
                "The company underwent a financial audit.",
                "External auditors will audit our accounts."
            ],
            "synonyms": ["examine", "inspect", "review"],
            "antonyms": ["ignore", "neglect", "overlook"],
            "difficulty": 3,
            "tags": ["business", "noun", "verb"]
        },
        {
            "id": "business_005",
            "word": "bankrupt",
            "phonetic": "/ˈbæŋkrʌpt/",
            "definition": "adj. 破产的；n. 破产者",
            "examples": [
                "The company went bankrupt last year.",
                "Filing for bankrupt is a difficult decision."
            ],
            "synonyms": ["insolvent", "broke", "failed"],
            "antonyms": ["solvent", "wealthy", "prosperous"],
            "difficulty": 2,
            "tags": ["business", "adjective", "noun"]
        },
        {
            "id": "business_006",
            "word": "bargain",
            "phonetic": "/ˈbɑːɡɪn/",
            "definition": "n. 交易；便宜货；v. 讨价还价",
            "examples": [
                "We reached a bargain on the price.",
                "The car was a real bargain at that price."
            ],
            "synonyms": ["deal", "negotiate", " haggle"],
            "antonyms": ["rip-off", "overcharge", "reject"],
            "difficulty": 2,
            "tags": ["business", "noun", "verb"]
        },
        {
            "id": "business_007",
            "word": "collaborate",
            "phonetic": "/kəˈlæbəreɪt/",
            "definition": "v. 合作，协作",
            "examples": [
                "We collaborated with several partners on this project.",
                "Teams collaborate better when they trust each other."
            ],
            "synonyms": ["cooperate", "work together", "team up"],
            "antonyms": ["compete", "oppose", "work alone"],
            "difficulty": 3,
            "tags": ["business", "verb"]
        },
        {
            "id": "business_008",
            "word": "dividend",
            "phonetic": "/ˈdɪvɪdend/",
            "definition": "n. 红利，股息",
            "examples": [
                "The company pays quarterly dividends to shareholders.",
                "Investing in stocks can provide dividend income."
            ],
            "synonyms": ["payout", "return", "profit"],
            "antonyms": ["loss", "cost", "expense"],
            "difficulty": 3,
            "tags": ["business", "noun"]
        },
        {
            "id": "business_009",
            "word": "fluctuate",
            "phonetic": "/ˈflʌktʃueɪt/",
            "definition": "v. 波动，变动",
            "examples": [
                "Prices fluctuate according to supply and demand.",
                "Stock prices fluctuated wildly during the crisis."
            ],
            "synonyms": ["vary", "change", "oscillate"],
            "antonyms": ["stabilize", "remain steady", "stay constant"],
            "difficulty": 4,
            "tags": ["business", "verb"]
        },
        {
            "id": "business_010",
            "word": "infrastructure",
            "phonetic": "/ˈɪnfrəstrʌktʃə(r)/",
            "definition": "n. 基础设施",
            "examples": [
                "The country needs to invest in its infrastructure.",
                "Good infrastructure is essential for economic growth."
            ],
            "synonyms": ["foundation", "base", "framework"],
            "antonyms": ["superstructure", "surface", "top"],
            "difficulty": 3,
            "tags": ["business", "noun"]
        }
    ]
    return words

def generate_technology_vocabulary():
    """生成科技英语词汇"""
    words = [
        {
            "id": "tech_001",
            "word": "algorithm",
            "phonetic": "/ˈælɡərɪðəm/",
            "definition": "n. 算法",
            "examples": [
                "The search algorithm ranks results by relevance.",
                "Programmers design algorithms to solve problems efficiently."
            ],
            "synonyms": ["procedure", "method", "process"],
            "antonyms": ["randomness", "chaos", "disorder"],
            "difficulty": 4,
            "tags": ["technology", "noun", "computer"]
        },
        {
            "id": "tech_002",
            "word": "bandwidth",
            "phonetic": "/ˈbændwɪdθ/",
            "definition": "n. 带宽",
            "examples": [
                "High bandwidth allows faster data transfer.",
                "The network has limited bandwidth."
            ],
            "synonyms": ["capacity", "throughput", "data rate"],
            "antonyms": ["bottleneck", "constraint", "limitation"],
            "difficulty": 3,
            "tags": ["technology", "noun", "network"]
        },
        {
            "id": "tech_003",
            "word": "compile",
            "phonetic": "/kəmˈpaɪl/",
            "definition": "v. 编译，汇编",
            "examples": [
                "You need to compile the code before running it.",
                "The compiler checks for syntax errors."
            ],
            "synonyms": ["assemble", "build", "construct"],
            "antonyms": ["decompile", "break down", "dismantle"],
            "difficulty": 4,
            "tags": ["technology", "verb", "programming"]
        },
        {
            "id": "tech_004",
            "word": "database",
            "phonetic": "/ˈdeɪtəbeɪs/",
            "definition": "n. 数据库",
            "examples": [
                "We store customer information in a secure database.",
                "The database contains millions of records."
            ],
            "synonyms": ["repository", "archive", "data bank"],
            "antonyms": ["chaos", "disorder", "mess"],
            "difficulty": 2,
            "tags": ["technology", "noun"]
        },
        {
            "id": "tech_005",
            "word": "encryption",
            "phonetic": "/ɪnˈkrɪpʃn/",
            "definition": "n. 加密",
            "examples": [
                "Encryption protects sensitive data from hackers.",
                "The website uses SSL encryption for security."
            ],
            "synonyms": ["encoding", "ciphering", "scrambling"],
            "antonyms": ["decryption", "decoding", "deciphering"],
            "difficulty": 4,
            "tags": ["technology", "noun", "security"]
        },
        {
            "id": "tech_006",
            "word": "interface",
            "phonetic": "/ˈɪntərfeɪs/",
            "definition": "n. 接口，界面；v. 连接",
            "examples": [
                "The user interface is intuitive and easy to use.",
                "Different systems need to interface with each other."
            ],
            "synonyms": ["connection", "boundary", "link"],
            "antonyms": ["disconnection", "separation", "isolation"],
            "difficulty": 3,
            "tags": ["technology", "noun", "verb"]
        },
        {
            "id": "tech_007",
            "word": "latency",
            "phonetic": "/ˈleɪtnsi/",
            "definition": "n. 延迟，潜伏",
            "examples": [
                "Network latency affects online gaming performance.",
                "Low latency is crucial for real-time applications."
            ],
            "synonyms": ["delay", "lag", "response time"],
            "antonyms": ["speed", "instantaneity", "immediacy"],
            "difficulty": 4,
            "tags": ["technology", "noun", "network"]
        },
        {
            "id": "tech_008",
            "word": "protocol",
            "phonetic": "/ˈprəʊtəkɒl/",
            "definition": "n. 协议，规程",
            "examples": [
                "HTTP is the protocol used for web communication.",
                "Follow the safety protocol when handling chemicals."
            ],
            "synonyms": ["standard", "procedure", "rules"],
            "antonyms": ["violation", "deviation", "exception"],
            "difficulty": 3,
            "tags": ["technology", "noun", "network"]
        },
        {
            "id": "tech_009",
            "word": "syntax",
            "phonetic": "/ˈsɪntæks/",
            "definition": "n. 语法，句法",
            "examples": [
                "Check the syntax of your code for errors.",
                "Python has a clean and simple syntax."
            ],
            "synonyms": ["grammar", "structure", "format"],
            "antonyms": ["semantics", "meaning", "content"],
            "difficulty": 4,
            "tags": ["technology", "noun", "programming"]
        },
        {
            "id": "tech_010",
            "word": "wireless",
            "phonetic": "/ˈwaɪələs/",
            "definition": "adj. 无线的",
            "examples": [
                "Wireless internet is available throughout the building.",
                "Wireless devices connect via radio waves."
            ],
            "synonyms": ["cordless", "radio", "Wi-Fi"],
            "antonyms": ["wired", "cabled", "connected"],
            "difficulty": 2,
            "tags": ["technology", "adjective", "network"]
        }
    ]
    return words

def generate_daily_vocabulary():
    """生成日常英语词汇"""
    words = [
        {
            "id": "daily_001",
            "word": "accommodate",
            "phonetic": "/əˈkɒmədeɪt/",
            "definition": "v. 容纳；适应",
            "examples": [
                "The hotel can accommodate 200 guests.",
                "We must accommodate different learning styles."
            ],
            "synonyms": ["house", "lodging", "adapt"],
            "antonyms": ["evict", "reject", "refuse"],
            "difficulty": 3,
            "tags": ["daily", "verb"]
        },
        {
            "id": "daily_002",
            "word": "affordable",
            "phonetic": "/əˈfɔːdəbl/",
            "definition": "adj. 买得起的",
            "examples": [
                "The apartment is affordable for young professionals.",
                "Healthcare should be affordable for everyone."
            ],
            "synonyms": ["cheap", "reasonable", "economical"],
            "antonyms": ["expensive", "costly", "unaffordable"],
            "difficulty": 2,
            "tags": ["daily", "adjective"]
        },
        {
            "id": "daily_003",
            "word": "available",
            "phonetic": "/əˈveɪləbl/",
            "definition": "adj. 可获得的；有空的",
            "examples": [
                "This product is available in all stores.",
                "The manager is not available right now."
            ],
            "synonyms": ["accessible", "obtainable", "free"],
            "antonyms": ["unavailable", "busy", "occupied"],
            "difficulty": 1,
            "tags": ["daily", "adjective"]
        },
        {
            "id": "daily_004",
            "word": "convenient",
            "phonetic": "/kənˈviːniənt/",
            "definition": "adj. 方便的",
            "examples": [
                "The location is convenient for shopping.",
                "Online shopping is very convenient."
            ],
            "synonyms": ["handy", "useful", "suitable"],
            "antonyms": ["inconvenient", "difficult", "troublesome"],
            "difficulty": 2,
            "tags": ["daily", "adjective"]
        },
        {
            "id": "daily_005",
            "word": "determine",
            "phonetic": "/dɪˈtɜːmɪn/",
            "definition": "v. 决定；查明",
            "examples": [
                "We need to determine the cause of the problem.",
                "Your attitude will determine your success."
            ],
            "synonyms": ["decide", "resolve", "figure out"],
            "antonyms": ["hesitate", "waver", "ignore"],
            "difficulty": 2,
            "tags": ["daily", "verb"]
        },
        {
            "id": "daily_006",
            "word": "essential",
            "phonetic": "/ɪˈsenʃl/",
            "definition": "adj. 必要的，本质的",
            "examples": [
                "Water is essential for life.",
                "Good communication is essential in relationships."
            ],
            "synonyms": ["necessary", "vital", "crucial"],
            "antonyms": ["unnecessary", "optional", "inessential"],
            "difficulty": 2,
            "tags": ["daily", "adjective"]
        },
        {
            "id": "daily_007",
            "word": "frequent",
            "phonetic": "/ˈfriːkwənt/",
            "definition": "adj. 频繁的",
            "examples": [
                "Frequent exercise is good for your health.",
                "We made frequent stops on our road trip."
            ],
            "synonyms": ["regular", "repeated", "common"],
            "antonyms": ["rare", "infrequent", "occasional"],
            "difficulty": 2,
            "tags": ["daily", "adjective"]
        },
        {
            "id": "daily_008",
            "word": "maintain",
            "phonetic": "/meɪnˈteɪn/",
            "definition": "v. 维持，保养",
            "examples": [
                "You need to maintain a healthy diet.",
                "Regular maintenance keeps the car running well."
            ],
            "synonyms": ["sustain", "preserve", "uphold"],
            "antonyms": ["neglect", "abandon", "ignore"],
            "difficulty": 2,
            "tags": ["daily", "verb"]
        },
        {
            "id": "daily_009",
            "word": "recommend",
            "phonetic": "/ˌrekəˈmend/",
            "definition": "v. 推荐，建议",
            "examples": [
                "I recommend this restaurant to everyone.",
                "The doctor recommended plenty of rest."
            ],
            "synonyms": ["suggest", "advise", "propose"],
            "antonyms": ["warn", "discourage", "reject"],
            "difficulty": 2,
            "tags": ["daily", "verb"]
        },
        {
            "id": "daily_010",
            "word": "significant",
            "phonetic": "/sɪɡˈnɪfɪkənt/",
            "definition": "adj. 重要的，有意义的",
            "examples": [
                "There was a significant improvement in his grades.",
                "This discovery is significant for medical research."
            ],
            "synonyms": ["important", "major", "meaningful"],
            "antonyms": ["insignificant", "minor", "trivial"],
            "difficulty": 3,
            "tags": ["daily", "adjective"]
        }
    ]
    return words

def save_vocabulary(words, filename):
    """保存词库到JSON文件"""
    filepath = os.path.join(VOCAB_DIR, filename)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(words, f, ensure_ascii=False, indent=2)
    print(f"✅ Generated {filename} with {len(words)} words")

def main():
    """主函数：生成所有词库文件"""
    print("🚀 开始生成词库文件...")

    # 确保目录存在
    os.makedirs(VOCAB_DIR, exist_ok=True)

    # 生成各个词库
    toefl_words = generate_toefl_vocabulary()
    save_vocabulary(toefl_words, 'toefl_ultra.json')

    ielts_words = generate_ielts_vocabulary()
    save_vocabulary(ielts_words, 'ielts_ultra.json')

    gre_words = generate_gre_vocabulary()
    save_vocabulary(gre_words, 'gre_ultra.json')

    business_words = generate_business_vocabulary()
    save_vocabulary(business_words, 'business_complete.json')

    tech_words = generate_technology_vocabulary()
    save_vocabulary(tech_words, 'technology_complete.json')

    daily_words = generate_daily_vocabulary()
    save_vocabulary(daily_words, 'daily_complete.json')

    print("\n✅ 所有词库生成完成！")

if __name__ == "__main__":
    main()
