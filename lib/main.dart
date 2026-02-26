import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/card_provider.dart';
import 'core/providers/progress_provider.dart';
import 'core/providers/quiz_provider.dart';
import 'shared/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
