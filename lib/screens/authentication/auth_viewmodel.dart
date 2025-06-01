import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  String? _authError;

  User? get user => _user;
  String? get authError => _authError;

  bool get isAuthenticated => _user != null && !(_user?.isAnonymous ?? true);

  AuthViewModel(){
    checkAuthStatus();
    // Listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> checkAuthStatus() async {
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<User?> signInAnonymously() async {
    try {
      final user = await _firebaseService.signInAnonymously();
      _user = user;
      notifyListeners();
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<bool> signIn() async {
    setLoading(true);
    _authError = null;
    // Capture previous user (could be anonymous)
    final prevUser = FirebaseAuth.instance.currentUser;
    final wasAnonymous = prevUser?.isAnonymous == true;
    final prevAnonUid = prevUser?.uid;
    try {
      final user = await _firebaseService.signIn(_loginEmail, _loginPassword);
      _user = user;
      // If previous user was anonymous and new user is not anonymous, migrate vocabularies
      if (wasAnonymous && prevAnonUid != null && user != null && !user.isAnonymous) {
        await _firebaseService.migrateTodos(prevAnonUid, user.uid);
      }
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          _authError = 'Invalid email or password.';
          break;
        case 'invalid-email':
          _authError = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          _authError = 'This user account has been disabled.';
          break;
        default:
          _authError = 'Authentication failed. Please try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _authError = 'Authentication failed. Please try again.';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signUp() async {
    setLoading(true);
    _authError = null;
    // Capture previous user (could be anonymous)
    final prevUser = FirebaseAuth.instance.currentUser;
    final wasAnonymous = prevUser?.isAnonymous == true;
    final prevAnonUid = prevUser?.uid;
    try {
      final user = await _firebaseService.signUp(_signUpEmail, _signUpPassword);
      _user = user;
      // If previous user was anonymous and new user is not anonymous, migrate todos
      if (wasAnonymous && prevAnonUid != null && user != null && !user.isAnonymous) {
        await _firebaseService.migrateTodos(prevAnonUid, user.uid);
      }
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _authError = 'This email address is already registered.';
          break;
        case 'invalid-email':
          _authError = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          _authError = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          _authError = 'The password is too weak. Please choose a stronger password.';
          break;
        default:
          _authError = 'Registration failed. Please try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _authError = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    _user = null;
    notifyListeners();
  }

  // Loading state for button
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // Login fields
  String _loginEmail = '';
  String _loginPassword = '';
  String? _loginEmailError;
  String? _loginPasswordError;

  // Sign Up fields
  String _signUpEmail = '';
  String _signUpPassword = '';
  String _signUpConfirmPassword = '';
  String? _signUpEmailError;
  String? _signUpPasswordError;
  String? _signUpConfirmPasswordError;

  // Getters for errors
  String? get loginEmailError => _loginEmailError;
  String? get loginPasswordError => _loginPasswordError;
  String? get signUpEmailError => _signUpEmailError;
  String? get signUpPasswordError => _signUpPasswordError;
  String? get signUpConfirmPasswordError => _signUpConfirmPasswordError;


  // Setters for login fields
  void setLoginEmail(String value) {
    _loginEmail = value;
    _loginEmailError = null;
    notifyListeners();
  }

  void setLoginPassword(String value) {
    _loginPassword = value;
    _loginPasswordError = null;
    notifyListeners();
  }

  // Setters for sign up fields
  void setSignUpEmail(String value) {
    _signUpEmail = value;
    _signUpEmailError = null;
    notifyListeners();
  }

  void setSignUpPassword(String value) {
    _signUpPassword = value;
    _signUpPasswordError = null;
    notifyListeners();
  }

  void setSignUpConfirmPassword(String value) {
    _signUpConfirmPassword = value;
    _signUpConfirmPasswordError = null;
    notifyListeners();
  }

  // Validation methods
  bool validateLogin() {
    bool isValid = true;
    _loginEmailError = _validateEmail(_loginEmail);
    _loginPasswordError = _validatePassword(_loginPassword);
    if (_loginEmailError != null || _loginPasswordError != null) {
      isValid = false;
    }
    notifyListeners();
    return isValid;
  }

  bool validateSignUp() {
    bool isValid = true;
    _signUpEmailError = _validateEmail(_signUpEmail);
    _signUpPasswordError = _validatePassword(_signUpPassword);
    _signUpConfirmPasswordError = _validateConfirmPassword(_signUpPassword, _signUpConfirmPassword);
    if (_signUpEmailError != null || _signUpPasswordError != null || _signUpConfirmPasswordError != null) {
      isValid = false;
    }
    notifyListeners();
    return isValid;
  }

  // Email validation
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Change password fields
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;
  String? _changePasswordError;

  // Getters for change password errors
  String? get currentPasswordError => _currentPasswordError;
  String? get newPasswordError => _newPasswordError;
  String? get confirmNewPasswordError => _confirmNewPasswordError;
  String? get changePasswordError => _changePasswordError;

  // Setters for change password fields
  void setCurrentPassword(String value) {
    _currentPassword = value;
    _currentPasswordError = null;
    _changePasswordError = null;
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value;
    _newPasswordError = null;
    _changePasswordError = null;
    notifyListeners();
  }

  void setConfirmNewPassword(String value) {
    _confirmNewPassword = value;
    _confirmNewPasswordError = null;
    _changePasswordError = null;
    notifyListeners();
  }

  // Change password method
  Future<bool> changePassword() async {
    if (!_validateChangePassword()) return false;
    
    setLoading(true);
    _changePasswordError = null;
    
    try {
      await _firebaseService.changePassword(_currentPassword, _newPassword);
      // Clear fields on success
      _currentPassword = '';
      _newPassword = '';
      _confirmNewPassword = '';
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _currentPasswordError = 'Incorrect current password';
      } else {
        _changePasswordError = 'Failed to change password. Please try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _changePasswordError = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  bool _validateChangePassword() {
    bool isValid = true;
    
    if (_currentPassword.isEmpty) {
      _currentPasswordError = 'Current password is required';
      isValid = false;
    }
    
    final newPassError = _validatePassword(_newPassword);
    if (newPassError != null) {
      _newPasswordError = newPassError;
      isValid = false;
    }
    
    if (_newPassword != _confirmNewPassword) {
      _confirmNewPasswordError = 'New passwords do not match';
      isValid = false;
    }
    
    if (!isValid) {
      notifyListeners();
    }
    
    return isValid;
  }

  // Confirm password validation
  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm password cannot be empty';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
