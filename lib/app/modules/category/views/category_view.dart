import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../color_constants.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/Travel_card_widget.dart';
import '../../global_widgets/loading_cards.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  @override
  Widget build(BuildContext context) {

    Get.lazyPut<HomeController>(
          () => HomeController(),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              if(controller.currentPage.value != 1){
                controller.currentPage.value --;
                controller.refreshPage(controller.currentPage.value);
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 15,
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.arrow_back_ios, color: controller.currentPage.value != 1 ? Colors.black : inactive)
              ),
            ),
          ),
          Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('${controller.currentPage.value} / ${controller.totalPages.value}', textAlign: TextAlign.center, style: Get.textTheme.headline1.merge(TextStyle(fontSize: 14, color: appColor)))
              )
          ),
          InkWell(
            onTap: () {
              if(controller.currentPage.value != controller.totalPages.value){
                controller.currentPage.value ++;
                controller.refreshPage(controller.currentPage.value);
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 15,
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.arrow_forward_ios_sharp, color: controller.currentPage.value != controller.totalPages.value? Colors.black : inactive)
              ),
            ),
          )
        ],
      )),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshPage(1);
        },
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: false,
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: buttonColor,
              expandedHeight: 140,
              elevation: 0.5,
              primary: true,
              pinned: true,
              floating: false,
              iconTheme: IconThemeData(color: Get.theme.primaryColor),
              title: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                width: 120,
                child: Text(controller.travelType.value.toUpperCase(), style: Get.textTheme.headline2.merge(TextStyle(color: Colors.white))),
                decoration: BoxDecoration(
                    color: controller.travelType.value != "air" ? Colors.white.withOpacity(0.4) : interfaceColor.withOpacity(0.4),
                    border: Border.all(
                      color: controller.travelType.value != "air" ? Colors.white.withOpacity(0.2) : interfaceColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Obx(() => Center(
                      child: Text(controller.travelList.length.toString(),
                          style: Get.textTheme.headline5.merge(TextStyle(color: interfaceColor))),
                    )),
                  )
                )
              ],
              bottom: PreferredSize(
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                            width: Get.width/1.8,
                            child: TextFormField(
                              //controller: controller.textEditingController,
                                style: Get.textTheme.bodyText2,
                                onChanged: (value)=> controller.filterSearchResults(value),
                                autofocus: false,
                                cursorColor: Get.theme.focusColor,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1, color: buttonColor),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    hintText: "Search here...",
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: Icon(Icons.search),
                                    hintStyle: Get.textTheme.caption,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                )
                            )
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: interfaceColor),
                          onPressed: ()=> Get.toNamed(Routes.ADD_TRAVEL_FORM),
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text('CREATE')
                        ),
                        SizedBox(width: 10)
                      ],
                    )
                  ),
                  preferredSize: Size.fromHeight(50.0)),
              flexibleSpace: Row(
                children: [
                  Container(
                    width: Get.width,
                    child: FlexibleSpaceBar(
                      background: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(controller.imageUrl.value), fit: BoxFit.cover)
                        ),
                      ),
                    )
                  )
                ]
              )
            ),
            SliverToBoxAdapter(
              child: Wrap(
                children: [
                  Obx(() => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: controller.loading.value ?
                      LoadingCardWidget() :
                      ListView.builder(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        primary: false,
                        shrinkWrap: true,
                        itemCount: controller.travelList.length,
                        itemBuilder: ((_, index) {
                          Future.delayed(Duration.zero, (){
                            controller.travelList.sort((a, b) => a["departure_date"].compareTo(b["departure_date"]));
                          });
                          return GestureDetector(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width/1.2,
                              child: TravelCardWidget(
                                  isUser: false,
                                  homePage: false,
                                  travelBy: controller.travelList[index]['booking_type'],
                                  depDate: DateFormat("dd MMM yyyy", 'fr_CA').format(DateTime.parse(controller.travelList[index]['departure_date'])).toString().toUpperCase(),
                                  arrTown: controller.travelList[index]['arrival_city_id'][1],
                                  depTown: controller.travelList[index]['departure_city_id'][1],
                                  qty: controller.travelList[index]['kilo_qty'],
                                  price: controller.travelList[index]['price_per_kilo'],
                                  color: background,
                                  text: Text(""),
                                  user: controller.travelList[index]['partner_id'][1],
                                  rating: controller.travelList[index]['average_rating'].toStringAsFixed(1),
                                  imageUrl: '${Domain.serverPort}/image/res.partner/${controller.travelList[index]['partner_id'][0]}/image_1920?unique=true&file_response=true'

                              ),
                            ),
                            onTap: ()=> Get.toNamed(Routes.TRAVEL_INSPECT, arguments: {'travelCard': controller.travelList[index], 'heroTag': 'services_carousel'}),
                            //Get.toNamed(Routes.E_SERVICE, arguments: {'eService': travel, 'heroTag': 'services_carousel'})
                          );
                        }),
                      ))
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildSearchBar(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1.5;
    return Container(
      height: 40,
      width: width,
      margin: EdgeInsets.only(top: 30),
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        //controller: controller.textEditingController,
        style: Get.textTheme.bodyText2,
        onChanged: (value)=> controller.filterSearchResults(value),
        autofocus: false,
        cursorColor: Get.theme.focusColor,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: buttonColor),
              borderRadius: BorderRadius.circular(20.0),
            ),
            hintText: "Search here...",
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(Icons.search),
            hintStyle: Get.textTheme.caption,
            contentPadding: EdgeInsets.all(10)
        ),
      ),
    );
  }
}
