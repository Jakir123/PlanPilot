import 'package:flutter/material.dart';
import 'utils/firebase_service.dart';

class TodoEditViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseService get firebaseService => _firebaseService;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> updateTodo({
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
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTodo({
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
      await _firebaseService.saveTodo(user.uid, todo, isAnonymous: isAnonymous);
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
}
