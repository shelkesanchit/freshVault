// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';
import '../models/item.dart';
import 'add_item_screen.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';
  
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }
  
  List<Item> _getEventsForDay(DateTime day, List<Item> allItems) {
    // Return items that expire on the selected day
    return allItems.where((item) => 
      item.expiryDate.year == day.year &&
      item.expiryDate.month == day.month &&
      item.expiryDate.day == day.day
    ).toList();
  }
  
  Color _getColorForDay(DateTime day, List<Item> allItems) {
    final events = _getEventsForDay(day, allItems);
    if (events.isEmpty) {
      return Colors.transparent;
    }
    
    // Check if any items are expired
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(day.year, day.month, day.day);
    
    if (dayDate.isBefore(today)) {
      return Colors.red.withOpacity(0.3); // Past expiry date
    } else if (dayDate.isAtSameMomentAs(today)) {
      return Colors.orange.withOpacity(0.3); // Today's expiry date
    } else {
      final daysDifference = dayDate.difference(today).inDays;
      if (daysDifference <= 7) {
        return Colors.orange.withOpacity(0.3); // Expiring soon (within a week)
      } else {
        return Colors.green.withOpacity(0.3); // Future expiry date
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final allItems = itemProvider.items;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, allItems)
        : <Item>[];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Expiry Calendar')),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final dayEvents = _getEventsForDay(date, allItems);
                    
                    if (dayEvents.isEmpty) {
                      return null;
                    }
                    
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: _getColorForDay(date, allItems),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          dayEvents.length.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final dayDate = DateTime(day.year, day.month, day.day);
                    
                    if (dayDate.isBefore(today)) {
                      // Past dates
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _getColorForDay(day, allItems),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }
                    
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getColorForDay(day, allItems),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          // Calendar Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.red.withOpacity(0.3), translate('Expired')),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange.withOpacity(0.3), translate('Expiring Soon')),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.green.withOpacity(0.3), translate('Future Expiry')),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          // Selected Day Events
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDay != null
                                ? DateFormat.yMMMMd().format(_selectedDay!)
                                : translate('No date selected'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: selectedEvents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    translate('No items expiring on this date'),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: Text(translate('Add Item for This Date')),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        AddItemScreen.routeName,
                                        arguments: {'initialExpiryDate': _selectedDay},
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: selectedEvents.length,
                              itemBuilder: (context, index) {
                                final item = selectedEvents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                    horizontal: 8.0,
                                  ),
                                  color: item.isExpired
                                      ? Colors.red.shade50
                                      : item.isExpiringSoon
                                          ? Colors.orange.shade50
                                          : null,
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.inventory_2_outlined),
                                    ),
                                    title: Text(item.name),
                                    subtitle: item.notes != null && item.notes!.isNotEmpty
                                        ? Text(item.notes!)
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              AddItemScreen.routeName,
                                              arguments: item,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () {
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
                                                      itemProvider.deleteItem(item.id);
                                                      Navigator.of(ctx).pop();
                                                    },
                                                    child: Text(
                                                      translate('Delete'),
                                                      style: const TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AddItemScreen.routeName,
            arguments: {'initialExpiryDate': _selectedDay ?? DateTime.now()},
          );
        },
        
        child: const Icon(Icons.add),
        tooltip: translate('Add Item'),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}