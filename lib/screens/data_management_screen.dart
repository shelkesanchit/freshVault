// ignore_for_file: use_build_context_synchronously, avoid_single_cascade_in_expression_statements

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';

class DataManagementScreen extends StatelessWidget {
  static const routeName = '/data-management';
  
  const DataManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Data Management')),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('Backup & Restore'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Backup Data
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.backup,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(translate('Backup Data')),
                subtitle: Text(translate('Save your items and categories')),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showBackupOptions(context),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Restore Data
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.restore,
                  color: Colors.amber,
                ),
                title: Text(translate('Restore Data')),
                subtitle: Text(translate('Load from a backup file')),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _restoreData(context),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              translate('Export'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Export to Excel
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.table_chart,
                  color: Colors.green,
                ),
                title: Text(translate('Export to Excel')),
                subtitle: Text(translate('Create a spreadsheet of your items')),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _exportToExcel(context),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Export to PDF
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                ),
                title: Text(translate('Export to PDF')),
                subtitle: Text(translate('Create a PDF report')),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _exportToPdf(context),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Management Tips
            Card(
              elevation: 1,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          translate('Tips'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${translate('Regular backups help prevent data loss')}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ${translate('Excel exports are great for analyzing your data in spreadsheets')}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ${translate('PDF reports are perfect for printing or sharing')}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showBackupOptions(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translate('Backup Options'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.save),
              title: Text(translate('Save to Device')),
              onTap: () {
                Navigator.of(ctx).pop();
                _backupData(context, shouldShare: false);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(translate('Share Backup File')),
              onTap: () {
                Navigator.of(ctx).pop();
                _backupData(context, shouldShare: true);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _backupData(BuildContext context, {required bool shouldShare}) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    try {
      final Map<String, dynamic> backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'items': itemProvider.items.map((item) => item.toJson()).toList(),
        'categories': categoryProvider.categories.map((category) => category.toJson()).toList(),
      };
      
      final jsonData = json.encode(backupData);
      final bytes = utf8.encode(jsonData);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = 'expiry_tracker_backup_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (shouldShare) {
        await Share.shareFiles([file.path], text: translate('Expiry Tracker Backup'));
      } else {
        final downloadDir = await getDownloadsDirectory() ?? await getExternalStorageDirectory();
        if (downloadDir != null) {
          final savedFile = await file.copy('${downloadDir.path}/$fileName');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${translate('Backup saved to')}: ${savedFile.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${translate('Error creating backup')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _restoreData(BuildContext context) async {
    // final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    // final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    // final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    // final translate = languageProvider.getTranslatedValue;
    
    // try {
    //   final result = await FilePicker.platform.pickFiles(
    //     type: FileType.custom,
    //     allowedExtensions: ['json'],
    //   );
      
    //   if (result != null && result.files.isNotEmpty) {
    //     final file = File(result.files.first.path!);
    //     final jsonString = await file.readAsString();
    //     final backupData = json.decode(jsonString) as Map<String, dynamic>;
        
    //     // Restore categories first
    //     final categoriesData = backupData['categories'] as List<dynamic>;
    //     final categories = categoriesData.map((data) => Category.fromJson(data)).toList();
    //     await categoryProvider.setCategories(categories);
        
    //     // Then restore items
    //     final itemsData = backupData['items'] as List<dynamic>;
    //     final items = itemsData.map((data) => Item.fromJson(data)).toList();
    //     await itemProvider.setItems(items);
        
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(translate('Data restored successfully')),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('${translate('Error restoring data')}: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
  }
  
  Future<void> _exportToExcel(BuildContext context) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    try {
      final excel = Excel.createExcel();
      
      // Create Items sheet
      final itemsSheet = excel['Items'];
      
      // Add headers
      final headers = [
        translate('Product Name'),
        translate('Category'),
        translate('Expiry Date'),
        translate('Days Left'),
        translate('Status'),
        translate('Notes'),
      ];
      
      for (var i = 0; i < headers.length; i++) {
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: '#E0E0E0',
          );
      }
      
      // Add items data
      final items = itemProvider.items;
      final categories = categoryProvider.categories;
      
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final category = categories.firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => Category(
            id: '', 
            name: 'Unknown', 
            icon: Icons.help, 
            color: Colors.grey,
          ),
        );
        
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          ..value = item.name;
        
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          ..value = category.name;
        
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          ..value = DateFormat('yyyy-MM-dd').format(item.expiryDate);
        
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          ..value = item.daysUntilExpiry;
        
        String status;
        if (item.isExpired) {
          status = translate('Expired');
        } else if (item.isExpiringSoon) {
          status = translate('Expiring Soon');
        } else {
          status = translate('Good');
        }
        
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          ..value = status;
        
        itemsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          ..value = item.notes ?? '';
      }
      
      // Auto-fit columns
      // Note: setColumnWidth is not supported in the current Excel package version
      // We'll skip this part since it causes errors
      
      // Create a Categories sheet
      final categoriesSheet = excel['Categories'];
      
      // Add headers
      final categoryHeaders = [
        translate('Category Name'),
        translate('Total Items'),
        translate('Expired Items'),
        translate('Expiring Soon'),
      ];
      
      for (var i = 0; i < categoryHeaders.length; i++) {
        categoriesSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = categoryHeaders[i]
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: '#E0E0E0',
          );
      }
      
      // Add categories data
      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];
        final categoryItems = items.where((item) => item.categoryId == category.id).toList();
        final expiredItems = categoryItems.where((item) => item.isExpired).length;
        final expiringSoonItems = categoryItems.where((item) => !item.isExpired && item.isExpiringSoon).length;
        
        categoriesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          ..value = category.name;
        
        categoriesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          ..value = categoryItems.length;
        
        categoriesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          ..value = expiredItems;
        
        categoriesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          ..value = expiringSoonItems;
      }
      
      // Auto-fit columns
      // Skip this part as well for the same reason
      
      // Remove the default sheet
      excel.delete('Sheet1');
      
      // Save the Excel file
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'expiry_tracker_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(excelBytes);
        
        await Share.shareFiles([file.path], text: translate('Expiry Tracker Data'));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${translate('Error exporting to Excel')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _exportToPdf(BuildContext context) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    try {
      final pdf = pw.Document();
      
      final items = itemProvider.items;
      final categories = categoryProvider.categories;
      
      // Create PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Expiry Tracker - ${translate('Item Report')}',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context context) {
            return pw.Footer(
              trailing: pw.Text(
                '${translate('Page')} ${context.pageNumber} ${translate('of')} ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(level: 1, text: translate('Items by Expiry Status')),
                  pw.Paragraph(
                    text: '${translate('Total Items')}: ${items.length}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.Paragraph(
                    text: '${translate('Expired Items')}: ${items.where((item) => item.isExpired).length}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.Paragraph(
                    text: '${translate('Expiring Soon')}: ${items.where((item) => !item.isExpired && item.isExpiringSoon).length}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Expired Items
                  _buildPdfItemsTable(
                    translate('Expired Items'),
                    items.where((item) => item.isExpired).toList(),
                    categories,
                    translate,
                  ),
                  pw.SizedBox(height: 30),
                  
                  // Expiring Soon Items
                  _buildPdfItemsTable(
                    translate('Expiring Soon Items'),
                    items.where((item) => !item.isExpired && item.isExpiringSoon).toList(),
                    categories,
                    translate,
                  ),
                  pw.SizedBox(height: 30),
                  
                  // Other Items
                  _buildPdfItemsTable(
                    translate('Other Items'),
                    items.where((item) => !item.isExpired && !item.isExpiringSoon).toList(),
                    categories,
                    translate,
                  ),
                  pw.SizedBox(height: 30),
                  
                  // Categories Summary
                  pw.Header(
                    level: 1,
                    text: translate('Categories Summary'),
                  ),
                  pw.TableHelper.fromTextArray(
                    context: context,
                    headers: [
                      translate('Category'),
                      translate('Total Items'),
                      translate('Expired'),
                      translate('Expiring Soon'),
                    ],
                    data: categories.map((category) {
                      final categoryItems = items.where((item) => item.categoryId == category.id).toList();
                      final expiredItems = categoryItems.where((item) => item.isExpired).length;
                      final expiringSoonItems = categoryItems.where((item) => !item.isExpired && item.isExpiringSoon).length;
                      
                      return [
                        category.name,
                        categoryItems.length.toString(),
                        expiredItems.toString(),
                        expiringSoonItems.toString(),
                      ];
                    }).toList(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    border: null,
                    headerHeight: 25,
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                    },
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.center,
                    },
                  ),
                ],
              ),
            ];
          },
        ),
      );
      
      // Save the PDF file
      final pdfBytes = await pdf.save();
      
      final tempDir = await getTemporaryDirectory();
      final fileName = 'expiry_tracker_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      
      await Share.shareFiles([file.path], text: translate('Expiry Tracker Report'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${translate('Error exporting to PDF')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  pw.Widget _buildPdfItemsTable(
    String title,
    List<Item> items,
    List<Category> categories,
    String Function(String) translate,
  ) {
    if (items.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 1, text: title),
          pw.Paragraph(
            text: translate('No items in this category'),
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      );
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 1, text: title),
        pw.TableHelper.fromTextArray(
          headers: [
            translate('Product Name'),
            translate('Category'),
            translate('Expiry Date'),
            translate('Days Left'),
            translate('Notes'),
          ],
          data: items.map((item) {
            final category = categories.firstWhere(
              (c) => c.id == item.categoryId,
              orElse: () => Category(
                id: '',
                name: 'Unknown',
                icon: Icons.help,  // Fixed: Using proper IconData
                color: Colors.grey, // Fixed: Using proper Color
              ),
            );
            
            return [
              item.name,
              category.name,
              DateFormat('yyyy-MM-dd').format(item.expiryDate),
              item.daysUntilExpiry.toString(),
              item.notes ?? '',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          border: null,
          headerHeight: 25,
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(3),
          },
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
            4: pw.Alignment.centerLeft,
          },
        ),
      ],
    );
  }
}