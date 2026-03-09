# English Learning App - Claude 开发指南

## 📚 项目概述

这是一个基于 Flutter 开发的英语学习应用，提供多种学习模式帮助用户高效记忆单词。

**主要功能**:
- 🎴 闪卡学习 (FSRS 算法)
- ✍️ 跟打练习
- 📝 听写练习
- 📊 选择题测试
- 📚 课程学习
- 🏆 游戏化系统 (积分、等级、成就)

**技术栈**: Flutter 3.41.2 + Dart + Provider + go_router + FSRS

## 🚀 快速开始

### 环境要求
```bash
Flutter SDK: 3.41.2 或更高
Dart SDK: 3.0.0 或更高
```

### 安装依赖
```bash
cd english_learning_app
flutter pub get
```

### 运行应用
```bash
# Web 版本 (推荐用于开发)
flutter run -d chrome --web-port 8085

# 移动端版本
flutter run

# 指定设备
flutter devices
flutter run -d <device_id>
```

### 停止应用
```bash
# 停止指定端口的应用
lsof -ti:8085 | xargs kill -9

# 或者使用 Ctrl+C 在终端停止
```

### 热重载
应用运行时，在命令行输入：
- `r` - 热重载 (快速应用代码更改)
- `R` - 热重启 (完全重新应用)
- `q` - 退出

## 📁 项目结构

```
lib/
├── main.dart                      # 应用入口
├── core/                          # 核心层
│   └── providers/                 # 状态管理 (Provider)
│       ├── app_provider.dart      # 应用状态 (积分、等级)
│       ├── card_provider.dart     # 闪卡状态
│       ├── progress_provider.dart # 学习进度
│       └── quiz_provider.dart     # 测试状态
├── data/                          # 数据层
│   └── models/                    # 数据模型
│       ├── word.dart              # 单词模型
│       ├── flashcard.dart         # 闪卡模型
│       ├── quiz.dart              # 测试模型
│       ├── gamification.dart      # 游戏化模型
│       ├── course.dart            # 课程模型
│       ├── typing_practice.dart   # 跟打模型
│       └── vocabulary_book.dart   # 词库模型
├── features/                      # 功能层
│   ├── flashcard/                 # 闪卡学习
│   │   ├── enhanced_flashcard_page.dart
│   │   └── study_result_page.dart
│   ├── quiz/                      # 选择题测试
│   │   ├── enhanced_quiz_page.dart
│   │   ├── quiz_result_page.dart
│   │   └── widgets/
│   │       └── quiz_option_card.dart
│   ├── typing/                    # 跟打练习
│   │   ├── typing_practice_page.dart
│   │   ├── typing_mode_selection_page.dart
│   │   └── widgets/
│   │       ├── typing_input_widget.dart
│   │       └── typing_stats_widget.dart
│   ├── vocabulary/                # 词库管理
│   │   └── vocabulary_selection_page.dart
│   ├── course/                    # 课程学习
│   │   ├── course_selection_page.dart
│   │   └── course_detail_page.dart
│   ├── home/                      # 主页
│   │   └── home_page.dart
│   ├── profile/                   # 个人资料
│   │   └── profile_page.dart
│   └── onboarding/                # 首次设置
│       └── first_time_setup_page.dart
├── shared/                        # 共享层
│   ├── router/                    # 路由配置
│   │   └── app_router.dart
│   ├── services/                  # 业务服务
│   │   ├── tts_service.dart       # 文字转语音
│   │   ├── audio_service.dart     # 音效服务
│   │   ├── vocabulary_service.dart # 词库管理
│   │   ├── gamification_service.dart # 游戏化服务
│   │   ├── quiz_generator_service.dart # 测试生成
│   │   ├── fsrs_service.dart      # FSRS 算法
│   │   └── error_book_service.dart # 错题本
│   └── widgets/                   # 通用组件
│       ├── level_indicator.dart   # 等级显示
│       └── error_boundary.dart    # 错误边界
└── utils/                         # 工具函数
    ├── constants.dart             # 常量定义
    └── helpers.dart               # 辅助函数
```

## 🎯 开发规范

### 代码风格
- **命名规范**: 遵循 Dart 官方指南
  - 类名: `PascalCase`
  - 变量/方法: `camelCase`
  - 常量: `lowerCamelCase`
  - 私有成员: `_camelCase`

- **文件组织**:
  - 每个文件只包含一个主要类
  - 使用 `part` 和 `part of` 分割大型文件
  - 按功能分组，按字母排序导入

- **注释规范**:
  ```dart
  /// 单行文档注释 (用于 public API)
  class MyClass {}

  /// 多行文档注释
  ///
  /// 详细说明...
  class MyOtherClass {}

  // 单行实现注释
  /* 多行实现注释 */
  ```

### 状态管理

**使用 Provider 模式**:

```dart
// 1. 创建 Provider
class MyProvider extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void updateValue(int newValue) {
    _value = newValue;
    notifyListeners();
  }
}

// 2. 在应用顶层提供
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
  child: MyApp(),
)

// 3. 在组件中使用
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyProvider>();
    return Text('${provider.value}');
  }
}
```

### 路由管理

**使用 go_router**:

```dart
// 1. 定义路由
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/flashcard',
      name: 'flashcard',
      builder: (context, state) => FlashcardPage(),
    ),
  ],
);

// 2. 导航到页面
context.push('/flashcard');
context.go('/flashcard');

// 3. 带参数导航
context.push('/flashcard', extra: {'words': words});

// 4. 返回
context.pop();
context.pop(result);
```

**注意事项**:
- ✅ 主应用内使用 go_router
- ✅ 首次设置使用 Navigator (因为不在路由系统中)
- ❌ 避免混用 Navigator 和 go_router

### UI 设计

**Material Design 3**:
```dart
// 使用主题
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.headlineMedium

// 统一按钮样式
ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 16),
  textStyle: const TextStyle(fontSize: 18),
)

// 卡片设计
Card(
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: ...
  ),
)
```

**动画规范**:
- 页面切换: 250-300ms
- 卡片翻转: 300ms
- 淡入淡出: 250ms
- 使用 `AnimatedOpacity` 和 `AnimatedBuilder`

### 数据持久化

**SharedPreferences** (当前):
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');
final value = prefs.getString('key');
```

**注意事项**:
- 所有重要的用户数据都要持久化
- 在 Provider 的 `initialize()` 方法中加载数据
- 在数据修改后立即保存

## 🔧 常见任务

### 添加新功能

1. **创建功能目录**:
   ```bash
   mkdir lib/features/my_feature
   ```

2. **创建页面文件**:
   ```dart
   // lib/features/my_feature/my_feature_page.dart
   class MyFeaturePage extends StatelessWidget {
     const MyFeaturePage({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(...);
     }
   }
   ```

3. **添加路由**:
   ```dart
   // lib/shared/router/app_router.dart
   GoRoute(
     path: '/my-feature',
     name: 'my_feature',
     builder: (context, state) => MyFeaturePage(),
   )
   ```

4. **添加导航入口**:
   ```dart
   // 在主页或其他页面添加按钮
   ElevatedButton(
     onPressed: () => context.push('/my-feature'),
     child: Text('我的功能'),
   )
   ```

### 添加新的数据模型

```dart
// lib/data/models/my_model.dart
class MyModel {
  final String id;
  final String name;

  MyModel({
    required this.id,
    required this.name,
  });

  MyModel copyWith({
    String? id,
    String? name,
  }) {
    return MyModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

### 调试技巧

1. **使用 debugPrint**:
   ```dart
   import 'package:flutter/foundation.dart';

   debugPrint('调试信息: $variable');
   ```

2. **查看日志**:
   ```bash
   flutter logs
   ```

3. **使用 DevTools**:
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

4. **性能分析**:
   ```dart
   // 在代码中标记性能分析点
   FlutterTimeline.startSync('operation_name');
   // ... 执行操作
   FlutterTimeline.finishSync();
   ```

## ⚠️ 重要注意事项

### 必须避免的错误

1. **Session 初始化错误**:
   ```dart
   // ❌ 错误
   late final TypingSession _session;

   // ✅ 正确
   late TypingSession _session;
   ```

2. **路由混用**:
   ```dart
   // ❌ 错误 - 在 MaterialApp 内使用 go_router
   MaterialApp(
     home: FirstTimeSetupPage(
       onComplete: () => context.push('/home'), // 错误！
     ),
   )

   // ✅ 正确 - 使用回调
   MaterialApp(
     home: FirstTimeSetupPage(
       onComplete: () {
         setState(() {
           _isFirstTime = false;
         });
       },
     ),
   )
   ```

3. **动画不同步**:
   ```dart
   // ❌ 错误 - 时长不一致
   AnimatedOpacity(duration: Duration(milliseconds: 200), ...)
   AnimatedOpacity(duration: Duration(milliseconds: 300), ...)

   // ✅ 正确 - 统一时长
   const duration = Duration(milliseconds: 250);
   AnimatedOpacity(duration: duration, ...)
   ```

4. **忘记导入 foundation**:
   ```dart
   // ❌ 错误 - debugPrint 未定义
   debugPrint('message');

   // ✅ 正确
   import 'package:flutter/foundation.dart';
   debugPrint('message');
   ```

### 性能优化

1. **使用 const 构造函数**:
   ```dart
   const SizedBox(height: 16);
   const Text('Hello');
   ```

2. **避免不必要的重建**:
   ```dart
   // 使用 context.watch() 只在需要时监听
   final provider = context.watch<MyProvider>();

   // 或使用 context.read() 读取但不监听
   final provider = context.read<MyProvider>();
   ```

3. **列表优化**:
   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) {
       return ListTile(title: Text(items[index]));
     },
   )
   ```

## 🧪 测试

### 运行测试
```bash
# 所有测试
flutter test

# 覆盖率
flutter test --coverage

# 特定测试文件
flutter test test/widget_test.dart
```

### 编写测试
```dart
// Widget 测试
testWidgets('MyWidget has title', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('My Title'), findsOneWidget);
});

// 单元测试
test('Addition works', () {
  expect(add(1, 1), equals(2));
});
```

## 📦 构建

### Web 构建
```bash
flutter build web --release
```

### APK 构建
```bash
flutter build apk --release
```

### iOS 构建
```bash
flutter build ios --release
```

## 🔄 Git 工作流

### 分支策略
- `main` - 主分支，稳定版本
- `feature/*` - 功能分支
- `bugfix/*` - 修复分支

### 提交规范
```bash
# 格式
<type>(<scope>): <subject>

# 类型
feat: 新功能
fix: 修复
docs: 文档
style: 格式
refactor: 重构
test: 测试
chore: 构建

# 示例
feat(flashcard): 添加翻转动画
fix(typing): 修复最后一题不跳转问题
docs(readme): 更新安装说明
```

### 提交步骤
```bash
git add -A
git commit -m "feat: 添加新功能"
git push
```

## 📚 相关资源

- [Flutter 文档](https://flutter.dev/docs)
- [Dart 文档](https://dart.dev/guides)
- [Provider 包](https://pub.dev/packages/provider)
- [go_router 包](https://pub.dev/packages/go_router)
- [FSRS 算法](https://github.com/open-spaced-repetition/fsrs4go)
- [Material Design 3](https://m3.material.io/)

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📞 联系方式

- **开发者**: wjx0138
- **GitHub**: https://github.com/wjx0138
- **项目仓库**: https://github.com/wjx0138/english-learning-app

---

**最后更新**: 2026-03-05
**维护者**: wjx0138
