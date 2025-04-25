// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/language_provider.dart';
import 'add_item_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  static const routeName = '/barcode-scanner';
  
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = false;
  String? _scannedBarcode;
  String? _productName;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Start scanning when the screen loads
    _startScanning();
  }
  
  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _scannedBarcode = null;
      _productName = null;
      _errorMessage = null;
    });
    
    // Simulate scanning
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // For demonstration, we'll use a mock barcode
      setState(() {
        _isScanning = false;
        _scannedBarcode = '5901234123457';
        
        // In a real app, you'd look up the product info from a database or API
        _productName = 'Sample Product';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _errorMessage = 'Error scanning barcode: $e';
      });
    }
  }
  
  void _addScannedProduct() {
    if (_productName != null) {
      // Navigate to the add item screen with pre-filled product name
      Navigator.of(context).pushReplacementNamed(
        AddItemScreen.routeName,
        arguments: {'initialProductName': _productName},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Scan Barcode')),
      ),
      body: Column(
        children: [
          // Scanning area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: _isScanning
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            translate('Scanning...'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                    : _scannedBarcode != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                translate('Barcode detected'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _scannedBarcode!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                translate('Point camera at a barcode'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
          
          // Result area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: Text(translate('Try Again')),
                            onPressed: _startScanning,
                          ),
                        ],
                      ),
                    )
                  : _scannedBarcode != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      translate('Product Information'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.inventory_2_outlined),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                translate('Name'),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                _productName ?? translate('Unknown product'),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: Text(translate('Scan Again')),
                                    onPressed: _startScanning,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: Text(translate('Add Product')),
                                    onPressed: _addScannedProduct,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            translate('Scan a barcode to get started'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: _scannedBarcode == null && !_isScanning
          ? FloatingActionButton(
              onPressed: _startScanning,
              child: const Icon(Icons.qr_code_scanner),
              tooltip: translate('Scan Barcode'),
            )
          : null,
    );
  }
}