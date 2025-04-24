import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../models/category.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/add-item';
  
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategoryId;
  File? _imageFile;
  bool _isImageLoading = false;
  bool _isSubmitting = false;
  
  Item? _editingItem;
  bool get _isEditing => _editingItem != null;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItemData();
    });
  }
  
  Future<void> _loadItemData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Item) {
      setState(() {
        _editingItem = args;
        _nameController.text = args.name;
        _quantityController.text = args.quantity?.toString() ?? '1';
        _locationController.text = args.location ?? '';
        _batchNumberController.text = args.batchNumber ?? '';
        _notesController.text = args.notes ?? '';
        _selectedDate = args.expiryDate;
        _selectedCategoryId = args.categoryId;
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: translate('Select Expiry Date'),
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _takePicture() async {
    setState(() {
      _isImageLoading = true;
    });
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      // Handle camera error
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }
  
  Future<void> _pickImage() async {
    setState(() {
      _isImageLoading = true;
    });
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      // Handle gallery error
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }
  
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategoryId == null) {
      _showCategoryError();
      return;
    }
    
    if (_selectedDate == null) {
      _showDateError();
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    
    final newItem = Item(
      id: _isEditing ? _editingItem!.id : const Uuid().v4(),
      name: _nameController.text.trim(),
      quantity: int.tryParse(_quantityController.text) ?? 1,
      expiryDate: _selectedDate!,
      categoryId: _selectedCategoryId!,
      location: _locationController.text.isEmpty ? null : _locationController.text.trim(),
      batchNumber: _batchNumberController.text.isEmpty ? null : _batchNumberController.text.trim(),
      notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
      imagePath: _imageFile?.path ?? _editingItem?.imagePath,
      isNotified: _isEditing ? _editingItem!.isNotified : false,
    );
    
    try {
      if (_isEditing) {
        await itemProvider.updateItem(newItem);
      } else {
        await itemProvider.addItem(newItem);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _showCategoryError() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('Please select a category')),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showDateError() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translate = languageProvider.getTranslatedValue;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('Please select an expiry date')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? translate('Edit Item') : translate('Add Item')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('Product Details'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Product Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: '${translate('Name')} *',
                            hintText: translate('Product name'),
                            prefixIcon: const Icon(Icons.inventory_2_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return translate('Please enter a product name');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '${translate('Category')} *',
                            hintText: translate('Select category'),
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          value: _selectedCategoryId,
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Row(
                                children: [
                                  Icon(
                                    category.icon, 
                                    color: category.color,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Quantity
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: translate('Quantity'),
                            hintText: '1',
                            prefixIcon: const Icon(Icons.numbers),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Expiry Date
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: '${translate('Expiry Date')} *',
                                hintText: translate('Select expiry date'),
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                              controller: TextEditingController(
                                text: _selectedDate == null
                                    ? ''
                                    : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Additional Details Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('Additional Information'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Location
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: translate('Location'),
                            hintText: translate('Select location'),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Batch Number
                        TextFormField(
                          controller: _batchNumberController,
                          decoration: InputDecoration(
                            labelText: translate('Batch Number'),
                            hintText: translate('Optional batch number'),
                            prefixIcon: const Icon(Icons.tag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Notes
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: translate('Notes'),
                            hintText: translate('Additional notes'),
                            prefixIcon: const Icon(Icons.note_alt_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Image Upload Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('Product Image'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Image Preview
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _isImageLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _editingItem?.imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            File(_editingItem!.imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image,
                                                size: 64,
                                                color: Colors.grey[500],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                translate('No image selected'),
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Image Selection Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _takePicture,
                                icon: const Icon(Icons.camera_alt),
                                label: Text(translate('Take Photo')),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library),
                                label: Text(translate('Gallery')),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(translate('Cancel')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator.adaptive()
                            : Text(_isEditing
                                ? translate('Update Product')
                                : translate('Add Product')),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}