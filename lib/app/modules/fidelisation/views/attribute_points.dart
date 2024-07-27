
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../../../common/ui.dart';
import '../../../../../color_constants.dart';
import '../../home/controllers/home_controller.dart';
import '../controller/validation_controller.dart';
import 'num_pad.dart';

class AttributionView extends GetView<ValidationController> {

  List bookings = [];
  String barcode = "";

  @override
  Widget build(BuildContext context) {

    Get.lazyPut(()=>HomeController());

    return Scaffold(
        backgroundColor: Get.theme.colorScheme.secondary,
        resizeToAvoidBottomInset: true,
        floatingActionButton: InkWell(
            onTap: ()=> controller.scan(),
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
        ),
        body: Container(
          height: Get.height,
          width: Get.width,
          padding: EdgeInsets.all(10),
          decoration: Ui.getBoxDecoration(color: backgroundColor),
          child: SingleChildScrollView(
            child: Obx(() => Column(
              children: [
                SizedBox(height: Get.height/8),
                controller.found.value ?
                  ListTile(
                    title: Text(controller.client['name'], style: Get.textTheme.headline4.merge(TextStyle(fontSize: 30))),
                    subtitle: Text("Points: ${controller.client['client_points']}, Bonus: ${controller.client['client_bonus']}", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20))),
                  ) : ListTile(
                  leading: Icon(Icons.info_outline, size: 30,),
                  title: Text("Scanner le code Qr pour attribuer des points...", style: Get.textTheme.headline4.merge(TextStyle(fontSize: 20))),
                ),
                SizedBox(height: 20),
                Text("Nombre de points: ", style: TextStyle( fontSize: 30)),
                SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  width: Get.width/2,
                  child: Center(
                      child: TextFormField(
                        controller: controller.pointController,
                        textAlign: TextAlign.center,
                        showCursor: false,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: controller.noValue.value ? specialColor.withOpacity(0.2) : Palette.background
                        ),
                        style: const TextStyle(fontSize: 40),
                        keyboardType: TextInputType.none,
                      )),
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    width: Get.width/1.5,
                    height: Get.height/1.8,
                    child: NumPad(
                      buttonSize: 120,
                      buttonColor: Colors.white,
                      iconColor: Colors.blueGrey,
                      controller: controller.pointController,
                      delete: () {
                        controller.pointController.text = controller.pointController.text
                            .substring(0, controller.pointController.text.length - 1);
                      },
                      // do something with the input numbers
                      onSubmit: () {
                        debugPrint('Your number: ${controller.pointController.text}');
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: Text(
                                "You code is ${controller.pointController.text}",
                                style: const TextStyle(fontSize: 30),
                              ),
                            ));
                      },
                    )
                ),
                SizedBox(height: 40),
                InkWell(
                    onTap: (){

                      if(controller.found.value){
                        var points = controller.client['client_points'] + int.parse(controller.pointController.text);
                        if(controller.pointController.text.isNotEmpty){
                          int partner = int.parse(barcode);
                          controller.isLoading.value = true;
                          controller.attributePoints(partner, points);
                        }else{
                          controller.noValue.value = true;
                        }
                      }else{
                        Get.showSnackbar(Ui.warningSnackBar(message: "Bien vouloir scanner un code Qr pour continuer!"));
                      }

                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width /2.5,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: controller.found.value ? primaryColor : inactive
                        ),
                        child: controller.isLoading.value ? Center(
                          child: SpinKitFadingCircle(color: employeeInterfaceColor, size: 20)
                        ) : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,size: 20,color: Palette.background,),
                            SizedBox(width: 10),
                            Text("ATTRIBUER", style: TextStyle(color: Palette.background, fontSize: 20))
                          ]
                        )
                    )
                )
              ]
            ))
          )
        )
    );
  }

}
