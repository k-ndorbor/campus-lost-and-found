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
  final String color;
  final String userId;
  final DateTime createdAt;
  final String status; // 'found' or 'lost'
  final String? claimedBy; // User ID who claimed the item (if any)
  final bool isClaimed;

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
    required this.color,
    required this.userId,
    required this.createdAt,
    required this.status,
    this.claimedBy,
    this.isClaimed = false,
  });

  // Convert Item to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'contact': contact,
      'isLost': isLost,
      'date': date,
      'color': color,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': status,
      'isClaimed': isClaimed,
      if (claimedBy != null) 'claimedBy': claimedBy,
    };
  }

  // Create Item from Firestore document
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
      color: data['color'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? (data['isLost'] ? 'lost' : 'found'),
      claimedBy: data['claimedBy'],
      isClaimed: data['isClaimed'] ?? false,
    );
  }
}
