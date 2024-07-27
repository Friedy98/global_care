import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../color_constants.dart';
import '../../../../main.dart';
import '../../../models/address_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import 'package:http/http.dart' as http;

import '../../auth/controllers/auth_controller.dart';
import '../../userBookings/controllers/bookings_controller.dart';
import '../views/home_view.dart';

class HomeController extends GetxController {
  var opacity1 = 0.0.obs;
  var opacity2 = 0.0.obs;
  var opacity3 = 0.0.obs;
  var firstBar = 0.0.obs;
  var secondBar = 0.0.obs;
  var userBonus = 0.obs;
  var currentPage= 0.obs;
  var points = 0.obs;
  var clientPoint = 5.obs;
  var userId = 0.obs;
  var userName = "".obs;
  List<HomeList> homeList = HomeList.homeList;
  var multiple = true.obs;
  var userDto = {}.obs;
  var items = [].obs;
  var appointmentIds = [];
  var planned = 0.0.obs;
  var done = 0.0.obs;
  var missed = 0.0.obs;
  var cancel = 0.0.obs;
  Timer timer;

  HomeController() {
    //_sliderRepo = new SliderRepository();
    //_categoryRepository = new CategoryRepository();
    //_eServiceRepository = new EServiceRepository();
  }

  @override
  void onInit() async {
    getUserDto();

    //print(listItems);
    super.onInit();
  }

  getUserDto()async{
    setData();
    final box = GetStorage();
    final userdata = box.read('userData');
    userId.value = userdata['partner_id'];

    if(Get.find<AuthController>().isEmployee.value){
      initValues();
    }else{
      var data = await getUserInfo(userId.value);
      userDto.value = data;
      userName.value = data['display_name'];
      clientPoint.value = data['client_points'];
      userBonus.value = data['client_bonus'];
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  initValues()async{
    Get.lazyPut(() => BookingsController());
    final box = GetStorage();
    final userdata = box.read('userData');

    var plannedList = [];
    var doneList = [];
    var missedList = [];
    var cancelList = [];

    var data = await Get.find<BookingsController>().getAppointments(userdata['appointment_ids']);

    for(var i in data){
      if(i['state'] == "reserved"){
        plannedList.add(i);
      }else{
        if(i['state'] == "done"){
          doneList.add(i);
        }else{
          if(i['state'] == "missed"){
            missedList.add(i);
          }else{
            if(i['state'] == "cancel"){
              cancelList.add(i);
            }
          }
        }
      }
    }
    planned.value = plannedList.length.toDouble();
    done.value = doneList.length.toDouble();
    missed.value = missedList.length.toDouble();
    cancel.value = cancelList.length.toDouble();
    items.value = plannedList;
  }

  refreshPage()async{
    Get.lazyPut(() => BookingsController());
    final box = GetStorage();
    final userdata = box.read('userData');
    var value = await getEmployeeData(userdata['id']);

    var plannedList = [];
    var doneList = [];
    var missedList = [];
    var cancelList = [];

    var data = await Get.find<BookingsController>().getAppointments(value['appointment_ids']);

    for(var i in data){
      if(i['state'] == "reserved"){
        plannedList.add(i);
      }else{
        if(i['state'] == "done"){
          doneList.add(i);
        }else{
          if(i['state'] == "missed"){
            missedList.add(i);
          }else{
            if(i['state'] == "cancel"){
              cancelList.add(i);
            }
          }
        }
      }
    }
    planned.value = plannedList.length.toDouble();
    done.value = doneList.length.toDouble();
    missed.value = missedList.length.toDouble();
    cancel.value = cancelList.length.toDouble();
    items.value = plannedList;
  }

  getEmployeeData(var ids)async{

    showDialog(
        context: Get.context,
        barrierDismissible: false,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/business.resource?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      Navigator.pop(Get.context);
      return json.decode(result)[0];
    }
    else {
      print(response.reasonPhrase);
    }
  }

  final colorList = <Color>[
    newStatus,
    validateColor,
    inactive,
    specialColor
  ];

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  void navigateTo() async{
    //String query = Uri.encodeComponent(address);
    String googleUrl = "https://www.google.com/maps/dir//William+On+Hair+-+Fashion+Beaut%C3%A9+Mons/data=!4m6!4m5!1m1!4e2!1m2!1m1!1s0x47c25006bb9d310b:0xe6a44322fcfa67ab?sa=X&hl=fr&ved=2ahUKEwiU6o2Z3uf8AhWUraQKHWuiAI0Q9Rd6BAhbEAU";
    final Uri _url = Uri.parse(googleUrl);

    await launchUrl(_url,mode: LaunchMode.platformDefault);
  }

  void launchInstagram() async{
    const url = "https://instagram.com/will_on_hair?igshid=YmMyMTA2M2Y=";
    final Uri _url = Uri.parse(url);

    await launchUrl(_url,mode: LaunchMode.platformDefault);
  }

  void avisClients() async{
    //String query = Uri.encodeComponent(address);
    String googleUrl = "https://willonhair.com/#avis-clients";
    final Uri _url = Uri.parse(googleUrl);

    await launchUrl(_url,mode: LaunchMode.platformDefault);
  }

  Future<void> changePage(int _index) async {

    Get.lazyPut(() => BookingsController());

    switch (_index) {
      case 0:
        {
          await Get.find<BookingsController>().refreshBookings();
          Get.find<BookingsController>().showBackButton.value = true;
          await Get.toNamed(Routes.APPOINTMENT_BOOK);
          break;
        }
      case 1:
        {
          await Get.toNamed(Routes.CONTACT);
          break;
        }
      case 2:
        {
          await navigateTo();
          break;
        }
      case 3:
        {
          ScaffoldMessenger.of(Get.context).showSnackBar(SnackBar(
            content: Text("chargement des données..."),
            duration: Duration(seconds: 3),
          ));
          await getUserDto();
          await Get.toNamed(Routes.FIDELITY_CARD);
          break;
        }
      case 4:
        {
          await launchInstagram();
          break;
        }
      case 5:
        {
          await avisClients();
          break;
        }
    }
  }

  Future getUserInfo(int id)async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/res.partner?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      return json.decode(data)[0];
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future setData() async {
    int point = await getPoints();

    firstBar.value = double.parse((point/2).toStringAsFixed(0));
    secondBar.value = (point - firstBar.value);
    print("$firstBar and $secondBar");

    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    opacity1.value = 1.0;
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    opacity2.value = 1.0;
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    opacity3.value = 1.0;
  }

  getPoints()async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/search_read/res.config.settings?fields=%5B%22manager_required_bonus_points%22%5D&with_context=%7B%7D&with_company=1'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      if(json.decode(data).isNotEmpty){
        return json.decode(data)[0]['manager_required_bonus_points'];
      }else{
        return 20;
      }

    }
    else {
      print(response.reasonPhrase);
    }
  }


  Address get currentAddress {
    return Get.find<SettingsService>().address.value;
  }

  getServiceDto(var item, var appointment) async{

    var headers = {
      'Cookie': 'frontend_lang=fr_FR; session_id=bb097a3095a1d281f01592bd331b9c8f9c8631bd; visitor_uuid=fcef730c94854dfc991dcde26c242a3e'
    };
    var request = http.Request('GET', Uri.parse('https://willonhair.shintheo.com/get_products?ids=$item'));
    request.body = '''{\n    "jsonrpc": "2.0"\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(Get.context);
      var data = await response.stream.bytesToString();
      var service = json.decode(data)[0];
      var duration = service["appointment_duration"]*60;
      showDialog(
          context: Get.context,
          builder: (_){
            return AlertDialog(
              title: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                      children: [
                        IconButton(
                          onPressed: ()=> Navigator.pop(Get.context),
                          icon: Icon(Icons.arrow_back, size: 30),
                        ),
                        SizedBox(width: 30),
                        Text(appointment['name'])
                      ]
                  )
              ),
              content: SizedBox(
                height: 100,
                width: Get.width,
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: FadeInImage(
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            image: NetworkImage("${Domain.serverPort}/image/appointment.product/${service['id']}/image_1920?unique=true&file_response=true",
                                headers: Domain.getTokenHeaders()),
                            placeholder: AssetImage(
                                "assets/img/loading.gif"),
                            imageErrorBuilder:
                                (context, error, stackTrace) {
                              return Image.asset(
                                  "assets/img/photo_2022-11-25_01-12-07.jpg",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.fitWidth);
                            },
                          )
                      ),
                      title: Text(service['name'].split(">").first + "\n"+ service["product_price"].toString()+" €",
                          style: Get.textTheme.headline2),
                      subtitle: Text(duration.toString()+" minutes", style: Get.textTheme.headline2),
                    )
                  ]
                )
              ),
              actions: [
                if(appointment['state'] == "reserved")
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: employeeInterfaceColor),
                      child: Text("Traiter le rendez-vous"),
                      onPressed: (){
                        Get.lazyPut(()=>BookingsController());
                        Get.find<BookingsController>().selectedAppointment.value = appointment;
                        Get.find<BookingsController>().getAppointmentOrder(appointment["order_id"][0]);
                        Get.find<BookingsController>().refreshBookings();
                        currentPage.value = 3;
                        Navigator.pop(Get.context);

                      },
                    ),
                  )
              ],
            );
          });
    }
    else {
      print(response.reasonPhrase);
    }
  }
}
