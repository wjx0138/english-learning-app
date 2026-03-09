import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/card_provider.dart';
import 'core/providers/progress_provider.dart';
import 'core/providers/quiz_provider.dart';
import 'shared/router/app_router.dart';
import 'shared/services/vocabulary_service.dart';
import 'features/onboarding/first_time_setup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          debugPrint('⚠️ SharedPreferences timeout - throwing exception');
          throw TimeoutException('SharedPreferences timeout');
        },
      );

      final isFirstTime = prefs.getBool('first_time_setup_complete') ?? true;

      if (mounted) {
        setState(() {
          _isFirstTime = isFirstTime;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error checking first time: $e');
      // On error, assume not first time to avoid getting stuck
      if (mounted) {
        setState(() {
          _isFirstTime = false;
          _isLoading = false;
        });
      }
    }
  }

  void _onSetupComplete() {
    // 直接更新状态，避免重新读取 SharedPreferences
    if (mounted) {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('加载中...'),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: _isFirstTime
          ? MaterialApp(
              title: '英语学习',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: ThemeMode.system,
              home: FirstTimeSetupPage(onComplete: _onSetupComplete),
            )
          : const AppWrapper(),
    );
  }
}

/// Wrapper for main app that initializes providers and uses router
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();

    // Fallback: Force show app after 3 seconds even if initialization isn't complete
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isInitialized) {
        debugPrint('⚠️ Initialization timeout - forcing app to show');
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      final appProvider = context.read<AppProvider>();
      final progressProvider = context.read<ProgressProvider>();

      // Initialize game data (includes points, level, achievements)
      await appProvider.initGameData().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('⚠️ AppProvider initialization timeout');
        },
      );

      // Initialize progress data (includes study statistics, achievements)
      await progressProvider.initialize().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('⚠️ ProgressProvider initialization timeout');
        },
      );

      // Load previously selected vocabulary book (non-blocking)
      _loadLastVocabulary(appProvider);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Initialization error: $e');
      // Still show the app even if initialization fails
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _loadLastVocabulary(AppProvider appProvider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBookId = prefs.getString('last_vocabulary_book_id');

      if (lastBookId != null && lastBookId.isNotEmpty) {
        final vocabularyService = VocabularyService();
        await vocabularyService.initialize();

        final book = vocabularyService.availableBooks
            .where((b) => b.id == lastBookId)
            .firstOrNull;

        if (book != null) {
          final words = await vocabularyService.loadVocabularyBook(book);
          await appProvider.loadVocabularyWords(words);
          debugPrint('✅ Loaded vocabulary: ${book.name} (${words.length} words)');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load last vocabulary: $e');
      // Don't fail - user can select vocabulary manually
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在加载应用...'),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: '英语学习',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
