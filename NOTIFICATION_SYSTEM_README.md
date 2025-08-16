# Custom Notification System for CLF App

This document explains how to use the custom notification system built into your Campus Lost and Found (CLF) app without relying on third-party services.

## 🎯 **What This System Provides**

### 1. **Local Device Notifications**
- Push notifications that appear on the device's notification panel
- Works even when the app is in the background
- Customizable sound, vibration, and appearance

### 2. **In-App Notifications**
- Beautiful overlay notifications within the app
- Different styles for different notification types
- Auto-dismiss after a configurable duration

### 3. **Real-time Chat Notifications**
- Automatic notifications for new messages
- Shows sender name and message preview
- Integrates with your existing chat system

### 4. **Specialized Notifications**
- Item found notifications
- Item claimed notifications
- Custom notification types for different events

## 🚀 **How to Use**

### **Basic Usage**

```dart
import 'package:your_app/services/notification_service.dart';

final notificationService = NotificationService();

// Show a simple notification
notificationService.showInAppNotification(
  title: 'Success!',
  message: 'Your item has been posted',
  type: NotificationType.success,
);

// Show a device notification
notificationService.showLocalNotification(
  title: 'New Message',
  body: 'You have a new message from John',
);
```

### **Notification Types**

```dart
enum NotificationType {
  info,      // Blue - General information
  success,   // Green - Success messages
  warning,   // Orange - Warnings
  error,     // Red - Error messages
  message,   // Dark blue - Chat messages
}
```

### **Specialized Notifications**

```dart
// Message notification
notificationService.showMessageNotification(
  senderName: 'John Doe',
  message: 'I found your phone!',
  conversationId: 'conv_123',
);

// Item found notification
notificationService.showItemFoundNotification(
  itemName: 'iPhone 13',
  finderName: 'Mike Johnson',
);

// Item claimed notification
notificationService.showItemClaimedNotification(
  itemName: 'MacBook Pro',
  claimantName: 'Alex Smith',
);
```

## 🔧 **Integration Examples**

### **1. Chat Screen Integration**

The chat screen automatically shows notifications for new messages:

```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatNotificationHelper _notificationHelper = ChatNotificationHelper();

  @override
  void initState() {
    super.initState();
    // Start listening to notifications for this conversation
    _notificationHelper.startListeningToConversation(
      widget.conversationId,
      widget.currentUserId,
    );
  }

  @override
  void dispose() {
    // Stop listening to notifications
    _notificationHelper.stopListeningToConversation(widget.conversationId);
    super.dispose();
  }
}
```

### **2. Item Posting Success**

```dart
// After successfully posting an item
void onItemPosted() {
  notificationService.showInAppNotification(
    title: 'Success!',
    message: 'Your item has been posted successfully',
    type: NotificationType.success,
  );
}
```

### **3. Error Handling**

```dart
void onError(String errorMessage) {
  notificationService.showInAppNotification(
    title: 'Error',
    message: errorMessage,
    type: NotificationType.error,
  );
}
```

## 📱 **Testing the System**

Navigate to `/notification-test` in your app to test all notification types:

1. **Local Device Notifications**: Test push notifications
2. **In-App Notifications**: Test overlay notifications
3. **Specialized Notifications**: Test item-related notifications

## 🏗️ **Architecture**

### **Core Components**

1. **NotificationService** (`lib/services/notification_service.dart`)
   - Manages local device notifications
   - Handles in-app notification streams
   - Provides high-level notification methods

2. **ChatNotificationHelper** (`lib/services/chat_notification_helper.dart`)
   - Integrates with your chat system
   - Listens for new messages in real-time
   - Shows appropriate notifications

3. **InAppNotificationOverlay** (`lib/widgets/in_app_notification.dart`)
   - Displays in-app notifications
   - Handles animation and positioning
   - Manages notification lifecycle

### **Data Flow**

```
Firestore → ChatNotificationHelper → NotificationService → UI
    ↓              ↓                      ↓           ↓
New Message → Detect Change → Show Notification → Display
```

## ⚙️ **Configuration**

### **Android Permissions**

The system automatically requests notification permissions. Add these to your `android/app/src/main/AndroidManifest.xml` if needed:

```xml
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### **iOS Permissions**

iOS permissions are handled automatically through the `flutter_local_notifications` package.

## 🔄 **Real-time Features**

### **Automatic Message Notifications**

- ✅ New messages trigger notifications automatically
- ✅ Shows sender name and message preview
- ✅ Works across all conversations
- ✅ Respects user's current conversation

### **Smart Notification Filtering**

- ❌ No notifications for your own messages
- ❌ No duplicate notifications
- ❌ No notifications for old messages
- ✅ Only recent messages (within 30 seconds)

## 🎨 **Customization**

### **Notification Appearance**

```dart
// Custom notification duration
notificationService.showInAppNotification(
  title: 'Custom Duration',
  message: 'This notification stays for 10 seconds',
  duration: Duration(seconds: 10),
);

// Custom notification styling
// Edit lib/widgets/in_app_notification.dart to change colors, fonts, etc.
```

### **Adding New Notification Types**

1. Add new type to `NotificationType` enum
2. Update `_getBackgroundColor()`, `_getIcon()`, etc. methods
3. Create specialized methods in `NotificationService`

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Notifications not showing**
   - Check if permissions are granted
   - Verify the notification service is initialized
   - Check console for error messages

2. **Chat notifications not working**
   - Ensure `ChatNotificationHelper` is properly integrated
   - Check Firestore security rules
   - Verify conversation structure

3. **Performance issues**
   - Notifications are lightweight and shouldn't affect performance
   - If issues persist, check Firestore query optimization

### **Debug Mode**

Enable debug prints by checking the console:

```dart
// The system automatically logs:
print('Conversations error: ${snapshot.error}');
print('Error parsing conversation: $e');
print('Error handling conversation update: $e');
```

## 🔮 **Future Enhancements**

### **Planned Features**

- [ ] Notification preferences (sound, vibration, etc.)
- [ ] Notification history
- [ ] Push notification scheduling
- [ ] Rich media notifications (images, buttons)
- [ ] Notification categories and filtering

### **Extensibility**

The system is designed to be easily extensible:

- Add new notification types
- Customize appearance and behavior
- Integrate with other app features
- Add notification analytics

## 📚 **API Reference**

### **NotificationService Methods**

```dart
// Core methods
Future<void> initialize()
Future<void> showLocalNotification({...})
void showInAppNotification({...})

// Specialized methods
void showMessageNotification({...})
void showItemFoundNotification({...})
void showItemClaimedNotification({...})

// Utility methods
void startListeningToNotifications(String userId)
Future<void> markNotificationAsRead(String notificationId)
void dispose()
```

### **ChatNotificationHelper Methods**

```dart
// Conversation management
void startListeningToConversations(String userId)
void startListeningToConversation(String conversationId, String currentUserId)
void stopListeningToConversation(String conversationId)
void stopAllListeners()

// Firestore integration
Future<void> createFirestoreNotification({...})
Future<void> markAllNotificationsAsRead(String userId)
Stream<int> getUnreadNotificationCount(String userId)
```

## 🎉 **Conclusion**

This custom notification system provides:

- ✅ **No third-party dependencies** (except Flutter packages)
- ✅ **Full control** over notification behavior
- ✅ **Real-time integration** with your chat system
- ✅ **Professional appearance** with smooth animations
- ✅ **Easy customization** and extension
- ✅ **Cross-platform support** (Android, iOS, Web)

The system is production-ready and can handle all your notification needs without external services!
