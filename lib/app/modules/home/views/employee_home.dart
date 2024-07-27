import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../../../color_constants.dart';
import '../../../../main.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../fidelisation/controller/validation_controller.dart';
import '../../fidelisation/views/attribute_points.dart';
import '../../global_widgets/main_drawer_widget.dart';
import '../../global_widgets/notifications_button_widget.dart';
import '../../root/controllers/root_controller.dart';
import '../../userBookings/controllers/bookings_controller.dart';
import '../../userBookings/views/bookings_view.dart';
import '../../userBookings/views/facturation.dart';
import '../../userBookings/views/interface_POS.dart';
import '../controllers/home_controller.dart';

class EmployeeHomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {

    Get.lazyPut<AuthController>(
          () => AuthController(),
    );
    Get.lazyPut(()=>HomeController());
    Get.lazyPut(()=>RootController());
    Get.lazyPut(()=>BookingsController());
    Get.lazyPut(()=>ValidationController());

    return Scaffold(
        floatingActionButton: Obx(() => controller.currentPage.value == 0 ? InkWell(
            onTap: ()=>{
              controller.currentPage.value = 3
            },
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('assets/img/qr-code.png'))
                )
            )
        ) : controller.currentPage.value != 4 ?
        FloatingActionButton(
              onPressed: (){
                if(MediaQuery.of(context).orientation == Orientation.portrait)
                {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                }else {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                }
              },
              child: Icon(Icons.screen_rotation),
            ) : SizedBox()
        ),
        appBar: AppBar(
          backgroundColor: appBarColor,
          leading: IconButton(
            icon: Icon(Icons.sort, color: Colors.white),
            onPressed: ()
            => showDialog(
              context: context,
              builder: (_) {
                return MainDrawerWidget();
              },
            ),
          ),
          title: Obx(() => Text( controller.currentPage.value == 0 ?
          Domain.AppName+", Tableau de bord" : controller.currentPage.value == 1 ? Domain.AppName+",  Mes rendez-vous"
              : controller.currentPage.value == 2 ? Domain.AppName+", Facturation" : controller.currentPage.value == 3 ? Domain.AppName+", Interface POS" : Domain.AppName+", Attribuer des points",
            style: Get.textTheme.headline6.merge(TextStyle(color: employeeInterfaceColor)),
          )),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [ NotificationsButtonWidget() ],
        ),
        backgroundColor: background,
        body: RefreshIndicator(

            onRefresh: ()=> controller.refreshPage(),

            child: FutureBuilder<bool>(
              future: controller.getData(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                } else {

                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: Obx(() => controller.currentPage.value == 0 ? build_dashboardView(context)
                        : controller.currentPage.value == 1 ? BookingsView()
                        : controller.currentPage.value == 2 ? EmployeeReceipt()
                        : controller.currentPage.value == 3 ? InterfacePOSView()
                        : AttributionView()
                    ),
                  );
                }
              },
            )
        )
    );
  }

  Widget build_dashboardView(BuildContext context){

    int hour = int.parse(DateFormat("HH").format(DateTime.now()).toString());
    var currentUser = Get.find<AuthController>().currentUser;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 15, top: 15),
                child: Obx(() => RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(text: hour > 12 ? "Bonsoir M/Mme ${currentUser['name']} 👋🏼" : "Bonjour M/Mme ${currentUser['name']} 👋🏼",
                              style: Get.textTheme.headline4.merge(TextStyle(color: appColor, fontSize: 30))
                          ),
                          /*TextSpan(text: "\nVous avez ✅ ${appointmentsPaid.length} rendez-vous approuvés et ⏰ ${appointmentsPending.length} rendez-vous planifié",
                                        style: TextStyle(color: appColor, fontSize: 15)),*/
                        ]
                    )
                ))
            )
          ),
          Obx(() => Container(
            alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 50),
              child: PieChart(
                dataMap: {
                  "PLANIFIÉ": controller.planned.value,
                  "FAIT": controller.done.value,
                  "MANQUÉ": controller.missed.value,
                  "ANNULÉ": controller.cancel.value,
                },
                animationDuration: Duration(milliseconds: 800),
                chartLegendSpacing: 50,
                chartRadius: MediaQuery.of(context).size.width / 3.5,
                colorList: controller.colorList,
                initialAngleInDegree: 0,
                chartType: ChartType.ring,
                ringStrokeWidth: 40,
                centerText: "Rendez-Vous",
                legendOptions: LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  legendShape: BoxShape.circle,
                  legendTextStyle: Get.textTheme.headline4.merge(TextStyle(fontSize: 30))
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesInPercentage: false,
                  showChartValuesOutside: false,
                  decimalPlaces: 1,
                ),
                // gradientList: ---To add gradient colors---
                // emptyColorGradient: ---Empty Color gradient---
              )
          )),
          SizedBox(height: 20),
          SizedBox(
            height: Get.height/1.4,
            width: Get.width,
            child: MyAppointments(context)
          )
        ]
      )
    );
  }

  Widget MyAppointments(BuildContext context){

    var length = controller.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text("Rendez-vous en attente",
                style: Get.textTheme.headline2.merge(TextStyle(color: appColor, fontSize: 30)
                )
            )
        ),
        SizedBox(height: 20),
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
                  length,
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

                          await controller.getServiceDto(controller.items[index]['service_id'][0], controller.items[index]);

                        },
                        cells: [
                          DataCell(Obx(() =>
                              Text(controller.items[index]["name"], style: Get.textTheme.headline4)
                          )),
                          DataCell(Obx(() =>
                              Text(controller.items[index]['service_id'][1].split(">").first, style: Get.textTheme.headline4)
                          )),
                          DataCell(Obx(() =>
                              Text(controller.items[index]['partner_id'][1], style: Get.textTheme.headline4)
                          )),
                          DataCell(Text("$start - $end", style: Get.textTheme.headline4)),
                          DataCell(SizedBox()),
                          DataCell(Obx(()=>
                              Text(controller.items[index]['state'].toUpperCase(), style: Get.textTheme.headline2.merge(
                                  TextStyle(color: bookingState == 'reserved' ? newStatus : bookingState == 'done' ? doneStatus : bookingState == 'cancel' ? inactive : specialColor)))
                          )
                          )
                        ]
                    );
                  }
              ),
            )
        )
      ],
    );
  }
}
