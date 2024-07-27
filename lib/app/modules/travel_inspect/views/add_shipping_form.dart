import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../color_constants.dart';
import '../../../../common/animation_controllers/animation.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../../responsive.dart';
import '../../account/widgets/account_link_widget.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../userBookings/widgets/bookings_list_loader_widget.dart';
import '../controllers/travel_inspect_controller.dart';

class AddShippingView extends GetView<TravelInspectController> {

  List bookings = [];

  @override
  Widget build(BuildContext context) {

    Get.lazyPut(() => AuthController());

    return Scaffold(
      //Get.theme.colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Obx(() =>
              Text(
                controller.editAppointment.value ?
                "Transfert de " +controller.appointmentDto['name'] :
                "Prendre rendez-vous",
                style: Get.textTheme.headline6.merge(TextStyle(color: Colors.white)),
              )
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => {Navigator.pop(context)},
          ),
        ),
        bottomSheet: Obx(() =>
        controller.showButton.value ?
        Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            height: 90,
            child: Row(
              children: [
                SizedBox(width: 10),
                IconButton(
                  onPressed: ()=> {
                    controller.showButton.value = false,
                    controller.formStep.value--
                  },
                  icon: Icon(Icons.arrow_circle_left, color: Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor, size: 35),
                ),
                Spacer(),
                BlockButtonWidget(
                  onPressed: ()=>{

                    if(!controller.buttonPressed.value){
                      if(controller.editAppointment.value){

                        controller.buttonPressed.value = !controller.buttonPressed.value,
                        controller.requestAppointment()

                      }else{
                        controller.buttonPressed.value = !controller.buttonPressed.value,
                        controller.requestAppointment()
                      }
                    }
                  },
                  text: !controller.buttonPressed.value ? SizedBox(
                      width: Get.width/2,
                      height: 40,
                      child: Text(
                        controller.editAppointment.value ? "TRANSFERER" : "SOUMETRE",
                        textAlign: TextAlign.center,
                        style: Get.textTheme.headline5.merge(TextStyle(color: Get.theme.primaryColor)),
                      )
                  ) : SizedBox(height: 20,
                      child: SpinKitFadingCircle(color: Colors.white, size: 20)), loginPage: false,
                ).paddingSymmetric(vertical: 10, horizontal: 20)
              ],
            )
        ) : SizedBox()
        ),

        body: Obx(() => Theme(
            data: ThemeData(
              //canvasColor: Colors.yellow,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: interfaceColor,
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
        )
    );
  }


  Widget buildLoader() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Image.asset(
        'assets/img/loading.gif',
        fit: BoxFit.cover,
        width: 200,
        height: 100,
      ),
    );
  }

  CupertinoStepper _buildStepper(StepperType type) {
    final canCancel = controller.formStep.value > 0;
    final canContinue = controller.editAppointment.value ? controller.formStep.value < 2 : controller.formStep.value < 4;
    return CupertinoStepper(
        type: type,
        currentStep: controller.formStep.value,
        onStepTapped: (step) {
          print(controller.categories.length);
          Get.showSnackbar(Ui.InfoSnackBar(message: "You are currently at step $step"));
        },
        controlsBuilder: (context, controls){
          return Obx(() =>
          !controller.showButton.value ?
              Row(
                children: [
                  if(controller.formStep.value != 0)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor),
                      onPressed: controls.onStepCancel,
                      child: Text('Retour'),
                    ),
                  Spacer(),
                  if(!controller.showButton.value)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor),
                      onPressed: controls.onStepContinue,
                      child:  Text('Continuer'),
                    ),
                ],
              ) : SizedBox()
          );
        },
        onStepCancel: canCancel ? () => {
          controller.showButton.value = false,
          controller.formStep.value--
        } : null,
        onStepContinue: canContinue ? !controller.editAppointment.value ? (){

          if(!controller.showButton.value){
            if(controller.formStep.value == 0){
              if(controller.categorySelected.isNotEmpty){
                controller.
                getCategoryHairStyle(controller.categoryDto['service_ids']);
                controller.formStep.value++;
                controller.getCategoryBarber(controller.categoryDto['resource_ids']);
              }else{
                Get.showSnackbar(Ui.InfoSnackBar(message: "Vous devez sélectonner une catégory avant de continuer"));
              };

            }else{
              if(controller.formStep.value == 1){

                if(controller.serviceSelected.isNotEmpty){
                  controller.formStep.value++;
                }else{
                  Get.showSnackbar(Ui.InfoSnackBar(message: "Vous devez sélectonner une coiffure avant de continuer"));
                };

              }else{
                if(controller.formStep.value == 2){

                  if(controller.employeeSelected.isNotEmpty){
                    if(controller.daySelected.value != 0){
                      controller.formStep.value++;
                    }else{
                      Get.showSnackbar(Ui.warningSnackBar(message: "Bien-vouloir choisir une date de rendez-vous"));
                    }

                  }else{
                    Get.showSnackbar(Ui.InfoSnackBar(message: "Vous devez sélectonner un coiffeur avant de continuer"));
                  };

                }else{
                  if(controller.formStep.value == 3){
                    if(controller.selectedTime.isNotEmpty){
                      controller.formStep.value++;
                      controller.showButton.value = true;
                    }else{
                      Get.showSnackbar(Ui.InfoSnackBar(message: "Bien-vouloir choisir une heure pour votre rendez-vous"));
                    };
                  }
                }
              }
            }
          }else{
            showDialog(
                context: Get.context,
                builder: (_){
                  return SpinKitFadingCircle(color: Colors.white, size: 50);
                });
          }
        } : (){
          if(!controller.showButton.value){
            if(controller.formStep.value == 1){
              if(controller.selectedTime.isNotEmpty){
                controller.formStep.value++;
                controller.showButton.value = true;
              }else{
                Get.showSnackbar(Ui.InfoSnackBar(message: "Bien-vouloir choisir une heure pour votre rendez-vous"));
              };
            }
          }
        } : (){},

        steps: [
          if(controller.editAppointment.value)...[
            for (var i = 0; i < 2; ++i)
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
          ]else...[
            for (var i = 0; i < 4; ++i)
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
      content: Obx(() =>
        controller.editAppointment.value ?
        LimitedBox(
            maxWidth: Get.width -20,
            maxHeight: Get.height/1.5,

            child: controller.formStep.value == 0 ? build_barberSelection(Get.context)
                : controller.formStep.value == 1 ? buildAppointmentTime(Get.context)
                : build_overView(Get.context)
        ) :
        LimitedBox(
            maxWidth: Get.width -20,
            maxHeight: Get.height/1.5,

            child: controller.formStep.value == 0 ? build_Category(Get.context)
                : controller.formStep.value == 1 ? build_hairStyle(Get.context)
                : controller.formStep.value == 2 ? build_barberSelection(Get.context)
                : controller.formStep.value == 3 ? buildAppointmentTime(Get.context)
                : build_overView(Get.context)
        )
      )
    );
  }

  Widget build_Category(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Choix de Category",
          style: TextStyle(
              fontSize: 14.0,
              color: Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Obx(() => controller.loadCategories.value ?
          BookingsListLoaderWidget() :
          ListView.builder(
              itemCount: controller.categories.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return DelayedAnimation(
                  delay: index == 0 ? 30 : 30*index,
                  child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        var list = [];
                        controller.categoryId.value = controller.categories[index]["id"];
                        if(controller.categorySelected.contains(controller.categories[index]['id'])){
                          controller.categorySelected.clear();
                        }else{
                          list.add(controller.categories[index]["id"]);
                          controller.categorySelected.value = list;
                          controller.categoryDto.value = controller.categories[index];
                          print(controller.categorySelected);
                        }
                        //widget.animationController.animateTo(0.2);

                      },
                      child: Obx(() =>
                          Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                  color: controller.categorySelected.contains(controller.categories[index]['id']) ? null : background,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  border: controller.categorySelected.contains(controller.categories[index]['id']) ? Border.all(width: 3, color: primaryColor) : null
                              ),
                              width: Get.width,
                              height: Responsive.isTablet(context) ? 200 : 100,
                              child: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: FadeInImage(
                                      width: Get.width/3,
                                      height: Responsive.isTablet(context) ? 200 : 100,
                                      fit: BoxFit.cover,
                                      image: NetworkImage('${Domain.serverPort}/image/business.resource.type/${controller.categories[index]["id"]}/image_1920?unique=true&file_response=true',
                                          headers: Domain.getTokenHeaders()),
                                      placeholder: AssetImage(
                                          "assets/img/loading.gif"),
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                            'assets/img/240_F_142999858_7EZ3JksoU3f4zly0MuY3uqoxhKdUwN5u.jpeg',
                                            width: Get.width/3,
                                            height: Responsive.isTablet(context) ? 200 : 100,
                                            fit: BoxFit.fitWidth);
                                      },
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(
                                        left: 16,
                                        top: 8,
                                        bottom: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(
                                            controller.categories[index]
                                            ["name"],
                                            textAlign:
                                            TextAlign.left,
                                            style: Get.textTheme.headline2
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          )
                      )
                  ),
                );
              })),
        ),
      ],
    );
  }

  Widget build_hairStyle(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Choix de Coiffure",
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Obx(() => controller.loadServices.value ?

          BookingsListLoaderWidget() :

              GridView(
            padding: const EdgeInsets.only(top: 0, left: 12, right: 12),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: List<Widget>.generate(
              controller.services.length,
                  (int index) {

                return DelayedAnimation(
                  delay: index == 0 ? 30 : 30 * index,
                  child: Obx(() => InkWell(
                    onTap: (){
                      var list = [];
                      controller.serviceId.value = controller.services[index]["id"];
                      if(controller.serviceSelected.contains(controller.services[index]['id'])){
                        controller.serviceSelected.clear();
                      }else{
                        list.add(controller.services[index]["id"]);
                        controller.serviceSelected.value = list;
                        controller.serviceDto.value = controller.services[index];
                        print(controller.serviceSelected);
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(15),
                          color: controller.serviceSelected.contains(controller.services[index]['id'])
                              ? background : Palette.background,
                          border: controller.serviceSelected.contains(controller.services[index]['id'])
                              ? Border.all(width: 2, color: Colors.blueAccent) : null
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              child: FadeInImage(
                                width: Get.width/3,
                                height: Responsive.isTablet(context) ? 240 : 150,
                                fit: BoxFit.cover,
                                image: NetworkImage('${Domain.serverPort}/image/appointment.product/${controller.services[index]["id"]}/image_1920?unique=true&file_response=true',
                                    headers: Domain.getTokenHeaders()),
                                placeholder: AssetImage(
                                    "assets/img/loading.gif"),
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/img/240_F_142999858_7EZ3JksoU3f4zly0MuY3uqoxhKdUwN5u.jpeg',
                                      width: Get.width/3,
                                      height: Responsive.isTablet(context) ? 240 : 150,
                                      fit: BoxFit.fitWidth);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(controller.services[index]
                            ["name"].split(">").first, style: Get.textTheme.headline4),
                            Text(controller.services[index]
                            ["product_price"].toString()+" €", style: Get.textTheme.headline2),
                            SizedBox(height: 10)
                          ]
                        )
                    )
                  ))
                );
              },
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: Responsive.isTablet(context) ? 330.0 : 220.0,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.5,
            ),
          )),
        ),
      ],
    );
  }

  Widget build_barberSelection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Choix du Coiffeur",
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
            height: Responsive.isTablet(context) ? 300 : 200,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() =>
                  controller.loadEmployees.value ?
                      ListView.builder(
                        itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index){
                          return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: buildLoader());
                          }
                      ) :
                      ListView.builder(
                          itemCount: controller.employees.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () async {
                                  var list = [];
                                  controller.employeeId.value = controller.employees[index]["id"];
                                  if(controller.employeeSelected.contains(controller.employees[index]['id'])){
                                    controller.employeeSelected.clear();
                                  }else{
                                    controller.getCalendar(controller.employees[index]['info_resource_calendar_id'][0]);
                                    controller.getAppointments(controller.employees[index]['appointment_ids']);
                                    list.add(controller.employees[index]["id"]);
                                    controller.employeeSelected.value = list;
                                    controller.employeeDto.value = controller.employees[index];
                                    print(controller.employeeSelected);
                                  }

                                },
                                child: Obx(() => Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(15),
                                        color: Palette.background,
                                        border: controller.employeeSelected.contains(controller.employees[index]['id'])
                                            ? Border.all(
                                            width: 3,
                                            color: primaryColor)
                                            : null
                                    ),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                          child: FadeInImage(
                                            width: Get.width/4,
                                            height: Responsive.isTablet(context) ? 200 : 110,
                                            fit: BoxFit.cover,
                                            image: NetworkImage('${Domain.serverPort}/image/hr.employee/${controller.employees[index]["employee_id"][0]}/image_1920?unique=true&file_response=true',
                                                headers: Domain.getTokenHeaders()),
                                            placeholder: AssetImage(
                                                "assets/img/loading.gif"),
                                            imageErrorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                  'assets/img/téléchargement (3).png',
                                                  width: Get.width/4,
                                                  height: Responsive.isTablet(context) ? 200 : 110,
                                                  fit: BoxFit.fitWidth);
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Text(controller.employees[index]['display_name'], style: Get.textTheme.headline4)
                                      ],
                                    )
                                ))
                            );
                          })
                  ),
                ),
              ],
            )
        ),
        SizedBox(height: 10),
        Obx(() => Container(
          height: Get.height / 2.7,
          //margin: EdgeInsets.all(10),
          color: controller.employeeSelected.isNotEmpty ? backgroundColor : null,
          child: controller.employeeSelected.isNotEmpty
              ? CalendarCarousel<Event>(
                onDayPressed:
                    (DateTime date, List<Event> events) {
                  var list = [];
                  if (controller.workingDays.contains(date.weekday)) {
                    controller.daySelected.value = date.weekday;
                    var index = controller.daySelected.value - 1;
                    for(var i=0; i<controller.workingDaysDto.length; i++){
                      if(controller.workingDaysDto[i]['dayofweek'] == index.toString()){
                        list.add("${controller.workingDaysDto[i]['hour_from']}-${controller.workingDaysDto[i]['hour_to']}");
                      }
                    }
                    controller.rangeHours.value = list;
                    controller.getTimeIntervals(list);
                    controller.appointmentDate.value = date.toString();
                    controller.checkAvailability(DateFormat("dd/MM/yyyy").format(date).toString());
                    controller.formStep.value++;
                  } else {
                    print("unavailable");
                  }
                },
                weekendTextStyle: TextStyle(
                  color: Colors.red,
                ),
                thisMonthDayBorderColor: Colors.grey,
                minSelectedDate: DateTime.now()
                    .subtract(const Duration(days: 0)),
                customDayBuilder: (
                    bool isSelectable,
                    int index,
                    bool isSelectedDay,
                    bool isToday,
                    bool isPrevMonthDay,
                    TextStyle textStyle,
                    bool isNextMonthDay,
                    bool isThisMonthDay,
                    DateTime day,
                    ) {
                  return Obx((){
                    var date = DateFormat("d/MM/yyyy").format(day);
                    if (controller.holidays.contains(date)) {
                      return Icon(Icons.event_busy);
                    }
                    if (!controller.workingDays.contains(day.weekday)) {
                      return Container(
                        color: Colors.grey.withOpacity(0.2),
                      );
                    } else {
                      return Center(
                        child: Text(DateFormat("dd").format(day).toString(),
                            style: TextStyle(color: day.compareTo(DateTime.now()) < 0 ? inactive : interfaceColor)
                        )
                      );
                    }
                  });
                },
                weekFormat: false,
                //markedDatesMap: _markedDateMap,
                height: Get.height / 2.7,
                selectedDateTime: DateTime.now(),
                daysHaveCircularBorder: false,
              )
              : Center(
              child: Text('Choisir un employé',
                  style: TextStyle(
                      color: inactive, fontSize: 14))),
        )
        ),
      ],
    );
  }

  Widget buildAppointmentTime(BuildContext context){

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Choix de l'heure",
          style: TextStyle(
            color: Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor,
              fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView(
            padding: const EdgeInsets.only(top: 0, left: 12, right: 12),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: List<Widget>.generate(
              controller.appointTime.length,
                  (int index) {
                    var condition = controller.availability.contains(controller.getTimeStringFromDouble(controller.appointTime[index]));
                    if(controller.editAppointment.value){
                      controller.appointmentEnd.value = controller.getTimeStringFromDouble(
                          controller.appointTime[index] * controller.appointmentDto['duration']*60*60);
                    }else{
                      controller.appointmentEnd.value = controller.getTimeStringFromDouble(
                          controller.appointTime[index] * controller.serviceDto['appointment_duration']*60*60);
                    }

                return DelayedAnimation(
                    delay: index == 0 ? 30 : 30 * index,
                    child: Obx(() =>
                        InkWell(
                            onTap: (){

                              if(!condition){
                                controller.timeDto.value = controller.getTimeStringFromDouble(controller.appointTime[index]);
                                var list = [];
                                if(controller.selectedTime.contains(controller.timeDto.value)){
                                  controller.selectedTime.clear();
                                }else{

                                  list.add(controller.timeDto.value);
                                  controller.selectedTime.value = list;
                                  int duration = (controller.serviceDto['appointment_duration'] * 60).toInt();
                                  var endTime = DateTime.parse("2000-09-20 ${controller.selectedTime.join(",")}:00").add(Duration(minutes: duration));
                                  controller.appointmentEnd.value = DateFormat("HH:mm").format(endTime).toString();
                                  controller.timeDto.value = controller.getTimeStringFromDouble(controller.appointTime[index]);
                                  //controller.formStep.value++;
                                }
                                print(controller.timeDto.value);
                              }
                            },
                            child: Container(
                                padding: EdgeInsets.all(10),
                                height: 30,
                                decoration: BoxDecoration(
                                    color: !condition ? controller.selectedTime.contains(controller.getTimeStringFromDouble(controller.appointTime[index]))
                                        ? Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor : appBarColor : inactive,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)
                                    )
                                ),
                                child: Center(
                                    child: Text(controller.getTimeStringFromDouble(controller.appointTime[index]),
                                        style: TextStyle(
                                            color: condition ? Palette.background : controller.selectedTime.contains(controller.getTimeStringFromDouble(controller.appointTime[index])) ?
                                            Colors.white : Colors.greenAccent,
                                            fontSize: 17, letterSpacing: 2)
                                    )
                                )
                            )
                        )
                    )
                );
              },
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 40.0,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget build_overView(BuildContext context){

    double size = Responsive.isTablet(context) ? 25 : 18;
    double priceSize = Responsive.isTablet(context) ? 30 : 22;

    return SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.start,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              controller.editAppointment.value ?
                  "Transfert de " +controller.appointmentDto['name'] :
              "Info De Réservation",
              style: TextStyle(
                  fontSize: priceSize, fontWeight: FontWeight.bold,
                  color: appColor),
            ),
            Divider(
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            AccountWidget(
              icon: Icons.calendar_month_rounded,
              text: "DATE:",
              label: DateFormat("yyyy-MM-dd").format(DateTime.parse(controller.appointmentDate.value)).toString(),
              labelColor: Colors.black,
              textColor: appColor,
            ),
            AccountWidget(
                icon: Icons.date_range_rounded,
                text: "TEMPS:",
                label: "${controller.timeDto.value} - ${controller.appointmentEnd.value}",
                labelColor: Colors.black,
                textColor: appColor,
            ),
            AccountWidget(
                icon: Icons.person,
                text: "AGENT:",
                label: controller.employeeDto['employee_id'][1],
                labelColor: Colors.black,
                textColor: appColor,
            ),
            AccountWidget(
              icon: Icons.cleaning_services,
              text: "SERVICE:",
              label: !controller.editAppointment.value ? controller.serviceDto['name'].split(">").first : controller.appointmentDto['service_id'][1].split(">").first,
              labelColor: Colors.black,
              textColor: appColor,
            ),
            if(!controller.editAppointment.value)
            AccountWidget(
              icon: Icons.timer,
              text: "DUREE:",
              label: "${controller.serviceDuration.value}minutes",
              labelColor: Colors.black,
              textColor: appColor,
            ),
            SizedBox(height: 20),
            if(!controller.editAppointment.value)
            Row(
              children: [
                Text(
                  "Prix total:",
                  style: TextStyle(
                      fontSize: priceSize,
                      color: appColor,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text("${controller.serviceDto['product_price']} €",
                  style: TextStyle(
                      fontSize: priceSize,
                      fontWeight: FontWeight.bold,
                      color: Get.find<AuthController>().isEmployee.value ? employeeInterfaceColor : interfaceColor
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height/4),
          ],
        ),
    );
  }
}
