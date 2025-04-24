import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final DateTime expiryDate;
  final String categoryId;
  final int? quantity;
  final String? location;
  final String? batchNumber;
  final String? notes;
  final String? imagePath;
  final bool isNotified;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.categoryId,
    this.quantity = 1,
    this.location,
    this.batchNumber,
    this.notes,
    this.imagePath,
    this.isNotified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiryDay.isBefore(today);
  }

  bool get isExpiringSoon {
    if (isExpired) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final difference = expiryDay.difference(today).inDays;
    
    return difference <= 7; // Within a week
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiryDay.difference(today).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expiryDate': expiryDate.toIso8601String(),
      'categoryId': categoryId,
      'quantity': quantity,
      'location': location,
      'batchNumber': batchNumber,
      'notes': notes,
      'imagePath': imagePath,
      'isNotified': isNotified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      expiryDate: DateTime.parse(json['expiryDate']),
      categoryId: json['categoryId'],
      quantity: json['quantity'],
      location: json['location'],
      batchNumber: json['batchNumber'],
      notes: json['notes'],
      imagePath: json['imagePath'],
      isNotified: json['isNotified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Item copyWith({
    String? id,
    String? name,
    DateTime? expiryDate,
    String? categoryId,
    int? quantity,
    String? location,
    String? batchNumber,
    String? notes,
    String? imagePath,
    bool? isNotified,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      batchNumber: batchNumber ?? this.batchNumber,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isNotified: isNotified ?? this.isNotified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}