import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../responsive.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: ListView(
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
                      ]
                  ),
                  margin: EdgeInsets.only(bottom: 50),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "\nMot de pass oublié".tr,
                      style: Get.textTheme.headline2.merge(TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  decoration: Ui.getBoxDecoration(
                    radius: 14,
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
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFieldWidget(
                        labelText: "Address mail".tr,
                        readOnly: false,
                        hintText: "johndoe@gmail.com".tr,
                        initialValue: controller.email.value,
                        onChanged: (value)=> controller.email.value = value,
                        onSaved: (input) => controller.phone.value = input,
                        validator: (input) => !GetUtils.isEmail(input) ? "Should be a valid email".tr : null,
                        iconData: Icons.alternate_email,
                      ),
                      Obx(() => BlockButtonWidget(
                        onPressed: ()async=> {
                          if(controller.email.value.isNotEmpty){
                            controller.onClick.value = true,
                            await controller.resetPassword(controller.email.value),
                          }

                        },
                        text: !controller.onClick.value? Text(
                          "Envoyer",
                          style: Get.textTheme.headline6.merge(TextStyle(color: Get.theme.primaryColor)),
                        ): SizedBox(height: 30,
                            child: SpinKitFadingCircle(color: Colors.white, size: 20)),
                        loginPage: true,
                        color: controller.email.value.isNotEmpty ?
                        Responsive.isTablet(context) ? employeeInterfaceColor : interfaceColor : Responsive.isTablet(context) ? employeeInterfaceColor.withOpacity(0.3) : interfaceColor.withOpacity(0.3),
                      ).paddingSymmetric(vertical: 35, horizontal: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("You don't have an account?".tr, style: TextStyle(color: Colors.black)),
                          TextButton(
                            onPressed: () {
                              Get.offAllNamed(Routes.REGISTER);
                            },
                            child: Text("Register".tr, style: TextStyle(color: interfaceColor)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("You remember your password!".tr, style: TextStyle(color: Colors.black)),
                          TextButton(
                            onPressed: () {
                              Get.offAllNamed(Routes.LOGIN);
                            },
                            child: Text("Login".tr, style: TextStyle(color: interfaceColor)),
                          ),
                        ],
                      ),
                    ],
                  );
                })
            ),
          ],
        )
    );
  }
}