import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/message_model.dart';
import '../../../models/notification_model.dart' as model;
import '../../../routes/app_routes.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/notifications_controller.dart';
import 'notification_item_widget.dart';

class TravelNotificationItemWidget extends GetView<NotificationsController> {
  TravelNotificationItemWidget({Key key, this.notification}) : super(key: key);
  final model.NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return NotificationItemWidget(
      notification: notification,
      onDismissed: (notification) {
        controller.removeNotification(notification);
      },
      icon: Icon(
        Icons.chat_outlined,
        color: Get.theme.scaffoldBackgroundColor,
        size: 34,
      ),
      onTap: (notification) async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Loading data..."),
          duration: Duration(seconds: 3),
        ));
        await controller.markAsReadNotification(notification);

        print(notification.message);
        var id;
        if(notification.id != null&& notification.title.contains('Travel Create')){
          id = notification.message.substring(notification.message.lastIndexOf(':')+2, notification.message.length-1);
        }
        if(notification.id != null&& notification.title.contains('Travel has been Accepted / Running')){
          id = notification.message.substring(notification.message.lastIndexOf(':')+2, notification.message.length-1);
        }
        if(notification.id != null&& notification.title.contains('Travel has been Completed')){
          id = notification.message.substring(notification.message.lastIndexOf(':')+2, notification.message.length-1);
        }
        if(notification.id != null&& notification.title.contains('Travel has been cancelled')){
          id = notification.message.substring(notification.message.lastIndexOf(':')+2, notification.message.length-1);
        }
        var travel = await controller.getTravelInfo(int.parse(id));
        Get.toNamed(Routes.TRAVEL_INSPECT, arguments: {'travelCard': travel, 'heroTag': 'services_carousel'});
        //Get.find<RootController>().changePage(2);
        //Get.toNamed(Routes.CHAT, arguments: new Message([], id: notification.id.toString()));

      },
    );
  }
}
