import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/item_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';

class ShoppingListItem {
  final String id;
  final String name;
  bool isChecked;
  
  ShoppingListItem({
    required this.id,
    required this.name,
    this.isChecked = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
    };
  }
  
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'],
      name: json['name'],
      isChecked: json['isChecked'] ?? false,
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  static const routeName = '/shopping-list';
  
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _textEditingController = TextEditingController();
  List<ShoppingListItem> _shoppingList = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }
  
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
  
  Future<void> _loadShoppingList() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final shoppingListData = prefs.getString('shopping_list');
      
      if (shoppingListData != null) {
        final decodedData = json.decode(shoppingListData) as List<dynamic>;
        setState(() {
          _shoppingList = decodedData
              .map((item) => ShoppingListItem.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      // Handle error loading shopping list
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveShoppingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shoppingListData = json.encode(
        _shoppingList.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('shopping_list', shoppingListData);
    } catch (e) {
      // Handle error saving shopping list
    }
  }
  
  void _addItem(String name) {
    if (name.trim().isEmpty) return;
    
    setState(() {
      _shoppingList.add(
        ShoppingListItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
        ),
      );
      _textEditingController.clear();
    });
    
    _saveShoppingList();
  }
  
  void _removeItem(String id) {
    setState(() {
      _shoppingList.removeWhere((item) => item.id == id);
    });
    
    _saveShoppingList();
  }
  
  void _toggleItem(String id) {
    setState(() {
      final item = _shoppingList.firstWhere((item) => item.id == id);
      item.isChecked = !item.isChecked;
    });
    
    _saveShoppingList();
  }
  
  void _clearCompletedItems() {
    setState(() {
      _shoppingList.removeWhere((item) => item.isChecked);
    });
    
    _saveShoppingList();
  }
  
  void _addExpiredItemsToList() {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final expiredItems = itemProvider.expiredItems;
    
    setState(() {
      for (final item in expiredItems) {
        // Check if the item is already in the shopping list
        if (!_shoppingList.any((listItem) => listItem.name == item.name)) {
          _shoppingList.add(
            ShoppingListItem(
              id: DateTime.now().millisecondsSinceEpoch.toString() + item.id,
              name: item.name,
            ),
          );
        }
      }
    });
    
    _saveShoppingList();
    
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('Expired items added to shopping list')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Shopping List')),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'add_expired',
                child: Row(
                  children: [
                    const Icon(Icons.add_shopping_cart, size: 20),
                    const SizedBox(width: 8),
                    Text(translate('Add Expired Items')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    const Icon(Icons.cleaning_services, size: 20),
                    const SizedBox(width: 8),
                    Text(translate('Clear Completed')),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'add_expired') {
                _addExpiredItemsToList();
              } else if (value == 'clear_completed') {
                _clearCompletedItems();
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: translate('Add item to shopping list'),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _addItem,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).primaryColor,
                      onPressed: () => _addItem(_textEditingController.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _shoppingList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              translate('Your shopping list is empty'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_shopping_cart),
                              label: Text(translate('Add Expired Items')),
                              onPressed: _addExpiredItemsToList,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _shoppingList.length,
                        itemBuilder: (ctx, index) {
                          final item = _shoppingList[index];
                          return Dismissible(
                            key: Key(item.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) => _removeItem(item.id),
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: item.isChecked
                                        ? Colors.grey
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: item.isChecked,
                                onChanged: (value) => _toggleItem(item.id),
                                activeColor: Theme.of(context).primaryColor,
                                secondary: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeItem(item.id),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}