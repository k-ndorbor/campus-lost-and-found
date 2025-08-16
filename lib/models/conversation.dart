import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participants; // List of user IDs
  final String? itemId; // Optional: reference to the item being discussed
  final DateTime lastMessageAt;
  final String lastMessage;
  final String lastMessageSenderId;
  final bool lastMessageIsRead;

  Conversation({
    required this.id,
    required this.participants,
    this.itemId,
    required this.lastMessageAt,
    required this.lastMessage,
    required this.lastMessageSenderId,
    this.lastMessageIsRead = false,
  });

  // Convert Conversation to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'itemId': itemId,
      'lastMessageAt': lastMessageAt,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageIsRead': lastMessageIsRead,
    };
  }

  // Create a Conversation from a Firestore document
  factory Conversation.fromMap(Map<String, dynamic> map, String id) {
    DateTime lastMessageAt;
    try {
      if (map['lastMessageAt'] is Timestamp) {
        lastMessageAt = (map['lastMessageAt'] as Timestamp).toDate();
      } else if (map['lastMessageAt'] is DateTime) {
        lastMessageAt = map['lastMessageAt'] as DateTime;
      } else {
        // Fallback to current time if lastMessageAt is missing or invalid
        lastMessageAt = DateTime.now();
      }
    } catch (e) {
      // If there's any error parsing the date, use current time
      lastMessageAt = DateTime.now();
    }

    return Conversation(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      itemId: map['itemId']?.toString(),
      lastMessageAt: lastMessageAt,
      lastMessage: map['lastMessage']?.toString() ?? '',
      lastMessageSenderId: map['lastMessageSenderId']?.toString() ?? '',
      lastMessageIsRead: map['lastMessageIsRead'] == true,
    );
  }
}
