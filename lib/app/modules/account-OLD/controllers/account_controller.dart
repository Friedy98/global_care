import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../services/my_auth_service.dart';

class AccountController extends GetxController {

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
  final buttonPressed = false.obs;
  var birthDate = ''.obs;
  final birthPlace = "".obs;
  final phone = "".obs;
  var selectedGender = "".obs;
  final editPlaceOfBirth = false.obs;
  final editResidentialAddress= false.obs;
  var pictureUpdated = false.obs;

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

  var dateOfDelivery = DateTime.now().add(Duration(days: 2)).toString().obs;
  var dateOfExpiration = DateTime.now().add(Duration(days: 3)).toString().obs;


  final _picker = ImagePicker();
  File image;
  var currentState = 0.obs;
  var currentUser = {}.obs;

  var birthCityId = 0.obs;
  var residentialAddressId = 0.obs;
  var listAttachment = [];
  var attachmentFiles = [].obs;
  var view = false.obs;
  var editing = false.obs;

  var predict1 = false.obs;
  var predict2 = false.obs;
  var errorCity1 = false.obs;
  //File passport;
  var enableNotification = true.obs;

  ScrollController scrollController = ScrollController();
  final formStep = 0.obs;
  TextEditingController depTown = TextEditingController();
  TextEditingController arrTown = TextEditingController();

  var selectedPiece = "Select identity piece".obs;

  var deviceTokens = [].obs;
  var tokens = [].obs;

  @override
  void onInit() async{
    pictureUpdated.value = false;
    var box = GetStorage();
    var userData = box.read("userData");
    var data = await getUserInfo(userData['partner_id']);
    currentUser.value = data;
    email.value = data['email'];
    userName.value = data['display_name'];
    selectedGender.value = genderList.elementAt(0);
    print("${email.value} and ${userName.value}");

    super.onInit();

  }

  onRefresh() async{

    var box = GetStorage();
    var userData = box.read("userData");
    var data = await getUserInfo(userData['partner_id']);
    currentUser.value = data;
    email.value = data['email'];
    userName.value = data['display_name'];
    print("${email.value} and ${userName.value}");
  }

  verifyOldPassword(String email, String password) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=dc69145b99f377c902d29e0b11e6ea9bb1a6a1ba'
    };
    var request = http.Request('POST', Uri.parse('https://preprod.hubkilo.com/web/session/authenticate'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "params": {
        "db": "preprod.hubkilo.com",
        "login": email,
        "password": password
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var data = json.decode(result)['result'];
      //print(data);
      if(data != null){
        return true;
      }
      else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "Wrong password, try again"));
        return false;
        //throw new Exception(response.reasonPhrase);
      }
    }
    else {Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occurred, please try again"));
      return false;
    }

  }

  updateUserPassword(String newPassword) async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Cookie': 'session_id=d2c885aa27073b1ccdcf777cdab4d1d3ef5bef08'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.serverPort}/write/res.users?ids=33&values='
        '{"password": "$newPassword"}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "Password Updated Successfully"));
    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message']));
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
    }
  }

  updateProfile()async{

    showDialog(
        context: Get.context,
        builder: (_){
          return SpinKitFadingCircle(color: Colors.white, size: 50);
        });

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('PUT', Uri.parse('${Domain.serverPort}/write/res.users?ids=${currentUser['user_ids'][0]}&values={'
        '"name": "${userName.value}",'
        '"email": "${email.value}",'
        '"login": "${email.value}",'
        '}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      onRefresh();
      Navigator.pop(Get.context);
      edit.value = false;
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Profile modifié avec succès"));
    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data)['message']));
      print(response.reasonPhrase);
    }
  }

  bool disableDate(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  profileImagePicker(String source) async {
    if(source=='camera'){
      final XFile pickedImage =
      await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        image = File(pickedImage.path);
        updateProfilePicture(image);
      }
    }
    else{
      final XFile pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        image = File(pickedImage.path);
        updateProfilePicture(image);
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Picture saved successfully".tr));
      }
    }
  }

  selectCameraOrGallery()async{
    showDialog(
        context: Get.context,
        builder: (_){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
                height: 170,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      onTap: ()async{
                        await profileImagePicker('camera');
                        Navigator.pop(Get.context);

                      },
                      leading: Icon(FontAwesomeIcons.camera),
                      title: Text('Take a picture', style: Get.textTheme.headline1.merge(TextStyle(fontSize: 15))),
                    ),
                    ListTile(
                      onTap: ()async{
                        await profileImagePicker('gallery');
                        Navigator.pop(Get.context);
                      },
                      leading: Icon(FontAwesomeIcons.image),
                      title: Text('Upload an image', style: Get.textTheme.headline1.merge(TextStyle(fontSize: 15))),
                    )
                  ],
                )
            ),
          );
        });
  }

  getUserInfo(int id) async{
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
      return data;
    } else {
      print(response.reasonPhrase);
    }
  }

  updateProfilePicture(File file)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
      'Content-Type': 'multipart/form-data'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${Domain.serverPort}/upload/res.partner/${currentUser['id']}/image_1920'));
    request.files.add(await http.MultipartFile.fromPath('ufile', file.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();


    if (response.statusCode == 200) {
      showDialog(
          context: Get.context,
          builder: (_){
            return SpinKitFadingCircle(color: Colors.white, size: 50);
          });
      onRefresh();
      pictureUpdated.value = true;
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Picture saved successfully".tr));
      Navigator.pop(Get.context);
    }
    else {
      var result = await response.stream.bytesToString();
      var data = json.decode(result);
      Get.showSnackbar(Ui.ErrorSnackBar(message: data['message']));
      print(response.reasonPhrase);
    }
  }

  getDeviceTokens()async{

    var tokenIds = deviceTokens;
    print(tokenIds);

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/fcm.device.token?ids=$tokenIds'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var data = json.decode(result);
      List ids = [];
      for(var i in data){
        if(i['token'] == Domain.deviceToken){
          ids.add(i['id']);
        }
      }
      removeDeviceToken(ids);
    }
    else {
      var data = await response.stream.bytesToString();
      print(data);
    }
  }

  removeDeviceToken(var ids)async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('DELETE', Uri.parse('${Domain.serverPort}/unlink/fcm.device.token?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      print(data);
      enableNotification.value = false;
    }
    else {
      var data = await response.stream.bytesToString();
      print(data);
    }
  }

  enableNotify()async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/create/fcm.device.token?values={'
        '"token": "${Domain.deviceToken}",'
        '"partner_id": ${Get.find<MyAuthService>().myUser.value.id}}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      enableNotification.value = true;
    }
    else {
      print(response.reasonPhrase);
    }
  }
}

