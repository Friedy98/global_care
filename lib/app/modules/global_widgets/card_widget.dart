
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:app/app/modules/global_widgets/pop_up_widget.dart';
import 'package:intl/intl.dart';

import '../../../color_constants.dart';
import '../../../main.dart';
import '../../routes/app_routes.dart';
import '../account/widgets/account_link_widget.dart';
import '../userBookings/controllers/bookings_controller.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({Key key,

    this.agent,
    this.service,
    this.price,
    this.imageUrl,
    this.onTap,
    @required this.shippingDateStart,
    @required this.shippingDateEnd,
    @required this.code,
    @required this.bookingState
  }) : super(key: key);

  final String code;
  final String imageUrl;
  final String agent;
  final String service;
  final String shippingDateStart;
  final String shippingDateEnd;
  final String bookingState;
  final double price;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<BookingsController>(
          () => BookingsController(),
    );
    //var selected = Get.find<BookingsController>().currentState.value ;
    return ClipRRect(
      child: Banner(
        location: BannerLocation.topEnd,
        message: bookingState == "reserved" ? "Planifié" : bookingState == "done" ? "Fait" : bookingState == 'cancel' ? "Annulé" : bookingState,
        color: bookingState == 'reserved' ? newStatus : bookingState == 'done' ? doneStatus : bookingState == 'cancel' ?  specialColor : inactive,
        child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              //side: BorderSide(color: interfaceColor.withOpacity(0.4), width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                //alignment: AlignmentDirectional.topStart,
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(code, overflow: TextOverflow.ellipsis,style: Get.textTheme.headline1.
                          merge(TextStyle(color: appColor, fontSize: 12))
                          )
                      ),
                      Text("${DateFormat("dd MMM yyyy, HH:mm").format(DateTime.parse(shippingDateStart))} - ${DateFormat(" HH:mm").format(DateTime.parse(shippingDateEnd))}",
                          style: Get.textTheme.headline1.merge(TextStyle(fontSize: 12, color: Colors.black))),
                      SizedBox(width: 20)
                    ]
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                      width: Get.width,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => showDialog(
                                  context: context, builder: (_){
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Material(
                                        child: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.close, size: 20))
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      child: FadeInImage(
                                        width: Get.width,
                                        height: Get.height/2,
                                        fit: BoxFit.cover,
                                        image: NetworkImage(this.imageUrl, headers: Domain.getTokenHeaders()),
                                        placeholder: AssetImage(
                                            "assets/img/loading.gif"),
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                              child: Container(
                                                  width: Get.width/1.5,
                                                  height: Get.height/3,
                                                  color: Colors.white,
                                                  child: Center(
                                                      child: Icon(Icons.person, size: 150)
                                                  )
                                              )
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                );
                              }),
                              child: ClipOval(
                                  child: FadeInImage(
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    image: NetworkImage(this.imageUrl, headers: Domain.getTokenHeaders()),
                                    placeholder: AssetImage(
                                        "assets/img/loading.gif"),
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                          "assets/img/téléchargement (1).png",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.fitWidth);
                                    },
                                  )
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                                child: Text(this.agent, style: TextStyle(fontSize: 12, color: appColor, overflow: TextOverflow.ellipsis)),
                            ),
                            TextButton(
                                onPressed: onTap,
                                child: Text("Voir plus", style: Get.textTheme.headline2.merge(TextStyle(color: Colors.blueAccent)))
                            ),
                            SizedBox(width: 10)
                          ]
                      )
                  )
                ]
              )
            )
        )
      ),
    );
  }
}