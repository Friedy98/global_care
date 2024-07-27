/*
 * Copyright (c) 2020 .
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../color_constants.dart';
import '../../global_widgets/text_field_widget.dart';

class AccountLinkWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String label;
  final bool edit;
  final Function onChange;

  const AccountLinkWidget({
    Key key,
    this.icon,
    this.text,
    this.label,
    @required this.edit,
    @required this.onChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: !edit ?
        Row(
          children: [
            Icon(icon, color: appColor),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              width: 1,
              height: 24,
              color: Get.theme.focusColor.withOpacity(0.3),
            ),
            SizedBox(
              width: Get.width/1.5,
              child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(text: text, style: Get.textTheme.headline1.merge(TextStyle(fontSize: 12, color: appColor))),
                      TextSpan(text: "\n$label",
                          style: Get.textTheme.headline2.merge(TextStyle(color: Colors.black, fontSize: 14))
                      )
                    ]
                  )
              )
            )
          ]
        ) :
        TextFieldWidget(
          labelText: text,
          isFirst: false,
          isLast: false,
          hintText: "John Doe",
          readOnly: false,
          initialValue: label,
          //onSaved: (input) => controller.currentUser.value.password = input,
          onChanged: onChange,
          validator: (input) => input.length < 3 ? "Should be more than 3 characters" : null,
          iconData: icon,
          keyboardType: TextInputType.text,
        )
      ),
    );
  }
}

class AccountWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String label;
  final Color labelColor;
  final Color textColor;

  const AccountWidget({
    Key key,
    this.icon,
    this.text,
    this.label,
    @required this.labelColor,
    @required this.textColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Icon( icon,color: buttonColor, size: 18),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: 1,
            height: 24,
            color: Get.theme.focusColor.withOpacity(0.3),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor))
          ),
          Text(label, style: TextStyle(color: labelColor))
        ],
      ),
    );
  }
}

