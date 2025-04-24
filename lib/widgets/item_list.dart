import 'package:flutter/material.dart';
import '../models/item.dart';
import 'item_card.dart';

class ItemList extends StatelessWidget {
  final List<Item> items;
  final String emptyMessage;
  
  const ItemList({
    Key? key,
    required this.items,
    required this.emptyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? Center(
            child: Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (ctx, i) => ItemCard(
              item: items[i],
            ),
          );
  }
}