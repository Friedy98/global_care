import 'package:app/app/modules/global_widgets/pop_up_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../color_constants.dart';
import '../../../main.dart';
import '../../../responsive.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/my_auth_service.dart';
import '../auth/controllers/auth_controller.dart';
import '../custom_pages/views/custom_page_drawer_link_widget.dart';
import '../fidelisation/controller/validation_controller.dart';
import '../home/controllers/home_controller.dart';
import '../root/controllers/root_controller.dart' show RootController;
import '../userBookings/controllers/bookings_controller.dart';
import 'drawer_link_widget.dart';

class MainDrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Get.lazyPut<AuthController>(
          () => AuthController(),
    );
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
    Get.lazyPut(() => ValidationController());
    Get.lazyPut(() => BookingsController());

    var currentUser = Get.find<AuthController>().currentUser;
    return Container(
      padding: EdgeInsets.only(left: 0, right: MediaQuery.of(context).size.width / 1.8),
      child: Drawer(
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Obx(() {
                      return GestureDetector(
                        onTap: () async {
                          await Get.find<RootController>().changePage(3);
                        },
                        child: UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withOpacity(0.1),
                          ),
                          accountName: Text(
                            currentUser['name'],
                            style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: employeeInterfaceColor, fontSize: 15)),
                          ),
                          accountEmail: Text(""
                          ),
                          currentAccountPicture: Stack(
                            children: [
                              if(Get.find<AuthController>().isEmployee.value)
                                ClipOval(
                                    child: FadeInImage(
                                      width: Responsive.isMobile(context) ? 100 : 150,
                                      height: Responsive.isMobile(context) ? 100 : 150,
                                      fit: BoxFit.cover,
                                      image: Domain.googleUser ? NetworkImage(Domain.googleImage) : NetworkImage('${Domain.serverPort}/image/business.resource/${currentUser['id']}/image_1920?unique=true&file_response=true', headers: Domain.getTokenHeaders()),
                                      placeholder: AssetImage(
                                          "assets/img/loading.gif"),
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                            'assets/img/téléchargement (3).png',
                                            width: Responsive.isMobile(context) ? 100 : 150,
                                            height: Responsive.isMobile(context) ? 100 : 150,
                                            fit: BoxFit.fitWidth);
                                      },
                                    )
                                ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Get.find<AuthService>().user.value.verifiedPhone ?? false ? Icon(Icons.check_circle, color: Get.theme.colorScheme.secondary, size: 24) : SizedBox(),
                              )
                            ],
                          ),
                        ),
                      );
                    })
                ),
                IconButton(
                    onPressed: ()=> Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_outlined, size: 30)
                )
              ]
            ),
            SizedBox(height: 40),
            DrawerLinkWidget(
                special: false,
                drawer: false,
                icon: Icons.dashboard,
                text: "Tableau de bord",
                onTap: (e) async{
                  Navigator.pop(context);
                  await Get.find<HomeController>().refreshPage();
                  Get.find<HomeController>().currentPage.value = 0;
                }
            ),
            DrawerLinkWidget(
                special: false,
                drawer: false,
                icon: Icons.note_alt_sharp,
                text: "Rendez-vous",
                onTap: (e) {
                  Navigator.pop(context);
                  Get.find<BookingsController>().refreshEmployeeBookings();
                  //Get.find<BookingsController>().filterAppointmentDates();
                  Get.find<HomeController>().currentPage.value = 1;
                }
            ),
            DrawerLinkWidget(
                special: false,
                drawer: false,
                icon: Icons.receipt_long,
                text: "Factures",
                onTap: (e) {
                  Navigator.pop(context);
                  Get.find<BookingsController>().getReceipts();
                  //Get.find<BookingsController>().filterDates();
                  Get.find<HomeController>().currentPage.value = 2;
                }
            ),
            DrawerLinkWidget(
                special: false,
                drawer: false,
                icon: Icons.settings,
                text: "Interface POS",
                onTap: (e) {
                  Navigator.pop(context);
                  Get.find<BookingsController>().refreshEmployeeBookings();
                  Get.find<HomeController>().currentPage.value = 3;
                }
            ),
            DrawerLinkWidget(
              special: false,
              drawer: false,
              icon: Icons.qr_code,
              text: "Scanner le code",
              onTap: (e) async {
                Navigator.pop(context);
                Get.find<ValidationController>().refreshPage();
                Get.find<HomeController>().currentPage.value = 4;
              },
            ),
            ListTile(
              dense: true,
              title: Text(
                "Help & Privacy",
                style: Get.textTheme.caption,
              ),
              trailing: Icon(
                Icons.remove,
                color: Get.theme.focusColor.withOpacity(0.3),
              ),
            ),
            CustomPageDrawerLinkWidget(),
            DrawerLinkWidget(
              special: true,
              drawer: false,
              icon: Icons.logout,
              text: "Déconnexion",
              onTap: (e) async {
                showDialog(
                    context: context,
                    builder: (_)=>  PopUpWidget(
                      title: "Vous serez redirigé vers la page de connexion! Voulez-vous vraiment vous déconnecter?",
                      cancel: 'Annuler',
                      confirm: 'Déconnexion',
                      onTap: ()async{
                        var box = GetStorage();
                        Get.find<HomeController>().currentPage.value = 0;
                        Domain.googleUser = false;
                        box.remove("userData");
                        Navigator.pop(context);

                        Get.toNamed(Routes.LOGIN);

                      }, icon: Icon(FontAwesomeIcons.warning, size: 40,color: inactive),
                    ));
              },
            ),
            ListTile(
              dense: true,
              title: Text(
                "Version",
                style: Get.textTheme.headline4,
              ),
              trailing: Text(
                Get.find<RootController>().packageInfo.version.toString(),
                style: Get.textTheme.headline4,
              ),
            )
          ],
        ),
      ),
    );
  }
}
