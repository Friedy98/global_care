import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../../responsive.dart';

class ValidationController extends GetxController {

  final isDone = false.obs;
  var isLoading = false.obs;
  final currentState = 0.obs;
  final validationType = 0.obs;
  var shipping = [].obs;
  var copyPressed = false.obs;
  var loading = false.obs;
  var client = {}.obs;
  var pointsToBonus = 0.obs;
  var found = false.obs;
  var noValue = false.obs;
  var scanned = false.obs;
  TextEditingController pointController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    initValues();
  }

  initValues()async{
    scan();
  }

  refreshPage()async{
    initValues();
  }

  Future scan() async {
    try {
      ScanResult qrCode = await BarcodeScanner.scan();
      String qrResult = qrCode.rawContent;
      //setState(() => barcode = qrResult);
      print(qrResult);
      var user = await getUserInfo(qrResult);
      client.value = user;
      if(Responsive.isMobile(Get.context)){
        showDialog(
            context: Get.context,
            builder: (_){
              return AlertDialog(
                title: Text(client['name'], style: TextStyle(fontSize: 16)),
                content: Text("Le client ${client['name']} a ${client['client_points']} points de fidelté et ${client['client_bonus']} poinnts de bonus",
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                actions: [
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: Center(
                            child: TextFormField(
                              controller: pointController,
                              textAlign: TextAlign.center,
                              showCursor: false,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: background
                              ),
                              style: const TextStyle(fontSize: 40),
                              keyboardType: TextInputType.number,
                            )
                        )
                      ),
                      SizedBox(width: 10),
                      TextButton(onPressed: () {
                        var points = client['client_points'] + int.parse(pointController.text);
                        attributePoints(int.parse(qrResult), points);

                      },
                          child: Text("SEND", style: TextStyle(fontSize: 20, color: blue)))
                    ],
                  )
                ],
              );
            });
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        Get.log('The user did not grant the camera permission!');
      } else {
        Get.log('Unknown error: $e');
      }
    } on FormatException{
      Get.log('null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      Get.log('Unknown error: $e');
    }
  }

  Future getUserInfo(var id)async{
    var headers = {
      'Accept': 'application/json',
      'Authorization': Domain.authorization,
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/read/res.partner?ids=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      found.value = true;
      return json.decode(data)[0];
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void attributePoints(int partner, var point) async{
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=fr_FR; session_id=6d065737e3cc1153d3a20eaf7fadf96f0f58b31e; visitor_uuid=fcef730c94854dfc991dcde26c242a3e'
    };
    var request = http.Request('POST', Uri.parse('https://willonhair.shintheo.com/fidelity/partner/$partner/points/$point'));
    request.body = json.encode({
      "jsonrpc": "2.0"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      isLoading.value = false;
      Get.showSnackbar(Ui.InfoSnackBar(message: "Nombre de point mise a jour avec succès"));
    }
    else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "Une érreur est survenue!"));
    }
  }

  @override
  void onClose() {
    //chatTextController.dispose();
  }
}
