import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/odoo_provider.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../../services/auth_service.dart';
import 'package:http/http.dart' as http;

import '../../../services/my_auth_service.dart';
import '../../global_widgets/pop_up_widget.dart';

class MessagesController extends GetxController {

  var message = Message([]).obs;
  ChatRepository _chatRepository;
  NotificationRepository _notificationRepository;
  AuthService _authService;
  var messagesList = <Message>[].obs;
  var chats = <Chat>[].obs;
  File imageFile;
  Rx<DocumentSnapshot> lastDocument = new Rx<DocumentSnapshot>(null);
  final isLoading = true.obs;
  final isDone = false.obs;
  final enableSend = false.obs;
  final validateMessage = {}.obs;
  var list = [];
  var messages = [].obs;
  var messagesSent = [].obs;
  final card = {}.obs;
  final travel = {}.obs;
  final departureTown = "".obs;
  final departureCountry = "".obs;
  final arrivalTown = "".obs;
  final arrivalCountry = "".obs;
  final receiver_id = 0.obs;
  final receiver_Name = "".obs;
  var messageId = 0.obs;
  ScrollController scrollController = ScrollController();
  TextEditingController chatTextController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  var chatText = 0.0.obs;
  Timer timer;
  /*MessagesController() {
    _chatRepository = new ChatRepository();
    _notificationRepository = new NotificationRepository();
    _authService = Get.find<AuthService>();
  }*/

  @override
  void onInit() async {

    timer = Timer.periodic(Duration(seconds: 3),
            (Timer timer) => refreshMessages());

    Get.lazyPut<MyAuthService>(
          () => MyAuthService(),
    );
    Get.lazyPut<OdooApiClient>(
          () => OdooApiClient(),
    );
    var arguments = Get.arguments as Map<String, dynamic>;
    card.value = arguments['shippingCard'];
    var data = await getTravelInfo(card['travelbooking_id'][0]);
    travel.value = data;
    print("travel: $travel");
    if(Get.find<MyAuthService>().myUser.value.id != card['partner_id'][0]){
      receiver_id.value = card['partner_id'][0];
      receiver_Name.value = card['partner_id'][1];
    }else{
      receiver_id.value = travel['partner_id'][0];
      receiver_Name.value = travel['partner_id'][1];
    }
    String departureCity = card['travel_departure_city_name'].split('(').first;
    String a = card['travel_departure_city_name'].split('(').last;
    String country1 = a.split(')').first;
    departureTown.value = departureCity;
    departureCountry.value = country1;
    String arrivalCity = card['travel_arrival_city_name'].split('(').first;
    String b = card['travel_arrival_city_name'].split('(').last;
    String country2 = b.split(')').first;
    arrivalTown.value = arrivalCity;
    arrivalCountry.value = country2;

    var result = await getShipping(card['id']);
    for(var i = 0; i<result.length; i++){
      if(!messages.contains(result[i])){
        messages.add(result[i]);
      }
    }

    print("messages are: $messages");
    super.onInit();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  checkValue(String value){
    if(value.isNotEmpty){
      enableSend.value = true;
    }else{
      enableSend.value = false;
    }
  }

  Future createMessage(Message _message) async {
    _message.users.insert(0, _authService.user.value);
    _message.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
    _message.readByUsers = [_authService.user.value.id];

    message.value = _message;

    _chatRepository.createMessage(_message).then((value) {
      listenForChats();
    });
  }

  Future deleteMessage(Message _message) async {
    messagesList.remove(_message);
    await _chatRepository.deleteMessage(_message);
  }

  void refreshMessages() async {
    var result = await getShipping(card['id']);
    if(result.length > messages.length){
      for(var i = 0; i<result.length; i++){
        int l = result.length - messages.length;
        if(i < l+1){
          messages.add(result[messages.length+i]);
          messagesSent.clear();
          print("reloaded");
        }
      }
    }else{
      print("no new message");
    }
    /*lastDocument = new Rx<DocumentSnapshot>(null);
    await listenForMessages();*/
  }

  sendMessage(int id)async{
    print(priceController.text);

    print("fields are: ${chatTextController.text}, $id, ${travel['partner_id'][0]}, ${card['id']}, ${double.parse(priceController.text)}");

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };

    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/create/m1st_hk_roadshipping.travelmessage?values={'
    '"name": "${chatTextController.text}",'
    '"sender_partner_id": $id,'
    '"receiver_partner_id": ${receiver_id.value},'
    '"shipping_id": ${card['id']},'
    '"price": ${double.parse(priceController.text)}'
    '}'
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();

      Fluttertoast.showToast(
        msg: "message sent",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: inactive,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print(data);
    }
    else {
      var data = await response.stream.bytesToString();
      print(json.decode(data)['message']);
    }
  }

  sendAutomaticMessage(int id)async{

    var chatMessage = "";

    if(id == travel['partner_id'][0]){
      chatMessage = "Price confirmed. In order to confirm your shipment, I invite you to pay the invoice attached";
    }else{
      chatMessage = "Price accepted. Please confirm the price by clicking on the button confirm price above";
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };

    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/create/m1st_hk_roadshipping.travelmessage?values={'
        '"name": "$chatMessage",'
        '"sender_partner_id": $id,'
        '"receiver_partner_id": ${receiver_id.value},'
        '"shipping_id": ${card['id']},'
        '"price": ${validateMessage['price']}'
        '}'
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();

      Fluttertoast.showToast(
        msg: "message sent",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: inactive,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print(data);
    }
    else {
      var data = await response.stream.bytesToString();
      print(json.decode(data)['message']);
    }
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
      print(data);
    }
  }

  Future getMessages(List ids)async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/m1st_hk_roadshipping.travelmessage?ids=$ids'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      isLoading.value = false;
      for(var i in json.decode(data)){
        if(i['shipper_validate']){
          validateMessage.value = i;
        }
      }
      return json.decode(data);
    }
    else {
      var data = await response.stream.bytesToString();
      print(data);
    }
  }

  shipperValidate(int id)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/call/m1st_hk_roadshipping.travelmessage/mark_shipper_validation/?ids=$id'
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      /*if(messages.length == 1){
        showDialog(
            context: Get.context,
            builder: (_)=>
                PopUpWidget(
                    cancel: "Back",
                    confirm: "Confirm",
                    onTap: () => confirmTransporting(),
                    icon: Icon(Icons.warning_amber_rounded),
                    title: "Are you sure you want to confirm this price? please make sure you and your contact mention where the exchange of the parcel will be made before validating!"
                )
        );
      }else{*/
      sendAutomaticMessage(Get.find<MyAuthService>().myUser.value.id);
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Shipping price set".tr));
      //}

    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data).tr));
    }
  }

  confirmTransporting()async{
    ScaffoldMessenger.of(Get.context).showSnackBar(SnackBar(
      content: Text("loading data..."),
      duration: Duration(seconds: 2),
    ));
    print(card['id']);

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };

    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/call/m1st_hk_roadshipping.travelmessage/set_to_validate/?ids=${messageId.value}'
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      sendAutomaticMessage(Get.find<MyAuthService>().myUser.value.id);
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Shipping price set".tr));

    }
    else {
      var data = await response.stream.bytesToString();
      Get.showSnackbar(Ui.ErrorSnackBar(message: json.decode(data).tr));
    }
  }

  Future listenForMessages() async {
    isLoading.value = true;
    isDone.value = false;
    Stream<QuerySnapshot> _userMessages;
    if (lastDocument.value == null) {
      _userMessages = _chatRepository.getUserMessages(_authService.user.value.id);
    } else {
      _userMessages = _chatRepository.getUserMessagesStartAt(_authService.user.value.id, lastDocument.value);
    }
    _userMessages.listen((QuerySnapshot query) {
      if (query.docs.isNotEmpty) {
        query.docs.forEach((element) {
          messagesList.add(Message.fromDocumentSnapshot(element));
        });
        lastDocument.value = query.docs.last;
      } else {
        isDone.value = true;
      }
      isLoading.value = false;
    });
  }

  listenForChats() async {
    message.value = await _chatRepository.getMessage(message.value);
    message.value.readByUsers.add(_authService.user.value.id);
    _chatRepository.getChats(message.value).listen((event) {
      chats.assignAll(event);
    });
  }

  /*addMessage(Message _message, String text) {
    Chat _chat = new Chat(text, DateTime.now().millisecondsSinceEpoch, _authService.user.value.id, _authService.user.value);
    if (_message.id == null) {
      _message.id = UniqueKey().toString();
      createMessage(_message);
    }
    _message.lastMessage = text;
    _message.lastMessageTime = _chat.time;
    _message.readByUsers = [_authService.user.value.id];
    //uploading.value = false;
    _chatRepository.addMessage(_message, _chat).then((value) {}).then((value) {
      List<User> _users = [];
      _users.addAll(_message.users);
      _users.removeWhere((element) => element.id == _authService.user.value.id);
      _notificationRepository.sendNotification(_users, _authService.user.value, "App\\Notifications\\NewMessage", text, _message.id);
    });
  }*/

  Future getImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile pickedFile;

    pickedFile = await imagePicker.pickImage(source: source);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      try {
        //uploading.value = true;
        return await _chatRepository.uploadFile(imageFile);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "Please select an image file".tr));
    }
  }

  getShipping(int id) async{

    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/m1st_hk_roadshipping.shipping?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      List list = json.decode(data)[0]['travelmessage_ids'];
      //print('shipping detail: ${json.decode(data)[0]}');
      var result = await getMessages(list);
      return result;
    }
    else {
      print(response.reasonPhrase);
    }
  }
}
