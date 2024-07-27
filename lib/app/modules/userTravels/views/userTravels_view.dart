import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../common/animation_controllers/animation.dart';
import '../../../../common/ui.dart';
import '../../../../color_constants.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../../services/my_auth_service.dart';
import '../../global_widgets/Travel_card_widget.dart';
import '../../global_widgets/loading_cards.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/user_travels_controller.dart';

class MyTravelsView extends GetView<UserTravelsController> {

  List bookings = [];

  @override
  Widget build(BuildContext context) {

    Get.lazyPut<MyAuthService>(
          () => MyAuthService(),
    );
    Get.lazyPut<RootController>(
          () => RootController(),
    );
    return Scaffold(
        backgroundColor: Get.theme.colorScheme.secondary,
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton.extended(
            heroTag: null,
            //backgroundColor: interfaceColor,
            onPressed: ()=>{

              for(var i=0; i < controller.items.length; i++){
                if(controller.items[i]['state'].contains("negotiating")){
                  controller.inNegotiation.value = true
                }else{
                  controller.inNegotiation.value = false
                }
              },
              if(!controller.inNegotiation.value){
                Get.toNamed(Routes.ADD_TRAVEL_FORM)
              }else{
                Get.showSnackbar(Ui.notificationSnackBar(message: "You cannot have simultaneous in the system two travels in negotiation! please update and try again"))
              }

            },
            label: Text('Transport'),
            icon: Icon(Icons.add, color: Palette.background)
        ),

        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
              onTap: ()async=> await Get.find<RootController>().changePage(3),
              child: ClipOval(
                child: FadeInImage(
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  image: NetworkImage('${Domain.serverPort}/image/res.partner/${Get.find<MyAuthService>().myUser.value.id}/image_1920?unique=true&file_response=true',
                      headers: Domain.getTokenHeaders()),
                  placeholder: AssetImage(
                      "assets/img/loading.gif"),
                  imageErrorBuilder:
                      (context, error, stackTrace) {
                    return Image.asset("assets/img/téléchargement (3).png", width: 20, height: 20);
                  },
                ),
              ),
            )
          ),
          title: Row(
            children: [
              Expanded(
                child: Obx(() => Text(
                  "My Travels, ${controller.items.length}",
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.headline5.merge(TextStyle(color: context.theme.primaryColor)),
                ))
              ),
              Container(
                  width: 150,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration.collapsed(
                        hintText: '',

                      ),
                      isExpanded: true,
                      alignment: Alignment.bottomRight,

                      style: TextStyle(color: labelColor),
                      value: controller.status[0],
                      // Down Arrow Icon
                      icon: Icon(Icons.filter_list),

                      items: controller.status.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == "NEGOTIATING" ? "PUBLISHED" : value,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        List filter = [];
                        controller.items.value = controller.origin;
                        if(newValue != 'ALL'){
                          for(var i in controller.items){

                            if(i['state'] == newValue.toLowerCase()){
                              filter.add(i);
                            }
                            controller.items.value = filter;
                          }
                        }else{
                          controller.items.value = controller.origin;
                        }
                      },
                    ),
                  )
              )
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              controller.initValues();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /*Container(
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        border: Border.all(
                          color: Get.theme.focusColor.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 12, left: 0),
                          child: Icon(Icons.search, color: Get.theme.colorScheme.secondary),
                        ),
                        Expanded(
                          child: Material(
                            color: Get.theme.primaryColor,
                            child: TextField(
                              //controller: controller.textEditingController,
                              style: Get.textTheme.bodyText2,
                              onChanged: (value)=> controller.filterSearchResults(value),
                              autofocus: false,
                              cursorColor: Get.theme.focusColor,
                              decoration: Ui.getInputDecoration(hintText: "Search for home service...".tr),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),*/

                  Container(
                      height: MediaQuery.of(context).size.height/1.2,
                      padding: EdgeInsets.all(10),
                      decoration: Ui.getBoxDecoration(color: backgroundColor),
                      child: Obx(() => Column(

                          children: [
                            controller.isLoading.value ?
                            Expanded(child: LoadingCardWidget()) :
                            controller.items.isNotEmpty ?
                            Expanded(
                                child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: controller.items.length +1,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemBuilder: (context, index) {
                                      if (index == controller.items.length) {
                                      return SizedBox(height: 80);
                                      } else {
                                        Future.delayed(Duration.zero, (){
                                          controller.items.sort((a, b) => b["__last_update"].compareTo(a["__last_update"]));
                                        });
                                      return GestureDetector(
                                        child: TravelCardWidget(
                                          isUser: true,
                                          travelState: controller.items[index]['state'],
                                          depDate: DateFormat("dd MMM yyyy", 'fr_CA').format(DateTime.parse(controller.items[index]['departure_date'])).toString(),
                                          arrTown: controller.items[index]['arrival_city_id'][1],
                                          depTown: controller.items[index]['departure_city_id'][1],
                                          qty: controller.items[index]['total_weight'],
                                          price: controller.items[index]['booking_price'],
                                          color: background,
                                          text: Text(""),
                                          imageUrl: 'https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Y2FyZ28lMjBwbGFuZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
                                          homePage: false,

                                          action: ()=> {

                                            ScaffoldMessenger.of(Get.context).showSnackBar(SnackBar(
                                              content: Text("Loading data..."),
                                              duration: Duration(seconds: 2),
                                            )),

                                            controller.publishTravel(controller.items[index]['id'])
                                          },
                                          travelBy: controller.items[index]['booking_type'],

                                        ),
                                        onTap: ()=>
                                            Get.toNamed(Routes.TRAVEL_INSPECT, arguments: {'travelCard': controller.items[index], 'heroTag': 'services_carousel'}),
                                      );}
                                    })
                            ) : SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height/1.6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.folderOpen, color: inactive.withOpacity(0.3),size: 80),
                                  Text('No Travels found', style: Get.textTheme.headline5.merge(TextStyle(color: inactive.withOpacity(0.3))))
                                ],
                              ),
                            )
                          ]
                      )
                    )
                  )
                ],
              )
            )
        )
    );
  }

  Widget buildInvoice(BuildContext context, List data) {
    return Column(

    );
  }
}
