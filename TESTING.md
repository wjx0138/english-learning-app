# 测试指南 - English Learning App

## 📊 测试现状分析

### ✅ 已有测试基础设施

**测试框架**: Flutter 官方测试框架 (`flutter_test`)

**测试文件** (11个):
```
test/
├── core/
│   ├── providers/providers_test.dart      # Provider 单元测试
│   └── utils/srs_algorithm_test.dart     # SRS 算法测试
├── data/
│   ├── models/course_test.dart           # Course 模型测试
│   └── models/word_test.dart             # Word 模型测试
├── features/
│   └── flashcard/widgets/card_widget_test.dart  # 闪卡组件测试
├── integration/
│   └── learning_flow_test.dart           # 学习流程集成测试
├── shared/
│   ├── services/gamification_service_test.dart  # 游戏化服务测试
│   └── widgets/
│       ├── common_widgets_test.dart      # 通用组件测试
│       ├── typing_widgets_test.dart      # 跟打组件测试
│       └── word_card_test.dart           # 单词卡片测试
└── e2e/
    └── user_flow_test.dart               # 端到端用户流程测试
```

## 🚀 运行测试

### 1. 运行所有测试
```bash
cd /Users/wangjiaxin/Desktop/english/english_learning_app

# 运行所有测试
flutter test

# 详细输出
flutter test --verbose

# 带覆盖率的测试
flutter test --coverage
```

### 2. 运行特定测试文件
```bash
# 测试单个文件
flutter test test/shared/widgets/typing_widgets_test.dart

# 测试特定目录
flutter test test/data/models/

# 测试特定测试组
flutter test --name "TypingInput"
```

### 3. 运行特定平台的测试
```bash
# Web 测试
flutter test -d chrome

# 移动端测试
flutter test -d iPhone
flutter test -d Android
```

### 4. 查看测试覆盖率
```bash
# 生成覆盖率报告
flutter test --coverage

# 在 macOS 上查看报告
open coverage/lcov.info/index.html

# 或使用 genhtml 工具
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 5. 监视模式（开发时使用）
```bash
# 自动重新运行测试
flutter test --watch

# 只运行失败的测试
flutter test --failed
```

## 📝 测试类型说明

### 1. 单元测试 (Unit Tests)

**用途**: 测试独立的函数、类或方法

**示例**:
```dart
// test/core/utils/srs_algorithm_test.dart
void main() {
  group('SRS Algorithm Tests', () {
    test('Should calculate next review date correctly', () {
      final now = DateTime.now();
      final nextDate = FSRS.calculateNextReview(
        lastReview: now,
        interval: 1,
        easeFactor: 2.5,
      );

      expect(nextDate.isAfter(now), true);
    });
  });
}
```

### 2. 组件测试 (Widget Tests)

**用途**: 测试单个 UI 组件的渲染和交互

**示例**:
```dart
// test/shared/widgets/typing_widgets_test.dart
testWidgets('Should display target word', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TypingInput(
          targetWord: 'test',
          onTextChanged: (_) {},
          onCorrect: () {},
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('test'), findsOneWidget);
});
```

### 3. 集成测试 (Integration Tests)

**用途**: 测试多个组件或服务协同工作

**示例**:
```dart
// test/integration/learning_flow_test.dart
testWidgets('Complete learning flow with gamification', (tester) async {
  // 测试完整的学习流程，包括：
  // 1. 选择词库
  // 2. 学习闪卡
  // 3. 获得积分
  // 4. 升级
});
```

### 4. 端到端测试 (E2E Tests)

**用途**: 测试完整的用户场景

**示例**:
```dart
// test/e2e/user_flow_test.dart
testWidgets('New user onboarding flow', (tester) async {
  // 测试新用户从首次设置到完成第一次学习的完整流程
});
```

## 🛠️ 编写新测试

### 测试模板

#### 1. 单元测试模板
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/...';

void main() {
  group('MyFeature Tests', () {
    setUp(() {
      // 每个测试前的初始化
    });

    tearDown(() {
      // 每个测试后的清理
    });

    test('Should do something correctly', () {
      // Arrange
      final input = 'test';

      // Act
      final result = myFunction(input);

      // Assert
      expect(result, equals('expected'));
    });

    test('Should handle edge case', () {
      // 测试边界情况
    });
  });
}
```

#### 2. 组件测试模板
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/...';

void main() {
  group('MyWidget Tests', () {
    testWidgets('Should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MyWidget), findsOneWidget);
    });

    testWidgets('Should respond to user interaction', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyWidget(
              onTap: () => callbackCalled = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 模拟用户点击
      await tester.tap(find.byType(MyWidget));
      await tester.pump();

      expect(callbackCalled, true);
    });

    testWidgets('Should update when data changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyWidget(value: 'initial'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 更新数据
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyWidget(value: 'updated'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('updated'), findsOneWidget);
    });
  });
}
```

#### 3. Provider 测试模板
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:english_learning_app/core/providers/my_provider.dart';

void main() {
  group('MyProvider Tests', () {
    late MyProvider provider;

    setUp(() {
      provider = MyProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('Should have initial value', () {
      expect(provider.value, equals(defaultValue));
    });

    test('Should update value correctly', () {
      provider.updateValue('new value');

      expect(provider.value, equals('new value'));
    });

    test('Should notify listeners when value changes', () {
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      provider.updateValue('new value');

      expect(notified, true);
    });
  });
}
```

#### 4. 服务测试模板
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_learning_app/shared/services/my_service.dart';

void main() {
  group('MyService Tests', () {
    late MyService service;

    setUp(() async {
      // 设置模拟依赖
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();

      service = MyService();
      await service.initialize();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('Should perform operation correctly', () async {
      final result = await service.doSomething();

      expect(result, isNotNull);
      expect(result.success, true);
    });

    test('Should handle errors gracefully', () async {
      // 测试错误处理
    });
  });
}
```

## 🎯 测试最佳实践

### 1. 测试命名规范

```dart
// ✅ 好的命名
test('Should return user when ID is valid', () {});
test('Should throw exception when user not found', () {});

// ❌ 不好的命名
test('test1', () {});
test('works', () {});
```

### 2. 使用 AAA 模式 (Arrange, Act, Assert)

```dart
test('Should calculate total price correctly', () {
  // Arrange - 准备测试数据
  final cart = Cart();
  cart.addItem(Item(price: 10, quantity: 2));

  // Act - 执行被测试的功能
  final total = cart.calculateTotal();

  // Assert - 验证结果
  expect(total, equals(20));
});
```

### 3. 测试边界条件

```dart
test('Should handle edge cases', () {
  // 测试空值
  expect(function(null), equals(default));

  // 测试空集合
  expect(function([]), equals(default));

  // 测试最大值/最小值
  expect(function(MAX_INT), handlesGracefully);

  // 测试负数
  expect(function(-1), handlesGracefully);
});
```

### 4. 使用有意义的断言

```dart
// ✅ 好的断言
expect(user.name, equals('John'));
expect(user.age, greaterThan(18));
expect(items, contains('item1'));

// ❌ 不好的断言
expect(user != null, true);
expect(user.name == 'John', true);
```

### 5. 保持测试独立

```dart
// ❌ 错误 - 测试之间有依赖
late User user;

setUp(() {
  user = User('name');
});

test('Test 1', () {
  user.name = 'new name'; // 影响其他测试
});

// ✅ 正确 - 每个测试独立
test('Test 1', () {
  final user = User('name');
  user.name = 'new name';
  expect(user.name, equals('new name'));
});

test('Test 2', () {
  final user = User('name');
  expect(user.name, equals('name'));
});
```

### 6. 使用模拟 (Mock) 和桩 (Stub)

```dart
// 使用 Mockito 包
import 'package:mockito/mockito.dart';

class MockService extends Mock implements MyService {}

test('Should call service correctly', () async {
  final mockService = MockService();

  // 设置桩
  when(mockService.getData()).thenAnswer((_) async => 'mock data');

  // 使用模拟对象
  final result = await mockService.getData();

  // 验证调用
  verify(mockService.getData()).called(1);
  expect(result, equals('mock data'));
});
```

## 📦 推荐的测试依赖

虽然项目已经有基本的测试框架，但以下包可以增强测试能力：

### 1. Mockito - 模拟对象
```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### 2. Golden Tests - 快照测试
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  golden_toolkit: ^0.15.0
```

### 3. Integration Test - 集成测试
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### 4. Provider 测试扩展
```yaml
dev_dependencies:
  provider: ^6.1.1
  flutter_test:
    sdk: flutter
```

## 🔧 调试测试

### 1. 打印调试信息
```dart
test('Debug test', () {
  final value = calculate();

  // 使用 print 调试
  print('Value: $value');

  // 或者使用 debugPrint
  debugPrint('Detailed info: $value');

  expect(value, isNotNull);
});
```

### 2. 暂停测试执行
```dart
test('Paused test', () async {
  await tester.pumpWidget(MyWidget());
  await tester.pumpAndSettle();

  // 暂停以便手动检查
  await tester.pump(const Duration(hours: 1));

  expect(find.byType(MyWidget), findsOneWidget);
});
```

### 3. 查看组件树
```dart
test('Inspect widget tree', () async {
  await tester.pumpWidget(MyWidget());
  await tester.pumpAndSettle();

  // 打印组件树
  debugDumpApp();
});
```

## 📈 测试覆盖率目标

### 推荐的覆盖率目标：

- **整体代码覆盖率**: ≥ 80%
- **核心业务逻辑**: ≥ 90%
- **UI 组件**: ≥ 70%
- **工具函数**: ≥ 95%

### 查看覆盖率报告

```bash
# 生成覆盖率
flutter test --coverage

# 合并覆盖率（如果有多个测试套件）
lcov --merge coverage/lcov.info -o coverage/merged.info

# 生成 HTML 报告
genhtml coverage/merged.info -o coverage/html

# 在浏览器中查看
open coverage/html/index.html
```

## 🚨 常见测试问题

### 1. 测试超时
```bash
# 增加超时时间
flutter test --timeout=30s
```

### 2. 平台特定问题
```bash
# 指定测试平台
flutter test --platform=chrome
```

### 3. 测试依赖问题
```bash
# 清理并重新获取依赖
flutter clean
flutter pub get
flutter test
```

### 4. 异步测试问题
```dart
// ✅ 正确处理异步
test('Async test', () async {
  await Future.delayed(Duration(seconds: 1));
  expect(true, true);
});

// ✅ 使用 tester.pump() 处理动画
testWidgets('Animation test', (tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.pump(); // 触发一帧
  await tester.pump(Duration(milliseconds: 300)); // 等待动画完成
});
```

## 📚 相关资源

- [Flutter 测试文档](https://flutter.dev/testing)
- [Flutter 测试 Cookbook](https://flutter.dev/docs/cookbook/testing)
- [Mockito 包文档](https://pub.dev/packages/mockito)
- [Provider 测试指南](https://pub.dev/documentation/provider/latest/provider/provider-library.html)

## ✅ 检查清单

在提交代码前，确保：

- [ ] 所有测试通过
- [ ] 测试覆盖率符合要求
- [ ] 新功能有对应的测试
- [ ] Bug 修复有回归测试
- [ ] 测试命名清晰
- [ ] 测试独立且可重复
- [ ] 异常情况有测试覆盖

---

**最后更新**: 2026-03-05
**维护者**: wjx0138
