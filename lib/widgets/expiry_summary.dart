import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';

class ExpirySummary extends StatelessWidget {
  const ExpirySummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (ctx, itemData, _) {
        final expiredCount = itemData.expiredItems.length;
        final expiringSoonCount = itemData.expiringSoonItems.length;
        final totalCount = itemData.items.length;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryCard(
                context,
                'Total',
                totalCount.toString(),
                Icons.inventory_2_outlined,
                Colors.blue,
              ),
              _buildSummaryCard(
                context,
                'Expiring Soon',
                expiringSoonCount.toString(),
                Icons.warning_amber_outlined,
                Colors.amber,
              ),
              _buildSummaryCard(
                context,
                'Expired',
                expiredCount.toString(),
                Icons.error_outline,
                Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}