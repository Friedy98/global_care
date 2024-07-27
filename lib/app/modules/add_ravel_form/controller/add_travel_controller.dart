import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/media_model.dart';
import '../../../models/my_user_model.dart';
import '../../../repositories/user_repository.dart';
import '../../../services/my_auth_service.dart';
import '../../root/controllers/root_controller.dart';
import 'package:http/http.dart' as http;

import '../../userTravels/controllers/user_travels_controller.dart';

class AddTravelController extends GetxController{

  var avatar = new Media().obs;
  final isDone = false.obs;
  var departureDate = DateTime.now().add(Duration(days: 2)).toString().toString().split(".").first.obs;
  var arrivalDate = DateTime.now().add(Duration(days: 3)).toString().toString().split(".").first.toString().obs;
  var departureId = 0.obs;
  var arrivalId = 0.obs;
  var restriction = ''.obs;
  var quantity = 0.0.obs;
  var price = 0.0.obs;
  var canBargain = false.obs;
  var predict1 = false.obs;
  var predict2 = false.obs;
  var townEdit = false.obs;
  var town2Edit = false.obs;
  var travelType = "road".obs;
  var errorCity1 = false.obs;
  File passport;
  var countries = [].obs;
  var list = [];
  var loadPassport = false.obs;
  var loadTicket = false.obs;
  File ticket;
  final travelCard = {}.obs;
  var travelTypeSelected = false.obs;
  var buttonPressed = false.obs;
  var ticketUpload = false.obs;
  GlobalKey<FormState> newTravelKey;
  ScrollController scrollController = ScrollController();
  final formStep = 0.obs;
  TextEditingController depTown = TextEditingController();
  TextEditingController arrTown = TextEditingController();
  final user = new MyUser().obs;
  var url = ''.obs;
  TextEditingController birthPlaceTown = TextEditingController();
  TextEditingController residentialTown = TextEditingController();
  //final Rx<MyUser> currentUser = Get.find<MyAuthService>().myUser;
  final updatePassword = false.obs;
  final deleteUser = false.obs;
  final hidePassword = true.obs;
  final oldPassword = "".obs;
  final newPassword = "".obs;
  final userName = "".obs;
  final email = "".obs;
  final gender = "".obs;
  var editNumber = false.obs;
  final confirmPassword = "".obs;
  final smsSent = "".obs;
  //final buttonPressed = false.obs;
  var birthDate = ''.obs;
  final birthPlace = "".obs;
  final residence = "".obs;
  final phone = "".obs;
  var selectedGender = "".obs;
  final editPlaceOfBirth = false.obs;
  final editResidentialAddress= false.obs;
  var birthDateSet = false.obs;
  var isConform = false.obs;

  var loadAttachments = true.obs;
  final identityPieceSelected = ''.obs;
  final userRatings = 0.0.obs;

  File identificationFile;

  var edit = false.obs;
  //File identificationFilePhoto;

  var genderList = [
    "MALE".tr,
    "FEMALE".tr
  ].obs;
  GlobalKey<FormState> profileForm;
  UserRepository _userRepository;

  var dateOfDelivery = DateTime.now().add(Duration(days: 2)).toString().obs;
  var dateOfExpiration = DateTime.now().add(Duration(days: 3)).toString().obs;


  final _picker = ImagePicker();
  File image;
  //UploadRepository _uploadRepository;
  var currentState = 0.obs;
  var loadImage = false.obs;
  var currentUser = Get.find<MyAuthService>().myUser;

  var birthCityId = 0.obs;
  var residentialAddressId = 0.obs;
  var listAttachment = [];
  var attachmentFiles = [].obs;
  var view = false.obs;
  var editing = false.obs;

  var predict1Profile = false.obs;
  var predict2Profile = false.obs;
  var errorCity1Profile = false.obs;
  //File passport;
  //var countries = [].obs;
 // var list = [];

  @override
  void onInit() async {
    user.value = Get.find<MyAuthService>().myUser.value;
    birthDate.value = user.value.birthday;
    birthPlace.value = user.value.birthplace;
    residence.value =user.value.street;
    final box = GetStorage();
    list = box.read("allCountries");
    countries.value = list;
    print("first country is ${countries[0]}");
    var arguments = Get.arguments as Map<String, dynamic>;

    if(arguments != null){
      travelCard.value = arguments['travelCard'];

      print("travel is $travelCard");
      if (travelCard != null) {
        travelType.value = travelCard['booking_type'];
        departureId.value = travelCard['departure_city_id'][0];
        arrivalId.value = travelCard['arrival_city_id'][0];
        departureDate.value = travelCard['departure_date'];
        arrivalDate.value = travelCard['arrival_date'];
        depTown.text = travelCard['departure_city_id'][1];
        arrTown.text = travelCard['arrival_city_id'][1];
        quantity.value = travelCard['total_weight'];
        price.value = travelCard['booking_price'];
        //restriction.value = travelCard['total_weight'];
      }
    }

    super.onInit();
  }

  void filterSearchResults(String query) {
    List dummySearchList = [];
    dummySearchList = list;
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['display_name']
          .toString().toLowerCase().contains(query.toLowerCase()) ).toList();
      countries.value = dummyListData;
      for(var i in countries){
        print(i['display_name']);
      }
      return;
    } else {
      countries.value = list;
    }
  }

  //final _picker = ImagePicker();

  passportPicker(String source) async {
    if(source=='camera'){
      final XFile pickedImage =
      await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        passport = File(pickedImage.path);
        loadPassport.value = !loadPassport.value;
      }
    }
    else{
      final XFile pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        passport = File(pickedImage.path);
        loadPassport.value = !loadPassport.value;
      }

    }

  }

  ticketPicker(String source) async {
    if(source=='camera'){
      final XFile pickedImage =
      await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        ticket = File(pickedImage.path);
        loadTicket.value = !loadTicket.value;
      }
    }
    else{
      final XFile pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        ticket = File(pickedImage.path);
        loadTicket.value = !loadTicket.value;
      }

    }

  }

  backToHome()async{
    await Get.find<RootController>().changePage(0);
  }

  chooseDepartureDate() async {
    DateTime pickedDate = await showRoundedDatePicker(
      context: Get.context,
      imageHeader: AssetImage("assets/img/istockphoto-1421193265-612x612.jpg"),
      initialDate: DateTime.now().add(Duration(days: 2)),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 10),
      styleDatePicker: MaterialRoundedDatePickerStyle(
        textStyleYearButton: TextStyle(
          fontSize: 52,
          color: Colors.white,
        )
      ),
      borderRadius: 16,
      selectableDayPredicate: disableDepartureDate
    );
    String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
    if (formattedDate.isNotEmpty) {
      departureDate.value = pickedDate.toString();
      TimeOfDay selectedTime = await showTimePicker(
        context: Get.context,
        initialTime: TimeOfDay.now(),
      );
      departureDate.value = "$formattedDate ${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}:00";

    }
    print(departureDate.value);
  }

  chooseArrivalDate() async {
    DateTime pickedDate = await showRoundedDatePicker(
      context: Get.context,
      imageHeader: AssetImage("assets/img/pexels-julius-silver-753331.jpg"),
      initialDate: DateTime.parse(departureDate.value),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 10),
        styleDatePicker: MaterialRoundedDatePickerStyle(
            textStyleYearButton: TextStyle(
              fontSize: 52,
              color: Colors.white,
            )
        ),
      borderRadius: 16,
      selectableDayPredicate: disableArrivalDate
    );
    String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
    if (formattedDate.isNotEmpty) {
      arrivalDate.value = pickedDate.toString();
      TimeOfDay selectedTime = await showTimePicker(
        context: Get.context,
        initialTime: TimeOfDay.now(),
      );
      arrivalDate.value = "$formattedDate ${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}:00";
      print(arrivalDate.value);
    }
  }

  bool disableDepartureDate(DateTime day) {
    if ((day.isAfter(DateTime.now().add(Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  bool disableArrivalDate(DateTime day) {
    if ((day.isAfter(DateTime.parse(departureDate.value).subtract(Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  createRoadTravel()async{

    final box = GetStorage();
    var session_id = box.read('session_id');

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Cookie': 'session_id=7c27b4e93f894c9b8b48cad4e00bb4892b5afd83'
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/create/m1st_hk_roadshipping.travelbooking?values='
        '{"name": "New_Travel/${DateFormat("yyyy/MM/dd").format(DateTime.now())}",'
        '"booking_type": "${travelType.value}",'
        '"departure_city_id": "${departureId.value}",'
        '"arrival_city_id": "${arrivalId.value}",'
        '"arrival_date": "${arrivalDate.value}",'
        '"departure_date": "${departureDate.value}",'
        '"partner_id": ${Get.find<MyAuthService>().myUser.value.id}'
        '}'
    ));

  request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      print("travel response: $data");
      Future.delayed(Duration(seconds: 3),()async{
        Navigator.pop(Get.context);
        Navigator.pop(Get.context);
        Get.find<UserTravelsController>().refreshMyTravels();
      });
      buttonPressed.value = false;
      showDialog(
          context: Get.context, builder: (_){
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Lottie.asset("assets/img/successfully-done.json"),
        );
      });
    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occurred! Please make sure your travel is still in published state or verify your information and try again".tr));
      buttonPressed.value = false;
      print("Error response: ${json.decode(data)['message']}");
    }
  }

  updateRoadTravel()async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Cookie': 'session_id=7884fbe019046ffc1379f17c73f57a9e344a6d8a'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.serverPort}/write/m1st_hk_roadshipping.travelbooking?values={'
        '"name": "Update_Travel/${DateFormat("yyyy/MM/dd").format(DateTime.now())}",'
        '"booking_type": "${travelType.value}",'
        '"departure_city_id": "${departureId.value}",'
        '"arrival_city_id": "${arrivalId.value}",'
        '"arrival_date": "${arrivalDate.value}",'
        '"departure_date": "${departureDate.value}"'
        '}&ids=${travelCard['id']}'
    ));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var data = await response.stream.bytesToString();
      print("travel response: $data");
      buttonPressed.value = false;
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Your travel has been updated successfully ".tr));
      Navigator.pop(Get.context);

    }
    else {
      var data = await response.stream.bytesToString();
      print(data);
      buttonPressed.value = false;
      Get.showSnackbar(Ui.ErrorSnackBar(message: "${json.decode(data)['message']}".tr));
      throw new Exception(response.reasonPhrase);
    }
  }

  chooseBirthDate() async {
    DateTime pickedDate = await showRoundedDatePicker(

      context: Get.context,

      imageHeader: AssetImage("assets/img/istockphoto-1421193265-612x612.jpg"),
      height: MediaQuery.of(Get.context).size.height*0.5,
      initialDate: DateTime.now().subtract(Duration(days: 1)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      styleDatePicker: MaterialRoundedDatePickerStyle(
          textStyleYearButton: TextStyle(
            fontSize: 52,
            color: Colors.white,
          )
      ),
      borderRadius: 16,
      //selectableDayPredicate: disableDate
    );
    if (pickedDate != null && pickedDate != birthDate.value) {
      birthDate.value = DateFormat('dd/MM/yy').format(pickedDate);
      user.value.birthday = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void updateProfile() async {
    _userRepository = new UserRepository();
    user.value.street = residentialAddressId.value.toString();
    user.value.birthplace = birthCityId.value.toString();
    await updatePartner(user.value);
  }

  updatePartner(MyUser myUser) async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('PUT', Uri.parse('${Domain.serverPort}/write/res.partner?ids=${myUser.id}&values={'
        '"birth_city_id": "${myUser.birthplace}",'
        '"residence_city_id": "${myUser.street}",'
        '"gender": "${myUser.sex}",'
        '"birthdate":"${myUser.birthday}"}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      user.value = await _userRepository.get(user.value.id);
      Get.find<MyAuthService>().myUser.value = user.value;
    }
    else {
      buttonPressed.value = false;
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message']));
    }
  }

  @override
  void onClose() {
    //chatTextController.dispose();
  }
}
