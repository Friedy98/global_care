
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../main.dart';
import '../../../models/custom_page_model.dart';
import '../../../providers/odoo_provider.dart';
import '../../../repositories/custom_page_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/my_auth_service.dart';
import '../../account/controllers/account_controller.dart';
import '../../account/views/account_view.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/home2_view.dart';
import '../../home/widgets/fidelity_card_view.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../notifications/views/notifications_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../userBookings/controllers/bookings_controller.dart';
import '../../userBookings/views/bookings_view.dart';
import '../../userTravels/controllers/user_travels_controller.dart';
import '../../userTravels/views/userTravels_view.dart';

class RootController extends GetxController {
  final currentIndex = 0.obs;
  final notificationsCount = 0.obs;
  final customPages = <CustomPage>[].obs;
  NotificationsController _notificationController;
  //NotificationRepository _notificationRepository;
  CustomPageRepository _customPageRepository;
  PackageInfo packageInfo;

  RootController() {
    //_notificationRepository = new NotificationRepository();
    _notificationController = new NotificationsController();
    _customPageRepository = new CustomPageRepository();
  }

  @override
  void onInit() async {
    await getNotificationsCount();
    super.onInit();

    packageInfo = await PackageInfo.fromPlatform();
  }

  List<Widget> pages = [
    Home2View(),
    BookingsView(),
    FidelityCardWidget(),
    AccountView(),
  ];

  Widget get currentPage => pages[currentIndex.value];

  Future<void> changePageInRoot(int _index) async {
    Get.lazyPut<AccountController>(()=>AccountController());
    Get.lazyPut<MyAuthService>(
          () => MyAuthService(),
    );
    Get.lazyPut<OdooApiClient>(
          () => OdooApiClient(),
    );
    Get.lazyPut(()=> HomeController());
    //print(Get.find<MyAuthService>().myUser.value.name);
    currentIndex.value = _index;
    await refreshPage(_index);
  }

  Future<void> changePageOutRoot(int _index) async {
    Get.lazyPut<MyAuthService>(
          () => MyAuthService(),
    );
    Get.lazyPut<OdooApiClient>(
          () => OdooApiClient(),
    );
    currentIndex.value = _index;
    await refreshPage(_index);
    await Get.offNamedUntil(Routes.ROOT, (Route route) {
      if (route.settings.name == Routes.ROOT) {
        return true;
      }
      return false;
    }, arguments: _index);
  }

  Future<void> changePage(int _index) async {
    if (Get.currentRoute == Routes.ROOT) {
      await changePageInRoot(_index);
    } else {
      await changePageOutRoot(_index);
    }
  }

  Future<void> refreshPage(int _index) async {
    switch (_index) {
      case 0:
        {
          break;
        }
      case 1:
        {
          await Get.find<BookingsController>().refreshBookings();
          break;
        }
      case 2:
        {
          ScaffoldMessenger.of(Get.context).showSnackBar(SnackBar(
            content: Text("chargement des données..."),
            duration: Duration(seconds: 3),
          ));
          await Get.find<HomeController>().getUserDto();
          break;
        }

      case 3:
        {
          Get.lazyPut(()=>AccountController());
          await Get.find<AccountController>().onRefresh();
          break;
        }
    }
  }

  void getNotificationsCount() async {
    var count = 0;
    var list = await _notificationController.getNotifications();
    for(int i =0; i<list.length; i++ ){
        if(list[i].isSeen == false){
          count = count +1;
        }


    }
    notificationsCount.value =count;
    print('Notification: '+notificationsCount.toString());
  }
}
