import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: translate('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search functionality
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const ItemsGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddItemScreen.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: translate('Add Item'),
      ),
    );
  }
}

class ItemsGrid extends StatefulWidget {
  const ItemsGrid({Key? key}) : super(key: key);

  @override
  State<ItemsGrid> createState() => _ItemsGridState();
}

class _ItemsGridState extends State<ItemsGrid> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final categories = categoryProvider.categories;
    
    return Column(
      children: [
        Material(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: translate('All Items')),
              Tab(text: translate('Expired')),
              Tab(text: translate('Expiring Soon')),
              Tab(text: translate('Good')),
            ],
          ),
        ),
        
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Search Field
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: translate('Search items...'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              
              // Category Filter
              const SizedBox(width: 8),
              PopupMenuButton<String?>(
                icon: Icon(
                  Icons.filter_list,
                  color: _selectedCategoryId != null
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                tooltip: translate('Filter by category'),
                onSelected: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: null,
                    child: Row(
                      children: [
                        const Icon(Icons.clear),
                        const SizedBox(width: 8),
                        Text(translate('All Categories')),
                      ],
                    ),
                  ),
                  ...categories.map(
                    (category) => PopupMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Sort Options
              PopupMenuButton(
                icon: const Icon(Icons.sort),
                tooltip: translate('Sort by'),
                onSelected: (value) {
                  // Handle sorting options
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'name_asc',
                    child: Text(translate('Name (A to Z)')),
                  ),
                  PopupMenuItem(
                    value: 'name_desc',
                    child: Text(translate('Name (Z to A)')),
                  ),
                  PopupMenuItem(
                    value: 'expiry_asc',
                    child: Text(translate('Expiry Date (Nearest)')),
                  ),
                  PopupMenuItem(
                    value: 'expiry_desc',
                    child: Text(translate('Expiry Date (Furthest)')),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Items Display
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Items Tab
              ItemsTabContent(
                items: itemProvider.items,
                searchQuery: _searchQuery,
                categoryId: _selectedCategoryId,
                emptyMessage: translate('No items found'),
                emptyDescription: translate('Add your first item by clicking the + button below'),
              ),
              
              // Expired Items Tab
              ItemsTabContent(
                items: itemProvider.expiredItems,
                searchQuery: _searchQuery,
                categoryId: _selectedCategoryId,
                emptyMessage: translate('No expired items'),
                emptyDescription: translate('You have no expired items'),
              ),
              
              // Expiring Soon Tab
              ItemsTabContent(
                items: itemProvider.expiringSoonItems,
                searchQuery: _searchQuery,
                categoryId: _selectedCategoryId,
                emptyMessage: translate('No items expiring soon'),
                emptyDescription: translate('You have no items expiring soon'),
              ),
              
              // Good Items Tab
              ItemsTabContent(
                items: itemProvider.goodItems,
                searchQuery: _searchQuery,
                categoryId: _selectedCategoryId,
                emptyMessage: translate('No items in good condition'),
                emptyDescription: translate('Add items to see them here'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ItemsTabContent extends StatelessWidget {
  final List items;
  final String searchQuery;
  final String? categoryId;
  final String emptyMessage;
  final String emptyDescription;
  
  const ItemsTabContent({
    Key? key,
    required this.items,
    required this.searchQuery,
    this.categoryId,
    required this.emptyMessage,
    required this.emptyDescription,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Filter items by search query and category
    final filteredItems = items.where((item) {
      final matchesQuery = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = categoryId == null || item.categoryId == categoryId;
      return matchesQuery && matchesCategory;
    }).toList();
    
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              items.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                emptyDescription,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    // Use ListView instead of GridView for better display of ItemCard
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredItems.length,
      itemBuilder: (ctx, index) {
        final item = filteredItems[index];
        return ItemCard(item: item);
      },
    );
  }
}