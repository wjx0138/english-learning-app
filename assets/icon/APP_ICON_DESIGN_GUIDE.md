# 应用图标设计规范

**项目**: English Learning App
**设计时间**: 2026-02-28
**版本**: v1.0

---

## 📱 图标尺寸要求

### Android (Google Play)

| 尺寸 | 用途 | 文件名 |
|-----|------|--------|
| 512x512px | Google Play商店图标 | `ic_launcher_play_store.png` |
| 192x192px | Adaptive Icon (前景) | `ic_launcher_foreground.png` |
| 108x108px | Adaptive Icon (蒙版) | `ic_launcher_monochrome.png` |
| 48x48dp | 应用图标 (mdpi) | `ic_launcher.png` |

### iOS (App Store)

| 尺寸 | 用途 | 文件名 |
|-----|------|--------|
| 1024x1024px | App Store图标 | `AppIcon-1024x1024.png` |
| 180x180px | iPhone (@3x) | `AppIcon-60@3x.png` |
| 167x167px | iPad Pro (@2x) | `AppIcon-83.5@2x.png` |
| 152x152px | iPad (@2x) | `AppIcon-76@2x.png` |
| 120x120px | iPhone (@2x) | `AppIcon-60@2x.png` |
| 87x87px | iPhone Settings (@3x) | `AppIcon-29@3x.png` |
| 58x58px | iPhone Settings (@2x) | `AppIcon-29@2x.png` |

---

## 🎨 设计建议

### 主题元素

1. **主色调**:
   - 主色: #4CAF50 (绿色 - 代表学习和成长)
   - 辅助色: #FFC107 (琥珀色 - 代表成就)
   - 背景: 白色或浅色渐变

2. **核心图形**:
   - ✅ 推荐元素: 书本 📚、卡片 🎴、大脑 🧠、字母 Aa
   - ✅ 简洁风格: 扁平化、Material Design
   - ✅ 识别性: 在小尺寸下也能清晰识别

3. **设计原则**:
   - 简洁明了
   - 易于识别
   - 与应用功能相关
   - 避免文字过多

### 推荐设计方向

#### 方案1: 卡片+书本
```
┌─────────────────┐
│                 │
│    ┌─────┐      │
│    │ Aa  │      │
│    └─────┘      │
│       📚         │
│                 │
└─────────────────┘
```

#### 方案2: 字母+成长
```
┌─────────────────┐
│                 │
│      🌱         │
│      │          │
│      Aa         │
│                 │
└─────────────────┘
```

#### 方案3: 简约文字
```
┌─────────────────┐
│                 │
│     ┌───┐       │
│     │ENG│       │
│     └───┘       │
│   Learning      │
│                 │
└─────────────────┘
```

---

## 🎯 设计交付清单

### 必需文件

- [ ] **AppIcon-1024x1024.png** (iOS App Store主图标)
- [ ] **ic_launcher_play_store.png** (Android Play Store图标)
- [ ] **ic_launcher.png** (Android应用图标)
- [ ] **ic_launcher_round.png** (Android圆形图标)

### 设计源文件

- [ ] **icon_design.svg** (矢量源文件)
- [ ] **icon_design.figma** (或其他设计软件文件)

---

## 🛠️ 快速生成方案

### 方案A: 使用在线工具

1. **Canva** (https://www.canva.com)
   - 搜索 "App Icon"
   - 选择教育类模板
   - 自定义颜色和文字
   - 导出多个尺寸

2. **AppIconGenerator** (https://appicon.co)
   - 上传1024x1024图标
   - 自动生成所有尺寸
   - 下载完整包

3. **MakeAppIcon** (https://makeappicon.com)
   - 拖拽1024x1024图标
   - 自动生成iOS和Android尺寸
   - 下载配置好的文件

### 方案B: 使用Flutter插件

```bash
# 安装图标生成插件
flutter pub global activate flutter_launcher_icons

# 在pubspec.yaml中配置
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon_1024.png"
  adaptive_icon_background: "#4CAF50"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"

# 生成图标
flutter pub global run flutter_launcher_icons
```

### 方案C: 使用AI生成工具

1. **Midjourney** 或 **DALL-E**
   - 提示词: "Simple app icon for English learning app, green color, book and card, minimalist, flat design, white background, vector style"
   - 选择最佳方案
   - 使用Canva或Figma调整

---

## 📦 图标文件夹结构

### Android
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
├── mipmap-xxxhdpi/ic_launcher.png (192x192)
└── mipmap-xxxhdpi/ic_launcher_round.png
```

### iOS
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── AppIcon-60@2x.png (120x120)
├── AppIcon-60@3x.png (180x180)
├── AppIcon-76@2x.png (152x152)
├── AppIcon-83.5@2x.png (167x167)
├── AppIcon-29@2x.png (58x58)
├── AppIcon-29@3x.png (87x87)
└── AppIcon-1024x1024.png (1024x1024)
```

---

## ✅ 设计验收标准

- [ ] 所有必需尺寸已生成
- [ ] 在小尺寸(48x48)下清晰可辨
- [ ] 符合Material Design(iOS设计规范)
- [ ] 主色调与应用一致
- [ ] 背景干净或透明
- [ ] 在各种壁纸下都能看清
- [ ] 已测试在真机上的显示效果

---

## 🎨 配色方案参考

### 主题色
```yaml
Primary:    #4CAF50  (Material Green 500)
Secondary:  #FFC107  (Amber 500)
Background: #FFFFFF  (White)
Surface:    #F5F5F5  (Grey 100)
```

### 图标渐变
```css
渐变1: #4CAF50 → #8BC34A (绿色渐变)
渐变2: #66BB6A → #4CAF50 (浅绿到绿)
渐变3: #FFC107 → #FFB300 (琥珀色渐变)
```

---

## 📝 后续步骤

1. **选择设计方案** (30分钟)
   - 从推荐方案中选择或自行设计
   - 确定主色调和核心元素

2. **创建图标** (1-2小时)
   - 使用Figma/Illustrator/Canva创建
   - 导出1024x1024源文件

3. **生成所有尺寸** (30分钟)
   - 使用AppIconGenerator自动生成
   - 或手动导出所需尺寸

4. **集成到项目** (30分钟)
   - 放置到对应文件夹
   - 配置pubspec.yaml
   - 测试显示效果

---

**创建**: 2026-02-28
**设计师**: 待定
**状态**: 🚧 进行中
