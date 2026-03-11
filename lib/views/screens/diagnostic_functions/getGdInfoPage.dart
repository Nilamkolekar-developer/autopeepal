import 'package:autopeepal/logic/controller/diagnosticFunctions/gdInfoController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GDInfoPage extends StatelessWidget {
  final GdInfoController controller = Get.put(GdInfoController());

  GDInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.dtcCode.value.isNotEmpty
            ? controller.dtcCode.value
            : "GD Info")),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            SizedBox.expand(
              child: Image.asset(
                "assets/new/backgroundimg.png",
                fit: BoxFit.cover,
              ),
            ),
        
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Obx(() => Text(
                          controller.description.value,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
        
                    const SizedBox(height: 20),
        
                    // Causes
                    Obx(() => _sectionCard(
                          "Causes",
                          Text(
                            controller.causes.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )),
        
                    const SizedBox(height: 15),
        
                    // Remedial Action
                    Obx(() => _sectionCard(
                          "Remedial Action",
                          Text(
                            controller.remedialAction.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )),
        
                    const SizedBox(height: 15),
        
                    // Images Section
                    Obx(() {
                      if (controller.images.isEmpty) {
                        return _sectionCard(
                          "Images",
                          const Padding(
                            padding: EdgeInsets.all(30),
                            
                          ),
                        );
                      }
        
                      return _sectionCard(
                        "Images",
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.images.length,
                          itemBuilder: (context, index) {
                            final img = controller.images[index];
        
                            // Fix double /media if exists
                            String? imageUrl = img.gdImage;
                            if (imageUrl != null &&
                                imageUrl.contains("/media/media")) {
                              imageUrl =
                                  imageUrl.replaceFirst("/media/media", "/media");
                            }
        
                            return Padding(
                              padding: const EdgeInsets.all(15),
                              child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.gdZoomImage,
                                      arguments: {
                                        "image": imageUrl,
                                        "title": controller.dtcCode.value,
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      if (imageUrl != null && imageUrl.isNotEmpty)
                                        Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons
                                                  .broken_image, // built-in broken image icon
                                              size: 80, // adjust size as needed
                                              color: Colors
                                                  .white, // adjust color as needed
                                            );
                                          },
                                        )
                                      else
                                        const Icon(
                                          Icons.broken_image,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      const SizedBox(height: 5),
                                      Text(
                                        img.imageName ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Card Helper
  Widget _sectionCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.blue),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
