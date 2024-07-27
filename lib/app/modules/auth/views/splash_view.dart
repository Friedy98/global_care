
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';

class SplashView extends GetView<AuthController>{

  @override
  Widget build(BuildContext context) {

    return AnimatedSplashScreen.withScreenFunction(
      splash: Image.asset("assets/img/photo_2022-11-25_01-12-07.jpg"),
      duration: 5000,
      splashIconSize: double.infinity,
      screenFunction: () async{
        return LoginView();
      },
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
      //pageTransitionType: PageTransitionType.scale,
    );
  }
}