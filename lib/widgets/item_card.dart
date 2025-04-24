import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../providers/language_provider.dart';
import '../screens/add_item_screen.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final Function? onDelete;
  
  const ItemCard({
    Key? key,
    required this.item,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final category = categoryProvider.findById(item.categoryId);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isExpired
              ? Colors.red.withOpacity(0.5)
              : item.isExpiringSoon
                  ? Colors.orange.withOpacity(0.5)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(context, category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category badge
                  if (category != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon, 
                              size: 16,
                              color: category.color,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: category.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Expiry indicator
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.isExpired
                            ? Colors.red.withOpacity(0.2)
                            : item.isExpiringSoon
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.isExpired
                            ? '${translate('Expired')}: ${item.daysUntilExpiry.abs()} ${translate('days ago')}'
                            : item.isExpiringSoon
                                ? '${item.daysUntilExpiry} ${translate('days left')}'
                                : translate('Good'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item.isExpired
                              ? Colors.red
                              : item.isExpiringSoon
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Item Information Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  if (item.imagePath != null)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(right: 12),
                      child: item.imagePath != null
                          ? Image.file(
                              File(item.imagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                    ),
                  
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Item Name
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Expiry Date
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${translate('Expires on')} ${DateFormat('MMM dd, yyyy').format(item.expiryDate)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item.isExpired
                                      ? Colors.red
                                      : item.isExpiringSoon
                                          ? Colors.orange
                                          : Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        // Quantity (if available)
                        if (item.quantity != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.format_list_numbered,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${translate('Quantity')}: ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Location (if available)
                        if (item.location != null && item.location!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${translate('Location')}: ${item.location}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Button
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AddItemScreen.routeName,
                        arguments: item,
                      );
                    },
                    tooltip: translate('Edit'),
                  ),
                  
                  // Delete Button
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _showDeleteDialog(
                      context,
                      itemProvider,
                      translate,
                    ),
                    tooltip: translate('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showItemDetails(BuildContext context, Category? category) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (item.imagePath != null) ...[
                Center(
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(item.imagePath!)),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      ),
                    ),
                  ),
                ),
              ],
              
              // Title
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Details Table
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  _buildTableRow(
                    translate('Category'),
                    category?.name ?? translate('Unknown'),
                    icon: category?.icon ?? Icons.category,
                    color: category?.color,
                  ),
                  _buildTableRow(
                    translate('Expiry Date'),
                    DateFormat('MMMM dd, yyyy').format(item.expiryDate),
                    icon: Icons.calendar_today,
                    color: item.isExpired
                        ? Colors.red
                        : item.isExpiringSoon
                            ? Colors.orange
                            : Colors.green,
                  ),
                  _buildTableRow(
                    translate('Status'),
                    item.isExpired
                        ? translate('Expired')
                        : item.isExpiringSoon
                            ? translate('Expiring Soon')
                            : translate('Good'),
                    icon: item.isExpired
                        ? Icons.error_outline
                        : item.isExpiringSoon
                            ? Icons.warning_amber_outlined
                            : Icons.check_circle_outline,
                    color: item.isExpired
                        ? Colors.red
                        : item.isExpiringSoon
                            ? Colors.orange
                            : Colors.green,
                  ),
                  if (item.quantity != null)
                    _buildTableRow(
                      translate('Quantity'),
                      item.quantity.toString(),
                      icon: Icons.format_list_numbered,
                    ),
                  if (item.location != null && item.location!.isNotEmpty)
                    _buildTableRow(
                      translate('Location'),
                      item.location!,
                      icon: Icons.location_on_outlined,
                    ),
                  if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
                    _buildTableRow(
                      translate('Batch Number'),
                      item.batchNumber!,
                      icon: Icons.tag,
                    ),
                ],
              ),
              
              // Notes
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  translate('Notes'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.notes!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: Text(translate('Close')),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(translate('Edit')),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamed(
                        AddItemScreen.routeName,
                        arguments: item,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  TableRow _buildTableRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: color ?? Colors.grey,
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value,
            style: TextStyle(
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  void _showDeleteDialog(
    BuildContext context,
    ItemProvider itemProvider,
    String Function(String) translate,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('Delete Item')),
        content: Text(
          '${translate('Are you sure you want to delete')} ${item.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(translate('Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onDelete != null) {
                onDelete!();
              } else {
                itemProvider.deleteItem(item.id);
              }
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