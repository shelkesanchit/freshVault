import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../providers/language_provider.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/categories';
  
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryNameController = TextEditingController();
  Color selectedColor = Colors.blue;
  IconData selectedIcon = Icons.category;
  
  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Categories')),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      translate('Add New Category'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        labelText: translate('Category Name'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(translate('Select Icon')),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildIconOption(Icons.shopping_basket),
                                  _buildIconOption(Icons.fastfood),
                                  _buildIconOption(Icons.local_drink),
                                  _buildIconOption(Icons.medication),
                                  _buildIconOption(Icons.cleaning_services),
                                  _buildIconOption(Icons.pets),
                                  _buildIconOption(Icons.category),
                                  _buildIconOption(Icons.bakery_dining),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(translate('Select Color')),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildColorOption(Colors.red),
                                  _buildColorOption(Colors.blue),
                                  _buildColorOption(Colors.green),
                                  _buildColorOption(Colors.amber),
                                  _buildColorOption(Colors.purple),
                                  _buildColorOption(Colors.teal),
                                  _buildColorOption(Colors.orange),
                                  _buildColorOption(Colors.pink),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_categoryNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                translate('Please enter a category name'),
                              ),
                            ),
                          );
                          return;
                        }
                        
                        // Fixed: Added the 'id' parameter 
                        final newCategory = Category(
                          id: const Uuid().v4(), // Generate a unique ID
                          name: _categoryNameController.text,
                          icon: selectedIcon,
                          color: selectedColor,
                        );
                        
                        categoryProvider.addCategory(newCategory);
                        _categoryNameController.clear();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              translate('Category added successfully'),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Text(translate('Add Category')),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Text(translate('No categories added yet')),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: categories.length,
                    itemBuilder: (ctx, index) {
                      final category = categories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: category.color.withOpacity(0.2),
                            child: Icon(category.icon, color: category.color),
                          ),
                          title: Text(category.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(context, category),
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
  
  Widget _buildIconOption(IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIcon = icon;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selectedIcon == icon ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedIcon == icon ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: selectedIcon == icon ? selectedColor : Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
  
  void _showDeleteDialog(BuildContext context, Category category) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('Delete Category')),
        content: Text(
          '${translate('Are you sure you want to delete')} ${category.name}? ${translate('All items in this category will also be deleted.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(translate('Cancel')),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false).deleteCategory(category.id);
              Provider.of<ItemProvider>(context, listen: false).deleteCategoryItems(category.id);
              Navigator.of(ctx).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    translate('Category deleted successfully'),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              translate('Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}