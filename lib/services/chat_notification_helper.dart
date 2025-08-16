import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class ChatNotificationHelper {
  static final ChatNotificationHelper _instance = ChatNotificationHelper._internal();
  factory ChatNotificationHelper() => _instance;
  ChatNotificationHelper._internal();

  final NotificationService _notificationService = NotificationService();
  final Map<String, StreamSubscription> _conversationListeners = {};

  // Start listening to conversations for a user
  void startListeningToConversations(String userId) {
    FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          _handleConversationUpdate(change.doc, userId);
        }
      }
    });
  }

  // Handle conversation updates (new messages)
  void _handleConversationUpdate(DocumentSnapshot doc, String currentUserId) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final lastMessage = data['lastMessage'] as String? ?? '';
      final lastMessageSenderId = data['lastMessageSenderId'] as String? ?? '';
      final lastMessageAt = data['lastMessageAt'] as Timestamp?;
      final participants = List<String>.from(data['participants'] ?? []);

      // Don't show notification for messages sent by current user
      if (lastMessageSenderId == currentUserId) return;

      // Don't show notification if message is empty or old
      if (lastMessage.isEmpty || lastMessageAt == null) return;

      // Check if this is a recent message (within last 30 seconds)
      final messageTime = lastMessageAt.toDate();
      final now = DateTime.now();
      if (now.difference(messageTime).inSeconds > 30) return;

      // Get the sender's name
      _getSenderName(lastMessageSenderId).then((senderName) {
        _notificationService.showMessageNotification(
          senderName: senderName,
          message: lastMessage,
          conversationId: doc.id,
        );
      });

    } catch (e) {
      print('Error handling conversation update: $e');
    }
  }

  // Get sender's name from user document
  Future<String> _getSenderName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        return userData?['name'] ?? 
               userData?['displayName'] ?? 
               userData?['email']?.toString().split('@').first ?? 
               'Someone';
      }
      return 'Someone';
    } catch (e) {
      return 'Someone';
    }
  }

  // Start listening to a specific conversation
  void startListeningToConversation(String conversationId, String currentUserId) {
    // Stop existing listener if any
    _conversationListeners[conversationId]?.cancel();

    _conversationListeners[conversationId] = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final messageDoc = snapshot.docs.first;
        final messageData = messageDoc.data();
        final senderId = messageData['senderId'] as String? ?? '';
        final content = messageData['content'] as String? ?? '';

        // Don't show notification for messages sent by current user
        if (senderId != currentUserId && content.isNotEmpty) {
          _getSenderName(senderId).then((senderName) {
            _notificationService.showMessageNotification(
              senderName: senderName,
              message: content,
              conversationId: conversationId,
            );
          });
        }
      }
    });
  }

  // Stop listening to a specific conversation
  void stopListeningToConversation(String conversationId) {
    _conversationListeners[conversationId]?.cancel();
    _conversationListeners.remove(conversationId);
  }

  // Stop all listeners
  void stopAllListeners() {
    for (final listener in _conversationListeners.values) {
      listener.cancel();
    }
    _conversationListeners.clear();
  }

  // Create a notification in Firestore (for cross-device notifications)
  Future<void> createFirestoreNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'additionalData': additionalData,
      });
    } catch (e) {
      print('Error creating Firestore notification: $e');
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  // Get unread notification count
  Stream<int> getUnreadNotificationCount(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
