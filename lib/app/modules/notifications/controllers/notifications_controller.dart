import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/notification_model.dart';
import '../../../repositories/notification_repository.dart';
import '../../../services/my_auth_service.dart';
import '../../root/controllers/root_controller.dart';
import 'package:http/http.dart' as http;

class NotificationsController extends GetxController {
  final notifications = [].obs;
  final travelId = 0.obs;
  final chatInfo = {}.obs;
  NotificationRepository _notificationRepository;

  NotificationsController() {
    _notificationRepository = new NotificationRepository();
  }

  @override
  void onInit() async {
    await refreshNotifications();
    super.onInit();
  }

  Future refreshNotifications({bool showMessage}) async {
    //await getBackgroundMessage();
    notifications.clear();
    var backendList = await getNotifications();
    //
    for (var i = 0; i < backendList.length; i++) {
        notifications.add(backendList[backendList.length-i-1]);
    }
    Get.find<RootController>().getNotificationsCount();
    if (showMessage == true) {
      Get.showSnackbar(Ui.SuccessSnackBar(message: "List of notifications refreshed successfully".tr));
    }
  }

  Future getNotifications() async {


    await getBackgroundMessage();

    var list = [];

    for (var i = 0; i < Domain.myBoxStorage.value.length; i++) {
      NotificationModel model = NotificationModel(
       id: Domain.myBoxStorage.value.getAt(i)['id'] ,
        disable: Domain.myBoxStorage.value.getAt(i)['disable'],
        isSeen: Domain.myBoxStorage.value.getAt(i)['isSeen'],
        message: Domain.myBoxStorage.value.getAt(i)['message'],
        timestamp: Domain.myBoxStorage.value.getAt(i)['timestamp'].toString(),
        title: Domain.myBoxStorage.value.getAt(i)['title']
      );
      list.add(model);
    }

    return list;

  }

  getBackgroundMessage() async {
    if (!Hive.isBoxOpen('backgroundMessage')) {
      await Hive.openBox('backgroundMessage');
    }

    for (int j = 0; j < Hive.box("backgroundMessage").length; j++) {

        Domain.myBoxStorage.value.add(Hive.box("backgroundMessage").getAt(j));

      }

    await Hive.box("backgroundMessage").clear();
    await Hive.box("backgroundMessage").close();
  }



  Future removeNotification(NotificationModel notification) async {
    for (var i = 0; i < Domain.myBoxStorage.value.length; i++) {
      if(Domain.myBoxStorage.value.getAt(i)['id'] == notification.id)
      {
        Domain.myBoxStorage.value.deleteAt(i);
      }

    }
    await refreshNotifications();



  }

  Future markAsReadNotification(NotificationModel notification) async {
    for (var i = 0; i < Domain.myBoxStorage.value.length; i++) {
      if(Domain.myBoxStorage.value.getAt(i)['id'] == notification.id)
      {
        final remoteModel = NotificationModel(
          title: notification?.title.toString(),
          id: notification.id,
          isSeen: true,
          message: notification.message,
          timestamp: notification.timestamp,
          disable: false,
        );
        Domain.myBoxStorage.value.putAt(i, remoteModel.toJson());
      }

    }
    await refreshNotifications();


  }


  Future getTravelInfo(int id)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Cookie': 'session_id=7c27b4e93f894c9b8b48cad4e00bb4892b5afd83'
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/m1st_hk_roadshipping.travelbooking?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      return json.decode(data)[0];
    }
    else {
      var data = await response.stream.bytesToString();
      //isLoading.value = false;
      //print(data);
    }
  }

  getSingleShipping(int id) async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/m1st_hk_roadshipping.shipping?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print(result);
      return json.decode(result)[0];
    }
    else {
      print(response.reasonPhrase);
    }

  }

}