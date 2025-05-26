import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plan_pilot/screens/authentication/auth_screen.dart';
import 'package:plan_pilot/screens/authentication/sign_in_screen.dart';
import 'package:plan_pilot/todo_edit_viewmodel.dart';
import 'package:plan_pilot/utils/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'utils/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'screens/authentication/auth_viewmodel.dart';

import 'utils/session_manager.dart';// Added import statement

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones(); // <-- REQUIRED for scheduling
  await NotificationService.initialize();

  // // Register the UI isolate's SendPort to allow for communication from the
  // // background isolate.
  // IsolateNameServer.registerPortWithName(
  //   port.sendPort,
  //   'isolate',
  // );
  //
  // runApp(const AlarmManagerExampleApp());

  await AndroidAlarmManager.initialize();
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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initApp();

    // Listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _isLoggedIn = user != null && !user.isAnonymous;
      });
    });
  }

  Future<void> _initApp() async {
    final themeMode = await SessionManager.getThemeMode();
    final onboardingCompleted = await SessionManager.isOnboardingCompleted();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isDark = themeMode == ThemeMode.dark;
      _onboardingCompleted = onboardingCompleted;
      _isLoggedIn = user != null && !user.isAnonymous;
      _initialized = true;
    });
  }

  void toggleTheme() async {
    setState(() {
      isDark = !isDark;
    });
    await SessionManager.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void onboardingCompleted() async{
    await SessionManager.setOnboardingCompleted(true);
    setState(() {
      _onboardingCompleted = true;
    });
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
        home: Builder(
          builder: (context) {
            
            if (!_initialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!_onboardingCompleted) {
              return OnboardingScreen(
                onFinish: onboardingCompleted,
                isDark: isDark,
              );
            }

            // Check authentication status
            if (!_isLoggedIn) {
              return AuthScreen(
                isDark: isDark,
              );
            }

            return HomeScreen(
              isDark: isDark,
              onThemeToggle: toggleTheme,
            );
          },
        ),
      ),
    );
  }
}

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Example app for Espresso plugin.
class AlarmManagerExampleApp extends StatelessWidget {
  const AlarmManagerExampleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x9f4376f8),
      ),
      home: const _AlarmHomePage(),
    );
  }
}

class _AlarmHomePage extends StatefulWidget {
  const _AlarmHomePage();

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<_AlarmHomePage> {
  int _counter = 0;
  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();
    _checkExactAlarmPermission();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await _incrementCounter());
  }

  void _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    setState(() {
      _exactAlarmPermissionStatus = currentStatus;
    });
  }

  Future<void> _incrementCounter() async {
    developer.log('Increment counter!');
    print('Increment counter!');
    setState(() {
      _counter++;
    });
  }

  // The background
  static SendPort? uiSendPort;

  // The callback for our alarm
  @pragma('vm:entry-point')
  static Future<void> callback() async {
    developer.log('Alarm fired!');
    print('Alarm fired!');

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName('isolate');
    uiSendPort?.send(null);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme
        .of(context)
        .textTheme
        .headlineMedium;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android alarm manager plus example'),
        elevation: 4,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Alarms fired during this run of the app: $_counter',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Total alarms fired since app installation: $_counter ?? ''}',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (_exactAlarmPermissionStatus.isDenied)
              Text(
                'SCHEDULE_EXACT_ALARM is denied\n\nAlarms scheduling is not available',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              )
            else
              Text(
                'SCHEDULE_EXACT_ALARM is granted\n\nAlarms scheduling is available',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _exactAlarmPermissionStatus.isDenied
                  ? () async {
                await Permission.scheduleExactAlarm
                    .onGrantedCallback(() =>
                    setState(() {
                      _exactAlarmPermissionStatus =
                          PermissionStatus.granted;
                    }))
                    .request();
              }
                  : null,
              child: const Text('Request exact alarm permission'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _exactAlarmPermissionStatus.isGranted
                  ? () async {
                await AndroidAlarmManager.oneShot(
                  const Duration(seconds: 5),
                  // Ensure we have a unique alarm ID.
                  59,
                  NotificationService.alarmCallback,
                  exact: true,
                  wakeup: true,
                );
              }
                  : null,
              child: const Text('Schedule OneShot Alarm'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
