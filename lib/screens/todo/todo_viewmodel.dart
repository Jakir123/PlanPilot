import 'package:flutter/material.dart';
import '../../utils/firebase_service.dart';
import '../../utils/notification_service.dart';
import 'dart:async';
import '../permission_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoEditViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  FirebaseService get firebaseService => _firebaseService;
  bool _isLoading = false;
  String? _error;
  Timer? _notificationTimer;

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> updateTodo({
    required BuildContext context,
    required String docId,
    required String userId,
    required String title,
    String? description,
    DateTime? dueDateTime,
    bool reminder = false,
    String priority = 'Low',
    String? category,
    bool isAnonymous = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final todoData = {
        'title': title,
        'description': description ?? '',
        'dueDateTime': dueDateTime?.toIso8601String(),
        'reminder': reminder,
        'priority': priority,
        'category': category ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Cancel existing notification if any
      if(reminder){
        await NotificationService.cancelAlarm(docId.hashCode);
      }

      // Schedule new notification if reminder is enabled and dueDateTime is set
      if (reminder && dueDateTime != null) {
        final success = await NotificationService.checkAndScheduleReminderUsingAlarmManager(
          context,
          title,
          description ?? '',
          dueDateTime,
          docId,
        );
        if (!success) {
          return false;
        }
      }

      await _firebaseService.updateTodo(
        userId: userId,
        docId: docId,
        todo: todoData,
        isAnonymous: isAnonymous,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTodo({
    required BuildContext context,
    required String userId,
    required String docId,
    required bool isNotificationEnabled,
    required bool isAnonymous,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Cancel any existing notification first
      if(isNotificationEnabled){
        NotificationService.cancelAlarm(
          docId.hashCode,
        );
      }

      await firebaseService.deleteTodo(
        userId: userId,
        docId: docId,
        isAnonymous: isAnonymous,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTodo({
    required BuildContext context,
    required String title,
    String? description,
    DateTime? dueDateTime,
    bool reminder = false,
    String priority = 'Low',
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = _firebaseService.getCurrentUser();
      if (user == null) {
        _error = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final isAnonymous = user.isAnonymous;
      final todo = {
        'title': title,
        'description': description ?? '',
        'dueDateTime': dueDateTime?.toIso8601String(),
        'reminder': reminder,
        'priority': priority,
        'category': category ?? '',
        'createdAt': DateTime.now().toIso8601String(),
        'isCompleted': false,
        'userId': user.uid,
      };

      // Save todo first to get the document ID
      final docRef = await _firebaseService.saveTodo(user.uid, todo, isAnonymous: isAnonymous);
      final docId = docRef.id;
      todo['id'] = docId;

      // If reminder is enabled and dueDateTime is set, schedule notification
      if (reminder && dueDateTime != null) {
        final success = await NotificationService.checkAndScheduleReminderUsingAlarmManager(
          context,
          title,
          description ?? '',
          dueDateTime,
          docId,
        );
        if (!success) {
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
