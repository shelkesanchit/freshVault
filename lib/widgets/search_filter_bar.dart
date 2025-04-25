import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';

class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onFilterChanged;
  
  const SearchFilterBar({
    Key? key, 
    required this.onSearch, 
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'expiryDate';
  bool _sortAscending = true;
  String? _selectedCategoryId;
  String _expiryFilter = 'all'; // all, expiringSoon, expired
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _getLocalizedText('Search products...'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            onChanged: widget.onSearch,
          ),
        ),
        
        // Expand/Collapse Filter Button
        ExpansionTile(
          title: Text(_getLocalizedText('Filters & Sorting')),
          leading: const Icon(Icons.filter_list),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            // Category Filter
            Row(
              children: [
                Text(_getLocalizedText('Category:'), 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategoryId,
                    hint: Text(_getLocalizedText('All Categories')),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(_getLocalizedText('All Categories')),
                      ),
                      ...categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(category.icon, color: category.color, size: 16),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                      _updateFilters();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Expiry Filter
            Row(
              children: [
                Text(_getLocalizedText('Expiry Status:'), 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment<String>(
                        value: 'all',
                        label: Text(_getLocalizedText('All')),
                        icon: const Icon(Icons.view_list),
                      ),
                      ButtonSegment<String>(
                        value: 'expiringSoon',
                        label: Text(_getLocalizedText('Expiring Soon')),
                        icon: const Icon(Icons.warning_amber_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'expired',
                        label: Text(_getLocalizedText('Expired')),
                        icon: const Icon(Icons.error_outline),
                      ),
                    ],
                    selected: {_expiryFilter},
                    onSelectionChanged: (Set<String> selected) {
                      setState(() {
                        _expiryFilter = selected.first;
                      });
                      _updateFilters();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Sort Options
            Row(
              children: [
                Text(_getLocalizedText('Sort By:'), 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _sortBy,
                    items: [
                      DropdownMenuItem<String>(
                        value: 'expiryDate',
                        child: Text(_getLocalizedText('Expiry Date')),
                      ),
                      DropdownMenuItem<String>(
                        value: 'name',
                        child: Text(_getLocalizedText('Name')),
                      ),
                      DropdownMenuItem<String>(
                        value: 'category',
                        child: Text(_getLocalizedText('Category')),
                      ),
                      DropdownMenuItem<String>(
                        value: 'dateAdded',
                        child: Text(_getLocalizedText('Date Added')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                        _updateFilters();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                    _updateFilters();
                  },
                  tooltip: _sortAscending 
                    ? _getLocalizedText('Ascending') 
                    : _getLocalizedText('Descending'),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Reset Filters Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(_getLocalizedText('Reset Filters')),
                  onPressed: () {
                    setState(() {
                      _selectedCategoryId = null;
                      _expiryFilter = 'all';
                      _sortBy = 'expiryDate';
                      _sortAscending = true;
                      _searchController.clear();
                    });
                    widget.onSearch('');
                    _updateFilters();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }

  void _updateFilters() {
    final filters = {
      'categoryId': _selectedCategoryId,
      'expiryFilter': _expiryFilter,
      'sortBy': _sortBy,
      'sortAscending': _sortAscending,
    };
    
    widget.onFilterChanged(filters);
  }
  
  // Placeholder for multilanguage support - will be connected to translation service
  String _getLocalizedText(String text) {
    // This will be replaced with actual translation
    return text;
  }
}