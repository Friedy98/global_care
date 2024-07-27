import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../color_constants.dart';
import '../../../providers/laravel_provider.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/booking_notification_item_widget.dart';
import '../widgets/new_price_notification_item_widget.dart';
import '../widgets/travel_notification_item_widget.dart';
import '../widgets/notification_item_widget.dart';

class NotificationDetailsView extends GetView<NotificationsController> {
  var notification;

  @override
  Widget build(BuildContext context) {
    var arguments = Get.arguments as Map<String, dynamic>;
    if (arguments != null) {
      if (arguments['notification'] != null) {
        notification = arguments['notification'];

        Get.lazyPut(() => NotificationsController());

        return Scaffold(
            appBar: AppBar(
                title: Text(
                  "Notification Details".tr,
                  style: Get.textTheme.headline6.merge(
                      TextStyle(color: Colors.white)),
                ),
                centerTitle: true,
                backgroundColor: appBarColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white)
                )
            ),
            bottomSheet:  viewData(
              'sent time :',
              notification.timestamp?.toString(),
              FontWeight.bold,
              Colors.grey,
              12,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    if (notification != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            viewData(
                                '', notification.title, FontWeight.bold, Colors
                                .black, 20),
                            viewData(' ', notification.message, FontWeight
                                .normal,
                                Colors.black, 12),

                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
            )

        );
      }
    }
  }

  Widget viewData(String title, String value, FontWeight fontWeight,
      Color color,
      double fontSize) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toString(),
            style: TextStyle(fontWeight: fontWeight, color: color),
          ),
          Expanded(
              child: Text(value ?? 'N/A',
                  style: TextStyle(
                      fontWeight: fontWeight,
                      color: color,
                      fontSize: fontSize)))
        ],
      ),
    );
  }
}