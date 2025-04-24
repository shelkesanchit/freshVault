import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  
  CategoryProvider() {
    _initializeDefaultCategories();
  }
  
  void _initializeDefaultCategories() {
    if (_categories.isEmpty) {
      _categories = [
        Category(
          id: 'food',
          name: 'Food',
          icon: Icons.fastfood,
          color: Colors.orange,
        ),
        Category(
          id: 'medicine',
          name: 'Medicine',
          icon: Icons.medication,
          color: Colors.red,
        ),
        Category(
          id: 'cosmetics',
          name: 'Cosmetics',
          icon: Icons.face,
          color: Colors.pink,
        ),
        Category(
          id: 'cleaning',
          name: 'Cleaning',
          icon: Icons.cleaning_services,
          color: Colors.blue,
        ),
        Category(
          id: 'other',
          name: 'Other',
          icon: Icons.category,
          color: Colors.grey,
        ),
      ];
    }
  }
  
  List<Category> get categories {
    return [..._categories];
  }
  
  Category findById(String id) {
    return _categories.firstWhere((category) => category.id == id);
  }
  
  Future<void> fetchAndSetCategories() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('categories')) {
      await _saveCategories();
      return;
    }
    
    final categoriesData = json.decode(prefs.getString('categories')!) as List<dynamic>;
    final loadedCategories = categoriesData.map((category) => Category.fromJson(category)).toList();
    
    if (loadedCategories.isEmpty) {
      _initializeDefaultCategories();
    } else {
      _categories = loadedCategories;
    }
    
    notifyListeners();
  }
  
  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _saveCategories();
    notifyListeners();
  }
  
  Future<void> updateCategory(Category updatedCategory) async {
    final categoryIndex = _categories.indexWhere((category) => category.id == updatedCategory.id);
    if (categoryIndex >= 0) {
      _categories[categoryIndex] = updatedCategory;
      await _saveCategories();
      notifyListeners();
    }
  }
  
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((category) => category.id == id);
    await _saveCategories();
    notifyListeners();
  }
  
  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String categoriesJson = json.encode(_categories.map((category) => category.toJson()).toList());
    await prefs.setString('categories', categoriesJson);
  }
  // Add these methods to your CategoryProvider class

Future<void> setCategories(List<Category> categories) async {
  _categories = categories;
  await _saveCategories();
  notifyListeners();
}
}