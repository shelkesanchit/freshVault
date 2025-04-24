import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';
import '../models/item.dart';

class BulkOperationsScreen extends StatefulWidget {
  static const routeName = '/bulk-operations';
  
  const BulkOperationsScreen({Key? key}) : super(key: key);

  @override
  State<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends State<BulkOperationsScreen> {
  final Set<String> _selectedItemIds = {};
  String? _selectedCategoryId;
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;
  
  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }
  
  void _selectAllItems(List<Item> items) {
    setState(() {
      if (_selectedItemIds.length == items.length) {
        // If all items are already selected, deselect all
        _selectedItemIds.clear();
      } else {
        // Otherwise, select all items
        _selectedItemIds.clear();
        _selectedItemIds.addAll(items.map((item) => item.id));
      }
    });
  }
  
  Future<void> _deleteSelectedItems(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate('No items selected')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('Delete Selected Items')),
        content: Text(
          '${translate('Are you sure you want to delete')} ${_selectedItemIds.length} ${translate('items')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              translate('Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final itemProvider = Provider.of<ItemProvider>(context, listen: false);
        for (final itemId in _selectedItemIds) {
          await itemProvider.deleteItem(itemId);
        }
        
        setState(() {
          _selectedItemIds.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate('Items deleted successfully')),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${translate('Error deleting items')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _updateSelectedItemsCategory(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate('No items selected')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedCategoryId == null) {
      // Show category selection dialog
      await _showCategorySelectionDialog(context);
    }
    
    if (_selectedCategoryId != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final itemProvider = Provider.of<ItemProvider>(context, listen: false);
        for (final itemId in _selectedItemIds) {
          final item = itemProvider.findById(itemId);
          if (item != null) {
            final updatedItem = Item(
              id: item.id,
              name: item.name,
              expiryDate: item.expiryDate,
              categoryId: _selectedCategoryId!,
              quantity: item.quantity,
              location: item.location,
              batchNumber: item.batchNumber,
              notes: item.notes,
              imagePath: item.imagePath,
              isNotified: item.isNotified,
            );
            await itemProvider.updateItem(updatedItem);
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate('Category updated for selected items')),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${translate('Error updating category')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _updateSelectedItemsExpiryDate(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate('No items selected')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedExpiryDate == null) {
      // Show date selection dialog
      await _selectDate(context);
    }
    
    if (_selectedExpiryDate != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final itemProvider = Provider.of<ItemProvider>(context, listen: false);
        for (final itemId in _selectedItemIds) {
          final item = itemProvider.findById(itemId);
          if (item != null) {
            final updatedItem = Item(
              id: item.id,
              name: item.name,
              expiryDate: _selectedExpiryDate!,
              categoryId: item.categoryId,
              quantity: item.quantity,
              location: item.location,
              batchNumber: item.batchNumber,
              notes: item.notes,
              imagePath: item.imagePath,
              isNotified: item.isNotified,
            );
            await itemProvider.updateItem(updatedItem);
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate('Expiry date updated for selected items')),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${translate('Error updating expiry date')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _showCategorySelectionDialog(BuildContext context) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    final categories = categoryProvider.categories;
    
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('Select Category')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final category = categories[index];
              return ListTile(
                leading: Icon(category.icon, color: category.color),
                title: Text(category.name),
                onTap: () => Navigator.of(ctx).pop(category.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(translate('Cancel')),
          ),
        ],
      ),
    );
    
    if (selectedCategory != null) {
      setState(() {
        _selectedCategoryId = selectedCategory;
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: translate('Select New Expiry Date'),
      cancelText: translate('Cancel'),
      confirmText: translate('Set Date'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final items = itemProvider.items;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Bulk Operations')),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: translate('Select All'),
            onPressed: () => _selectAllItems(items),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Actions Card
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate('Bulk Actions'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${translate('Selected')}: ${_selectedItemIds.length} ${translate('items')}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.category),
                                  label: Text(translate('Update Category')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: _selectedItemIds.isEmpty
                                      ? null
                                      : () => _updateSelectedItemsCategory(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(translate('Update Expiry')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: _selectedItemIds.isEmpty
                                      ? null
                                      : () => _updateSelectedItemsExpiryDate(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: Text(translate('Delete')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: _selectedItemIds.isEmpty
                                      ? null
                                      : () => _deleteSelectedItems(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Items List
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                translate('No items to display'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (ctx, index) {
                            final item = items[index];
                            final category = categoryProvider.findById(item.categoryId);
                            final isSelected = _selectedItemIds.contains(item.id);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: isSelected
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : null,
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => _toggleItemSelection(item.id),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: item.isExpired
                                              ? Colors.red
                                              : item.isExpiringSoon
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(item.expiryDate),
                                          style: TextStyle(
                                            color: item.isExpired
                                                ? Colors.red
                                                : item.isExpiringSoon
                                                    ? Colors.orange
                                                    : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (category != null)
                                      Row(
                                        children: [
                                          Icon(
                                            category.icon,
                                            size: 16,
                                            color: category.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(category.name),
                                        ],
                                      ),
                                  ],
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade200,
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white)
                                      : Text(
                                          item.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Theme.of(context).primaryColor,
                                          ),
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