import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  DateTime _currentDateTime;
  String _currentUserLogin;
  
  UserProvider({
    required DateTime currentDateTime,
    required String currentUserLogin,
  })  : _currentDateTime = currentDateTime,
        _currentUserLogin = currentUserLogin;
  
  DateTime get currentDateTime => _currentDateTime;
  String get currentUserLogin => _currentUserLogin;
  
  void updateCurrentDateTime(DateTime newDateTime) {
    _currentDateTime = newDateTime;
    notifyListeners();
  }
  
  void updateCurrentUserLogin(String newUserLogin) {
    _currentUserLogin = newUserLogin;
    notifyListeners();
  }
}