import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../e_service/widgets/e_service_til_widget.dart';
import '../../global_widgets/pop_up_widget.dart';
import '../../root/controllers/root_controller.dart';
import '../controllers/account_controller.dart';
import '../widgets/account_link_widget.dart';

class AccountView extends GetView<AccountController> {

  @override
  Widget build(BuildContext context) {
    //var _currentUser = Get.find<MyAuthService>().myUser;
    Get.lazyPut(() => RootController());
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () async {
              controller.onRefresh();
            },
            child: SingleChildScrollView(
                primary: true,
                child: Column(
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Container(
                          height: 300,
                          width: Get.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("assets/img/240_F_142999858_7EZ3JksoU3f4zly0MuY3uqoxhKdUwN5u.jpeg")),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(color: Get.theme.focusColor.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5)),
                              ]
                          ),
                          margin: EdgeInsets.only(bottom: 50),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "\nMon Profile".tr,
                              style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                decoration: Ui.getBoxDecoration(
                                  //radius: 14,
                                  border: Border.all(width: 5, color: Get.theme.primaryColor),
                                ),
                                child: InkWell(
                                    onTap: ()=>{

                                      showDialog(
                                          context: context,
                                          builder: (_){
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
                                                    image: Domain.googleUser ? NetworkImage(Domain.googleImage) : NetworkImage('${Domain.serverPort}/image/res.partner/${controller.currentUser['id']}/image_1920?unique=true&file_response=true', headers: Domain.getTokenHeaders()),
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
                                          })
                                    },
                                    child: Obx(() =>
                                    !controller.pictureUpdated.value ?
                                    Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: FadeInImage(
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            image: Domain.googleUser ? NetworkImage(Domain.googleImage) : NetworkImage('${Domain.serverPort}/image/res.partner/${controller.currentUser['id']}/image_1920?unique=true&file_response=true',
                                                headers: Domain.getTokenHeaders()),
                                            placeholder: AssetImage(
                                                "assets/img/loading.gif"),
                                            imageErrorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                  'assets/img/man.png',
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.contain);
                                            }
                                        )
                                    ) : Image.file(controller.image, width: 100, height: 100, fit: BoxFit.cover)
                                    )
                                )
                            ),
                            CircleAvatar(
                                backgroundColor: interfaceColor,
                                radius: 20,
                                child: IconButton(
                                    onPressed: ()=>{
                                      controller.selectCameraOrGallery()
                                    },
                                    icon: Icon(Icons.camera_alt, color: Get.theme.primaryColor)
                                )
                            )
                          ],
                        ),
                      ],
                    ),
                    Obx(() =>
                    controller.currentUser['name'] == null ?
                    SpinKitFadingCircle(color: Colors.blue,size: 30) :
                    EServiceTilWidget(
                        title: Text("Mes Information", style: Get.textTheme.subtitle2.merge(TextStyle(fontSize: 16, color: Colors.black))),
                        actions: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: controller.edit.value ? inactive : interfaceColor),
                            child: Text(!controller.edit.value ? "Modifier profile" : "Annuler"),
                            onPressed: ()=>{
                              controller.edit.value = !controller.edit.value,
                            }
                        ),
                        content: SingleChildScrollView(
                            child: Column(
                                children: [
                                  Obx(() =>
                                      AccountLinkWidget(
                                        icon: Icons.person,
                                        text: "Nom complet",
                                        label: controller.currentUser['name'],
                                        edit: controller.edit.value,
                                        onChange: (value)=> controller.userName.value = value,
                                      )
                                  ),
                                  Divider(color: background),
                                  Obx(() =>
                                      AccountLinkWidget(
                                        icon: Icons.alternate_email_outlined,
                                        text: "Email",
                                        label: controller.currentUser['email'].toString(),
                                        edit: controller.edit.value,
                                        onChange: (value)=> controller.email.value = value,
                                      )
                                  ),
                                  Divider(color: background),
                                  Obx(() =>
                                      AccountLinkWidget(
                                        icon: Icons.phone_android,
                                        text: "Mobile",
                                        label: controller.currentUser['phone'].toString(),
                                        edit: controller.edit.value,
                                        onChange: (value)=> controller.phone.value = value,
                                      )
                                  ),
                                  Divider(color: background),
                                  Obx(() =>
                                  controller.edit.value ?
                                  ElevatedButton(
                                      child: Text("Soumetre"),
                                      onPressed: ()=>{
                                        controller.updateProfile(),
                                      }
                                  ) : SizedBox()
                                  ),
                                  AccountLinkWidget(
                                    icon: Icons.star,
                                    text: "Nombre de points",
                                    label: controller.currentUser['client_points'].toString(),
                                    edit: false,
                                    onChange: (value)=>{},
                                  ),
                                  Divider(color: background),
                                  AccountLinkWidget(
                                    icon: Icons.wine_bar,
                                    text: "Nombre de bonus",
                                    label: controller.currentUser['client_bonus'].toString(),
                                    edit: false,
                                    onChange: (value)=>{},
                                  ),
                                  Divider(color: background),
                                  Obx(() => SwitchListTile( //switch at right side of label
                                      value: controller.enableNotification.value,
                                      onChanged: (bool value){

                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Loading data..."),
                                          duration: Duration(seconds: 3),
                                        ));

                                        print(Domain.deviceToken);
                                        if(controller.enableNotification.value){
                                          //controller.getDeviceTokens();
                                        }else{
                                          //controller.enableNotify();
                                        }

                                      },//luggageSelected
                                      title: Text("Enable Notifications on this device", style: Get.textTheme.headline2.merge(TextStyle(fontSize: 12)))
                                  )),

                                  InkWell(
                                      onTap: ()=>{
                                        Get.toNamed(Routes.NOTIFICATIONS)
                                      },
                                      child: AccountWidget(
                                        icon: Icons.notifications,
                                        text: "Notifications",
                                        label: "",
                                        labelColor: Colors.black,
                                        textColor: Colors.black,
                                      )
                                  ),
                                  InkWell(
                                      onTap: (){
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
                                      child: AccountWidget(
                                        icon: Icons.logout,
                                        text: "Déconnexion",
                                        label: "",
                                        labelColor: interfaceColor,
                                        textColor: specialColor,
                                      )
                                  ),
                                  /*ListTile(
                                    dense: true,
                                    title: Text(
                                      "Version",
                                      style: Get.textTheme.caption,
                                    ),
                                    trailing: Text(
                                      'Get.find<RootController>().packageInfo.version.toString()',
                                      style: Get.textTheme.caption,
                                    ),
                                  )*/
                                ]
                            )
                        )
                    )
                    )
                  ],
                )
            )
        )
    );
  }

  Widget buildLoader() {
    return Container(
        width: Get.width,
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 100,
          ),
        )
    );
  }
}


