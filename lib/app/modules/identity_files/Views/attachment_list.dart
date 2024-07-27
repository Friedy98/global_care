
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/loading_cards.dart';
import '../controller/import_identity_files_controller.dart';

class AttachmentView extends GetView<ImportIdentityFilesController> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //Get.theme.colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: background,
          title:  Text(
            "Identity files".tr,
            style: Get.textTheme.headline6.merge(TextStyle(color: appColor)),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: appColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: ()async{
            controller.onRefresh();

          },
          child: buildAttachments(context)
        )
    );
  }

  Widget buildAttachments(BuildContext context){
    return Obx(() => Container(
      height: Get.height,
      width: Get.width,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: Ui.getBoxDecoration(),
      child: Column(
        children: [
          if(controller.attachmentFiles.isEmpty)
          SizedBox(
              width: Get.width/2,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: interfaceColor
                  ),
                  onPressed: ()=> Get.toNamed(Routes.ADD_IDENTITY_FILES),
                  label: SizedBox(width: 100,height: 30,
                      child: Center(child: Text('Upload file'))),
                  icon: Icon(Icons.upload)
              )
          ),
          controller.loadAttachments.value ?
          Expanded(child: LoadingCardWidget()) :
          controller.attachmentFiles.isNotEmpty ?
          Expanded(
              child: ListView.builder(
                  itemCount: controller.attachmentFiles.length + 1,
                  itemBuilder: (context, item){

                    if (item == controller.attachmentFiles.length) {
                      return SizedBox(height: 120);
                    }else{

                      if(controller.attachmentFiles[item]['conformity']){
                        controller.isConform.value = true;
                      }

                      return Obx(() => Column(
                        children: [
                          if(item == 0 && !controller.isConform.value)
                            SizedBox(
                                width: Get.width/2,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: interfaceColor
                                    ),
                                    onPressed: ()=> Get.toNamed(Routes.ADD_TRAVEL_FORM),
                                    label: SizedBox(width: 100,height: 30,
                                        child: Center(child: Text('Upload file'))),
                                    icon: Icon(Icons.upload)
                                )
                            ),
                          SizedBox(height: 10),
                          Card(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Row(
                                  children: [
                                    Obx(() => InkWell(
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
                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                      child: FadeInImage(
                                                        width: Get.width,
                                                        height: Get.height/2,
                                                        image: NetworkImage('${Domain.serverPort}/image/ir.attachment/${controller.attachmentFiles[item]['id']}/datas?unique=true&file_response=true',
                                                            headers: Domain.getTokenHeaders()),
                                                        placeholder: AssetImage(
                                                            "assets/img/loading.gif"),
                                                        imageErrorBuilder:
                                                            (context, error, stackTrace) {
                                                          return Center(
                                                              child: Container(
                                                                  width: Get.width,
                                                                  height: Get.height/3,
                                                                  color: Colors.white,
                                                                  child: Center(
                                                                      child: Icon(Icons.file_copy_rounded, size: 150)
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
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                child: FadeInImage(
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage('${Domain.serverPort}/image/ir.attachment/${controller.attachmentFiles[item]['id']}/datas?unique=true&file_response=true',
                                                      headers: Domain.getTokenHeaders()),
                                                  placeholder: AssetImage(
                                                      "assets/img/loading.gif"),
                                                  imageErrorBuilder:
                                                      (context, error, stackTrace) {
                                                    return Icon(FontAwesomeIcons.camera, size: 50);
                                                  },
                                                )
                                            )
                                        )
                                    )),
                                    Expanded(
                                        child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text("Type", style: Get.textTheme.bodyText2.merge(TextStyle(color: appColor))),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 12),
                                                      width: 1,
                                                      height: 24,
                                                      color: Get.theme.focusColor.withOpacity(0.3),
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(controller.attachmentFiles[item]['attach_custom_type'], style: Get.textTheme.bodyText2),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text("Id Number", style: Get.textTheme.bodyText2.merge(TextStyle(color: appColor))),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 12),
                                                      width: 1,
                                                      height: 24,
                                                      color: Get.theme.focusColor.withOpacity(0.3),
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(controller.attachmentFiles[item]['name'], style: Get.textTheme.bodyText2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text("Validity", style: Get.textTheme.bodyText2.merge(TextStyle(color: appColor))),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 12),
                                                      width: 1,
                                                      height: 24,
                                                      color: Get.theme.focusColor.withOpacity(0.3),
                                                    ),
                                                    SizedBox(
                                                        width: 100,
                                                        child: controller.attachmentFiles[item]['duration_rest'] > 0 && controller.attachmentFiles[item]['conformity']?
                                                        Text("Valid".toUpperCase(), style: TextStyle(color: validateColor, fontWeight: FontWeight.bold))
                                                            : Text("Expired".toUpperCase(), style: TextStyle(color: specialColor, fontWeight: FontWeight.bold)
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text("Conformity", style: Get.textTheme.bodyText2.merge(TextStyle(color: appColor))),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 12),
                                                      width: 1,
                                                      height: 24,
                                                      color: Get.theme.focusColor.withOpacity(0.3),
                                                    ),
                                                    SizedBox(
                                                        width: 100,
                                                        child: controller.attachmentFiles[item]['duration_rest'] > 0 && controller.attachmentFiles[item]['conformity']?
                                                        Text("Verified".toUpperCase(), style: TextStyle(color: validateColor, fontWeight: FontWeight.bold)
                                                        ) : Text("Analysing...".toUpperCase(), style: TextStyle(color: inactive, fontWeight: FontWeight.bold))
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              /*SwitchListTile( //switch at right side of label
                                            value: controller.attachmentFiles[item]['conformity'],
                                            onChanged: (bool value){

                                            },
                                            title: Text("Conformity", style: Get.textTheme.bodyText2.merge(TextStyle(color: appColor)))
                                        )*/
                                            ]
                                        )
                                    )
                                  ]
                              )
                          )
                        ],
                      ));
                    }
                  }
              )
          ) :
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Get.height/3),
                FaIcon(FontAwesomeIcons.folderOpen, color: inactive.withOpacity(0.3),size: 80),
                Text('No Attachment found', style: Get.textTheme.headline5.merge(TextStyle(color: inactive.withOpacity(0.3)))),
              ],
            ),
          ),
        ],
      ),
    ));
  }

}
