import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../home/controllers/home_controller.dart';

class CategoryController extends GetxController {
  final page = 0.obs;
  final isLoading = true.obs;
  final isDone = false.obs;
  var travelList = [].obs;
  var list = [].obs;
  final imageUrl = "".obs;
  var travelType = "".obs;
  var totalPages = 0.obs;
  var currentPage = 1.obs;
  var loading = true.obs;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    var arguments = Get.arguments as Map<String, dynamic>;
    travelType.value = arguments['travelType'];
    print(travelList);
    if(arguments['travelType'] == "air"){
      imageUrl.value = "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Y2FyZ28lMjBwbGFuZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60";
    }else if(arguments['travelType'] == "Sea"){
      travelList[0].value = "https://media.istockphoto.com/id/591986620/fr/photo/porte-conteneurs-de-fret-générique-en-mer.jpg?b=1&s=170667a&w=0&k=20&c=gZmtr0Gv5JuonEeGmXDfss_yg0eQKNedwEzJHI-OCE8=";
    }else{
      imageUrl.value = "https://media.istockphoto.com/id/859916128/photo/truck-driving-on-the-asphalt-road-in-rural-landscape-at-sunset-with-dark-clouds.jpg?s=612x612&w=0&k=20&c=tGF2NgJP_Y_vVtp4RWvFbRUexfDeq5Qrkjc4YQlUdKc=";
    }
    travelList.value = await getAllRoadTravels(1);
    list.addAll(travelList);
    super.onInit();
  }

  void filterSearchResults(String query) {
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );

    List dummySearchList = [];
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['departure_city_id'][1]
          .toString().toLowerCase().contains(query.toLowerCase()) || element['arrival_city_id'][1]
          .toString().toLowerCase().contains(query.toLowerCase()) ).toList();
      travelList.value = dummyListData;
      return;
    } else {
      travelList.value = list;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
  }

  Future getAllRoadTravels(int i)async{
    print("number is : $i");
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://preprod.hubkilo.com/mobile/all/hub_raod/travels'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "params": {
        "page": i
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      isLoading.value = false;
      int pages = json.decode(data)['result']['total_pages'];
      totalPages.value = pages;
      print(totalPages.value);
      loading.value = false;
      return json.decode(data)['result']['travels'];
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void refreshPage(int value)async {

    List data = [];
    loading.value = true;
    data = await getAllRoadTravels(value);
    travelList.value = data;
    list.addAll(data);
  }
}
