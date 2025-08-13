import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final String imageUrl;
  final bool isLost;
  final String contact;
  final String date;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.contact,
    required this.isLost,
    required this.date,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      contact: data['contact'] ?? '',
      isLost: data['isLost'] ?? false,
      date: data['date'] ?? '',
    );
  }
}