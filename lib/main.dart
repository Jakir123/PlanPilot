import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plan_pilot/todo_edit_viewmodel.dart';
import 'package:plan_pilot/utils/notification_service.dart';
import 'utils/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'screens/authentication/auth_viewmodel.dart';

import 'utils/session_manager.dart';// Added import statement

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  bool _initialized = false;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final themeMode = await SessionManager.getThemeMode();
    final onboardingCompleted = await SessionManager.isOnboardingCompleted();
    setState(() {
      isDark = themeMode == ThemeMode.dark;
      _onboardingCompleted = onboardingCompleted;
      _initialized = true;
    });
  }

  void toggleTheme() async {
    setState(() {
      isDark = !isDark;
    });
    await SessionManager.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<TodoEditViewModel>(create: (_) => TodoEditViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: _onboardingCompleted
            ? HomeScreen(
                isDark: isDark,
                onThemeToggle: toggleTheme,
              )
            : OnboardingScreen(
                onFinish: () async {
                  await SessionManager.setOnboardingCompleted(true);
                  setState(() {
                    _onboardingCompleted = true;
                  });
                },
                isDark: isDark,
              ),
      ),
    );
  }
}
