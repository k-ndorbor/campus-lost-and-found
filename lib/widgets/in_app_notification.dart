import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class InAppNotificationWidget extends StatelessWidget {
  final AppNotification notification;

  const InAppNotificationWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: _getTextColor().withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: _getTextColor().withOpacity(0.6),
              size: 20,
            ),
            onPressed: () {
              // Remove notification
              NotificationService().showInAppNotification(
                title: notification.title,
                message: notification.message,
                type: notification.type,
                duration: Duration.zero,
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (notification.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.message:
        return const Color(0xFF1A237E);
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }

  Color _getIconColor() {
    return Colors.white;
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.info:
      default:
        return Icons.info;
    }
  }
}

class InAppNotificationOverlay extends StatefulWidget {
  final Widget child;

  const InAppNotificationOverlay({
    super.key,
    required this.child,
  });

  @override
  State<InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends State<InAppNotificationOverlay>
    with TickerProviderStateMixin {
  final List<AppNotification> _notifications = [];
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Listen to notifications
    NotificationService().notificationStream.listen((notification) {
      if (notification.isRemoved) {
        _removeNotification(notification.id);
      } else {
        _addNotification(notification);
      }
    });
  }

  void _addNotification(AppNotification notification) {
    setState(() {
      _notifications.add(notification);
    });
    _slideController.forward();
  }

  void _removeNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Show notifications at the top
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 0,
          right: 0,
          child: Column(
            children: _notifications.map((notification) {
              return SlideTransition(
                position: _slideAnimation,
                child: InAppNotificationWidget(notification: notification),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
