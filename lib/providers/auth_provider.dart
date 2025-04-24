import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  
  AuthProvider() {
    _autoLogin();
  }
  
  Future<void> _autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return;
      }
      
      final userEmail = prefs.getString('userEmail');
      if (userEmail != null) {
        _isAuthenticated = true;
        _userEmail = userEmail;
        _userId = prefs.getString('userId');
        notifyListeners();
      }
    } catch (e) {
      // Handle error during auto-login
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      // For demo, hardcode the credentials
      if (email == 'sanchit@gmail.com' && password == '1234') {
        _isAuthenticated = true;
        _userEmail = email;
        _userId = 'user-001';
        
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userEmail', email);
        prefs.setString('userId', 'user-001');
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> signup(String email, String password) async {
    try {
      // For demo, always allow sign up
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
      
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userEmail', email);
      prefs.setString('userId', _userId!);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userEmail = null;
      _userId = null;
      
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('userEmail');
      prefs.remove('userId');
      
      notifyListeners();
    } catch (e) {
      // Handle error during logout
    }
  }
}