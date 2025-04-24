import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';

class StatsScreen extends StatefulWidget {
  static const routeName = '/stats';
  
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Statistics')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: translate('Overview')),
            Tab(text: translate('Categories')),
            Tab(text: translate('Expiry Analysis')),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OverviewTab(),
          CategoriesTab(),
          ExpiryAnalysisTab(),
        ],
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final totalItems = itemProvider.items.length;
    final expiredItems = itemProvider.expiredItems.length;
    final expiringSoonItems = itemProvider.expiringSoonItems.length;
    final healthyItems = totalItems - expiredItems - expiringSoonItems;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              _buildSummaryCard(
                context,
                title: translate('Total Items'),
                value: totalItems.toString(),
                icon: Icons.inventory_2_outlined,
                color: Colors.blue,
              ),
              _buildSummaryCard(
                context,
                title: translate('Expired'),
                value: expiredItems.toString(),
                icon: Icons.error_outline,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSummaryCard(
                context,
                title: translate('Expiring Soon'),
                value: expiringSoonItems.toString(),
                icon: Icons.warning_amber_outlined,
                color: Colors.orange,
              ),
              _buildSummaryCard(
                context,
                title: translate('Healthy'),
                value: healthyItems.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (totalItems > 0) ...[
            // Pie Chart Title
            Text(
              translate('Expiry Status Distribution'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Custom Pie Chart Visualization
            SizedBox(
              height: 200,
              child: CustomPieChart(
                sections: [
                  PieSection(
                    value: healthyItems, 
                    totalValue: totalItems,
                    color: Colors.green,
                    label: translate('Healthy'),
                  ),
                  PieSection(
                    value: expiringSoonItems, 
                    totalValue: totalItems,
                    color: Colors.orange,
                    label: translate('Expiring Soon'),
                  ),
                  PieSection(
                    value: expiredItems, 
                    totalValue: totalItems,
                    color: Colors.red,
                    label: translate('Expired'),
                  ),
                ],
              ),
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate('No items added yet to generate statistics'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final allItems = itemProvider.items;
    final categories = categoryProvider.categories;
    
    // Calculate items per category
    final Map<String, int> itemsPerCategory = {};
    for (final category in categories) {
      itemsPerCategory[category.id] = itemProvider.getItemsByCategory(category.id).length;
    }
    
    int maxItems = 0;
    if (itemsPerCategory.isNotEmpty) {
      maxItems = itemsPerCategory.values.reduce((a, b) => a > b ? a : b);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('Items by Category'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (categories.isEmpty || allItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate('No categories or items to display'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            // Custom Bar Chart
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final itemCount = itemsPerCategory[category.id] ?? 0;
                  final percentage = maxItems > 0 ? itemCount / maxItems : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(category.icon, color: category.color, size: 16),
                            const SizedBox(width: 8),
                            Text(category.name),
                            const Spacer(),
                            Text(
                              itemCount.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            Container(
                              height: 20,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage.toDouble(), // Fixed: converted to double
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
          const SizedBox(height: 24),
          
          // Categories Table
          if (categories.isNotEmpty && allItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate('Category Details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(translate('Category'))),
                      DataColumn(label: Text(translate('Items'))),
                      DataColumn(label: Text(translate('Expired'))),
                      DataColumn(label: Text(translate('Expiring Soon'))),
                    ],
                    rows: categories.map((category) {
                      final categoryItems = itemProvider.getItemsByCategory(category.id);
                      final expiredCount = categoryItems.where((item) => item.isExpired).length;
                      final expiringSoonCount = categoryItems.where((item) => 
                        !item.isExpired && item.isExpiringSoon).length;
                      
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(category.icon, color: category.color, size: 16),
                                const SizedBox(width: 4),
                                Text(category.name),
                              ],
                            ),
                          ),
                          DataCell(Text(categoryItems.length.toString())),
                          DataCell(
                            Text(
                              expiredCount.toString(),
                              style: TextStyle(
                                color: expiredCount > 0 ? Colors.red : null,
                                fontWeight: expiredCount > 0 ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              expiringSoonCount.toString(),
                              style: TextStyle(
                                color: expiringSoonCount > 0 ? Colors.orange : null,
                                fontWeight: expiringSoonCount > 0 ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class ExpiryAnalysisTab extends StatelessWidget {
  const ExpiryAnalysisTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final items = itemProvider.items;
    
    if (items.isEmpty) {
      return Center(
        child: Text(
          translate('No items to analyze'),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }
    
    // Group items by expiry month
    final Map<String, List<ItemExpiryData>> itemsByMonth = {};
    final now = DateTime.now();
    final sixMonthsFromNow = DateTime(now.year, now.month + 6, now.day);
    
    for (final item in items) {
      if (item.expiryDate.isBefore(now.subtract(const Duration(days: 30))) || 
          item.expiryDate.isAfter(sixMonthsFromNow)) {
        continue;
      }
      
      final monthYear = DateFormat('MMM yyyy').format(item.expiryDate);
      if (!itemsByMonth.containsKey(monthYear)) {
        itemsByMonth[monthYear] = [];
      }
      
      itemsByMonth[monthYear]!.add(
        ItemExpiryData(
          name: item.name,
          expiryDate: item.expiryDate,
          isExpired: item.isExpired,
        ),
      );
    }
    
    // Sort months chronologically
    final sortedMonths = itemsByMonth.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      });
    
    // Find max count for scaling
    int maxCount = 0;
    for (final month in sortedMonths) {
      if (itemsByMonth[month]!.length > maxCount) {
        maxCount = itemsByMonth[month]!.length;
      }
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('Expiry Timeline (Next 6 Months)'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (sortedMonths.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate('No items expiring in the next 6 months'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: Column(
                children: [
                  Expanded(
                    child: CustomBarChart(
                      labels: sortedMonths,
                      values: sortedMonths.map((month) => 
                        itemsByMonth[month]!.length.toDouble()).toList(),
                      maxValue: maxCount.toDouble(),
                      barColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translate('Number of items expiring each month'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: 24),
          
          // Items expiring soon listing
          Text(
            translate('Items Expiring Soon'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (itemProvider.expiringSoonItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate('No items expiring soon'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemProvider.expiringSoonItems.length,
              itemBuilder: (context, index) {
                final item = itemProvider.expiringSoonItems[index];
                final daysLeft = item.daysUntilExpiry;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          daysLeft.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      '${translate('Expires on')} ${DateFormat('MMM dd, yyyy').format(item.expiryDate)}',
                    ),
                    trailing: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ItemExpiryData {
  final String name;
  final DateTime expiryDate;
  final bool isExpired;
  
  ItemExpiryData({
    required this.name,
    required this.expiryDate,
    required this.isExpired,
  });
}

// Custom Pie Chart Widget
class PieSection {
  final int value;
  final int totalValue;
  final Color color;
  final String label;
  
  PieSection({
    required this.value, 
    required this.totalValue, 
    required this.color, 
    required this.label,
  });
  
  double get percentage => totalValue > 0 ? value / totalValue : 0;
  String get percentageString => '${(percentage * 100).toStringAsFixed(1)}%';
}

class CustomPieChart extends StatelessWidget {
  final List<PieSection> sections;
  
  const CustomPieChart({
    Key? key, 
    required this.sections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: PieChartPainter(
                sections: sections,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ),
        // Legend
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.map((section) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: section.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${section.label} (${section.percentageString})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieSection> sections;
  final Color backgroundColor;
  
  PieChartPainter({
    required this.sections,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;
    final radius2 = radius * 0.8; // For the hole in the center
    
    double startAngle = -90 * (3.1415926535 / 180); // Start from the top (in radians)
    
    for (final section in sections) {
      final sweepAngle = section.percentage * 2 * 3.1415926535; // Full circle in radians
      
      final paint = Paint()
        ..color = section.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw a white circle in the center to create a donut chart
    final centerPaint = Paint()
      ..color = backgroundColor // Fixed: using the provided background color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius2, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Bar Chart Widget
class CustomBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double maxValue;
  final Color barColor;
  
  const CustomBarChart({
    Key? key, 
    required this.labels, 
    required this.values, 
    required this.maxValue,
    required this.barColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${maxValue.toInt()}'),
            Text('${(maxValue * 0.75).toInt()}'),
            Text('${(maxValue * 0.5).toInt()}'),
            Text('${(maxValue * 0.25).toInt()}'),
            Text('0'),
          ],
        ),
        const SizedBox(width: 8),
        // Chart
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    values.length,
                    (index) {
                      final height = values[index] / maxValue;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Container(
                            height: height * 200, // Scale for visualization
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: labels.map((label) => Expanded(
                  child: Text(
                    label.split(' ')[0], // Just show month abbreviation
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}