import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SessionManager{

  // user info
  static Future<String> getUserName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("userName") ?? "";
  }
  static Future<void> setUserName(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", userName);
  }

  // Onboarding flag
  static Future<bool> isOnboardingCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', completed);
  }

  // Theme mode
  static Future<ThemeMode> getThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? mode = prefs.getString('theme_mode');
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.light;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String modeStr = mode == ThemeMode.dark ? 'dark' : 'light';
    await prefs.setString('theme_mode', modeStr);
  }
}