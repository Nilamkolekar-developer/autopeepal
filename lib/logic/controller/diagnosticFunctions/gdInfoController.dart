// gd_info_controller.dart
import 'package:autopeepal/models/gd_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GdInfoController extends GetxController {
  RxString dtcCode = "".obs;
  RxString description = "".obs;
  RxString causes = "".obs;
  RxString remedialAction = "".obs;

  RxList<GdImageGD> images = <GdImageGD>[].obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null) {
      ResultGD gdData = args["gd"];
      dtcCode.value = args["code"] ?? "";
      description.value = gdData.gdDescription ?? "";
      causes.value = gdData.causes ?? "";
      remedialAction.value = gdData.remedialActions ?? "";

      List<GdImageGD> imgList = gdData.gdImages ?? [];
// GdInfoController.dart
for (var img in imgList) {
  if (img.gdImage != null && img.gdImage!.startsWith("/media")) {
    // Remove extra '/media' if exists
    var path = img.gdImage!;
    if (path.startsWith("/media/media")) {
      path = path.replaceFirst("/media", "");
    }
    img.gdImage = "http://4.224.248.152:3389$path";
    print("🔹 Fixed image URL: ${img.gdImage}");
  }
}

      images.assignAll(imgList);
    }
  }

  void openImage(String? url) {
    if (url == null) return;

    Get.dialog(
      Dialog(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Placeholder for broken image
              return Image.asset(
                "assets/new/placeholder.png",
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}