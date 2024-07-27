
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui.dart';
import '../../../../color_constants.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../global_widgets/card_widget.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/bookings_controller.dart';
import '../widgets/bookings_list_loader_widget.dart';

class BookingsView extends GetView<BookingsController> {

  @override
  Widget build(BuildContext context) {

    Get.lazyPut<RootController>(
          () => RootController(),
    );
    Get.lazyPut(() => AuthController());

    var firstDate = DateFormat("dd, MMMM", "fr_CA").format(DateTime.now()).toString().obs;
    var lastDate = DateFormat("dd, MMMM", "fr_CA").format(DateTime.now().add(Duration(days: 5))).toString().obs;
    controller.dateController.text = "$firstDate - $lastDate";

    return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: true,
        floatingActionButton: Obx(() =>
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            !Get.find<AuthController>().isEmployee.value ?
            FloatingActionButton.extended(
                backgroundColor: interfaceColor,
                heroTag: null,
                //backgroundColor: interfaceColor,
                onPressed: ()=> Get.toNamed(Routes.ADD_SHIPPING_FORM),
                label: Text('Prendre rendez-vous'),
                icon: Icon(Icons.add, color: Palette.background)
            ) : FloatingActionButton.extended(
                backgroundColor: employeeInterfaceColor,
                heroTag: null,
                //backgroundColor: interfaceColor,
                onPressed: ()=> Get.toNamed(Routes.ADD_SHIPPING_FORM),
                label: Text('Ajouter un rendez-vous'),
                icon: Icon(Icons.add, color: Palette.background)
            ),
            if(Get.width > 500)
            SizedBox(width: 70)
          ],
        )),

        appBar: !Get.find<AuthController>().isEmployee.value ? AppBar(
          backgroundColor: appBarColor,
          title: Obx(() => Text(
            "Mes rendez-vous, ${controller.items.length}",
            style: Get.textTheme.headline6.merge(TextStyle(color: Colors.white)),
          )),
          centerTitle: true,
          leading: Obx(() =>
          controller.showBackButton.value ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => {
                controller.showBackButton.value = false,
                Navigator.pop(context)
              }
          ) : SizedBox()
          ),
        ) : null,
        body: RefreshIndicator(
            onRefresh: () async {
              controller.refreshBookings();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(Get.find<AuthController>().isEmployee.value)
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                              width: Get.width/2,
                              child: TextFormField(
                                //controller: controller.textEditingController,
                                  style: Get.textTheme.headline4,
                                  onChanged: (value)=> controller.filterSearchAppointment(value),
                                  autofocus: false,
                                  cursorColor: Get.theme.focusColor,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: buttonColor),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      hintText: "Search here...",
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: Icon(Icons.search),
                                      hintStyle: Get.textTheme.caption,
                                      contentPadding: EdgeInsets.all(10)
                                  )
                              )
                          ),
                        ),
                        Spacer(),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: 50,
                            child: TextFormField(
                              controller: controller.dateController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(color: Colors.black)),
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                  filled: true,
                                  fillColor: Palette.background,
                                  suffixIcon: IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      onPressed: () {
                                        controller.appointments.value = controller.items;
                                        controller.selectDate();
                                      }
                                  )
                              ),
                              readOnly: true,
                            )
                        )
                      ]
                    ),
                  Obx(() => Container(
                      height: Get.height,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: Ui.getBoxDecoration(color: backgroundColor),
                      child:  controller.isLoading.value ? BookingsListLoaderWidget() :
                      controller.items.isNotEmpty ?
                      Get.find<AuthController>().isEmployee.value ? MyAppointments(context) : MyBookings(context)
                          : SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height/4),
                            FaIcon(FontAwesomeIcons.folderOpen, color: inactive.withOpacity(0.3),size: 80),
                            Text('Aucun rendez-vous trouvé', style: Get.textTheme.headline5.merge(TextStyle(color: inactive.withOpacity(0.3)))),
                          ]
                        )
                      )
                  ))
                ]
              )
            )
        )
    );
  }

  Widget MyAppointments(BuildContext context){
    return Obx(() => Column(
      children: [
        Expanded(
            child: DataTable2(
              columnSpacing: defaultPadding,
              headingRowColor: MaterialStateColor.resolveWith((states) => appBarColor),
              minWidth: 800,
              headingRowHeight: 60,
              dataRowHeight: 80,
              showCheckboxColumn: false,
              columns: [
                DataColumn(
                  label: Text("Reference", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Colors.white))),
                ),
                DataColumn(
                  label: Text("Service", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Colors.white))),
                ),
                DataColumn(
                  label: Text("Client", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Colors.white))),
                ),
                DataColumn(
                  label: Text("Date/heure", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Colors.white))),
                ),
                DataColumn(
                  label: Text(""),
                ),
                DataColumn(
                  label: Text("Stage", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Colors.white))),
                ),
              ],
              rows: List.generate(
                  controller.items.length,
                      (index){
                    var bookingState = controller.items[index]['state'];
                    var start = DateFormat("dd-MM-yyyy HH:mm").format(DateTime.parse(controller.items[index]['datetime_start'])).toString();
                    var end = DateFormat("HH:mm").format(DateTime.parse(controller.items[index]['datetime_end'])).toString();

                    return DataRow(
                      onSelectChanged: (value)async{
                        showDialog(
                            context: context,
                            builder: (_){
                              return SpinKitFadingCircle(color: Colors.white, size: 50);
                            });

                        await controller.getServiceDto(controller.items[index]['service_id'][0], controller.items[index], false);

                      },
                        cells: [
                          DataCell(Text(controller.items[index]["name"], style: Get.textTheme.headline4)),
                          DataCell(Text(controller.items[index]['service_id'][1].split(">").first, style: Get.textTheme.headline4)),
                          DataCell(Text(controller.items[index]['partner_id'][1], style: Get.textTheme.headline4)),
                          DataCell(Text("$start - $end", style: Get.textTheme.headline4)),
                          DataCell(SizedBox()),
                          DataCell(Text(controller.items[index]['state'].toUpperCase(), style: Get.textTheme.headline2.merge(
                              TextStyle(color: bookingState == 'reserved' ? newStatus : bookingState == 'done' ? doneStatus : bookingState == 'cancel' ? specialColor : inactive)))
                          )
                        ]
                    );
                  }
              ),
            )
        )
      ],
    ));
  }

  Widget MyBookings(BuildContext context){

    Get.lazyPut(() => AuthController());

    return Obx(() => Column(
      children: [
        Expanded(
            child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: controller.items.length+1 ,
                shrinkWrap: true,
                primary: false,
                itemBuilder: (context, index) {
                  var employeeId = 0;
                  var data = Get.find<AuthController>().resources;
                  if (index == controller.items.length) {
                    return SizedBox(height: Get.height/2);
                  } else {
                    for(var i in data){
                      if(i['id'] == controller.items[index]['resource_id'][0]){
                        employeeId = i['employee_id'][0];
                      }
                    }
                    return InkWell(
                      onTap: ()async{

                        /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Loading data..."),
                          duration: Duration(seconds: 2),
                        ));*/

                        showDialog(
                            context: context,
                            builder: (_){
                              return SpinKitFadingCircle(color: Colors.white, size: 50);
                            });
                        await controller.getServiceDto(controller.items[index]['service_id'][0], controller.items[index], true);

                      },
                      child: CardWidget(
                        shippingDateStart: controller.items[index]['datetime_start'],
                        shippingDateEnd: controller.items[index]['datetime_end'],
                        imageUrl: "${Domain.serverPort}/image/hr.employee/$employeeId/image_1920?unique=true&file_response=true",
                        code: controller.items[index]['name'],
                        bookingState: controller.items[index]['state'],
                        //price: controller.items[index]['shipping_price'],
                        agent: controller.items[index]['resource_id'][1],
                        service: controller.items[index]['service_id'][1],
                        onTap: ()async{
                          showDialog(
                              context: context,
                              builder: (_){
                                return SpinKitFadingCircle(color: Colors.white, size: 50);
                              });
                          await controller.getServiceDto(controller.items[index]['service_id'][0], controller.items[index], true);
                        }
                      )
                    );
                  }
                })
        )
      ],
    ));
  }

  Widget buildLoader() {
    return Container(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 100,
          ),
        ));
  }
}
