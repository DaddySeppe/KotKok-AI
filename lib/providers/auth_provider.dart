import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  bool _isBootstrapped = false;
  bool _isAuthenticated = false;
  String? _userId;
  String? _fullName;
  String? _email;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isBootstrapped => _isBootstrapped;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String get displayName => _fullName?.trim().isNotEmpty == true ? _fullName! : 'KotKok-user';
  String? get email => _email;
  String? get errorMessage => _errorMessage;

  Future<void> bootstrap() async {
    _isBootstrapped = false;
    final result = await _service.bootstrap();
    _isAuthenticated = result.isAuthenticated;
    _userId = result.userId;
    _fullName = result.fullName;
    _email = result.email;
    _isBootstrapped = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    final result = await _service.signIn(email: email, password: password);
    _setLoading(false);
    if (result.success) {
      _isAuthenticated = true;
      _userId = result.userId;
      _fullName = result.fullName;
      _email = result.email;
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);
    final result = await _service.signUp(fullName: fullName, email: email, password: password);
    _setLoading(false);
    if (result.success) {
      _isAuthenticated = true;
      _userId = result.userId;
      _fullName = result.fullName;
      _email = result.email;
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _service.signOut();
    _isAuthenticated = false;
    _userId = null;
    _fullName = null;
    _email = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
