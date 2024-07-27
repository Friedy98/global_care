import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/my_user_model.dart';
import '../../../providers/odoo_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/my_auth_service.dart';

class UserTravelsController extends GetxController {

  final isDone = false.obs;
  var isLoading = true.obs;
  var items = [].obs;
  var state = "".obs;
  var myTravelsList = [];
  var roadTravels = [];
  var listAttachment = [];
  var travelList = [];
  var inNegotiation = false.obs;
  var listForProfile = [].obs;
  var isConform = false.obs;
  final selectedState = <String>[].obs;
  var origin = [].obs;
  var status = ["ALL".tr, "PENDING".tr, "ACCEPTED".tr, "NEGOTIATING".tr, "COMPLETED".tr, "REJECTED".tr];

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    initValues();
    super.onInit();

  }

  @override
  void onReady(){

    initValues();
    super.onReady();
  }

  initValues()async{
    isLoading.value = true;
    Get.lazyPut(()=>UserTravelsController());
    Get.lazyPut<MyAuthService>(
          () => MyAuthService(),
    );
    Get.lazyPut<OdooApiClient>(
          () => OdooApiClient(),
    );
    await getUser(Get.find<MyAuthService>().myUser.value.id);
    myTravelsList = await myTravels();
    items.clear();
    origin.value = myTravelsList;
    items.value = myTravelsList;

    print(items);
  }

  Future refreshMyTravels() async {
    isLoading.value = true;
    items.clear();
    await getUser(Get.find<MyAuthService>().myUser.value.id);
    myTravelsList = await myTravels();
    origin.value = myTravelsList;
    items.value = myTravelsList;
    print(listForProfile.length.toString());
  }

  void toggleTravels(bool value, String type) {
    if (value) {
      selectedState.clear();
      selectedState.add(type);
    } else {
      selectedState.removeWhere((element) => element == type);
    }
  }
 
  Future getUser(int id) async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse(Domain.serverPort+'/read/res.partner?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var data = json.decode(result)[0];
      travelList = data['travelbooking_ids'];
      listAttachment = data['partner_attachment_ids'];
    } else {
      print(response.reasonPhrase);
    }
  }

  Future myTravels()async{

    print("travel ids are: $travelList");

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/m1st_hk_roadshipping.travelbooking?ids=$travelList'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      isLoading.value = false;
      return json.decode(data);
    }
    else {
      var data = await response.stream.bytesToString();
      isLoading.value = false;
      print(data);
    }
  }

  publishTravel(int travelId)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/call/m1st_hk_roadshipping.travelbooking/set_to_negotiating/?ids=$travelId'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Travel opened to the public"));
      await getUser(Get.find<MyAuthService>().myUser.value.id);
      myTravelsList = await myTravels();
      items.value = myTravelsList;
    }
    else {
      var data = await response.stream.bytesToString();
      showDialog(
          context: Get.context,
          builder: (_){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              icon: Icon(Icons.warning_amber_rounded, size: 40),
              title: Text("Identity files not conform!", style: Get.textTheme.headline2.merge(TextStyle(color: interfaceColor, fontSize: 14))),
              content: Text(json.decode(data)['message']+"\nDo you want to upload a new file?", style: Get.textTheme.headline4.merge(TextStyle(color: Colors.black, fontSize: 12))),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(Get.context),
                        child: Text("Back", style: Get.textTheme.headline4.merge(TextStyle(color: specialColor))
                        )
                    ),
                    SizedBox(width: 10),
                    TextButton(
                        onPressed: () => {
                          Navigator.pop(Get.context),
                          Get.toNamed(Routes.IDENTITY_FILES),
                        },
                        child: Text("Upload files", style: Get.textTheme.headline4
                        )
                    ),
                  ],
                )
              ],
            );
          });
    }
  }

  void filterSearchResults(String query) {
    List dummySearchList = [];
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['departure_city_id'][1]
          .toString().toLowerCase().contains(query.toLowerCase()) || element['arrival_city_id'][1]
          .toString().toLowerCase().contains(query.toLowerCase()) ).toList();
      items.value = dummyListData;
      return;
    } else {
      items.value = dummySearchList;
    }
  }

  @override
  void onClose() {
    //chatTextController.dispose();
  }
}
