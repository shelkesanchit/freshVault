import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _prefsKey = 'languageCode';
  
  String _currentLanguageCode = 'en';
  Map<String, Map<String, String>> _translations = {};
  
  LanguageProvider() {
    _loadLanguage();
    _initTranslations();
  }
  
  String get currentLanguageCode => _currentLanguageCode;
  
  Locale get currentLocale => Locale(_currentLanguageCode);
  
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語', 'flag': '🇯🇵'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский', 'flag': '🇷🇺'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português', 'flag': '🇵🇹'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어', 'flag': '🇰🇷'},
    {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'nl', 'name': 'Dutch', 'nativeName': 'Nederlands', 'flag': '🇳🇱'},
    {'code': 'sv', 'name': 'Swedish', 'nativeName': 'Svenska', 'flag': '🇸🇪'},
    {'code': 'pl', 'name': 'Polish', 'nativeName': 'Polski', 'flag': '🇵🇱'},
    {'code': 'da', 'name': 'Danish', 'nativeName': 'Dansk', 'flag': '🇩🇰'},
    {'code': 'fi', 'name': 'Finnish', 'nativeName': 'Suomi', 'flag': '🇫🇮'},
    {'code': 'no', 'name': 'Norwegian', 'nativeName': 'Norsk', 'flag': '🇳🇴'},
  ];
  
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLanguage = prefs.getString(_prefsKey);
      
      if (storedLanguage != null && 
          supportedLanguages.any((lang) => lang['code'] == storedLanguage)) {
        _currentLanguageCode = storedLanguage;
        notifyListeners();
      }
    } catch (e) {
      // Handle error loading language
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguageCode == languageCode) return;
    
    try {
      _currentLanguageCode = languageCode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, languageCode);
      
      notifyListeners();
    } catch (e) {
      // Handle error setting language
    }
  }
  
  // For backward compatibility with LanguageScreen
  void setLocale(Locale locale) {
    setLanguage(locale.languageCode);
  }
  
  String getTranslatedValue(String key) {
    final translations = _translations[_currentLanguageCode];
    
    if (translations != null && translations.containsKey(key)) {
      return translations[key]!;
    }
    
    // If translation not found, use English as fallback
    final englishTranslations = _translations['en'];
    if (englishTranslations != null && englishTranslations.containsKey(key)) {
      return englishTranslations[key]!;
    }
    
    // If no translation found, return the key itself
    return key;
  }
  
  void _initTranslations() {
    _translations = {
      'en': {
        // General
        'FreshVault': 'FreshVault',
        'Manage your expiry dates': 'Manage your expiry dates',
        'Version': 'Version',
        'Home': 'Home',
        'Categories': 'Categories',
        'Settings': 'Settings',
        'Language': 'Language',
        'Statistics': 'Statistics',
        'Display Templates': 'Display Templates',
        'Data Management': 'Data Management',
        'Shopping List': 'Shopping List',
        'Scan Barcode': 'Scan Barcode',
        'Calendar View': 'Calendar View',
        'Bulk Operations': 'Bulk Operations',
        'Cancel': 'Cancel',
        'Delete': 'Delete',
        'Edit': 'Edit',
        'Save': 'Save',
        'User': 'User',
        'Current Date': 'Current Date',
        'Light Mode': 'Light Mode',
        'Dark Mode': 'Dark Mode',
        'Developed by Sanchit Shelke': 'Developed by Sanchit Shelke',
        
        // Add Item Screen
        'Add Item': 'Add Item',
        'Edit Item': 'Edit Item',
        'Product Details': 'Product Details',
        'Additional Information': 'Additional Information',
        'Product Image': 'Product Image',
        'Name': 'Name',
        'Product name': 'Product name',
        'Category': 'Category',
        'Select category': 'Select category',
        'Quantity': 'Quantity',
        'Expiry Date': 'Expiry Date',
        'Select expiry date': 'Select expiry date',
        'Location': 'Location',
        'Select location': 'Select location',
        'Batch Number': 'Batch Number',
        'Optional batch number': 'Optional batch number',
        'Notes': 'Notes',
        'Additional notes': 'Additional notes',
        'No image selected': 'No image selected',
        'Take Photo': 'Take Photo',
        'Gallery': 'Gallery',
        'Add Product': 'Add Product',
        'Update Product': 'Update Product',
        'Please enter a product name': 'Please enter a product name',
        'Please select a category': 'Please select a category',
        'Please select an expiry date': 'Please select an expiry date',
        'Set Date': 'Set Date',
        
        // And many more translations...
      },
      
      // Add translations for other languages as well
    };
  }
}