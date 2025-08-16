import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // In-app notification controller
  final StreamController<AppNotification> _notificationController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream => _notificationController.stream;

  // Initialize the notification service
  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'clf_channel',
      'CLF Notifications',
      channelDescription: 'Notifications for Campus Lost and Found app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show an in-app notification
  void showInAppNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notificationController.add(notification);

    // Auto-remove notification after duration
    Future.delayed(duration, () {
      _notificationController.add(notification.copyWith(isRemoved: true));
    });
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screens here
    print('Notification tapped: ${response.payload}');
  }

  // Show message notification
  void showMessageNotification({
    required String senderName,
    required String message,
    required String conversationId,
  }) {
    // Show local notification
    showLocalNotification(
      title: 'New message from $senderName',
      body: message,
      payload: conversationId,
      id: DateTime.now().millisecondsSinceEpoch,
    );

    // Show in-app notification
    showInAppNotification(
      title: 'New message',
      message: '$senderName: $message',
      type: NotificationType.message,
    );
  }

  // Show item found notification
  void showItemFoundNotification({
    required String itemName,
    required String finderName,
  }) {
    showLocalNotification(
      title: 'Item Found!',
      body: '$itemName has been found by $finderName',
      id: DateTime.now().millisecondsSinceEpoch,
    );

    showInAppNotification(
      title: 'Item Found!',
      message: '$itemName has been found by $finderName',
      type: NotificationType.success,
    );
  }

  // Show item claimed notification
  void showItemClaimedNotification({
    required String itemName,
    required String claimantName,
  }) {
    showLocalNotification(
      title: 'Item Claimed',
      body: '$itemName has been claimed by $claimantName',
      id: DateTime.now().millisecondsSinceEpoch,
    );

    showInAppNotification(
      title: 'Item Claimed',
      message: '$itemName has been claimed by $claimantName',
      type: NotificationType.info,
    );
  }

  // Listen to Firestore for real-time notifications
  void startListeningToNotifications(String userId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _handleNotificationFromFirestore(data);
        }
      }
    });
  }

  // Handle notifications from Firestore
  void _handleNotificationFromFirestore(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'info';
    final title = data['title'] as String? ?? 'Notification';
    final message = data['message'] as String? ?? '';

    switch (type) {
      case 'message':
        showMessageNotification(
          senderName: data['senderName'] ?? 'Someone',
          message: message,
          conversationId: data['conversationId'] ?? '',
        );
        break;
      case 'item_found':
        showItemFoundNotification(
          itemName: data['itemName'] ?? 'Item',
          finderName: data['finderName'] ?? 'Someone',
        );
        break;
      case 'item_claimed':
        showItemClaimedNotification(
          itemName: data['itemName'] ?? 'Item',
          claimantName: data['claimantName'] ?? 'Someone',
        );
        break;
      default:
        showInAppNotification(
          title: title,
          message: message,
          type: NotificationType.info,
        );
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Dispose resources
  void dispose() {
    _notificationController.close();
  }
}

// In-app notification model
class AppNotification {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRemoved;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRemoved = false,
  });

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRemoved,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }
}

// Notification types
enum NotificationType {
  info,
  success,
  warning,
  error,
  message,
}
