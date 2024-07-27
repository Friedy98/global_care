import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../color_constants.dart';
import '../../../../common/helper.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/setting_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/phone_field_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  final Setting _settings = Get.find<SettingsService>().setting.value;
  String dropdownvalueGender = 'Select your gender'.tr;
  String dropdownvaluePiece = 'Select an identity piece'.tr;

  var selectedPiece = "Select an identity piece".obs;
  var selectedGender = "Select your gender".obs;


  var genderList = [
    'Select your gender'.tr,
    'Male'.tr,
    'Female'.tr,
  ];
  var identityPieceList = [
    'Select an identity piece'.tr,
    'CNI'.tr,
    'Passeport'.tr,
  ];

  var birthDay= DateTime.now().obs ;




  
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(
        body: Form(
          key: Domain.riKey1,
          child: ListView(
            primary: true,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    height: Get.height/5,
                    width: Get.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/img/240_F_142999858_7EZ3JksoU3f4zly0MuY3uqoxhKdUwN5u.jpeg")),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    margin: EdgeInsets.only(bottom: 50),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "\nCréer un compte".tr,
                        style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    decoration: Ui.getBoxDecoration(
                      radius: 20,
                      border: Border.all(width: 5, color: Get.theme.primaryColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image.asset(
                        'assets/img/photo_2022-11-25_01-12-07.jpg',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                 return Container(
                   padding: EdgeInsets.symmetric(horizontal: 10),
                   child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFieldWidget(
                          labelText: "Nom".tr,
                          hintText: "John Doe".tr,
                          readOnly: false,
                          initialValue: controller.name.value,
                          onSaved: (input) => controller.name.value = input,
                          onChanged: (input) => controller.name.value = input ,
                          validator: (input) => input.length < 3 ? "Should be more than 3 characters".tr : null,
                          iconData: Icons.person_outline,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                          margin: EdgeInsets.only(left: 5, right: 5, bottom: 10 ),
                          decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                              ],
                              border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                          child: IntlPhoneField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              hintText: '032655333333',
                              label: Text("Contact"),
                              suffixIcon: Icon(Icons.phone_android_outlined),
                            ),
                            style: TextStyle( color: Colors.black),
                            initialCountryCode: 'BE',
                            onChanged: (phone) {
                              String phoneNumber = phone.completeNumber;
                              controller.phone.value = phoneNumber;
                            },
                          ),
                        ),
                        TextFieldWidget(
                          labelText: "Adresse mail".tr,
                          hintText: "johndoe@gmail.com".tr,
                          readOnly: false,
                          initialValue: controller.email.value,
                          onChanged: (value) => controller.email.value = value,
                          onSaved: (input) => controller.email.value = input,
                          validator: (input) => !input.contains('@') ? "Should be a valid email".tr : null,
                          iconData: Icons.alternate_email,
                        ),

                        Obx(() {
                          return TextFieldWidget(
                            onChanged: (newValue){
                              controller.password.value = newValue;
                            },
                            labelText: "Password".tr,
                            hintText: "••••••••••••".tr,
                            readOnly: false,
                            initialValue: controller.password.value,
                            onSaved: (input) => controller.password.value = input,
                            validator: (input) => input.length < 3 ? "Should be more than 3 characters".tr : null,
                            obscureText: controller.hidePassword.value,
                            iconData: Icons.lock_outline,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.hidePassword.value = !controller.hidePassword.value;
                              },
                              color: Theme.of(context).focusColor,
                              icon: Icon(controller.hidePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          );
                        }),

                        Obx(() {
                          return TextFieldWidget(
                            onChanged: (newValue){
                              if(newValue!=controller.password.value){

                                controller.confirmPassword.value = 'password not matching';
                              }
                              else{
                                controller.confirmPassword.value = controller.password.value;
                              }
                            },
                            labelText: "Confirm Password".tr,
                            errorText: controller.confirmPassword.value == 'password not matching'?'password not matching':null,
                            hintText: "••••••••••••".tr,
                            readOnly: false,
                            obscureText: controller.hidePassword.value,
                            iconData: Icons.lock_outline,
                            keyboardType: TextInputType.visiblePassword,
                            isLast: true,
                            isFirst: false,
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.hidePassword.value = !controller.hidePassword.value;
                              },
                              color: Theme.of(context).focusColor,
                              icon: Icon(controller.hidePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          );
                        }),
                      ],
                    ),
                 );
                }
              )
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.vertical,
              children: [
                SizedBox(
                  width: Get.width,
                  child: BlockButtonWidget(
                    onPressed: () async{

                      if(Domain.riKey1.currentState.validate()){
                        if(controller.password.value == controller.confirmPassword.value)
                        {
                          await controller.register();
                        }
                      }

                    },
                    text: !controller.loading.value?Text(
                      "SOUMETRE".tr,
                      style: Get.textTheme.headline6.merge(TextStyle(color: Get.theme.primaryColor)),
                    ): SizedBox(height: 20,
                        child: SpinKitFadingCircle(color: Colors.white, size: 30)), loginPage: false,
                  ).paddingOnly(top: 15, bottom: 5, right: 20, left: 20),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Vous avez déjà un compte?".tr),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.LOGIN);
                      },
                      child: Text("connexion",style: TextStyle(fontFamily: "poppins",fontSize: 15, color: Colors.blueAccent)),
                    ),

                  ],).paddingOnly(bottom: 10)


              ],
            ),
          ],
        ),)

      ),
    );
  }
}
