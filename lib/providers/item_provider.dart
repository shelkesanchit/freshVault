import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/item.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  
  // Constructor
  ItemProvider() {
    _loadItems();
  }
  
  // Getters
  List<Item> get items {
    return [..._items];
  }
  
  List<Item> get expiredItems {
    return _items.where((item) => item.isExpired).toList();
  }
  
  List<Item> get expiringSoonItems {
    return _items.where((item) => !item.isExpired && item.isExpiringSoon).toList();
  }
  
  List<Item> get goodItems {
    return _items.where((item) => !item.isExpired && !item.isExpiringSoon).toList();
  }
  
  // Methods
  Item? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Item> getItemsByCategory(String categoryId) {
    return _items.where((item) => item.categoryId == categoryId).toList();
  }
  
  Future<void> addItem(Item item) async {
    _items.add(item);
    await _saveItems();
    notifyListeners();
  }
  
  Future<void> updateItem(Item updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index >= 0) {
      _items[index] = updatedItem;
      await _saveItems();
      notifyListeners();
    }
  }
  
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveItems();
    notifyListeners();
  }
  
  // Add the missing method for CategoryScreen.dart
  Future<void> deleteCategoryItems(String categoryId) async {
    _items.removeWhere((item) => item.categoryId == categoryId);
    await _saveItems();
    notifyListeners();
  }
  
  // Add the missing method for DataManagementScreen.dart
  Future<void> setItems(List<Item> newItems) async {
    _items = newItems;
    await _saveItems();
    notifyListeners();
  }
  
  // Storage
  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('items')) {
        return;
      }
      
      final itemsData = prefs.getString('items');
      if (itemsData != null) {
        final itemsList = json.decode(itemsData) as List<dynamic>;
        _items = itemsList.map((item) => Item.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error loading items
    }
  }
  
  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsData = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('items', itemsData);
    } catch (e) {
      // Handle error saving items
    }
  }
  
  // Import/Export
  Future<void> importItems(List<dynamic> itemsData) async {
    try {
      final newItems = itemsData.map((item) => Item.fromJson(item)).toList();
      _items = newItems;
      await _saveItems();
      notifyListeners();
    } catch (e) {
      // Handle error importing items
      rethrow;
    }
  }
  
  List<Map<String, dynamic>> exportItems() {
    return _items.map((item) => item.toJson()).toList();
  }
  
  // Clear all
  Future<void> clearAll() async {
    _items.clear();
    await _saveItems();
    notifyListeners();
  }
}