import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../color_constants.dart';
import '../../../responsive.dart';

class BlockButtonWidget extends StatelessWidget {
  const BlockButtonWidget({Key key,@required this.text, @required this.loginPage, this.color, @required this.onPressed}) : super(key: key);

  final Widget text;
  final bool loginPage;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      /*decoration: this.onPressed != null
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(color: this.color.withOpacity(0.3), blurRadius: 40, offset: Offset(0, 15)),
                BoxShadow(color: this.color.withOpacity(0.2), blurRadius: 13, offset: Offset(0, 3))
              ],
              // borderRadius: BorderRadius.all(Radius.circular(20)),
            )
          : null,*/
      child: MaterialButton(
        onPressed: this.onPressed,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        color: !loginPage ? Responsive.isTablet(context) ? employeeInterfaceColor : interfaceColor : color,
        disabledElevation: 0,
        disabledColor: Get.theme.focusColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: this.text,
        elevation: 0,
      ),
    );
  }
}
