import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/booking_model.dart';
import '../../../models/notification_model.dart' as model;
import '../../../routes/app_routes.dart';
import '../../../services/my_auth_service.dart';
import '../../root/controllers/root_controller.dart';
import '../../userBookings/controllers/bookings_controller.dart';
import '../controllers/notifications_controller.dart';
import 'notification_item_widget.dart';

class BookingNotificationItemWidget extends GetView<NotificationsController> {
  BookingNotificationItemWidget({Key key, this.notification}) : super(key: key);
  final model.NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return NotificationItemWidget(
      notification: notification,
      onDismissed: (notification) {
        controller.removeNotification(notification);
      },
      icon: Icon(
        Icons.assignment_outlined,
        color: Get.theme.scaffoldBackgroundColor,
        size: 34,
      ),
      onTap: (notification) async {
        print(notification.message);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Loading data..."),
          duration: Duration(seconds: 3),
        ));

        await controller.markAsReadNotification(notification);

        var id;
        if (notification.id != null &&
            notification.title.contains('A new Shipping has been created')) {
          id = notification.message.substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }

        if (notification.id != null &&
            notification.title.contains('Shipping has been Paid')) {
          id = notification.message.toString().substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }
        if (notification.id != null &&
            notification.title.contains('Shipping Cancelled')) {
          id = notification.message.substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }
        if (notification.id != null &&
            notification.title.contains('Packages has been delivered')) {
          id = notification.message.substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }
        if (notification.id != null &&
            notification.title.contains('Shipping has been rated')) {
          id = notification.message.substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }
        if (notification.id != null &&
            notification.title.contains('Shipping rejected')) {
          id = notification.message.substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }
        if (notification.id != null &&
            notification.title.contains('Packages has been received')) {
          id = notification.message.substring(
              notification.message.lastIndexOf(':') + 2,
              notification.message.length - 1);
        }

      },
    );
  }
}
