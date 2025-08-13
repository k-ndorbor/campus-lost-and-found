import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/item.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new item to Firestore
  Future<void> addItem(Item item) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      await _firestore.collection('items').add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // Get stream of items (filter by found/lost if specified)
  Stream<List<Item>> getItems({bool? isLost}) {
    try {
      Query query = _firestore.collection('items');
      
      if (isLost != null) {
        query = query.where('isLost', isEqualTo: isLost);
      }
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Item.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get items: $e');
    }
  }

  // Update an existing item
  Future<void> updateItem(Item item) async {
    try {
      await _firestore.collection('items').doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection('items').doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Get a single item by ID
  Future<Item?> getItemById(String itemId) async {
    try {
      final doc = await _firestore.collection('items').doc(itemId).get();
      if (doc.exists) {
        return Item.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get item: $e');
    }
  }

  // Get items by user ID
  Stream<List<Item>> getItemsByUserId(String userId, {bool? isLost}) {
    try {
      Query query = _firestore
          .collection('items')
          .where('userId', isEqualTo: userId);

      if (isLost != null) {
        query = query.where('isLost', isEqualTo: isLost);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Item.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get user items: $e');
    }
  }
}
