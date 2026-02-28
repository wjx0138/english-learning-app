# 应用截图指南

**项目**: English Learning App
**创建时间**: 2026-02-28

---

## 📱 截图尺寸要求

### iOS App Store

| 尺寸 | 用途 | 数量 |
|-----|------|------|
| 6.7" (1290x2796) | iPhone Pro Max | 3-10张 |
| 6.5" (1242x2688) | iPhone Plus/Max | 3-10张 |
| 5.5" (1242x2208) | iPhone Plus | 3-10张 |

### Android Google Play

| 尺寸 | 用途 | 数量 |
|-----|------|------|
| 手机 (16:9) | 主要截图 | 至少2张 |
| 平板 (16:9) | 平板截图 | 可选 |
| 手机 (16:10) | 可选 | 可选 |

**推荐尺寸**: 1080x1920px (手机竖屏)

---

## 🎯 截图内容清单

### 必需截图（至少5张）

1. **首页/主界面** (1张)
   - 显示今日学习进度
   - 快速开始按钮
   - 连续打卡天数

2. **单词卡片学习** (1-2张)
   - 卡片正面（单词）
   - 卡片背面（释义、例句）
   - 滑动操作提示

3. **打字练习** (1张)
   - 单词显示
   - 输入框
   - 速度/正确率统计

4. **学习统计/进度** (1张)
   - 学习曲线图表
   - 词汇量统计
   - 成就徽章

5. **课程/词库选择** (1张)
   - 词库列表
   - 进度显示

### 可选截图（5-10张）

6. **游戏化系统**
   - 成就页面
   - 等级进度
   - 积分奖励

7. **测验系统**
   - 测验界面
   - 结果分析

8. **设置页面**
   - 个性化选项
   - 主题切换

9. **词汇详情**
   - 音标显示
   - TTS发音

10. **错题本**
    - 错题列表
    - 重练功能

---

## 🎨 截图设计技巧

### 通用原则

1. **突出核心功能** - 每张截图展示1-2个主要功能
2. **简洁明了** - 避免过多元素干扰
3. **真实内容** - 使用真实数据而非示例数据
4. **视觉一致** - 所有截图保持统一的配色和风格
5. **添加标注** - 使用文字/箭头标注关键功能

### 设计模板

#### 模板1: 突出功能名称

```
┌─────────────────────┐
│                     │
│   📚 智能单词卡片    │
│                     │
│   ┌─────────────┐   │
│   │             │   │
│   │   abandon   │   │
│   │  /əˈbændən/ │   │
│   │             │   │
│   └─────────────┘   │
│                     │
│  左滑: 认识          │
│  右滑: 不认识        │
└─────────────────────┘
```

#### 模板2: 展示数据

```
┌─────────────────────┐
│                     │
│  📊 学习进度统计     │
│                     │
│   本周学习: 2,130词  │
│   ━━━━━━━━━━━━━ 85% │
│                     │
│   词汇量: 4,500      │
│   排名: 前 10%       │
└─────────────────────┘
```

#### 模板3: 流程展示

```
┌─────────────────────┐
│                     │
│  1️⃣ 选择词库        │
│       ↓             │
│  2️⃣ 开始学习        │
│       ↓             │
│  3️⃣ 复习巩固        │
│       ↓             │
│  ✅ 掌握词汇         │
│                     │
└─────────────────────┘
```

---

## 🛠️ 截图工具推荐

### iOS

1. **模拟器截图**
   ```bash
   # 运行应用
   flutter run

   # 截图 (命令行)
   xcrun simctl io booted screenshot screenshot.png

   # 或使用快捷键
   Cmd + Shift + 4 (选择区域)
   Cmd + Shift + 5 (高级截图)
   ```

2. **真机截图**
   - 按下电源键 + 音量+键
   - 照片 → 截图

3. **设备框架生成器**
   - [Frame Shot](https://www.frameshw.com)
   - [Mockuphone](https://mockuphone.com)
   - [Screely](https://screely.com)

### Android

1. **模拟器截图**
   ```bash
   # 运行应用
   flutter run

   # 截图
   adb shell screencap -p /sdcard/screenshot.png
   adb pull /sdcard/screenshot.png
   ```

2. **Android Studio**
   - Tools → Layout Inspector
   - 截图按钮

3. **在线框架工具**
   - [Mockuphone](https://mockuphone.com)
   - [Placeit](https://placeit.net)

---

## 📝 截图文案建议

### 标题文字（每张截图）

1. **首页**: "高效学习，轻松掌握词汇"
2. **卡片学习**: "智能算法，科学记忆"
3. **打字练习**: "边打边学，强化记忆"
4. **学习统计**: "可视化进度，一目了然"
5. **游戏化**: "趣味学习，持续动力"

### 描述文字（App Store）

1. "基于FSRS间隔重复算法，比传统方法更高效"
2. "63,000+词汇，覆盖CET4/6、托福、雅思、GRE"
3. "多种学习模式，让学习不再枯燥"
4. "详细的数据分析，见证每一点进步"
5. "成就系统激励，养成学习习惯"

---

## 🎬 截图制作流程

### 第一步: 准备应用状态

```dart
// 添加测试数据
final testData = {
  'todayWords': 50,
  'totalWords': 4500,
  'streak': 15,
  'level': 8,
  // ... 其他数据
};
```

### 第二步: 运行应用

```bash
# iOS模拟器
flutter run -d iPhone

# Android模拟器
flutter run -d emulator
```

### 第三步: 访问各个页面

```bash
# 在应用中导航到不同页面
# 1. 首页
# 2. 卡片学习页
# 3. 打字练习页
# 4. 统计页面
# 5. 课程页面
# ...
```

### 第四步: 截取屏幕

```bash
# iOS
xcrun simctl io booted screenshot screen1.png

# Android
adb shell screencap -p > screen1.png
```

### 第五步: 添加设备框架

使用在线工具或自动化脚本:

```bash
# 使用screenshot-generator
npm install -g screenshot-generator

screenshot-generator \
  --input screen1.png \
  --device "iPhone 14 Pro" \
  --output screen1-framed.png
```

### 第六步: 添加标注

使用Figma/Sketch/Photoshop添加:
- 功能标题
- 箭头指示
- 说明文字

---

## ✅ 截图验收标准

- [ ] 至少5张截图
- [ ] 所有截图尺寸正确
- [ ] 没有模糊或失真
- [ ] 没有状态栏干扰
- [ ] 内容真实可信
- [ ] 文字清晰可读
- [ ] 突出核心功能
- [ ] 视觉风格统一
- [ ] 添加了适当的标注
- [ ] 在设备上测试显示效果

---

## 📦 文件命名规范

```
screenshots/
├── ios/
│   ├── iPhone_14_Pro_1.png (1290x2796)
│   ├── iPhone_14_Pro_2.png (1290x2796)
│   ├── iPhone_14_Pro_3.png (1290x2796)
│   ├── iPhone_14_Pro_4.png (1290x2796)
│   └── iPhone_14_Pro_5.png (1290x2796)
└── android/
    ├── phone_screenshot_1.png (1080x1920)
    ├── phone_screenshot_2.png (1080x1920)
    ├── phone_screenshot_3.png (1080x1920)
    ├── phone_screenshot_4.png (1080x1920)
    └── phone_screenshot_5.png (1080x1920)
```

---

## 🎯 快速截图方案

### 使用自动化脚本

```bash
# 创建脚本文件 screenshot_app.sh

#!/bin/bash

# 启动应用
flutter run &
FLUTTER_PID=$!

# 等待应用启动
sleep 5

# 截图函数
take_screenshot() {
    local name=$1
    local wait_time=$2

    sleep $wait_time

    # iOS截图
    xcrun simctl io booted screenshot "screenshots/${name}.png"

    # Android截图
    # adb shell screencap -p > "screenshots/${name}.png"
}

# 导航到不同页面并截图
take_screenshot "01_home" 2
take_screenshot "02_flashcard" 2
take_screenshot "03_typing" 2
take_screenshot "04_progress" 2
take_screenshot "05_courses" 2

# 关闭应用
kill $FLUTTER_PID

echo "截图完成！"
```

---

## 📝 后续步骤

1. **准备测试数据** (30分钟)
   - 添加演示账号
   - 设置学习进度
   - 准备词汇数据

2. **截取原始屏幕** (1小时)
   - 运行应用
   - 访问所有页面
   - 截取屏幕截图

3. **添加设备框架** (1小时)
   - 使用在线工具
   - 或使用Photoshop批处理

4. **添加标注文字** (1-2小时)
   - 使用Figma/Sketch
   - 添加标题和说明
   - 确保统一风格

5. **导出最终版本** (30分钟)
   - 导出PNG格式
   - 检查文件大小
   - 验证尺寸要求

---

**创建**: 2026-02-28
**状态**: 🚧 待完成
