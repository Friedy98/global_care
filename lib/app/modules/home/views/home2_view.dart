import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../color_constants.dart';
import '../../../../common/animation_controllers/animation.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../../services/my_auth_service.dart';
import '../../fidelisation/controller/validation_controller.dart';
import '../../global_widgets/notifications_button_widget.dart';
import '../../global_widgets/pop_up_widget.dart';
import '../controllers/home_controller.dart';

class Home2View extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut<MyAuthService>(
          () => MyAuthService(),
    );
    Get.lazyPut(() => ValidationController());

    return Scaffold(
        backgroundColor: background,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: Obx(() => IconButton(onPressed: ()=> controller.multiple.value = !controller.multiple.value,
            icon: Icon(controller.multiple.value ? Icons.dashboard : Icons.view_agenda, color: Colors.white,))
        ),
        title: Text(
               Domain.AppName,
               style: Get.textTheme.headline6.merge(TextStyle(color: Colors.white)),
             ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              NotificationsButtonWidget(),
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (_)=>  PopUpWidget(
                              title: "Voulez vous vraiment vous déconnecter? veillez confirmer votre choix",
                              cancel: 'Annuler',
                              confirm: 'Confirmer',
                              onTap: ()async{
                                var box = GetStorage();
                                Domain.googleUser = false;
                                box.remove("userDto");

                                Get.toNamed(Routes.LOGIN);

                              }, icon: Icon(FontAwesomeIcons.warning, size: 40,color: inactive),
                            ));
                      },
                      icon: Icon(FontAwesomeIcons.signOut,
                          color: Colors.white
                      )
                  )
              )
            ],
          ),
        ],
      ),
        /*floatingActionButton: InkWell(
            onTap: ()=>{
              Get.find<ValidationController>().scan()
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
        ),*/
      body: RefreshIndicator(

        onRefresh: ()=> controller.getUserDto(),

        child: FutureBuilder<bool>(
          future: controller.getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),
                  Expanded(
                    child: FutureBuilder<bool>(
                      future: controller.getData(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        } else {
                          return Obx(() => GridView(
                            padding: const EdgeInsets.only(
                                top: 0, left: 12, right: 12),
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: List<Widget>.generate(
                              controller.homeList.length,
                                  (int index) {
                                return DelayedAnimation(
                                    delay: index == 0 ? 30 : 30 * index,
                                    child: AspectRatio(
                                      aspectRatio: 1.5,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0)),
                                        child: Stack(
                                          alignment:
                                          AlignmentDirectional.center,
                                          children: <Widget>[
                                            Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.6),
                                                        offset:
                                                        const Offset(4, 4),
                                                        blurRadius: 16,
                                                      ),
                                                    ],
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          controller.homeList[index]
                                                              .imagePath),
                                                      fit: BoxFit.cover,
                                                      colorFilter:
                                                      ColorFilter.mode(
                                                          Colors
                                                              .black
                                                              .withOpacity(
                                                              0.2),
                                                          BlendMode.darken),
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(15),

                                                    //border: Border.all(width: 3, color: Colors.grey)
                                                  ),
                                                )),
                                            Center(
                                              child: !controller.multiple.value
                                                  ? Text(
                                                controller.homeList[index].title,
                                                style: TextStyle(
                                                    fontSize: 40,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color:
                                                    Colors.white),
                                              )
                                                  : Text(
                                                controller.homeList[index].title,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color:
                                                    Colors.white),
                                              ),
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.grey
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(4.0)),
                                                onTap: ()async => await controller.changePage(index)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                );
                              },
                            ),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: controller.multiple.value ? 2 : 1,
                              mainAxisSpacing: 12.0,
                              crossAxisSpacing: 12.0,
                              childAspectRatio: 1.5,
                            ),
                          ));
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        )
      )
    );
  }
}
