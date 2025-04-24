import 'package:flutter/foundation.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  
  List<NotificationItem> get notifications => [..._notifications];
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  NotificationProvider() {
    _initializeNotifications();
  }
  
  void _initializeNotifications() {
    // Add some demo notifications
    addNotification(
      'Welcome to FreshVault',
      'Track your product expiry dates easily and never let a product expire again.',
    );
    
    addNotification(
      'Getting Started',
      'Add your first product by clicking the + button on the home screen.',
    );
    
    // Add a notification about upcoming expiry
    addNotification(
      'Items Expiring Soon',
      'You have 3 items that will expire within the next week.',
    );
  }
  
  void addNotification(String title, String message) {
    _notifications.add(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    
    notifyListeners();
  }
  
  void markAsRead(String id) {
    final notification = _notifications.firstWhere((n) => n.id == id);
    notification.isRead = true;
    notifyListeners();
  }
  
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }
  
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}