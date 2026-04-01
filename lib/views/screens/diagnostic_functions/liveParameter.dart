import 'package:autopeepal/logic/controller/diagnosticFunctions/liveParameterController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveParameter extends StatelessWidget {
  LiveParameter({super.key});
  final controller = Get.put(LiveParameterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Select Parameter"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _ecuTabs(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                /// 🔹 Search + Filter
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          style: TextStyles.textfieldTextStyle1,
                          cursorColor: Colors.black,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            prefixIcon: const Icon(Icons.search, size: 22),
                            prefixIconConstraints: const BoxConstraints(
                                minHeight: 30, minWidth: 35),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: AppColors.primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.primaryColor, width: 1.5),
                            ),
                          ),
                          onChanged: (value) {
                            controller.searchKey = value;
                            controller.searchPid();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          controller.showGroupOverlay.value = true;
                        },
                        child: Image.asset(
                          "assets/new/ic_groupfilter.png",
                          height: 45,
                          width: 45,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 PID List
                Expanded(
                  child: Obx(() {
                    if (controller.isBusy.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.pidList.isEmpty) {
                      return const Center(child: Text("No Parameters Found"));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: controller.pidList.length,
                      itemBuilder: (context, index) {
                        final pid = controller.pidList[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  pid.shortName ?? pid.code ?? "Unnamed PID",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 1.2,
                              child: Obx(() {
                                final isSelected =
                                    controller.selectedPidList.contains(pid);
                                return Checkbox(
                                  value: isSelected,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return AppColors.primaryColor;
                                    }
                                    return null;
                                  }),
                                  side: BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                  onChanged: (value) {
                                    if (value == true) {
                                      controller.selectedPidList.add(pid);
                                    } else {
                                      controller.selectedPidList.remove(pid);
                                    }
                                  },
                                );
                              }),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                        height: 5,
                        color: AppColors.primaryColor,
                        thickness: 1,
                        indent: 4,
                        endIndent: 4,
                      ),
                    );
                  }),
                ),

                /// 🔹 Continue Button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => controller.continueClicked(
                        context, controller.saveFile),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!controller.showGroupOverlay.value) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Group Filter",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// List
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.groupList.length,
                                itemBuilder: (context, index) {
                                  final grp = controller.groupList[index];

                                  return Obx(() => CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: grp.isSelected.value,
                                        title: Text(grp.groupName.value),

                                        /// ✅ Checkbox color (checked)
                                        activeColor: AppColors.primaryColor,

                                        /// ✅ Border color when unchecked
                                        side: BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 1.5,
                                        ),

                                        /// ✅ Rounded checkbox
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),

                                        /// ✅ Check color
                                        checkColor: Colors.white,

                                        onChanged: (val) {
                                          controller
                                              .handleGroupCheckboxChanged(grp);
                                        },
                                      ));
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primaryColor, // ✅ button color
                                  foregroundColor: Colors.white, // text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  controller.showGroupOverlay.value = false;
                                },
                                child: const Text(
                                  "Ok",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _ecuTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.ecusList.map((ecu) {
              final isSelected =
                  controller.selectedEcu.value?.ecuName == ecu.ecuName;

              return GestureDetector(
                onTap: () async {
                  controller.selectedPidList.clear();
                  await controller.onTabClicked(ecu);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ecu.ecuName ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
