import 'package:autopeepal/logic/controller/diagnosticFunctions/routinePreconditionTestController.dart';
import 'package:autopeepal/models/iorTest_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IorPreconditionPage extends StatelessWidget {
  final controller = Get.put(routinePreconditionController());

  IorPreconditionPage(IorResult iorResult, String seedIndex,
      String writeFnIndex, int? noOfInjectors, List<int> firingOrder);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preconditions")),
      body: Stack(
        children: [
          Obx(
            () => SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  // Static Preconditions
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.iorStaticList.length,
                    itemBuilder: (context, index) {
                      final item = controller.iorStaticList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(10, 10),
                              blurRadius: 40,
                            )
                          ],
                        ),
                        child: Text(
                          item.description,
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 10),

                  // Manual Preconditions
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.iorManualList.length,
                    itemBuilder: (context, index) {
                      final item = controller.iorManualList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(10, 10),
                              blurRadius: 40,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.description)),
                            Obx(() => Checkbox(
                                  value: item.isCheck,
                                  onChanged: (val) {
                                    item.isCheck = val ?? false;
                                  },
                                )),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 10),

                  // PID Preconditions
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.iorPidList.length,
                    itemBuilder: (context, index) {
                      final item = controller.iorPidList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(10, 10),
                              blurRadius: 40,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description,
                                style: TextStyle(fontSize: 14)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text("Min: ${item.lowerLimit}"),
                                SizedBox(width: 30),
                                Text("Value: ${item.currentValue}"),
                                SizedBox(width: 30),
                                Text("Max: ${item.upperLimit}"),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      controller.checkConditionsAndNavigate();
                    },
                    child: Text("Continue"),
                  ),
                ],
              ),
            ),
          ),

          // Loader overlay
          Obx(() => controller.isBusy.value
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox.shrink()),
        ],
      ),
    );
  }
}
