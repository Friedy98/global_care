import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/my_user_model.dart';
import '../../../models/option_model.dart';
import 'package:http/http.dart' as http;

import '../../userBookings/controllers/bookings_controller.dart';

class TravelInspectController extends GetxController {

  TextEditingController city = TextEditingController();
  var isClicked = false.obs;
  var luggageTypes = ["envelope", "briefcase", "suitcase"].obs;
  final user = new MyUser().obs;
  var showButton = false.obs;
  var categoryId = 0.obs;
  var serviceId = 0.obs;
  var employeeId = 0.obs;
  var categorySelected = [].obs;
  var serviceSelected = [].obs;
  var employeeSelected = [].obs;
  var categoryDto = {}.obs;
  var serviceDto = {}.obs;
  var employeeDto = {}.obs;
  var formStep = 0.obs;
  var loadCategories = true.obs;
  var loadServices = true.obs;
  var loadEmployees = true.obs;
  var buttonPressed = false.obs;
  var daySelected = 0.obs;
  TextEditingController birthPlaceTown = TextEditingController();
  TextEditingController residentialTown = TextEditingController();
  //final Rx<MyUser> currentUser = Get.find<MyAuthService>().myUser;

  var genderList = [
    "MALE",
    "FEMALE"
  ].obs;
  var categories = [].obs;
  var services = [].obs;
  var employees = [].obs;
  var workingDays = [].obs;
  var workingDaysDto = [].obs;
  var holidays = [].obs;
  var rangeHours = [].obs;
  var appointTime = [].obs;
  var appointments = [].obs;
  var availability = [].obs;
  var selectedTime = [].obs;
  var timeDto = "".obs;
  var appointmentDate = "".obs;
  var appointmentEnd = "".obs;
  var serviceDuration = 0.obs;
  var currentUser = {}.obs;
  var editAppointment = false.obs;
  var appointmentDto = {}.obs;

  @override
  void onInit() async {

    final box = GetStorage();
    var userDto = box.read("userData");
    var data = await getCategories();
    currentUser.value = userDto;
    categories.value = data;
    super.onInit();
  }

  refreshPage()async{
    onInit();
  }

  @override
  void onReady() async {
    //await refreshEService();
    super.onReady();
  }

  Future refreshEService() async {
    onInit();
  }

  updateAppointment(var selectedAppointment, var data)async{
    getCategoryBarber(data);
    editAppointment.value = true;
    appointmentDto.value = selectedAppointment;


  }

  Future getCategories()async{
    loadCategories.value = true;
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/search_read/business.resource.type'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      loadCategories.value = false;
        return json.decode(data);
    }
    else {
      return [];
      print(response.reasonPhrase);
    }
  }

  String getTimeStringFromDouble(double value) {

    /*int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);
    print('$hourValue:$minuteString');
    return '$hourValue:$minuteString';*/

    int hour = value.toInt() ~/ 3600;
    int minutes = ((value.toInt() - hour * 3600)) ~/ 60;
    return "${hour.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, '0')}";

  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  getTimeIntervals(List list)async{

    double h1 = 0;
    double h2 = 0;
    double dur = 0.0;
    double duration = 0.0;
    if(editAppointment.value){
      dur = appointmentDto['duration']*60*60;
      duration = appointmentDto['duration']*60;
    }else{
      dur = serviceDto['appointment_duration']*60*60;
      duration = serviceDto['appointment_duration']*60;
    }
    serviceDuration.value = duration.toInt();
    var hours = [];

    for(var x in list){
      h1 = (double.parse(x.split("-").first) * 60 * 60);
      h2 = (double.parse(x.split("-").last) * 60 * 60);
      for (var i = h1; i < h2; i += dur) {
        print(i);
        hours.add(i);
      }
    }
    appointTime.value = hours;
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
      appointments.value = json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  TextStyle getTitleTheme(Option option) {
    if (option.checked.value) {
      return Get.textTheme.bodyText2.merge(TextStyle(color: Get.theme.colorScheme.secondary));
    }
    return Get.textTheme.bodyText2;
  }

  TextStyle getSubTitleTheme(Option option) {
    if (option.checked.value) {
      return Get.textTheme.caption.merge(TextStyle(color: Get.theme.colorScheme.secondary));
    }
    return Get.textTheme.caption;
  }

  Color getColor(Option option) {
    if (option.checked.value) {
      return Get.theme.colorScheme.secondary.withOpacity(0.1);
    }
    return null;
  }

  getCategoryHairStyle(var values)async{
    loadServices.value = true;
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
      services.value = json.decode(data);
      loadServices.value = false;
      print(services);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getUser(int id)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/res.partner?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void getCategoryBarber(var ids) async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/business.resource?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var list = json.decode(data);
      loadEmployees.value = false;
      employees.value = list;
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getCalendar(var id)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Cookie': 'session_id=24beda0f1d665f23cdaf28741023ccdefca871bf'
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/resource.calendar?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var working = json.decode(data)[0]['attendance_ids'];
      var rest = json.decode(data)[0]['leave_ids'];
      getWorkingDays(working);
      getRestDays(rest);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getWorkingDays(var ids)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/resource.calendar.attendance?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var days = [];
      var data = await response.stream.bytesToString();
      var list = json.decode(data);
      workingDaysDto.value = list;
      for(var a in list){
        int index = int.parse(a['dayofweek'])+1;
        days.add(index);
      }
      workingDays.value = days;
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getRestDays(var ids)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Cookie': 'session_id=24beda0f1d665f23cdaf28741023ccdefca871bf'
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/resource.calendar.leaves?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var days = [];
      var data = await response.stream.bytesToString();
      var list = json.decode(data);
      for(var a in list){
        var dayFrom = DateFormat("d/MM/yyyy").format(DateTime.parse(a['date_from'])).toString();
        var dayTo = DateFormat("d/MM/yyyy").format(DateTime.parse(a['date_to'])).toString();
        days.add("$dayFrom-$dayTo");
      }
      holidays.value = days;
      print(holidays);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  requestAppointment()async{
    var date = DateFormat("yyyy-MM-dd").format(DateTime.parse(appointmentDate.value)).toString();

    Get.lazyPut(() => BookingsController());

    var dateTimeStart = DateTime.parse("$date ${selectedTime.join(",")}:00").toString().split(".").first;
    var dateTimeEnd = DateTime.parse("$date ${selectedTime.join(",")}:00").add(Duration(minutes: serviceDuration.value)).toString().split(".").first;
    print("$dateTimeStart and $dateTimeEnd and current user id : ${currentUser['partner_id']}");
    print("${categoryId.value}, ${serviceId.value}, ${employeeId.value}");

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request =  editAppointment.value ? http.Request('POST',Uri.parse('${Domain.serverPort}/create/business.appointment?values={ '
        '"resource_type_id": ${appointmentDto['resource_type_id'][0]},'
        '"partner_id": ${appointmentDto['partner_id'][0]},'
        //'"description": "",'
        '"service_id": ${appointmentDto['service_id'][0]},'
        '"resource_id": ${employeeId.value},'
        '"datetime_start": "$dateTimeStart",'
        '"datetime_end": "$dateTimeEnd"'
        '}'
    )) :
    http.Request('POST',Uri.parse('${Domain.serverPort}/create/business.appointment?values={ '
        '"resource_type_id": ${categoryId.value},'
        '"partner_id": ${currentUser['partner_id']},'
    //'"description": "",'
        '"service_id": ${serviceId.value},'
        '"resource_id": ${employeeId.value},'
        '"datetime_start": "$dateTimeStart",'
        '"datetime_end": "$dateTimeEnd"'
        '}'
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200)  {
      var result = await response.stream.bytesToString();
      print(result);
      buttonPressed.value = false;
      Get.find<BookingsController>().refreshBookings();
      if(editAppointment.value){

        cancelBooking(appointmentDto['id']);

      }else{
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Votre demande de rendez-vous à été envoyé avec succès"));
        Navigator.pop(Get.context);
      }

    }
    else {
      var data = await response.stream.bytesToString();
      buttonPressed.value = false;
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message']));
    }
  }

  cancelBooking(int id) async{

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
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Votre rendez-vous à été transféré avec succès"));
    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message'] ));
      print(response.reasonPhrase);
    }
  }

  void checkAvailability(String day) async{
    List values = [];
    for(var a in appointments){
      if(DateFormat("dd/MM/yyyy").format(DateTime.parse(a['datetime_start'])).toString() == day){
        values.add(DateFormat("HH:mm").format(DateTime.parse(a['datetime_start'])));
        values.add(DateFormat("HH:mm").format(DateTime.parse(a['datetime_end'])));
      }
    }
    print("appointments: $appointments");
    availability.value = values;
    print(values);
  }
}
