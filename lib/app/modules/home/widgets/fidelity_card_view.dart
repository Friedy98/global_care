import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../color_constants.dart';
import '../../../../common/animation_controllers/animation.dart';
import 'dart:io' as plateform;
import '../controllers/home_controller.dart';

class FidelityCardWidget extends GetWidget<HomeController> {

  @override
  Widget build(BuildContext context) {

    controller.timer = Timer.periodic(Duration(seconds: 3),
            (Timer timer) => controller.getUserDto());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        leading: IconButton(onPressed: ()=> {
          controller.timer.cancel(),
          Navigator.pop(context)
        },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text("Fidelity Card", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,
            letterSpacing: 2, color: Palette.background)),
      ),
      bottomSheet: Container(
        height: Get.height/3,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32.0),
                topRight: Radius.circular(32.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: inactive.withOpacity(0.2),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Obx(()=> Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DelayedAnimation(
                      delay: 1000,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 32.0, left: 18, right: 16),
                          child: Obx(() => RichText(
                              text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: "POINTS ",
                                        style: TextStyle(fontSize: 18,
                                            letterSpacing: 1,
                                            color: Colors.grey
                                                .withOpacity(0.8))),
                                    TextSpan(text: "\n ${controller.clientPoint.value}",style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                        letterSpacing: 0.27,
                                        color: buttonColor),
                                    )
                                  ]
                              )
                          ))
                      ),
                    ),
                    DelayedAnimation(
                      delay: 800,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 8, top: 16),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RatingBar(
                                    initialRating: controller.clientPoint.value.toDouble() > controller.firstBar.value.toDouble() ?
                                    controller.firstBar.value.toDouble() : controller.clientPoint.value.toDouble(),
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: controller.firstBar.value <= 5 ? 5 : controller.firstBar.value.toInt(),
                                    itemSize: controller.firstBar.value <= 5 ? 30 : 15,
                                    ratingWidget: RatingWidget(
                                      full: Icon(Icons.star,color: buttonColor),
                                      half: Icon(Icons.star_half,color: buttonColor),
                                      empty: Icon(Icons.star, color: inactive),
                                    ),
                                    itemPadding:
                                    EdgeInsets.zero,
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    }
                                ),
                                RatingBar(
                                  initialRating: controller.clientPoint.value.toDouble() > controller.firstBar.value.toDouble() ?
                                  controller.clientPoint.value.toDouble() - controller.secondBar.value.toDouble() :
                                  controller.clientPoint.value.toDouble() - controller.firstBar.value.toDouble(),
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: controller.secondBar.value <= 5 ? 5 : controller.secondBar.value.toInt(),
                                  itemSize: controller.secondBar.value <= 5 ? 30 : 15,
                                  ratingWidget: RatingWidget(
                                    full: Icon(Icons.star,color: buttonColor),
                                    half: Icon(Icons.star_half,color: buttonColor),
                                    empty: Icon(Icons.star, color: inactive),
                                  ),
                                  itemPadding:
                                  EdgeInsets.zero,
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(color: Colors.blue),
                SizedBox(height: 10),
                DelayedAnimation(
                    delay: 600,
                    child: Text("BONUS",
                        style: TextStyle(fontSize: 25,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: Colors.red))
                ),
                SizedBox(height: 10),
                DelayedAnimation(
                  delay: 400,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 5,
                            color: Colors.red
                        )
                    ),
                    child: Center(
                      child: Text(controller.userBonus.value.toString(),style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          letterSpacing: 0.5,
                          color: buttonColor),),
                    ),
                  ),
                ),
              ],
            )
            ),
          ),
        ),
      ),
      backgroundColor: background,
      body: SizedBox(
        height: Get.height,
        child: Column(

          children: <Widget>[
            SizedBox(height: 20),
            DelayedAnimation(
                delay: 600,
                child: Container(
                    padding: EdgeInsets.only(top: 00,bottom: 20, left: 60, right: 60),
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    child: QrImage(
                      data: controller.userId.value.toString(),
                      version: QrVersions.auto,
                      size: Get.width/2,
                      gapless: false,
                    )
                )
            ),
          ],
        ),
      ),
    );
  }
}
