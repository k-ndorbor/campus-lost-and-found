import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Different Types of Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Local Notifications
            const Text(
              'Local Device Notifications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showLocalNotification(
                  title: 'Test Notification',
                  body: 'This is a test local notification',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Local Notification'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showLocalNotification(
                  title: 'Message from John',
                  body: 'Hey, I found your lost phone!',
                  payload: 'conversation_123',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Message Notification'),
            ),
            
            const SizedBox(height: 32),
            
            // In-App Notifications
            const Text(
              'In-App Notifications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showInAppNotification(
                  title: 'Success!',
                  message: 'Your item has been posted successfully',
                  type: NotificationType.success,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Success Notification'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showInAppNotification(
                  title: 'Warning',
                  message: 'Please provide more details about your item',
                  type: NotificationType.warning,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Warning Notification'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showInAppNotification(
                  title: 'Error',
                  message: 'Failed to upload image. Please try again.',
                  type: NotificationType.error,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Error Notification'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showInAppNotification(
                  title: 'New Message',
                  message: 'Sarah: I think I found your laptop!',
                  type: NotificationType.message,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Message Notification'),
            ),
            
            const SizedBox(height: 32),
            
            // Specialized Notifications
            const Text(
              'Specialized Notifications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showItemFoundNotification(
                  itemName: 'iPhone 13',
                  finderName: 'Mike Johnson',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Item Found Notification'),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                notificationService.showItemClaimedNotification(
                  itemName: 'MacBook Pro',
                  claimantName: 'Alex Smith',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Item Claimed Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
