import 'package:autopeepal/logic/controller/diagnosticFunctions/routineTestPlayController.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IorTestPlayPage extends StatelessWidget {
  final controller = Get.put(RoutineTestPlayController());

  IorTestPlayPage(
    Type iorResult,
    seedIndex,
    writeFnIndex,
    noOfInj,
    firingOrder,
  ); // Replace with your Controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // page_bg_color
      appBar: AppBar(title: const Text("Self Test")),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 1. IorTestList (StackLayout equivalent)
                Obx(() => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.iorTestList.length,
                      itemBuilder: (context, index) {
                        var item = controller.iorTestList[index];
                        return Visibility(
                          visible: item.testVisible.value,
                          child: _buildTestItemCard(item),
                        );
                      },
                    )),

                const SizedBox(height: 20),

                // 2. TxtAction Label
                Obx(() => Text(
                      controller.txtAction.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),

                const SizedBox(height: 20),

                // 3. Timer and Test Status
                Obx(() => Visibility(
                      visible: controller.timerVisible.value,
                      child: Column(
                        children: [
                          Visibility(
                            visible: controller.timerVisible.value,
                            child: Text(
                              controller.timer.value,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Visibility(
                            visible: controller.layoutVisible.value,
                            child: Text(
                              controller.testStatus.value,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // 4. Overlays (InputView, OutputView, etc.)
          _buildPopupOverlay(
            visible: controller.inputViewVisible,
            title: "Input PIDs",
            content: _buildInputList(),
            onOk: () => controller.startTestClicked(),
            onCancel: () => controller.hideInputViewClicked(),
          ),

          _buildPopupOverlay(
            visible: controller.outputViewVisible,
            title: controller.outputHeader.value,
            content: _buildOutputList(),
            onOk: () => controller.okClicked(),
          ),

          // Loader View
          Obx(() => controller.isBusy.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // Individual Card for Test List
  Widget _buildTestItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.description ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Obx(() => IconButton(
                    icon: Image.asset(item.imageSource.value, width: 30),
                    onPressed: item.btnActivationStatus.value
                        ? () => controller.testActionClickedDirect(false, "")
                        : null,
                  )),
            ],
          ),
          if (item.descriptionVisible.value)
            Text(item.testInstruction ?? '',
                style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Generic Popup Builder
  Widget _buildPopupOverlay({
    required RxBool visible,
    required String title,
    required Widget content,
    VoidCallback? onOk,
    VoidCallback? onCancel,
  }) {
    return Obx(() => Visibility(
          visible: visible.value,
          child: Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.blue, // theme_color
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white)),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: content,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (onCancel != null)
                        TextButton(
                            onPressed: onCancel, child: const Text("Cancel")),
                      if (onOk != null)
                        TextButton(onPressed: onOk, child: const Text("OK")),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildInputList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.testInputList.length,
      itemBuilder: (context, index) {
        var pid = controller.testInputList[index];
        return ListTile(
          title: Text(pid.shortName ?? ''),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              onChanged: (val) => pid.writePid = val,
              decoration: const InputDecoration(hintText: "Value"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutputList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.showTestOutputList.length,
      itemBuilder: (context, index) {
        var pid = controller.showTestOutputList[index];
        return Column(
          children: pid.piCodeVariable!
              .map<Widget>((v) => ListTile(
                    title: Text(v.shortName),
                    subtitle: Text("${v.min} - ${v.max}"),
                    trailing: Text("${v.showResolution} ${v.unit}"),
                  ))
              .toList(),
        );
      },
    );
  }
}
