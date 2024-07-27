import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../color_constants.dart';
import '../../../../main.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/bookings_controller.dart';
import 'package:flutter/services.dart';

import '../widgets/bookings_list_item_widget.dart';

class InterfacePOSView extends GetView<BookingsController> {

  @override
  Widget build(BuildContext context) {

    Get.lazyPut<RootController>(
          () => RootController(),
    );
    Get.lazyPut(() => AuthController());

    return Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: true,
        bottomSheet: buildBottomSheet(context),
        body: RefreshIndicator(
            onRefresh: () async {
              controller.refreshBookings();
            },
            child:  SingleChildScrollView(
              child: Obx(() =>
                  Column(
                    children: [
                      Row(
                          children: [
                            Container(
                                padding: EdgeInsets.all(10),
                                width: Get.width/2,
                                height: 70,
                                child: TextFormField(
                                  controller: controller.searchController,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: backgroundColor,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                      hintText: "Rechercher des services",
                                      contentPadding: EdgeInsets.all(10),
                                      hintStyle: TextStyle(fontSize: 12),
                                      suffixIcon: InkWell(
                                          child: Container(
                                            height: 35,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  bottomRight: Radius.circular(5)
                                              ),
                                              color: Colors.blue,
                                            ),
                                            padding: EdgeInsets.all(5),
                                            child: Center(
                                                child: Icon(!controller.search.value ? Icons.search : Icons.close, color: Palette.background)
                                            ),
                                          ),
                                          onTap: ()async{
                                            if(controller.search.value){
                                              controller.search.value = !controller.search.value;
                                              controller.items.clear();
                                              controller.items.addAll(controller.allServices);
                                              controller.searchController.clear();
                                            }
                                          }
                                      )
                                  ),
                                  onChanged: (value) {
                                    controller.filterSearchServices(value);
                                  },
                                )
                            ),
                            Spacer(),
                            Padding(
                                padding: EdgeInsets.all(10),
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: employeeInterfaceColor),
                                    onPressed: (){

                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) => BookingsListItemWidget()
                                      );
                                      controller.refreshEmployeeBookings();
                                    },
                                    icon: Icon(Icons.recommend),
                                    label: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Text("Commandes"))
                                )),
                            SizedBox(width: 10),
                          ]
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: Get.width/2,
                                child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        margin: EdgeInsets.all(10),
                                        width: Get.width/2.1,
                                        child: ListView.builder(
                                          itemCount: controller.allCategories.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return Obx(() => InkWell(
                                              child: Container(
                                                margin: EdgeInsets.only(right: 10.0, top: 8.0),
                                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  color: controller.selected.value == index ? employeeInterfaceColor : inactive,
                                                ),
                                                child: Center(
                                                  child: Text(controller.allCategories[index]["name"],
                                                    style: TextStyle(
                                                        color: controller.selected.value == index ? CupertinoColors.white : appColor, letterSpacing: 2),
                                                  ),
                                                ),
                                              ),
                                              onTap: ()async{
                                                controller.isLoading.value = true;
                                                controller.getServiceByCategory(controller.allCategories[index]['service_ids']);
                                                controller.selected.value = index;
                                                //controller.search.value = false;

                                              },
                                            ));
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: Get.height/1.7,
                                          width: Get.width/2,
                                          child: Obx(() =>
                                              Column(
                                                children: [

                                                  Expanded(
                                                      child: controller.isLoading.value ?
                                                      GridView.builder(
                                                        itemBuilder: (context, index){
                                                          return buildLoader();
                                                        },
                                                        itemCount: 10,

                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2, mainAxisExtent: 190.0, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0),
                                                      ) :
                                                      GridView.builder(
                                                          itemCount: controller.servicesByCategory.length,
                                                          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 2, mainAxisExtent: 200.0, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0),
                                                          itemBuilder: (context, index) {
                                                            //articles?.sort((a, b) => b.date.compareTo(a.date));
                                                            double duration = controller.servicesByCategory[index]["appointment_duration"] * 60;

                                                            return InkWell(
                                                                onTap: ()async{

                                                                  if(controller.extraServices.contains(controller.servicesByCategory[index])){
                                                                    controller.extraServices.remove(controller.servicesByCategory[index]);
                                                                  }else{
                                                                    controller.extraServices.add(controller.servicesByCategory[index]);
                                                                  }

                                                                },
                                                                child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      border: controller.extraServices.contains(controller.servicesByCategory[index]) ? Border.all(width: 2, color: employeeInterfaceColor) : null,
                                                                      color: controller.extraServices.contains(controller.servicesByCategory[index]) ? background : Colors.white,
                                                                    ),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        FadeInImage(
                                                                          width: 120,
                                                                          height: 120,
                                                                          fit: BoxFit.cover,
                                                                          image: NetworkImage('${Domain.serverPort}/image/appointment.product/${controller.servicesByCategory[index]['id']}/image_1920?unique=true&file_response=true', headers: Domain.getTokenHeaders()),
                                                                          placeholder: AssetImage(
                                                                              "assets/img/loading.gif"),
                                                                          imageErrorBuilder:
                                                                              (context, error, stackTrace) {
                                                                            return Image.asset(
                                                                                'assets/img/photo_2022-11-25_01-12-07.jpg',
                                                                                width: 120,
                                                                                height: 120,
                                                                                fit: BoxFit.fitWidth);
                                                                          },
                                                                        ),
                                                                        Text(controller.servicesByCategory[index]["name"].split(">").first + " $duration mins", style: Get.textTheme.headline4),
                                                                        Text("${controller.servicesByCategory[index]["product_price"]} EUR", style: Get.textTheme.headline4)
                                                                      ]
                                                                    )
                                                                )
                                                            );
                                                          }
                                                      )
                                                  )
                                                ],
                                              )
                                          )
                                      )
                                    ]
                                )
                            ),
                            SizedBox(
                                width: Get.width/2,
                                height: Get.height - Get.height/4,
                                child: Card(
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                  child: Column(
                                      children: [
                                        Obx(() => Row(
                                            children: [
                                              RichText(
                                                  text: TextSpan(
                                                      children: [
                                                        TextSpan(text: "Détails de ", style: TextStyle(fontSize: 20, color: appColor)),
                                                        TextSpan(text: controller.selectedAppointment['name']
                                                            , style: TextStyle(fontSize: 20, color: appColor, fontWeight: FontWeight.bold))
                                                      ]
                                                  )
                                              ),
                                              Spacer(),
                                              if(controller.loadOrder.value)
                                                SpinKitFadingCircle(color: employeeInterfaceColor, size: 30),
                                              if(controller.selectedAppointment.isNotEmpty)
                                              TextButton(
                                                  onPressed: ()=> {
                                                    controller.selectedAppointment.value = {},
                                                    controller.orderDto.value = {}
                                                  },
                                                  child: Text("Annuler", style: Get.textTheme.headline2.merge(TextStyle(color: specialColor))
                                                  )
                                              ),
                                              SizedBox(width: 10)
                                            ]
                                        )),
                                        SizedBox(height: 10),
                                        if(controller.extraProducts.isNotEmpty && controller.selectedAppointment.isNotEmpty)...[
                                          Expanded(
                                            child: Obx(() =>
                                                ListView.builder(
                                                  itemCount: controller.extraProducts.length,
                                                  itemBuilder: (context, index){

                                                    List data = [];
                                                    var item = controller.extraProducts[index];
                                                    data.add(item);

                                                    return Card(
                                                        child: Padding(
                                                            padding: EdgeInsets.all(10),
                                                            child: Row(
                                                                children: [
                                                                  Text(item['product_id'][1].split(">").first, style: TextStyle(fontSize: 17, color: appColor)),
                                                                  Spacer(),
                                                                  Text("${item['price_total']} EUR",
                                                                      style: TextStyle(color: specialColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                                                  SizedBox(width: 5),
                                                                  if(item.length > 1 && index != 0)
                                                                  IconButton(
                                                                    onPressed: (){
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (_){
                                                                            return AlertDialog(
                                                                                title: Column(
                                                                                    children: [
                                                                                      Icon(Icons.warning_amber_outlined,
                                                                                          size: 50, color: inactive),
                                                                                      SizedBox(height: 10),
                                                                                      Text("Confirmer l'Action"),
                                                                                    ]
                                                                                ),
                                                                                backgroundColor: Color(0xFFE5F0FA),
                                                                                scrollable: true,
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                                                content: Container(
                                                                                  //color: Palette.background
                                                                                  width: Get.width/2,
                                                                                    height: 100,
                                                                                    child: Column(
                                                                                        children: [
                                                                                          Text("Voulez-vous vraiment Supprimer cette ligne?", style: Get.textTheme.headline4),
                                                                                          SizedBox(height: 30),
                                                                                          Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                ElevatedButton.icon(
                                                                                                    icon: Icon(
                                                                                                      Icons.close,
                                                                                                      size: 14,
                                                                                                    ),
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                        primary: inactive),
                                                                                                    onPressed: () {
                                                                                                      Navigator.of(context).pop();
                                                                                                    },
                                                                                                    label: Text("Annuler")),
                                                                                                SizedBox(width: 20),
                                                                                                ElevatedButton.icon(
                                                                                                    icon: Icon(
                                                                                                        Icons.delete,
                                                                                                        size: 14
                                                                                                    ),
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                        primary: specialColor),
                                                                                                    onPressed: () {
                                                                                                      String value = '';
                                                                                                      String type = "";
                                                                                                      if(controller.selectedAppointment['product_discount_id'] != false){
                                                                                                        type = controller.selectedAppointment['product_discount_id'][1].split(" ").first;
                                                                                                      }
                                                                                                      if(item['product_id'][1].contains("Bonus de ")){
                                                                                                        value = "Bonus";
                                                                                                      }else{
                                                                                                        if(item['product_id'][1].split(">").first.contains(type)){
                                                                                                          value = "Réduction";
                                                                                                        }
                                                                                                      }
                                                                                                      controller.removeLine(item['id'], value);
                                                                                                    },
                                                                                                    label: Text("Suprimer")),
                                                                                              ]
                                                                                          ),
                                                                                        ]
                                                                                    )
                                                                                )
                                                                            );
                                                                          });
                                                                    },
                                                                    icon: Icon(Icons.delete),
                                                                  ),
                                                                  SizedBox(width: 5),
                                                                ]
                                                            )
                                                        )
                                                    );
                                                  },
                                                )
                                            ),
                                          )
                                        ],
                                        SizedBox(height: 10),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: controller.extraServices.length,
                                            itemBuilder: (context, index){

                                              List data = [];
                                              var item = controller.extraServices[index];
                                              data.add(item);
                                              double duration = controller.servicesByCategory[index]["appointment_duration"] * 60;

                                              return Card(
                                                  child: Padding(
                                                      padding: EdgeInsets.all(10),
                                                      child: ListTile(

                                                        title: Text(item['name'].split(">").first + ", \n$duration mins", style: TextStyle(fontSize: 14, color: appColor)),
                                                        subtitle: Text("${item["product_price"]} €",
                                                            style: TextStyle(color: specialColor, fontSize: 14)),
                                                        trailing: ElevatedButton(
                                                            onPressed: (){
                                                              var data = json.encode({
                                                                "product_id": item["product_id"],
                                                                "appointment_id": controller.selectedAppointment['id'],
                                                                "product_uom_qty": 1,
                                                                "from_web_mobile": true
                                                              });
                                                              controller.loadOrder.value = true;
                                                              controller.
                                                              addProductLine(item['id'], item, data);

                                                            },
                                                            child: Text('Confirmer')
                                                        ),
                                                      )
                                                  )
                                              );
                                            },
                                          ),
                                        ),
                                      ]
                                  )
                                  )
                                )
                            )
                          ]
                      )
                    ],
                  )
              )
            )
        )
    );
  }

  Widget buildBottomSheet(BuildContext context){

    //var userDto = controller.userDto;
    var width = Get.width/3;
    double height = 60;
    double total = 0.0;

    return Container(
      width: Get.width,
      height: Get.height/4,
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 3,
                child: Obx(() =>
                    RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(text: "Client Bonus: ", style: TextStyle(color: Colors.white, letterSpacing: 1, fontSize: 20)),
                              TextSpan(text: controller.selectedAppointment.isNotEmpty ? controller.clientBonus.value.toString() : "0.",
                                  style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 25, fontWeight: FontWeight.bold))
                            ]
                        )
                    )
                )
              ),
              Spacer(),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 3,
                child: Obx(() =>
                    RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(text: "Total: ", style: TextStyle(color: Colors.white, letterSpacing: 1, fontSize: 20)),
                              TextSpan(text: controller.selectedAppointment.isNotEmpty ? "${controller.price.value} EUR" : "0 EUR",
                                  style: TextStyle(color: validateColor, letterSpacing: 2, fontSize: 25, fontWeight: FontWeight.bold))
                            ]
                        )
                    )
                )
              )
            ]
          ),
          Divider(color: Colors.white),
          //SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  width: width,
                  height: height,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage("assets/img/man.png"),
                                )
                            )
                        ),
                        SizedBox(width: 10),
                        Obx(() => Expanded(
                            child: Text(controller.selectedAppointment['partner_id'] != null ? controller.selectedAppointment['partner_id'][1] : "ANONYME", style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 20), overflow: TextOverflow.ellipsis,
                            )
                        ))
                      ]
                  )
              ),
              InkWell(
                onTap: ()=> {
                  showDialog(
                      context: context,
                      builder: (_){
                        return SpinKitFadingCircle(color: Colors.white, size: 50);
                      }),
                  controller.getResources()

                },
                  child: Obx(() =>
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: controller.selectedAppointment['partner_id'] != null ? Colors.blue : inactive, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          width: width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          height: height,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/img/data-transfer.png"),
                                      )
                                  ),
                                ),
                                Text("TRANSFERER", style: TextStyle(color: controller.selectedAppointment['partner_id'] != null ? Colors.white : inactive, letterSpacing: 2, fontSize: 20)
                                ),
                              ],
                            ),
                          )
                      )
                  )
                )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){

                  if(controller.selectedAppointment.isNotEmpty){
                    controller.getRemise();
                  }
                },
                child: Obx(() =>
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: controller.selectedAppointment['partner_id'] != null ? employeeInterfaceColor : inactive, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        width: width,
                        padding: EdgeInsets.only(left: 5, right: 5),
                        height: height,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      width: 30,
                                      height: 30,
                                      margin: EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage("assets/img/offer.png"),
                                          )
                                      )
                                  ),
                                  Text("REMISE", style: TextStyle(color: controller.selectedAppointment['partner_id'] != null ? Colors.white : inactive, letterSpacing: 2, fontSize: 20)
                                  )
                                ]
                            )
                        )
                    )
                )
              ),
              InkWell(
                  onTap: ()async{

                    if(controller.selectedAppointment.isNotEmpty && controller.clientBonus.value > 0){
                      await controller.getBonuses();
                    }

                  },
                  child: Obx(() =>
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: controller.selectedAppointment.isNotEmpty && controller.clientBonus.value > 0 ? employeeInterfaceColor : inactive, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          width: width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          height: height,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                              width: 30,
                                              height: 30,
                                              margin: EdgeInsets.only(left: 10, right: 10),
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage("assets/img/gift.png"),
                                                  )
                                              )
                                          ),
                                          Text("Mes Bonus", style: TextStyle(color: controller.clientBonus.value > 0 && controller.selectedAppointment['partner_id'] != null ? Colors.white : inactive, letterSpacing: 2, fontSize: 20))
                                        ]
                                    )
                                  ]
                              )
                          )
                      )
                  )
              )
            ]
          ),
          InkWell(
            onTap: (){
              if(controller.selectedAppointment.isNotEmpty){
                showDialog(
                    context: context,
                    builder: (_){
                      return showContext(context);
                    });
              }
            },
            child: Obx(() =>
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: height,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: controller.selectedAppointment.isNotEmpty ? employeeInterfaceColor : inactive,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Center(child: Text("TERMINER", style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 20))),
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget showContext(BuildContext context){
    return AlertDialog(
        title: Column(
          children: [
            Icon(Icons.warning_amber_outlined,
                size: 60, color: inactive),
            SizedBox(height: 10),
            Text("Confirmer l'Action", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 18, letterSpacing: 2))),
          ],
        ),
        backgroundColor: backgroundColor,
        scrollable: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Container(
          //color: Palette.background,
            height: 120,
            child: Column(
                children: [
                  Text("Voulez-vous vraiment Terminer le rendez-vous ${controller.selectedAppointment['display_name']} ?", style: Get.textTheme.headline4),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            icon: Icon(
                              Icons.close,
                              size: 17,
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: inactive),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            label: Text("Annuler")),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                            icon: Icon(
                              Icons.check,
                              size: 17,
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: validateColor),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_){
                                    return SpinKitFadingCircle(color: Colors.white, size: 50);
                                  });
                              controller.markDone();
                            },
                            label: Text("TERMINER")),
                      ]
                  )
                ]
            )
        )
    );
  }

  Widget buildLoader() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Image.asset(
        'assets/img/loading.gif',
        fit: BoxFit.cover,
        width: 200,
        height: 100,
      ),
    );
  }
}
