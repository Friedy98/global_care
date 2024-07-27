import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import 'package:http/http.dart' as http;
import '../../../providers/odoo_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/my_auth_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../travel_inspect/controllers/travel_inspect_controller.dart';

class BookingsController extends GetxController {

  var predict1 = false.obs;
  var errorCity1 = false.obs;
  TextEditingController searchController = TextEditingController();
  var street = "".obs;
  var clientBonus = 0.obs;
  var bonusList = [].obs;
  var remise = [].obs;
  var remiseList = [].obs;
  var userDto = {}.obs;
  var search = false.obs;
  var price = 0.0.obs;
  var employeeDto = {}.obs;
  var orderDto = {}.obs;
  var bonus = [].obs;
  var paymentLink = "".obs;
  var items = [].obs;
  var resources = [].obs;
  var selectedResource = [].obs;
  var sample = [];
  var isLoading = true.obs;
  var allServices = [].obs;
  var extraServices = [].obs;
  var extraProducts = [].obs;
  var appointments = [].obs;
  var allCategories = [].obs;
  var drawerAppointments = [].obs;
  var drawerAppointmentsOrigin = [].obs;
  var servicesByCategory = [].obs;
  var origin = [].obs;
  var invoice = [];
  var receipts = [].obs;
  var invoiceArticles = [].obs;
  var selectedAppointment = {}.obs;
  var selected = 0.obs;
  var totalInvoice = 0.0.obs;
  var loadOrder = false.obs;
  var loadingAppointments = true.obs;
  var treated = false.obs;
  var bonusId = 0;
  var showBackButton = false.obs;
  var firstDate = DateFormat("dd, MMMM", "fr_CA").format(DateTime.now()).toString().obs;
  var lastDate = DateFormat("dd, MMMM", "fr_CA").format(DateTime.now().subtract(Duration(days: 7))).toString().obs;
  TextEditingController dateController = TextEditingController();

  selectDate()async{

    final DateTimeRange result = await showDateRangePicker(
      context: Get.context,
      locale: Locale("fr", "FR"),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030, 12, 31).add(Duration(days: 30)),
      currentDate: DateTime.now(),
      saveText: 'Confirmer',
    );
    items.value = sample;

    List<String> dates = result.toString().split(" - ");
    String date1 = dates[0];
    String date2 = dates[1];
    DateTime startDate = DateTime.parse(date1);
    DateTime endDate = DateTime.parse(date2);

    firstDate.value = DateFormat("dd, MMMM yyyy", "fr_CA").format(startDate).toString();
    lastDate.value = DateFormat("dd, MMMM yyyy", "fr_CA").format(endDate).toString();
    dateController.text = firstDate.value + " - " + lastDate.value;

    List list = [];
    List finalList = [];
    final daysToGenerate = endDate.add(Duration(days: 1)).difference(startDate).inDays;
    finalList = List.generate(daysToGenerate, (i) => DateTime(startDate.year, startDate.month, startDate.day + (i)));

    List intervalDates = [];
    for(var i=0; i<finalList.length; i++){
      String formatted2 = DateFormat("yyyy-MM-dd").format(finalList[i]).toString();
      intervalDates.add(formatted2);
    }
    for(var a=0; a<items.length; a++){
      String formatted = DateFormat("yyyy-MM-dd").format(DateTime.parse(items[a]['day_date'])).toString();
      for(var i in intervalDates){
        if(i == formatted){
          list.add(items[a]);
        }
      }
    }
    print("interval dates: $intervalDates");
    items.value = list;
  }

  selectDateInterval()async{

    final DateTimeRange result = await showDateRangePicker(
      context: Get.context,
      locale: Locale("fr", "FR"),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030, 12, 31).add(Duration(days: 30)),
      currentDate: DateTime.now(),
      saveText: 'Confirmer',
    );
    receipts.value = invoice;

    List<String> dates = result.toString().split(" - ");
    String date1 = dates[0];
    String date2 = dates[1];
    DateTime startDate = DateTime.parse(date1);
    DateTime endDate = DateTime.parse(date2);

    firstDate.value = DateFormat("dd, MMMM yyyy", "fr_CA").format(startDate).toString();
    lastDate.value = DateFormat("dd, MMMM yyyy", "fr_CA").format(endDate).toString();
    dateController.text = firstDate.value + " - " + lastDate.value;

    List list = [];
    List finalList = [];
    final daysToGenerate = endDate.add(Duration(days: 1)).difference(startDate).inDays;
    finalList = List.generate(daysToGenerate, (i) => DateTime(startDate.year, startDate.month, startDate.day + (i)));

    List intervalDates = [];
    double total = 0.0;
    for(var i=0; i<finalList.length; i++){
      String formatted2 = DateFormat("yyyy-MM-dd").format(finalList[i]).toString();
      intervalDates.add(formatted2);
    }
    for(var a=0; a<receipts.length; a++){
      String formatted = DateFormat("yyyy-MM-dd").format(DateTime.parse(receipts[a]['invoice_date_due'])).toString();
      for(var i in intervalDates){
        if(i == formatted){
          list.add(receipts[a]);
          total += receipts[a]['amount_total'];
        }
      }
    }
    print("interval dates: $intervalDates");
    receipts.value = list;
    totalInvoice.value = total;
  }

  filterDates()async{

    List list = [];
    List finalList = [];
    DateTime end = DateTime.now().subtract(Duration(days: 7));
    final daysToGenerate = end.add(Duration(days: 1)).difference(DateTime.now()).inDays;
    finalList = List.generate(daysToGenerate, (i) => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + (i)));

    List dates = [];
    for(var i=0; i<finalList.length; i++){
      String formatted2 = DateFormat("yyyy-MM-dd").format(finalList[i]).toString();
      dates.add(formatted2);
      for(var a=0; a<receipts.length; a++){
        String formatted = DateFormat("yyyy-MM-dd").format(DateTime.parse(receipts[a]['invoice_date_due'])).toString();
        for(var i in dates){
          if(i == formatted){
            list.add(receipts[a]);
          }
        }
      }
    }
    print("interval dates: $dates");
    receipts.value = list;
  }

  filterAppointmentDates()async{

    List list = [];
    List finalList = [];
    DateTime end = DateTime.now().subtract(Duration(days: 7));
    final daysToGenerate = end.add(Duration(days: 1)).difference(DateTime.now()).inDays;
    finalList = List.generate(daysToGenerate, (i) => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + (i)));

    List dates = [];
    for(var i=0; i<finalList.length; i++){
      String formatted2 = DateFormat("yyyy-MM-dd").format(finalList[i]).toString();
      dates.add(formatted2);
      for(var a=0; a<appointments.length; a++){
        String formatted = DateFormat("yyyy-MM-dd").format(DateTime.parse(appointments[a]['datetime_start'])).toString();
        for(var i in dates){
          if(i == formatted){
            list.add(appointments[a]);
          }
        }
      }
    }
    print("interval dates: $dates");
    appointments.value = list;
  }

  BookingsController() {
    Get.lazyPut<OdooApiClient>(
          () => OdooApiClient(),
    );
    Get.lazyPut<TravelInspectController>(
          () => TravelInspectController(),
    );
  }

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut<OdooApiClient>(
          () => OdooApiClient(),
    );
    initValues();
  }

  @override
  void onReady(){
    initValues();
    super.onReady();
  }

  initValues()async{
    isLoading.value = true;
    loadingAppointments.value = true;
    Get.lazyPut<AuthController>(
          () => AuthController(),
    );
    var data = await getCategories();
    allCategories.value = data;
    final box = GetStorage();
    var userdata = box.read("userData");
    userDto.value = userdata;
    print(userDto);

    if(Get.find<AuthController>().isEmployee.value){
      getAppointments(userDto['appointment_ids']);
    }else{
      await getCurrentUser(userDto['partner_id']);
    }
  }

  refreshBookings()async{
    initValues();
  }

  refreshEmployeeBookings()async{
    Get.lazyPut(() => HomeController());
    final box = GetStorage();
    final userdata = box.read('userData');
    var value = await Get.find<HomeController>().getEmployeeData(userdata['id']);

    await getAppointments(value['appointment_ids']);
  }

  void filterSearchResults(String query) {
    List dummySearchList = [];
    dummySearchList.addAll(drawerAppointmentsOrigin);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['partner_id'][1].toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      drawerAppointments.value = dummyListData;
      return;
    } else {
      drawerAppointments.clear();
      drawerAppointments.value = drawerAppointmentsOrigin;
    }
  }

  void filterSearchAppointment(String query) {
    List dummySearchList = [];
    dummySearchList.addAll(sample);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['partner_id'][1].toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      items.value = dummyListData;
      return;
    } else {
      items.clear();
      items.value = sample;
    }
  }

  void filterSearchInvoice(String query) {
    List dummySearchList = [];
    dummySearchList.addAll(invoice);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['invoice_partner_display_name'].toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      receipts.value = dummyListData;
      return;
    } else {
      receipts.clear();
      receipts.value = invoice;
    }
  }

  void filterSearchServices(String query){
    List dummySearchList = [];
    dummySearchList.addAll(origin);
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['name'].toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      servicesByCategory.value = dummyListData;
      return;
    } else {
      servicesByCategory.clear();
      servicesByCategory.value = origin;
    }
  }

  Future getCategories()async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/search_read/business.resource.type'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      getServiceByCategory(json.decode(data)[0]['service_ids']);
      return json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getServiceByCategory(var values)async{
    var ids = values.join(",");
    print(ids);
    var headers = {
      'Cookie': 'frontend_lang=fr_FR; session_id=bb097a3095a1d281f01592bd331b9c8f9c8631bd; visitor_uuid=fcef730c94854dfc991dcde26c242a3e'
    };
    var request = http.Request('GET', Uri.parse('https://willonhair.shintheo.com/get_products?ids=$ids'));
    request.body = '''{\n    "jsonrpc": "2.0"\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      isLoading.value = false;
      origin.value = json.decode(data);
      servicesByCategory.value = json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future getCurrentUser(var id)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/res.partner?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      isLoading.value = false;
      var result = json.decode(data)[0];
      getAppointments(result['appointment_ids']);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getAppointments(var ids)async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/business.appointment?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      items.value = json.decode(data);
      sample = json.decode(data);
      isLoading.value = false;
      return json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getResources()async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/search_read/business.resource'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      isLoading.value = false;
      var sample = [];
      for(var i in json.decode(data)){
        if(selectedAppointment["resource_type_id"][0] == i['resource_type_id'][0] && i['id'] != selectedAppointment['resource_id'][0]){
          sample.add(i);
        }
      }
      resources.value = sample;
      Navigator.pop(Get.context);
      var resourceId = 0;
      var resourceName = '';

      showDialog(
          context: Get.context,
          builder: (_){
            return AlertDialog(

              title: SizedBox(
                width: Get.width,
                height: 50,
                child: Row(
                    children: [
                      Expanded(
                          child: Text("Transferer le rendez-vous ${selectedAppointment['name']}")
                      ),
                      IconButton(
                          onPressed: ()=> {
                            selectedResource.clear(),
                            Navigator.pop(Get.context)
                          },
                          icon: Icon(Icons.close, size: 30, color: Colors.black)
                      )
                    ]
                )
              ),
              content: SizedBox(
                width: Get.width,
                height: Get.height/2,
                child: Column(
                  children: [
                    Expanded(
                        child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 260.0,
                              mainAxisSpacing: 12.0,
                              crossAxisSpacing: 25.0,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: resources.length,
                            itemBuilder: (context, item){
                              return InkWell(
                                  onTap: (){

                                    selectedResource.clear();
                                    selectedResource.add(resources[item]);
                                    resourceId = resources[item]['id'];
                                    resourceName = resources[item]["display_name"];
                                    print(resourceId);

                                  },
                                  child: Obx(() =>
                                      Container(
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(15),
                                            color: selectedResource.contains(resources[item]) ? background : Palette.background,
                                          ),
                                          child: Column(
                                              children: [
                                                ClipRRect(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                    child: FadeInImage(
                                                        width: 200,
                                                        height: 200,
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage('${Domain.serverPort}/image/hr.employee/${resources[item]["employee_id"][0]}/image_1920?unique=true&file_response=true',
                                                            headers: Domain.getTokenHeaders()),
                                                        placeholder: AssetImage(
                                                            "assets/img/loading.gif"),
                                                        imageErrorBuilder:
                                                            (context, error, stackTrace) {
                                                          return Image.asset(
                                                              'assets/img/man.png',
                                                              width: 200,
                                                              height: 200,
                                                              fit: BoxFit.cover);
                                                        }
                                                    )
                                                ),
                                                SizedBox(height: 10),
                                                Text(resources[item]["display_name"], style: Get.textTheme.headline4.merge(TextStyle(color: selectedResource.contains(resources[item]) ?
                                                employeeInterfaceColor : Colors.black))
                                                ),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              );
                            })
                    )
                  ],
                ),
              ),
              actions: [

                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(() =>
                          InkWell(
                            onTap: ()=> {
                              if(selectedResource.isNotEmpty){
                                transferAppointment(resourceId, resourceName)
                              }
                            },
                            child: Container(
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedResource.isNotEmpty ? interfaceColor : null,
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    border: selectedResource.isEmpty ? Border.all(width: 2, color: inactive) : null
                                ),
                                child: Center(
                                  child: Text("Transférer", style: TextStyle(color: selectedResource.isEmpty ? inactive : Colors.white, letterSpacing: 2, fontSize: 15)),)
                            ),
                          )
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: (){
                          var data = [];
                          var serviceData;
                          for(var i in allCategories){
                            if(selectedAppointment['resource_type_id'][0] == i['id']){
                              data = i['resource_ids'];
                            }
                          }
                          for(var a in data){
                            if(a == selectedAppointment['resource_id'][0]){
                              data.remove(a);
                            }
                          }
                          Get.lazyPut(() => TravelInspectController());
                          Get.find<TravelInspectController>().updateAppointment(selectedAppointment, data);
                          Get.find<TravelInspectController>().editAppointment.value = true;
                          Get.toNamed(Routes.ADD_SHIPPING_FORM);
                        },
                        child: Container(
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                              color: interfaceColor,
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Center(
                              child: Text("Modifier l'heure", style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 15)),)
                        )
                      ),
                    ]
                )
              ],
            );
          });

    }
    else {
      print(response.reasonPhrase);
    }
  }

  transferAppointment(int resourceId, String resourceName)async{
    var box = GetStorage();
    showDialog(
        context: Get.context,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });
    print("${selectedAppointment['id']} and $resourceId and $resourceName");

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('PUT', Uri.parse('${Domain.serverPort}/write/business.appointment?ids=%5B%22${selectedAppointment['id']}%22%5D&values=%7B%0A%20%20%22resource_id%22%3A%20$resourceId%0A%7D&with_context=%7B%7D&with_company=1'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(Get.context);
      print(await response.stream.bytesToString());
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Rendez-vous à été transféré a $resourceName avec succès".tr ));
      selectedAppointment.clear();
      var data = await getUserInfo(userDto['id']);
      box.write("userDto", data);
      Navigator.pop(Get.context);

    }
    else {
      var data = await response.stream.bytesToString();
      Navigator.pop(Get.context);
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message']));
      print(response.reasonPhrase);
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
      var data = await response.stream.bytesToString();
      print(data);
      print(response.reasonPhrase);
    }
  }

  uploadProfileImage(File file, int id) async {
    if (Get.find<MyAuthService>().myUser.value.email==null) {
      throw new Exception("You don't have the permission to access to this area!".tr + "[ uploadImage() ]");
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Content-Type': 'multipart/form-data',
      'Cookie': 'session_id=a5b5f221b0eca50ae954ad4923fead1063097951'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${Domain.serverPort}/upload/res.partner/$id/image_1920'));
    request.files.add(await http.MultipartFile.fromPath('ufile', file.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();


    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      //var user = await getUser();
      //var uuid =user.image ;

      //return uuid;
    }
    else {
      print(response.reasonPhrase);
    }
  }

  launchURL(var link) async {
    if(link.toString() != "false"){
      ScaffoldMessenger.of(Get.context).showSnackBar(SnackBar(
        content: Text(link.toString()),
        backgroundColor: validateColor.withOpacity(0.4),
        margin: EdgeInsets.only(
            bottom: Get.height - 160,
            left: 10,
            right: 10),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));

      final Uri url = Uri.parse(link);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }else{
      ScaffoldMessenger.of(Get.context).showSnackBar(SnackBar(
        content: Text("Error occurred...[$link]"),
        margin: EdgeInsets.only(
            bottom: Get.height - 160,
            left: 10,
            right: 10),
        behavior: SnackBarBehavior.floating,
        backgroundColor: specialColor.withOpacity(0.4),
        duration: Duration(seconds: 2),
      ));
    }
  }

  getReceipts()async{

    showDialog(
        context: Get.context,
        barrierDismissible: false,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/search_read/account.move'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      List list = json.decode(data);
      List sample = [];
      double total = 0.0;
      for(var i=0; i < list.length; i++){
        print("${list[i]['invoice_user_id'][1]} and ${Get.find<AuthController>().currentUser['user_id'][1]}");
        if(list[i]['invoice_user_id'][0] == Get.find<AuthController>().currentUser['user_id'][0] && list[i]['payment_state'] == "paid"){

          sample.add(list[i]);
          total += list[i]['amount_total'];
        }
      }
      receipts.value = sample;
      invoice = sample;
      totalInvoice.value = total;
      print(receipts);
      Navigator.pop(Get.context);
    }
    else {
      print(response.reasonPhrase);
      Navigator.pop(Get.context);
    }

  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }



  @override
  void onClose() {
    //chatTextController.dispose();
  }

  getServiceDto(var item, var appointment, bool client) async{

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
                height: 120,
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
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(appointment['state'] == "reserved")
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: specialColor),
                      child: Text("Annuler le rendez-vous"),
                      onPressed: ()=>{

                        Navigator.pop(Get.context),
                        if(client){
                          showDialog(
                              context: Get.context,
                              builder: (_){
                                return AlertDialog(
                                    title: Text("Annuler le rendez-vous"),
                                    content: Text('Voulez vous vraiment annuler votre rendez-vous?', style: Get.textTheme.headline4),
                                    actions: [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                                onPressed: ()=> Navigator.pop(Get.context),
                                                child: Text('Retour')
                                            ),
                                            SizedBox(width: 10),
                                            TextButton(
                                                onPressed: ()=> cancelBooking(appointment['id']),
                                                child: Text('Annuler le rendez-vous', style: Get.textTheme.headline2)
                                            )
                                          ]
                                      )
                                    ]
                                );
                              }
                          )
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    if(appointment['state'] == "reserved" && !client)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: employeeInterfaceColor),
                      child: Text("Traiter le rendez-vous"),
                      onPressed: ()=>{

                        Get.lazyPut(() => HomeController()),

                        Navigator.pop(Get.context),

                        selectedAppointment.value = appointment,
                        getAppointmentOrder(appointment["order_id"][0]),
                        refreshBookings(),
                        Get.find<HomeController>().currentPage.value = 3

                      },
                    )
                  ],
                )
              ]
            );
          });
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getAppointmentOrder(var ids)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/sale.order?ids=$ids'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      orderDto.value = json.decode(data)[0];
      var value = await getUserInfo(selectedAppointment['partner_id'][0]);
      clientBonus.value = value['client_bonus'];
      getOrderLine(json.decode(data)[0]['order_line']);
    }
    else {
    print(response.reasonPhrase);
    }
  }

  addProductLine(var ids, var item, var data) async {
    print("$ids and ${selectedAppointment['id']}");
    var headers = {
      'api-key': Domain.apiKey,
      'Content-Type': 'text/plain'
    };
    var request = http.Request('POST', Uri.parse('https://willonhair.shintheo.com/api/associated.product.line/create'));
    request.body = data;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200)  {

      adaptSales(item);

    }
    else {
      print(response.reasonPhrase);
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message']));
      loadOrder.value = false;
    }
  }

  cancelBooking(int id) async{
    Navigator.pop(Get.context);

    showDialog(
        context: Get.context,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/call/business.appointment/action_cancel?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      Navigator.pop(Get.context);
      refreshBookings();
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Votre rendez-vous à été annulé avec succès".tr ));
    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message'] ));
      print(response.reasonPhrase);
    }
  }

  void getOrderLine(var ids) async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/sale.order.line?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      extraProducts.value = json.decode(data);
      print(extraProducts);
      loadOrder.value = false;
      double total = 0;
      for(var a in extraProducts){
        total += a['price_total'].toDouble();
      }
      price.value = total;
    }
    else {
      print("error here");
      print(response.reasonPhrase);
      loadOrder.value = false;
    }
  }

  updateAppointment(String data, String type)async{
    var headers = {
      'api-key': Domain.apiKey,
      'Content-Type': 'text/plain',
    };
    var request = http.Request('PUT', Uri.parse('https://willonhair.shintheo.com/api/business.appointment/${selectedAppointment['id']}'));
    request.body = data;

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      if(json.decode(data)['responseCode'] == 200){
        if(type == "remove"){
          adaptSales("remove");
        }else{
          adaptSales("remise");
        }

      }else{
        print("Error on update: ${json.decode(data)}");
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void markDone() async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/call/business.appointment/action_mark_done?ids=${selectedAppointment['id']}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      Navigator.pop(Get.context);
      refreshBookings();
      selectedAppointment.value = {};
      orderDto.value = {};
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Ce rendez-vous à été traité avec succès".tr ));
      Navigator.pop(Get.context);
    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message'] ));
      print(response.reasonPhrase);
    }
  }

  void adaptSales(var item) async{
    loadOrder.value = true;
    var headers = {
      'accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/call/business.appointment/action_adapt_sale_order?ids=${selectedAppointment['id']}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      if(item == "remise"){
        getAppointmentOrder(selectedAppointment['order_id'][0]);
        Navigator.pop(Get.context);
        Navigator.pop(Get.context);
        Get.showSnackbar(Ui.InfoSnackBar(message: "Reduction effectué avec  succès!"));
      }else{

        if(item == "bonus"){
          extraServices.remove(item);
          var point = clientBonus.value - 1;
          clientBonus = clientBonus - 1;

          bonusList.clear();
          updateUser(point);
          Get.showSnackbar(Ui.InfoSnackBar(message: "Bonus ajouté!!!"));
        }else{
          getAppointmentOrder(selectedAppointment['order_id'][0]);
          if(item == "remove"){
            extraServices.remove(item);
            Navigator.pop(Get.context);
            Navigator.pop(Get.context);
            Get.showSnackbar(Ui.InfoSnackBar(message: "Bonus retiré!!!"));
          }else{
            extraServices.remove(item);
            Get.showSnackbar(Ui.InfoSnackBar(message: "Service ajouté!!!"));
          }
        }
      }
    }
    else {
      print('Error AdaptSales ${response.reasonPhrase}');
    }
  }

  getBonuses() async{
    var box = GetStorage();
    if(box.read("bonus") != null){
      bonus.value = box.read("bonus");
      showDialog(
          context: Get.context,
          builder: (BuildContext context) =>
              AlertDialog(
                  contentPadding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  backgroundColor: background,
                  content: buildBonusBox(context),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            bonusList.clear();
                            Navigator.pop(Get.context);
                          },
                          child: Container(
                              width: 150,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(width: 2, color: inactive)
                              ),
                              child: Center(
                                child: Text("Annuler", style: TextStyle(color: inactive, letterSpacing: 2, fontSize: 15)),)
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: ()async{

                            showDialog(
                                context: context,
                                builder: (_){
                                  return SpinKitFadingCircle(color: Colors.white, size: 50);
                                });

                            var values = json.encode({
                              "discount_type": "bonus"
                            });
                            useMyBonus(values);
                          },
                          child: Obx(() =>
                              Container(
                                  width: 150,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: bonusList.isNotEmpty ? interfaceColor : null,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      border: bonusList.isEmpty ? Border.all(width: 2, color: inactive) : null
                                  ),
                                  child: Center(
                                    child: Text("Continuer", style: TextStyle(color: bonusList.isEmpty ? inactive : Colors.white, letterSpacing: 2, fontSize: 15)),)
                              )
                          ),
                        ),
                      ]
                  )
                ],
              )
      );
    }else{
      proceedGetBonus();
    }
  }

  proceedGetBonus()async{
    var box = GetStorage();
    showDialog(
        context: Get.context,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/product.product?ids=21,22,51'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var values = json.decode(data);
      bonus.value = values;
      box.write("bonus", values);
      Navigator.pop(Get.context);

      showDialog(
          context: Get.context,
          builder: (BuildContext context) =>
              AlertDialog(
                  contentPadding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  backgroundColor: background,
                  content: buildBonusBox(context),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            bonusList.clear();
                            Navigator.pop(Get.context);
                          },
                          child: Container(
                              width: 150,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(width: 2, color: inactive)
                              ),
                              child: Center(
                                child: Text("Annuler", style: TextStyle(color: inactive, letterSpacing: 2, fontSize: 15)),)
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: ()async{

                            showDialog(
                                context: context,
                                builder: (_){
                                  return SpinKitFadingCircle(color: Colors.white, size: 50);
                                });
                            var values = json.encode({
                              "discount_type": "bonus"
                            });
                            useMyBonus(values);
                          },
                          child: Obx(() =>
                              Container(
                                  width: 150,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: bonusList.isNotEmpty ? interfaceColor : null,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      border: bonusList.isEmpty ? Border.all(width: 2, color: inactive) : null
                                  ),
                                  child: Center(
                                    child: Text("Continuer", style: TextStyle(color: bonusList.isEmpty ? inactive : Colors.white, letterSpacing: 2, fontSize: 15)),)
                              )
                          ),
                        ),
                      ]
                  )
                ],
              )
      );
    }
    else {
      print(response.reasonPhrase);
      loadOrder.value = false;
    }
  }

  Widget buildBonusBox(BuildContext context){
    return Container(
        height: 240,
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Choix du bonus", style: Get.textTheme.headline2),
              SizedBox(height: 30),
              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: bonus.length,
                      itemBuilder: (context, index) {

                        return InkWell(
                            onTap: (){
                              bonusId = bonus[index]['id'];
                              bonusList.clear();
                              bonusList.add(bonus[index]);
                              print(bonusId);
                            },
                            child: Obx(() =>
                                Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    padding: EdgeInsets.all(10),
                                    height: 70,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                        border: bonusList.contains(bonus[index]) ? Border.all(width: 2, color: interfaceColor) : null
                                    ),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(bonus[index]['discount_management'].toString().toUpperCase(), style: Get.textTheme.headline2),
                                          Text(bonus[index]['list_price'].abs().toInt().toString(), style: Get.textTheme.headline2.
                                          merge(TextStyle(fontSize: 100, color: bonusList.contains(bonus[index]) ? interfaceColor : Colors.black))
                                          )
                                        ]
                                    )
                                )
                            )
                        );
                      }
                  )
              ),
              //bonuses[index]["id"]
            ]
        )
    );
  }

  void useMyBonus(var value) async{
    var headers = {
      'api-key': Domain.apiKey,
      'Content-Type': 'text/plain',
    };
    var request = http.Request('PUT', Uri.parse('https://willonhair.shintheo.com/api/business.appointment/${selectedAppointment['id']}'));
    request.body = value;

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var data = await response.stream.bytesToString();
      if(json.decode(data)['responseCode'] == 200){
        addBonusType();
      }else{
        print("Error on update: ${json.decode(data)}");
      }

    }
    else {
      var data = await response.stream.bytesToString();
      print(response.reasonPhrase);
      print("Error on update: ${json.decode(data)}");
    }

  }

  void addBonusType() async{

    var headers = {
      'accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('POST', Uri.parse( '${Domain.serverPort}/create/associated.product.line.bonus?values=%7B%0A%20%20%22'
        'product_id%22%3A%20$bonusId%2C%0A%20%20%22'
        'product_uom_qty%22%3A%201%2C%0A%20%20%22'
        'appointment_id%22%3A%20${selectedAppointment['id']}%0A%7D'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      adaptSales("bonus");
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void getRemise() async{
    var box = GetStorage();

    if(box.read('remise') != null){
      remise.value = box.read('remise');
      showDialog(
          context: Get.context,
          builder: (BuildContext context) =>
              AlertDialog(
                  contentPadding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  backgroundColor: background,
                  content: buildRemiseBox(context),
                actions: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            remiseList.clear();
                            Navigator.pop(Get.context);
                          },
                          child: Container(
                              width: 150,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(width: 2, color: inactive)
                              ),
                              child: Center(
                                child: Text("Annuler", style: TextStyle(color: inactive, letterSpacing: 2, fontSize: 15)),)
                          ),
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          onTap: ()async{

                            showDialog(
                                context: context,
                                builder: (_){
                                  return SpinKitFadingCircle(color: Colors.white, size: 50);
                                });
                            var data = json.encode({
                              "discount_type": "value",
                              "product_discount_id": remiseList[0]['id']
                            });
                            updateAppointment(data, "");

                          },
                          child: Obx(() =>
                              Container(
                                  width: 150,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: remiseList.isNotEmpty ? interfaceColor : null,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      border: remiseList.isEmpty ? Border.all(width: 2, color: inactive) : null
                                  ),
                                  child: Center(
                                    child: Text("Continuer", style: TextStyle(color: remiseList.isEmpty ? inactive : Colors.white, letterSpacing: 2, fontSize: 15)),)
                              )
                          ),
                        ),
                      ]
                  )
                ],
              )
      );

    }else{
      showDialog(
          context: Get.context,
          builder: (_){
            return SpinKitFadingCircle(color: Colors.white, size: 50);
          });

      var headers = {
        'Accept': 'application/json',
        'Authorization': Domain.authorization
      };
      var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/product.product?ids=1,38,39,40,5,6,41,42,43,10,11,44,13,14,45,46,47,48,49,50'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        Navigator.pop(Get.context);
        var data = json.decode(result);
        box.write("remise", data);

        remise.value = data;

        showDialog(
            context: Get.context,
            builder: (BuildContext context) =>
                AlertDialog(
                    contentPadding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    backgroundColor: background,
                    content: buildRemiseBox(context),
                  actions: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){
                              remiseList.clear();
                              Navigator.pop(Get.context);
                            },
                            child: Container(
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    border: Border.all(width: 2, color: inactive)
                                ),
                                child: Center(
                                  child: Text("Annuler", style: TextStyle(color: inactive, letterSpacing: 2, fontSize: 15)),)
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: ()async{

                              showDialog(
                                  context: context,
                                  builder: (_){
                                    return SpinKitFadingCircle(color: Colors.white, size: 50);
                                  });
                              var data = json.encode({
                                "discount_type": "value",
                                "product_discount_id": remiseList[0]['id']
                              });
                              updateAppointment(data, "");

                            },
                            child: Obx(() =>
                                Container(
                                    width: 150,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: remiseList.isNotEmpty ? interfaceColor : null,
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                        border: remiseList.isEmpty ? Border.all(width: 2, color: inactive) : null
                                    ),
                                    child: Center(
                                      child: Text("Continuer", style: TextStyle(color: remiseList.isEmpty ? inactive : Colors.white, letterSpacing: 2, fontSize: 15)),)
                                )
                            ),
                          ),
                        ]
                    )
                  ],
                )
        );

      }
      else {
        print('Error remise ${response.reasonPhrase}');
      }
    }
  }

  Widget buildRemiseBox(BuildContext context){
    return Container(
        height: Get.height/2.7,
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Choix de la remise", style: Get.textTheme.headline2),
              SizedBox(height: 30),
              Expanded(
                  child: GridView.builder(
                      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, mainAxisExtent: 120.0, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
                      shrinkWrap: true,
                      itemCount: remise.length,
                      itemBuilder: (context, index) {

                        return InkWell(
                            onTap: (){
                              remiseList.clear();
                              remiseList.add(remise[index]);
                              print("${remiseList[0]['id']}, ${remise[index]['id']} and ${remise[index]['list_price']}");
                            },
                            child: Obx(() =>
                                Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    padding: EdgeInsets.all(10),
                                    height: 60,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                        border: remiseList.contains(remise[index]) ? Border.all(width: 2, color: interfaceColor) : null
                                    ),
                                    child: Center(
                                        child: Text(remise[index]['list_price'].toInt().toString()+ " €", style: Get.textTheme.headline4.
                                        merge(TextStyle(fontSize: 30, color: remiseList.contains(remise[index]) ? interfaceColor : Colors.black))
                                        )
                                    )
                                )
                            )
                        );
                      }
                  )
              ),
              //bonuses[index]["id"]
            ]
        )
    );
  }

  updateUser(var point)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('PUT', Uri.parse('${Domain.serverPort}/write/res.partner?ids=${selectedAppointment['partner_id'][0]}&values={'
        '"client_bonus": $point'
        '}'
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      getAppointmentOrder(selectedAppointment['order_id'][0]);
      Navigator.pop(Get.context);
      Navigator.pop(Get.context);
      print(data);
    }
    else {
      print(response.reasonPhrase);
      var data = await response.stream.bytesToString();
      print(data);
    }
  }

  removeLine(int id, String type)async{

    showDialog(
        context: Get.context,
        barrierDismissible: false,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });

    print(selectedAppointment['extra_product_ids']);
    List data = [];
    List list = [];
    List ids = [];
    list.addAll(selectedAppointment['extra_product_ids']);
    list.forEach( (e) {
      if(e == id)
        data.add(e);
    });

    list.removeWhere( (e) => data.contains(e));
    list.forEach((element) {
      ids.add(element);
    });
    print('length is : ${extraProducts.length}');
    if(type != "Réduction") {
      if(type == "Bonus"){
        var values = json.encode({
          "product_line_bonus_ids": ids,
          "discount_type": "none"
        });
        updateAppointment(values, "remove");
      }else{
        if (extraProducts.length > 1) {
          var values = json.encode({
            "extra_product_ids": ids
          });
          updateAppointment(values, "");
        } else {
          var values = json.encode({
            "extra_product_ids": null
          });
          updateAppointment(values, "");
        }
      }
    }else{
      var values = json.encode({
        "discount_type": "none"
      });
      updateAppointment(values, "");
    }
    print("new list: $ids");
  }

  Future getInvoiceLine(List ids)async {

    showDialog(
        context: Get.context,
        barrierDismissible: false,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/account.move.line?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      invoiceArticles.value = json.decode(data);
      Navigator.pop(Get.context);
      return json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }
  }

}
