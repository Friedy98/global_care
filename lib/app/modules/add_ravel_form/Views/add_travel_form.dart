
import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../account/widgets/account_link_widget.dart';
import '../../global_widgets/block_button_widget.dart';
import '../controller/add_travel_controller.dart';

class AddTravelsView extends GetView<AddTravelController> {

  List bookings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Get.theme.colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: background,
          title:  Text(
            "New Travel Form".tr,
            style: Get.textTheme.headline6.merge(TextStyle(color: appColor)),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: appColor),
            onPressed: () => {Navigator.pop(context)},
          ),
        ),
      body: Obx(() => Theme(
          data: ThemeData(
            //canvasColor: Colors.yellow,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: controller.formStep.value != 3 ? Get.theme.colorScheme.secondary : validateColor,
                background: Colors.red,
                secondary: validateColor,
              )
          ),
          child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(
                  height: MediaQuery.of(context).size.height
              ),
              child: _buildStepper(StepperType.horizontal)
          )),
        /*OrientationBuilder(
              builder: (BuildContext context, Orientation orientation){
                switch (orientation) {
                  case Orientation.portrait:
                    return _buildStepper(StepperType.vertical);
                  case Orientation.landscape:
                    return _buildStepper(StepperType.horizontal);
                  default:
                    throw UnimplementedError(orientation.toString());
                }
              }
          )*/
      )
    );
  }

  Widget stepOne(BuildContext context){
    return Form(
        key: controller.newTravelKey,
        child: ListView(
          primary: true,
          //padding: EdgeInsets.all(10),
          children: [
            InkWell(
                onTap: ()=> controller.chooseDepartureDate(),
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Departure Date".tr,
                        style: Get.textTheme.bodyText1,
                        textAlign: TextAlign.start,
                      ),
                      Obx(() =>
                          ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text(controller.departureDate.value,
                                style: Get.textTheme.headline1.merge(TextStyle(color: Colors.black, fontSize: 16)),
                              )
                          )
                      )
                    ],
                  ),
                )
            ),
            InkWell(
                onTap: ()=>{ controller.chooseArrivalDate() },
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Arrival Date".tr,
                        style: Get.textTheme.bodyText1,
                        textAlign: TextAlign.start,
                      ),
                      Obx(() =>
                          ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text(controller.arrivalDate.value,
                                style: Get.textTheme.headline1.merge(TextStyle(color: Colors.black, fontSize: 16)),
                              )
                          ))
                    ],
                  ),
                )
            ),
            Obx(() => Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
              decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                  ],
                  border: Border.all(color: controller.errorCity1.value ? specialColor : Get.theme.focusColor.withOpacity(0.05))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Departure Town",
                      style: Get.textTheme.bodyText1,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 10),
                    Row(
                        children: [
                          Icon(Icons.location_pin),
                          SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2,
                            child: TextFormField(
                              controller: controller.depTown,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding:
                                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              ),
                              //initialValue: controller.travelCard.isEmpty || controller.townEdit.value ? controller.departureTown.value : controller.travelCard['departure_town'],
                              style: Get.textTheme.headline1.merge(TextStyle(color: Colors.black, fontSize: 16)),
                              onChanged: (value)=>{
                                if(value.isNotEmpty){
                                controller.errorCity1.value = false
                                },
                                if(value.length > 2){
                                  controller.predict1.value = true,
                                  controller.filterSearchResults(value)
                                }else{
                                  controller.predict1.value = false,
                                }
                              },
                              cursorColor: Get.theme.focusColor,
                            ),
                          ),
                        ]
                    )
                  ]
              ),
            )),
            if(controller.predict1.value)
            Obx(() => Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                color: Get.theme.primaryColor,
                height: 200,
                child: ListView(
                    children: [
                      for(var i =0; i < controller.countries.length; i++)...[
                        TextButton(
                            onPressed: (){
                              controller.depTown.text = controller.countries[i]['display_name'];
                              controller.predict1.value = false;
                              controller.departureId.value = controller.countries[i]['id'];
                            },
                            child: Text(controller.countries[i]['display_name'], style: TextStyle(color: appColor))
                        )
                      ]
                    ]
                )
            )),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
              decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                  ],
                  border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Arrival Town",
                      style: Get.textTheme.bodyText1,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 10),
                    Row(
                        children: [
                          Icon(Icons.location_pin),
                          SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2,
                            child: TextFormField(
                              controller: controller.arrTown,
                              readOnly: controller.departureId.value != 0 ? false : true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding:
                                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              ),
                              onTap: (){
                                if(controller.departureId.value == 0){
                                  controller.errorCity1.value = true;
                                  Get.showSnackbar(Ui.warningSnackBar(message: "Please, first select a departure city!!! ".tr));
                                }
                              },
                              //initialValue: controller.travelCard.isEmpty || controller.townEdit.value ? controller.departureTown.value : controller.travelCard['departure_town'],
                              style: Get.textTheme.headline1.merge(TextStyle(color: Colors.black, fontSize: 16)),
                              onChanged: (value)=>{
                                if(value.length > 2){
                                  controller.predict2.value = true,
                                  controller.filterSearchResults(value)
                                }else{
                                  controller.predict2.value = false,
                                }
                              },
                              cursorColor: Get.theme.focusColor,
                            ),
                          ),
                        ]
                    )
                  ]
              ),
            ),
            if(controller.predict2.value)
              Obx(() => Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                  color: Get.theme.primaryColor,
                  height: 200,
                  child: ListView(

                      children: [
                        for(var i =0; i < controller.countries.length; i++)...[
                          TextButton(
                              onPressed: (){
                                controller.arrTown.text = controller.countries[i]['display_name'];
                                controller.predict2.value = false;
                                controller.arrivalId.value = controller.countries[i]['id'];
                              },
                              child: Text(controller.countries[i]['display_name'], style: TextStyle(color: appColor))
                          )
                        ]
                      ]
                  )
              )),
          ]
        )
    );
  }

  Widget stepTwo(BuildContext context){
    return Form(
        key: controller.newTravelKey,
        child: Obx(() => ListView(
          primary: true,
          //padding: EdgeInsets.all(10),
          children: [
            Text("Select travel Type".tr,
              style: Get.textTheme.headline6.merge(TextStyle(color: buttonColor)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: ()=>{
                controller.travelType.value = 'road'
              },
              child: Container(
                  height: 130,
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      image: DecorationImage(
                          image: AssetImage("assets/img/photo_2023-08-25_10-14-00.jpg"), fit: BoxFit.contain),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      border: controller.travelType.value == 'road' ? Border.all(color: interfaceColor, width: 2) : null),
                  child: Text('Road',style: TextStyle(fontSize: 20))
              )
            ),
            InkWell(
              onTap: ()=>{
                controller.travelType.value = 'air'
              },
              child: Container(
                  height: 130,
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      image: DecorationImage(
                          image: AssetImage("assets/img/photo_2023-08-25_10-14-45.jpg"), fit: BoxFit.contain),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      border: controller.travelType.value == 'air' ? Border.all(color: interfaceColor, width: 2) : null),
                  child: Text('Air',style: TextStyle(fontSize: 20))
              ),
            ),
            /*if(controller.travelType.value != "road")...[
              TextFieldWidget(
                initialValue: controller.travelCard.isNotEmpty ? controller.travelCard['kilo_qty'].toString() : "",
                keyboardType: TextInputType.number,
                validator: (input) => input.isEmpty ? "field required!".tr : null,
                onChanged: (input) => controller.quantity.value = double.parse(input),
                labelText: "Quantity".tr,
                iconData: Icons.shopping_cart_rounded,
              ),
              TextFieldWidget(
                //onSaved: (input) => controller.user.value.name = input,
                initialValue: controller.travelCard.isNotEmpty ? controller.travelCard['price_per_kilo'].toString() : "",
                keyboardType: TextInputType.number,
                onChanged: (input) => controller.price.value = double.parse(input),
                validator: (input) => input.isEmpty ? "field required!".tr : null,
                labelText: "Price /kg".tr,
                iconData: Icons.attach_money,
              )
            ]*/
          ],
        ))
    );
  }

  Widget stepThree(BuildContext context){
    return Form(
      key: controller.newTravelKey,
      child: ListView(
        primary: true,
            children: [
                    Align(
                      alignment: Alignment.centerLeft,
                        child: Text("Complete your user profile info".tr, style: Get.textTheme.headline2.merge(TextStyle(color: appColor, fontSize: 15))).paddingSymmetric(horizontal: 22, vertical: 5)).marginOnly(bottom: 20),

                    InkWell(
                        onTap: controller.birthDate.value == '--/--/--'?(){
                          controller.chooseBirthDate();
                          //controller.user.value.birthday = DateFormat('yy/MM/dd').format(controller.birthDate.value);
                          controller.birthDateSet.value = true;
                        }:(){},
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                              ],
                              border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text("Date of birth".tr,
                                style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black)),
                                textAlign: TextAlign.start,
                              ),
                              Obx(() {
                                return ListTile(
                                    leading: FaIcon(
                                        FontAwesomeIcons.birthdayCake, size: 20),
                                    title: Text(controller.birthDate.value.toString(),
                                      style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black)),
                                    ));
                              })
                            ],
                          ),
                        )
                    ),
              controller.user.value.sex =='false'?
              Container(
                  margin: EdgeInsets.only(left: 5, right: 5, top:20),
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                      border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration.collapsed(
                          hintText: ''),
                      onSaved: (input) => controller.selectedGender.value == "Male"?controller.user?.value?.sex = "male":controller.user?.value?.sex = "female",
                      isExpanded: true,
                      alignment: Alignment.bottomCenter,
                      style: Get.textTheme.bodyText1,
                      value: controller.user.value.sex=="male"?controller.selectedGender.value=controller.genderList[0]:controller.selectedGender.value=controller.genderList[1],
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: controller.genderList.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        controller.selectedGender.value = newValue;
                        if(controller.selectedGender.value == "MALE"){
                          controller.user.value.sex = "male";
                        }
                        else{
                          controller.user.value.sex = "female";
                        }

                      },).marginOnly(left: 20, right: 20).paddingOnly( top: 20, bottom: 14),
                  )
              ).paddingOnly(bottom: 14,
              ):
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                    ],
                    border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                child: Obx(() =>
                    ListTile(
                      title: Text('Gender',style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black))),
                      leading: FaIcon(FontAwesomeIcons.venusMars, size: 20),
                      subtitle: Text(controller.user.value.sex=='false'?'not defined':controller.user.value.sex,style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black)),
                      ),
                    )
                ),
              ),
                    Obx(() {
                      return controller.user.value.birthplace=='--'?
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            margin: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                                color: Get.theme.primaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                                ],
                                border: Border.all(color: controller.errorCity1.value ? specialColor : Get.theme.focusColor.withOpacity(0.05))),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text("City of Birth",
                                    style: Get.textTheme.bodyText1,
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                      children: [
                                        Icon(Icons.location_pin),
                                        SizedBox(width: 10),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width/2,
                                          child: TextFormField(
                                            controller: controller.birthPlaceTown,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding:
                                              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                            ),
                                            //initialValue: controller.travelCard.isEmpty || controller.townEdit.value ? controller.departureTown.value : controller.travelCard['departure_town'],
                                            style: Get.textTheme.headline1.merge(TextStyle(color: Colors.black, fontSize: 16)),
                                            onChanged: (value)=>{
                                              if(value.isNotEmpty){
                                                controller.errorCity1Profile.value = false
                                              },
                                              if(value.length > 2){
                                                controller.predict1Profile.value = true,
                                                controller.filterSearchResults(value)
                                              }else{
                                                controller.predict1Profile.value = false,
                                              }
                                            },
                                            cursorColor: Get.theme.focusColor,
                                          ),
                                        ),
                                      ]
                                  )
                                ]
                            ),
                          ),

                        ],
                      )
                          :
                      Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                            margin: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                                color: Get.theme.primaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                                ],
                                border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                            child: Obx(() =>
                                ListTile(
                                  title: Text('Place of birth',style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black))),
                                  leading: FaIcon(FontAwesomeIcons.locationPin, size: 20),
                                  subtitle: Text(controller.user.value.birthplace==null?'':controller.user.value.birthplace,style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black)),
                                  ),
                                )
                            ),
                          );
                      }),
                    if(controller.predict1Profile.value)
                      Obx(() => Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                          color: Get.theme.primaryColor,
                          height: 200,
                          child: ListView(
                              children: [
                                for(var i =0; i < controller.countries.length; i++)...[
                                  TextButton(
                                      onPressed: (){
                                        controller.birthPlaceTown.text = controller.countries[i]['display_name'];
                                        controller.birthPlace.value = controller.birthPlaceTown.text;
                                        controller.predict1Profile.value = false;
                                        controller.birthCityId.value = controller.countries[i]['id'];
                                      },
                                      child: Text(controller.countries[i]['display_name'], style: TextStyle(color: appColor))
                                  )
                                ]
                              ]
                          )
                      )),
                    controller.user.value.street=='--'?
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          margin: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
                          decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                              ],
                              border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("Residential Address",
                                  style: Get.textTheme.bodyText1,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(height: 10),
                                Row(
                                    children: [
                                      Icon(Icons.location_pin),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width/2,
                                        child: TextFormField(
                                          controller: controller.residentialTown,
                                          //readOnly: controller.birthCityId.value != 0 ? false : true,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            contentPadding:
                                            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                                          ),
                                          onTap: (){
                                            if(controller.birthCityId.value == 0){
                                              controller.errorCity1Profile.value = true;
                                              Get.showSnackbar(Ui.warningSnackBar(message: "Please, first select a residential address!! ".tr));
                                            }
                                          },
                                          //initialValue: controller.travelCard.isEmpty || controller.townEdit.value ? controller.departureTown.value : controller.travelCard['departure_town'],
                                          style: Get.textTheme.headline1.merge(TextStyle(color: Colors.black, fontSize: 16)),
                                          onChanged: (value)=>{
                                            if(value.length > 2){
                                              controller.predict2Profile.value = true,
                                              controller.filterSearchResults(value)
                                            }else{
                                              controller.predict2Profile.value = false,
                                            }
                                          },
                                          cursorColor: Get.theme.focusColor,
                                        ),
                                      ),
                                    ]
                                )
                              ]
                          ),
                        ),

                      ],
                    )
                        :
                    Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                              ],
                              border: Border.all(color: Get.theme.focusColor.withOpacity(0.05))),
                          child: Obx(() =>
                              ListTile(
                                title: Text('Residential address',style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black))),
                                leading: FaIcon(FontAwesomeIcons.locationPin, size: 20),
                                subtitle: Text(controller.user.value.street==null?'':controller.user.value.street,style: Get.textTheme.bodyText1.merge(TextStyle(color: Colors.black)),
                                ),

                              )
                          ),
                        ),
                    if(controller.predict2Profile.value)
                      Obx(() => Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          color: Get.theme.primaryColor,
                          height: 200,
                          child: ListView(
                              children: [
                                for(var i =0; i < controller.countries.length; i++)...[
                                  TextButton(
                                      onPressed: (){
                                        controller.residentialTown.text = controller.countries[i]['display_name'];
                                        controller.residence.value = controller.residentialTown.text;
                                        controller.predict2Profile.value = false;
                                        controller.residentialAddressId.value = controller.countries[i]['id'];
                                      },
                                      child: Text(controller.countries[i]['display_name'], style: TextStyle(color: appColor))
                                  )
                                ]
                              ]
                          )
                      )),

              //SizedBox(height: 20),
              /*Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: Ui.getBoxDecoration(),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Change password!", style: Get.textTheme.bodyText2.merge(TextStyle(color: Colors.redAccent))),
                          Text("Fill your old password and type new password and confirm it", style: Get.textTheme.caption.merge(TextStyle(color: Colors.redAccent))),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),

                    MaterialButton(
                      onPressed: () {
                        showDialog(context: context,
                            builder: (_){
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: buildPassword(context)
                              );
                            });
                      },
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Get.theme.colorScheme.secondary,
                      child: Text("Change".tr, style: Get.textTheme.bodyText2.merge(TextStyle(color: Get.theme.primaryColor))),
                      elevation: 0,
                      highlightElevation: 0,
                      hoverElevation: 0,
                      focusElevation: 0,
                    ),

                  ],
                ),
              ),*/

            ],
      ),
    );
  }

  Widget buildLoader() {
    return Container(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 100,
          ),
        ));
  }

  CupertinoStepper _buildStepper(StepperType type) {
    final canCancel = controller.formStep.value > 0;
    final canContinue = controller.formStep.value < 3 ;
    return CupertinoStepper(
      type: type,
      currentStep: controller.formStep.value,
      onStepTapped: (step) {
        if(controller.formStep.value!=2){
          if(controller.depTown.text.isNotEmpty && controller.arrTown.text.isNotEmpty){
            controller.formStep.value = step;
          }else{
            Get.showSnackbar(Ui.warningSnackBar(message: "All fields are required ".tr));
          }

        }
        else{
          if(controller.birthDate.value == '--/--/--' || controller.birthPlace.value=='--' || controller.residence.value =='--' ||controller.user.value.sex=='false'){
            Get.showSnackbar(Ui.warningSnackBar(message: "All fields are required ".tr));
          }
          else
          {
            controller.formStep.value = step;
          }
        }
      },
      onStepCancel: canCancel ? () => controller.formStep.value-- : null,
      onStepContinue: canContinue ? (){
        if(controller.formStep.value!=2){
          if(controller.depTown.text.isNotEmpty && controller.arrTown.text.isNotEmpty){
            controller.formStep.value++;
          }else{
            Get.showSnackbar(Ui.warningSnackBar(message: "All fields are required ".tr));
          }

        }
        else{
          if(controller.birthDate.value == '--/--/--' || controller.birthPlace.value=='--' || controller.residence.value =='--'){
            Get.showSnackbar(Ui.warningSnackBar(message: "All fields are required ".tr));
          }
          else
            {
              controller.formStep.value++;
            }
        }

      } : null,
      steps: [
        for (var i = 0; i < 3; ++i)
          _buildStep(
            title: Text(''),
            isActive: i == controller.formStep.value,
            state: i == controller.formStep.value
                ? StepState.indexed
                : i < controller.formStep.value ? StepState.complete : StepState.indexed,
          ),
        _buildStep(
          title: Icon(Icons.check),
          state: StepState.indexed,
        )
      ]
    );
  }

  Step _buildStep({
    Widget title,
    StepState state = StepState.complete,
    bool isActive = false,
  }) {
    return Step(
      title: title,
      subtitle: Text(''),
      state: state,
      isActive: isActive,
      content: LimitedBox(
        maxWidth: Get.width -20,
        maxHeight: controller.formStep.value != 3 ? 450 : 500,

        child: controller.formStep.value == 0 ? stepOne(Get.context)
        : controller.formStep.value == 1 ? stepTwo(Get.context)
        : stepThree(Get.context)
      )
    );
  }
}
