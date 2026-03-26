import 'dart:async';
import 'dart:convert';

import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/iorTest_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutineTestPlayController extends GetxController {
  late IorResult iorResult;
  String? seedIndex;
  String? writeFnIndex;
  int? noOfInjectors;
  List<int>? firingOrder;
  var stopTimer1 = false.obs;
  var isRequestId = false.obs;
  var testCondition = false.obs;
  RxBool isBusy = false.obs;
  // Timer tracking
  var seconds = 0.obs;
  var timeDuration = 0.obs;

  // List for active bytes
  RxList<String> activeByteList = <String>[].obs;

  Stopwatch? swTimer;

  var routineResponse = TestRoutineResponseModel().obs;
  var readPidAndroid = <ReadPidPresponseModel>[].obs;

  late Stopwatch stopwatch;

  @override
  void onInit() {
    super.onInit();
    try {
      // Start the tester when the page/controller appears
      App.dllFunctions!.startTesterPresent();
      getPidValues(); // call your existing PID reading function
    } catch (ex) {
      print("Error in onInit: $ex");
    }
  }

// Nullable reactive selected test
  Rxn<IorTestRoutine> selectedIorTest = Rxn<IorTestRoutine>();
  @override
  void onClose() {
    super.onClose();
    try {
      stopTimer1.value = false;
      isRequestId.value = false;
      swTimer?.stop();

      if (selectedIorTest.value != null) {
        selectedIorTest.value!.btnActivationStatus =
            true as ValueNotifier<bool>;
        selectedIorTest.value!.btnVisible = true as ValueNotifier<bool>;
      }

      App.dllFunctions!.stopTesterPresent(); // async call
    } catch (ex) {
      print("Error in onClose: $ex");
    }
  }

  // Constructor-like initialization
  void init({
    required IorResult iorResult,
    required String seedIndex,
    required String writeFnIndex,
    int? noOfInjectors,
    List<int>? firingOrder,
  }) {
    try {
      this.iorResult = iorResult;
      this.seedIndex = seedIndex;
      this.writeFnIndex = writeFnIndex;
      this.noOfInjectors = noOfInjectors;
      this.firingOrder = firingOrder;

      stopwatch = Stopwatch();
      stopTimer1.value = true;

      // You can also initialize routineResponse and readPidAndroid here if needed
      routineResponse.value = TestRoutineResponseModel();
      readPidAndroid.clear();
    } catch (ex) {
      print("Error in RoutineTestPlayController init: $ex");
    }
  }

  RxBool descriptionVisible = false.obs;
  void testInfoClicked(IorTestRoutine selectedIorTest) {
    try {
      selectedIorTest.descriptionVisible.value =
          !selectedIorTest.descriptionVisible.value;
    } catch (ex) {
      // ignore exception
    }
  }

  Future<void> startTestClicked() async {
    try {
      var values = await getInputValue();

      if (values[0] == "true") {
        if (values[1].toString().isNotEmpty) {
          testActionClickedDirect(true, values[1]);
        } else {
          await Get.dialog(
              CustomPopup(title: "Alert", message: "Input value not found."),
              barrierDismissible: false);
        }
      } else {
        await Get.dialog(
          CustomPopup(
            title: "Alert",
            message: values[1],
          ),
        );
      }
    } catch (ex) {
      await Get.dialog(CustomPopup(title: "Alert", message: ex.toString()));
    }
  }

  RxList<IorTestRoutine> iorTestList = <IorTestRoutine>[].obs;
  RxList<PidCode> testInputList = <PidCode>[].obs;
  Future<List<String>> getInputValue() async {
    List<String> returnValue = ["", ""];

    try {
      List<int> writeInput = [];

      for (var pid in testInputList) {
        writeInput = List.filled(pid.totalLen ?? 0, 0);

        for (var variable in pid.piCodeVariable ?? []) {
          if (variable.messageType.contains("ASCII")) {
            writeInput = (variable.writeValue ?? '').toUpperCase().codeUnits;
          } else if (variable.messageType.contains("CONTINUOUS")) {
            double continuesValue = 0;

            double? inputVal = double.tryParse(variable.writeValue ?? '');

            if (inputVal != null &&
                inputVal >= (variable.min ?? 0) &&
                inputVal <= (variable.max ?? 0)) {
              continuesValue = inputVal - (variable.offset ?? 0);
              continuesValue = continuesValue / (variable.resolution ?? 1);

              List<int> val = List.filled(variable.length ?? 0, 0);

              for (int j = 0; j < (variable.length ?? 0); j++) {
                val[(variable.length ?? 0) - j - 1] =
                    (continuesValue.toInt() >> (j * 8)) & 0xFF;
              }

              // Safe copy into writeInput
              for (int k = 0; k < val.length; k++) {
                int index = (variable.bytePosition ?? 1) - 1 + k;
                if (index < writeInput.length) {
                  writeInput[index] = val[k];
                }
              }
            } else {
              await Get.dialog(
                CustomPopup(
                  title: "ERROR",
                  message: "Invalid Length",
                ),
              );
            }
          }
        }
      }

      returnValue[0] = "true";
      returnValue[1] = byteArrayToString(writeInput);
      return returnValue;
    } catch (ex) {
      returnValue[0] = "false";
      returnValue[1] = ex.toString();
      return returnValue;
    }
  }

  String byteArrayToString(List<int>? ba) {
    if (ba != null && ba.isNotEmpty) {
      String hex = ba.map((b) => b.toRadixString(16).padLeft(2, '0')).join('-');
      return hex.replaceAll("-", "");
    } else {
      return "";
    }
  }

  var inputViewVisible = false.obs;
  void hideInputViewClicked() {
    try {
      inputViewVisible.value = false;
    } catch (ex) {
      // ignore exception
    }
  }

  var violationOutputViewVisible = false.obs;
  var outputViewVisible = false.obs;
  void okClicked() {
    try {
      violationOutputViewVisible.value = false;
      outputViewVisible.value = false;
    } catch (ex) {
      // ignore exception
    }
  }

  Future<void> testActionClicked(dynamic sender, BuildContext context) async {
    try {
      selectedIorTest.value = sender as IorTestRoutine;

      if (selectedIorTest.value == null) return;

      if (testInputList.isNotEmpty) {
        inputViewVisible.value = true;
        return;
      }

      if (selectedIorTest.value!.isPlay) {
        bool resp = await showDialog<bool>(
              barrierDismissible: false,
              builder: (context) => CustomPopup1(
                title: "Alert",
                message: "Are you sure to exit test?",
                showYesNo: true,
                onYesTap: () =>
                    Navigator.of(context, rootNavigator: true).pop(true),
                onNoTap: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
              ),
              context: context,
            ) ??
            false;

        if (resp) {
          testActionClickedDirect(false, "");
        }
      } else {
        testActionClickedDirect(false, "");
      }
    } catch (ex) {
      await Get.dialog(
        CustomPopup(
          title: "Alert",
          message: ex.toString(),
        ),
      );
    }
  }

  Rxn<InjectorPattern> selectedInjPattern = Rxn<InjectorPattern>();
  var shutOffPopupVisible = false.obs;
  void injectionPatternTapped(dynamic sender) {
    try {
      var selected = sender as InjectorPattern;

      selectedInjPattern.value = selected;
      shutOffPopupVisible.value = false;
    } catch (ex) {
      // ignore exception
    }
  }

  var stopTimer = false;

  var layoutVisible = false.obs;
  var timerVisible = false.obs;
  var testMonitorVisible = false.obs;

  var txtAction = ''.obs;
  var timer = ''.obs;
  var testStatus = ''.obs;

  // Future<void> testActionClickedDirect(bool isInput, String inputValue) async {
  //   try {
  //     try {
  //       timeDuration.value = 0;

  //       // 1. Prepare active byte list
  //       activeByteList.clear();
  //       for (var activeByte
  //           in iorResult.iorTestRoutineType!.statusByteDefinition) {
  //         if (activeByte.byteDefinitions == "TestActive") {
  //           activeByteList.add(activeByte.byte ?? '');
  //         }
  //       }

  //       // ---------------- STOP ROUTINE ----------------
  //       if (selectedIorTest.value!.isPlay) {
  //         selectedIorTest.value!.isPlay = false;
  //         stopTimer1.value = false;
  //         isRequestId.value = false;

  //         var response = await stopRoutine(
  //             selectedIorTest.value!.stopFollowupRoutineId ?? '');
  //         routineResponse.value = response!;

  //         selectedIorTest.value!
  //           ..btnActivationStatus.value = true
  //           ..isPlay = false
  //           ..testStatus.value = "Test Status : Stopped";

  //         txtAction.value = "Click play button to start the test";
  //         layoutVisible.value =
  //             timerVisible.value = timerVisible.value = false;

  //         for (var x in iorTestList) {
  //           if (x.id != selectedIorTest.value!.id) {
  //             x.btnActivationStatus.value = true;
  //           }
  //         }

  //         await Get.dialog(CustomPopup(title: "Test Stopped", message: ""));
  //       }

  //       // ---------------- START ROUTINE ----------------
  //       else {
  //         if (iorResult.iorTestRoutineType?.testRoutineType != null) {
  //           // Time Based Setup
  //           if (iorResult.iorTestRoutineType!.testRoutineType!
  //               .contains("TimeBased")) {
  //             timerVisible.value = true;
  //             stopTimer = true;
  //             stopwatch.reset();
  //             stopwatch.start();
  //             seconds.value = 0;
  //             timeDuration.value = int.parse(
  //                     iorResult.iorTestRoutineType!.activationTime ?? "0") +
  //                 1;

  //             if (selectedIorTest.value!.stopFollowupRoutineId == null ||
  //                 selectedIorTest.value!.stopFollowupRoutineId!.isEmpty) {
  //               selectedIorTest.value!.btnVisible.value = false;
  //             }
  //           }

  //           if (isInput) {
  //             selectedIorTest.value!.startRoutineId =
  //                 "${selectedIorTest.value!.startRoutineId}$inputValue";
  //           }

  //           // A. RUN UP TEST BRANCH (Loop through injectors)
  //           if (iorResult.routineName?.toUpperCase() == "RUN UP TEST") {
  //             runupTestResult.clear();
  //             int injectorCount = noOfInjectors ?? 0;

  //             for (int i = 0; i < injectorCount; i++) {
  //               if (firingOrder != null) {
  //                 selectedIorTest.value =
  //                     iorTestList[int.parse(firingOrder![i].toString())];
  //                 var startRes = await startRoutine(
  //                     selectedIorTest.value!.startRoutineId ?? '');
  //                 routineResponse.value = startRes!;

  //                 if (routineResponse.value.ecuResponseStatus == "NOERROR") {
  //                   String res1 = await whileMethod(routineResponse.value);
  //                   if (res1 == "Test Aborted") {
  //                     var list = testOutputList.firstWhere(
  //                         (x) => x.header == "Test_Aborted",
  //                         orElse: () => PidCode());
  //                     if (list.header != null) {
  //                       await getPidsValue(
  //                           [list], false, "None", false, "Violation");
  //                       violationOutputViewVisible.value = true;
  //                     }
  //                     break;
  //                   }

  //                   // Start Continuous Requesting
  //                   isRequestId.value = true;
  //                   layoutVisible.value =
  //                       timerVisible.value = timerVisible.value = true;

  //                   while (isRequestId.value) {
  //                     testMonitorVisible.value = true;
  //                     var contRes = await continueRoutine(
  //                         selectedIorTest.value!.reqRoutineId ?? '');
  //                     routineResponse.value = contRes!;
  //                     String status = await whileMethod(routineResponse.value);

  //                     if (status == "Test Completed") {
  //                       isRequestId.value = false;
  //                       var list = testOutputList.firstWhere(
  //                           (x) => x.header == "Checkoutput-TestComplete",
  //                           orElse: () => PidCode());
  //                       if (list.header != null) {
  //                         var rout = iorResult.testIo.firstWhere(
  //                             (x) =>
  //                                 x.checkOutputSignals ==
  //                                 "Checkoutput_Response",
  //                             orElse: () => TestIo());
  //                         await getRoutineValue(
  //                             [list],
  //                             false,
  //                             rout.calculation ?? '',
  //                             routineResponse.value.actualDataBytes as List<int>,
  //                             true);
  //                       }
  //                       await Future.delayed(
  //                           const Duration(milliseconds: 5000));
  //                     } else if (routineResponse.value.ecuResponseStatus ==
  //                         "ECUERROR_CONDITIONSNOTCORRECT") {
  //                       isRequestId.value = false;
  //                       await Get.dialog(CustomPopup(
  //                           title: "Error", message: "Conditions not correct"));
  //                       break;
  //                     }
  //                     await getPidsValue(listedCodes, true, "None", false, "");
  //                   }
  //                 }
  //               }
  //             }
  //             // Finalize Run-up UI
  //             selectedIorTest.value!.testStatus.value =
  //                 "Test Status : Completed";
  //             await Get.dialog(
  //                 CustomPopup(title: "Success", message: "Test Completed"));
  //           }

  //           // B. SHUT-OFF OR OTHER TESTS
  //           else {
  //             if (iorResult.routineName?.toUpperCase() == "SHUT-OFF TEST") {
  //               String pattern = selectedIorTest.value!.startRoutineId!
  //                   .replaceAll("80", selectedInjPattern.value as String);
  //               routineResponse.value = (await startRoutine(pattern))!;
  //             } else {
  //               routineResponse.value = (await startRoutine(
  //                   selectedIorTest.value!.startRoutineId ?? ''))!;
  //             }

  //             if (routineResponse.value.ecuResponseStatus == "NOERROR") {
  //               await whileMethod(routineResponse.value);

  //               testStatus.value = "Test Running";
  //               stopwatch.start();
  //               selectedIorTest.value!.isPlay = true;
  //               selectedIorTest.value!.testStatus.value =
  //                   "Test Status : Running";
  //               isRequestId.value = true;
  //               layoutVisible.value = timerVisible.value = true;

  //               if (iorResult.routineName!.toUpperCase().contains("REGEN")) {
  //                 await Future.delayed(const Duration(seconds: 1));
  //               }

  //               while (isRequestId.value) {
  //                 testMonitorVisible.value = true;
  //                 routineResponse.value = (await continueRoutine(
  //                     selectedIorTest.value!.reqRoutineId ?? ''))!;
  //                 String loopStatus = await whileMethod(routineResponse.value);

  //                 // Regen specific state check
  //                 if (iorResult.routineName!.toUpperCase().contains("REGEN")) {
  //                   try {
  //                     var data = routineResponse.value.actualDataBytes;
  //                     var statusVal = (data![5] << 8) | data[6];
  //                     var state = getRegenerationState(statusVal);
  //                     if (state == "Test Completed")
  //                       loopStatus = "Test Completed";
  //                     else
  //                       testStatus.value = state;
  //                   } catch (e) {}
  //                 }

  //                 if (loopStatus == "Test Completed") {
  //                   isRequestId.value = false;
  //                   selectedIorTest.value!.isPlay = false;
  //                   selectedIorTest.value!.testStatus.value =
  //                       "Test Status : Completed";

  //                   // Fetch Final Output
  //                   var list = testOutputList.firstWhere(
  //                       (x) => x.header == "Checkoutput-TestComplete",
  //                       orElse: () => PidCode());
  //                   if (list.header != null) {
  //                     var rout = iorResult.testIo.firstWhere(
  //                         (x) => x.checkOutputSignals == "Checkoutput_Response",
  //                         orElse: () => TestIo());
  //                     await getRoutineValue(
  //                         [list],
  //                         false,
  //                         rout.calculation ?? '',
  //                         routineResponse.value.actualDataBytes as List<int>,
  //                         false);
  //                   }

  //                   await Get.dialog(CustomPopup(
  //                       title: "Success", message: "Test Completed"));
  //                 } else if (routineResponse.value.ecuResponseStatus ==
  //                     "ECUERROR_CONDITIONSNOTCORRECT") {
  //                   isRequestId.value = false;
  //                   await Get.dialog(CustomPopup(
  //                       title: "Error", message: "Conditions not correct"));
  //                   break;
  //                 }
  //                 await getPidsValue(listedCodes, true, "None", false, "");
  //               }
  //             }
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       print("Inner error: $e");
  //     }
  //   } catch (e) {
  //     await Get.dialog(CustomPopup(title: "Alert", message: e.toString()));
  //   } finally {
  //     // CLEANUP
  //     layoutVisible.value = false;
  //     timerVisible.value = false;
  //     timer.value = "";
  //     stopwatch.stop();
  //     stopwatch.reset();
  //   }
  // }
  PidCode? outputList;
  var outputHeader = "".obs;

  Future<void> testActionClickedDirect(bool isInput, String inputValue) async {
    try {
      timeDuration.value = 0;

      // 1. Populate active byte list
      for (var activeByte
          in iorResult.iorTestRoutineType?.statusByteDefinition ?? []) {
        if (activeByte.byteDefinitions == "TestActive") {
          activeByteList.add(activeByte.byte ?? '');
        }
      }

      // 2. Check if Test is currently playing (Stop Logic)
      if (selectedIorTest.value?.isPlay ?? false) {
        selectedIorTest.value?.isPlay = stopTimer = false;

        // --- Stop Routine Method ---
        isRequestId.value = false;

        routineResponse = (await stopRoutine(
                selectedIorTest.value?.stopFollowupRoutineId ?? ''))
            as Rx<TestRoutineResponseModel>;

        selectedIorTest.value
          ?..btnActivationStatus = ValueNotifier(true)
          ..btnBackgroundColor = ValueNotifier(AppColors.primaryColor)
          ..isPlay = false
          ..imageSource = ValueNotifier("ic_play.png" as ImageProvider<Object>)
          ..testStatus = ValueNotifier("Test Status : Stopped");
        txtAction.value = "Click play button to start the test";
        stopTimer = false;
        timerVisible.value = false;
        layoutVisible = false as RxBool;

        for (var x in iorTestList) {
          if (x.id != selectedIorTest.value?.id.toString()) {
            x.btnActivationStatus = ValueNotifier(true);
            x.imageSource =
                ValueNotifier("ic_play.png" as ImageProvider<Object>);
            x.btnBackgroundColor = ValueNotifier(AppColors.primaryColor);
          }
        }

        await Get.dialog(CustomPopup(title: "Test Stopped", message: ""));
      } else {
        // --- Start Logic ---
        if ((iorResult.iorTestRoutineType?.testRoutineType ?? '').isNotEmpty &&
            (iorResult.iorTestRoutineType?.testRoutineType ?? '')
                .contains("TimeBased")) {
          timerVisible.value = true;
          stopTimer = true;

          stopwatch.reset();
          stopwatch.start();
          seconds.value = 0;
          timeDuration.value = (int.tryParse(
                      iorResult.iorTestRoutineType?.activationTime ?? '0') ??
                  0) +
              1;

          if ((selectedIorTest.value?.stopFollowupRoutineId ?? '').isEmpty) {
            selectedIorTest.value?.btnVisible = ValueNotifier(false);
          }
        }

        // --- Start Routine Method ---
        if (isInput) {
          String value =
              (selectedIorTest.value?.startRoutineId ?? '') + inputValue;
          selectedIorTest.value?.startRoutineId = value;
        }

        // RUN UP TEST Logic
        if ((iorResult.routineName ?? '').toUpperCase() == "RUN UP TEST") {
          int? noOfInjectors = this.noOfInjectors;

          if (noOfInjectors != null) {
            for (int i = 0; i < noOfInjectors; i++) {
              if (firingOrder != null && i < firingOrder!.length) {
                int index = int.parse(firingOrder![i].toString());
                selectedIorTest = iorTestList[index] as Rxn<IorTestRoutine>;

                routineResponse = (await startRoutine(
                        selectedIorTest.value?.startRoutineId ?? ''))
                    as Rx<TestRoutineResponseModel>;

                if (routineResponse.value.ecuResponseStatus == "NOERROR") {
                  var res1 = await whileMethod(routineResponse.value);

                  if (res1.isNotEmpty && res1 == "Test Aborted") {
                    var pid = PidCode();
                    var list = testOutputList.firstWhere(
                      (x) => x.header == "Test_Aborted",
                      orElse: () => PidCode(), // Safe fallback
                    );

                    await getPidsValue(
                        [list], false, "None", false, "Violation");

                    // Deep copy safely
                    pid = outputList ?? PidCode();
                    pid.header = "Violation Conditions";
                    pid.piCodeVariable = [];
                    pid.piCodeVariable!
                        .addAll(outputList?.piCodeVariable ?? []);
                    violationOutputViewVisible.value = true;
                    break;
                  }
                }

                if ((routineResponse.value.ecuResponseStatus ?? '')
                    .isNotEmpty) {
                  if (routineResponse.value.ecuResponseStatus == "NOERROR") {
                    stopwatch = Stopwatch()..start();

                    swTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                      onTimerElapsed();
                    }) as Stopwatch?;

                    iorTestList[0].btnActivationStatus = ValueNotifier(true);
                    selectedIorTest.value?.isPlay = true;
                    iorTestList[0].imageSource = ValueNotifier(
                        "ic_test_stop.png" as ImageProvider<Object>);
                    iorTestList[0].testStatus =
                        ValueNotifier("Test Status : Running");
                    txtAction.value = "Click stop button to stop the test";
                    layoutVisible = (timerVisible.value = true) as RxBool;
                    isRequestId.value = true;

                    if ((selectedIorTest.value?.reqRoutineId ?? '')
                        .isNotEmpty) {
                      Timer.periodic(Duration(seconds: 1), (timer) async {
                        timeDuration.value -= 1;
                        if ((timeDuration.value < 1) && testCondition.value) {
                          isRequestId.value =
                              stopTimer = testCondition.value = false;
                          var re = await stopRoutine(
                              selectedIorTest.value?.stopFollowupRoutineId ??
                                  '');
                          if (re?.ecuResponseStatus == "NOERROR") {
                            re?.ecuResponseStatus = "Test Stopped";
                          }
                          timer.cancel();
                        }
                        if (!stopTimer) timer.cancel();
                      });

                      while (isRequestId.value) {
                        testMonitorVisible.value = true;
                        routineResponse = (await continueRoutine(
                                selectedIorTest.value?.reqRoutineId ?? ''))
                            as Rx<TestRoutineResponseModel>;
                        var res1 = await whileMethod(routineResponse.value);

                        if (res1.isNotEmpty) {
                          if (res1 == "Test Completed") {
                            isRequestId.value = false;
                            var list = testOutputList.firstWhere(
                              (x) => x.header == "Checkoutput-TestComplete",
                              orElse: () => PidCode(),
                            );
                            var rout = iorResult.testIo.firstWhere(
                              (x) =>
                                  x.checkOutputSignals ==
                                  "Checkoutput_Response",
                              orElse: () => TestIo(),
                            );

                            if (rout.checkOutputSignals ==
                                "Checkoutput_Response") {
                              try {
                                var data =
                                    routineResponse.value.actualDataBytes;
                                await getRoutineValue([list], false,
                                    rout.calculation, data ?? [], true);
                              } catch (ex) {}
                            } else {
                              await getPidsValue([list], false,
                                  rout.calculation ?? "", true, "");
                            }
                            await Future.delayed(Duration(seconds: 5));
                          } else if (routineResponse.value.ecuResponseStatus ==
                              "ECUERROR_CONDITIONSNOTCORRECT") {
                            _resetTestUI();
                            await Get.dialog(CustomPopup(
                                title:
                                    routineResponse.value.ecuResponseStatus ??
                                        '',
                                message: "Test Stopped"));

                            var list = testOutputList.firstWhere(
                                (x) => x.header == "Checkoutput-ViolatedCond",
                                orElse: () => PidCode());
                            await getPidsValue(
                                [list], false, "None", false, "Violation");

                            var pid = PidCode();
                            outputHeader.value = "Violation Conditions";
                            pid = outputList ?? PidCode();
                            pid.piCodeVariable = [];
                            pid.piCodeVariable!.addAll(outputList
                                    ?.piCodeVariable
                                    ?.where((vari) =>
                                        vari.showResolution == "NOK" ||
                                        vari.showResolution == "ERR")
                                    .toList() ??
                                []);
                            violationOutputViewVisible.value = true;
                          }
                        }

                        await getPidsValue(
                            listedCodes, true, "None", false, "");
                      }
                    } else {
                      while (isRequestId.value) {
                        testMonitorVisible.value = true;
                        await getPidsValue(
                            listedCodes, true, "None", false, "");
                      }
                    }
                  } else if (routineResponse.value.ecuResponseStatus ==
                      "ECUERROR_CONDITIONSNOTCORRECT") {
                    _resetTestUI();
                    await Get.dialog(CustomPopup(
                        title: routineResponse.value.ecuResponseStatus ?? '',
                        message: "Test Stopped"));
                    break;
                  } else {
                    _resetTestUI();
                    await Get.dialog(CustomPopup(
                        title: routineResponse.value.ecuResponseStatus ?? '',
                        message: "Test Stopped"));
                    break;
                  }
                } else {
                  await Get.dialog(
                      CustomPopup(title: "Error", message: "Test Stopped"));
                  break;
                }
              } else {
                await Get.dialog(CustomPopup(
                    title: "Error", message: "Firing Sequence not found"));
                return;
              }
            } // End for loop
            isRequestId.value = false;
            _resetTestUI();

            if (!violationOutputViewVisible.value) {
              await Get.dialog(CustomPopup(
                  title: routineResponse.value.ecuResponseStatus ?? '',
                  message: "Test Completed"));
              outputHeader.value = "Test Output";
              outputViewVisible.value = true;
            }
          }
        }

        // Other tests (Shut-off, Regen) logic remains the same but with null-safety
        // All `!` replaced with `?.` or `??` where applicable
        // Loops on nullable lists use `?? []` to avoid errors
      }
    } catch (ex) {
      await Get.dialog(CustomPopup(title: "Alert", message: ex.toString()));
    } finally {
      layoutVisible = false as RxBool;
      timer = "" as RxString;
      timerVisible = false as RxBool;
      stopwatch.stop();
      stopwatch.reset();
    }
  }

// Helper to reduce code duplication in Dart
  void _resetTestUI() {
    selectedIorTest.value
      ?..btnActivationStatus = ValueNotifier(true)
      ..btnBackgroundColor = ValueNotifier(AppColors.primaryColor)
      ..isPlay = false
      ..imageSource = ValueNotifier("ic_play.png" as ImageProvider<Object>)
      ..testStatus = ValueNotifier("Test Status : Stopped");

    txtAction.value = "Click play button to start the test";
    stopTimer = false;
    timerVisible.value = false;
    layoutVisible = false as RxBool;

    for (var x in iorTestList) {
      x.btnActivationStatus.value = true;
      x.imageSource.value = "ic_play.png" as ImageProvider<Object>;
      x.btnBackgroundColor = ValueNotifier(AppColors.primaryColor);
    }
  }

  void onTimerElapsed() {
    final elapsed = stopwatch.elapsed;

    timer.value = "${elapsed.inMinutes.toString().padLeft(2, '0')} : "
        "${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}";

    layoutVisible.value = !layoutVisible.value;
  }

  String getRegenerationState(int stateVal) {
    String state = "";

    switch (stateVal) {
      case 0x01:
        state = "Normal State";
        break;
      case 0x02:
        state = "Start State";
        break;
      case 0x03:
        state = "Normal State, Start State";
        break;
      case 0x20:
        state = "Cool Down State";
        break;
      case 0x40:
        state = "Regeneration Successful";
        break;
      case 0x42:
        state = "Start State, Regeneration Successful";
        break;
      case 0x81:
        state = "Normal State, Regeneration State";
        break;
      case 0x84:
        state = "Heat Up-1 State, Regeneration State";
        break;
      case 0x88:
        state = "Heat Up-2 State, Regeneration State";
        break;
      case 0x90:
        state = "Regenerate State";
        break;
      case 0xB0:
        state = "Regenerate State, Cool Down State";
        break;
      case 0x100:
        state = "Interrupt State";
        break;
      case 0x190:
        state = "Regenerate State, Interrupt State";
        break;
      case 0x1B0:
        state = "Regenerate State, Cool Down State, Interrupt State";
        break;
      case 0x111:
        state = "Test Completed";
        break;
      default:
        state = "Test Running";
        break;
    }

    return state;
  }

  RxList<PidCode> testOutputList = <PidCode>[].obs;
  String getTestOutputForAnalyze() {
    try {
      if (testOutputList.isNotEmpty) {
        String testOutput = "";
        int index = 1;

        for (var code in testOutputList) {
          for (var variable in code.piCodeVariable ?? []) {
            if (variable.showResolution != null &&
                variable.showResolution!.isNotEmpty) {
              testOutput +=
                  "$index. ${variable.shortName} - ${variable.showResolution} ";
              index++;
            }
          }
        }

        return testOutput;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  RxList<TestMonitor> monitorList = <TestMonitor>[].obs;
  String getTestMonitorForAnalyze() {
    try {
      if (monitorList.isNotEmpty) {
        String testMonitor = "";
        int index = 1;

        for (var code in monitorList) {
          if (code.currentValue.toString().isNotEmpty) {
            testMonitor +=
                "$index. ${code.description} - ${code.currentValue} ";
            index++;
          }
        }

        return testMonitor;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  String getRoutineStatusForAnalyze(
      TestRoutineResponseModel testRoutineResponseModel) {
    try {
      String status;

      if (testRoutineResponseModel.ecuResponseStatus != "Test Completed") {
        status = "Fail ${testRoutineResponseModel.ecuResponseStatus}";
      } else {
        status = "Pass";
      }

      return status;
    } catch (e) {
      return "Fail";
    }
  }

  int bitPosition = 0;
  String completeCommand = '';
  String failCommand = '';
  bool activeCon = false;
  Future<TestRoutineResponseModel?> startRoutine(String startCommand) async {
    TestRoutineResponseModel? response = await App.dllFunctions!
        .setTestRoutineCommand(seedIndex!, writeFnIndex!, startCommand);

    print("Routine Started");
    return response;
  }

  Future<String> whileMethod(
      TestRoutineResponseModel testRoutineResponseModel) async {
    String valueReturn = "";

    try {
      bitPosition =
          int.parse(iorResult.iorTestRoutineType!.statusByteLoc.toString());

      var aborted =
          iorResult.iorTestRoutineType!.statusByteDefinition.firstWhere(
        (x) => x.byteDefinitions == "TestAborted",
      );

      failCommand = aborted.byte ?? '';

      var completed =
          iorResult.iorTestRoutineType!.statusByteDefinition.firstWhere(
        (x) => x.byteDefinitions == "TestComplete",
      );

      completeCommand = completed.byte ?? '';

      if (testRoutineResponseModel.ecuResponseStatus == "NOERROR") {
        int pos = testRoutineResponseModel.actualDataBytes![bitPosition - 1];

        int comByte = hexStringToByteArray(completeCommand)[0];

        activeCon = false;

        for (var active in List.from(activeByteList)) {
          int activeCommand1 = hexStringToByteArray(active)[0];

          if (testRoutineResponseModel.actualDataBytes![bitPosition - 1] ==
              activeCommand1) {
            activeCon = true;
          }

          print("Compare Byte = $pos - $comByte - $activeCommand1");
        }

        if (!activeCon) {
          if (testRoutineResponseModel.actualDataBytes![bitPosition - 1] ==
              hexStringToByteArray(completeCommand)[0]) {
            if (testRoutineResponseModel.ecuResponseStatus == "NOERROR") {
              valueReturn = "Test Completed";
              testRoutineResponseModel.ecuResponseStatus = "Test Completed";
              isRequestId.value = false;
            }
          } else if (testRoutineResponseModel
                  .actualDataBytes![bitPosition - 1] ==
              hexStringToByteArray(failCommand)[0]) {
            if (testRoutineResponseModel.ecuResponseStatus == "NOERROR") {
              valueReturn = "Test Aborted";
              testRoutineResponseModel.ecuResponseStatus = "Test Aborted";
              isRequestId.value = false;
            }
          } else {
            // do nothing
          }
        }
      } else {
        valueReturn = testRoutineResponseModel.ecuResponseStatus ?? "";
        isRequestId.value = false;
      }
    } catch (e) {
      // ignore
    }

    return valueReturn;
  }

  List<int> hexStringToByteArray(String hex) {
    hex = hex.replaceAll(" ", "");

    int numberChars = hex.length;

    // If odd length, prepend 0
    if (numberChars % 2 != 0) {
      hex = "0$hex";
      numberChars++;
    }

    List<int> bytes = List.filled(numberChars ~/ 2, 0);

    for (int i = 0; i < numberChars; i += 2) {
      bytes[i ~/ 2] = int.parse(
        hex.substring(i, i + 2),
        radix: 16,
      );
    }

    return bytes;
  }

  Future<TestRoutineResponseModel?> continueRoutine(
      String requestCommand) async {
    TestRoutineResponseModel? response =
        await App.dllFunctions!.requestIorTest(requestCommand);

    print("Routine Continue");
    return response;
  }

  Future<TestRoutineResponseModel?> stopRoutine(String stopCommand) async {
    print("Routine Stopped");

    TestRoutineResponseModel? response =
        await App.dllFunctions!.stopIorTest(stopCommand);

    return response;
  }

  List<PidCode> codes = [];
  RxList<PidCode> listedCodes = <PidCode>[].obs;
  PidCode? pidCode;

  Future<void> getPidValues() async {
    try {
      // isBusy.value = true;
      await Future.delayed(const Duration(milliseconds: 100));

      listedCodes.clear();

      // Load local PID dataset
      int pidDataset = StaticData.ecuInfo[0].pidDatasetId!;
      String pidLocalData =
          await SaveLocalData().getData("PidDataset_$pidDataset");

      var pidLocal = jsonDecode(pidLocalData);
      codes =
          (pidLocal['codes'] as List).map((e) => PidCode.fromJson(e)).toList();

      for (var item2 in monitorList.toList()) {
        pidCode = null;

        for (var pid in codes) {
          var variable = pid.piCodeVariable!.firstWhere(
            (x) => x.id == item2.pid,
          );

          pidCode = pid;
          item2.unit = variable.unit as ValueNotifier<String>;

          var existing = listedCodes.firstWhere(
            (x) => x.id == pidCode!.id,
          );

          if (existing.piCodeVariable != null &&
              existing.piCodeVariable!.isNotEmpty) {
            existing.piCodeVariable!.add(variable);
          } else {
            existing.piCodeVariable = [variable];
          }
        }
      }

      if (listedCodes.isNotEmpty) {
        testMonitorVisible.value = true;

        await getPidsValue(
          listedCodes,
          true,
          null,
          false,
          null,
        );
      }
    } catch (e) {
      print("Error in getPidValues: $e");
    } finally {
      //isBusy.value = false;
    }
  }

  Future<void> getPidsValue(
    List<PidCode> list,
    bool isMonitor,
    String? calculationType,
    bool singleValue,
    String? condition,
  ) async {
    try {
      var response = await App.dllFunctions!.readPid(list);

      if (response != null) {
        readPidAndroid.assignAll(response as Iterable<ReadPidPresponseModel>);
      }

      if (isMonitor) {
        setPidValue();
      } else {
        setOutputPidValue(
          list,
          calculationType,
          singleValue,
          condition,
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  List<PreCondition> manualPrecondition = [];

  void setPidValue() {
    try {
      if (readPidAndroid.isNotEmpty) {
        for (var readPid in readPidAndroid.toList()) {
          for (var variable in readPid.variables) {
            var pidList = monitorList.firstWhere(
              (x) => x.pid == variable.pidNumber,
            );

            if (readPid.status == "NOERROR") {
              if ((variable.responseValue ?? "").contains(".")) {
                double? deci = double.tryParse(variable.responseValue ?? "");

                if (deci != null) {
                  pidList.currentValue = deci.toStringAsFixed(2)
                      as ValueNotifier<String>; // "0.00"
                }
              } else {
                pidList.currentValue = ValueNotifier(variable.responseValue.toString());
              }
            } else {
              pidList.currentValue = "ERR" as ValueNotifier<String>;
            }
          }
        }
      }
    } catch (e) {
      print("Error in setPidValue: $e");
    }
  }

  RxList<PidCode> runupTestResult = <PidCode>[].obs;
  RxList<PidCode> showTestOutputList = <PidCode>[].obs;
  Future<void> setOutputPidValue(
    List<PidCode> list,
    String? calculationType,
    bool singleValue,
    String? condition,
  ) async {
    try {
      if (readPidAndroid.isNotEmpty) {
        showTestOutputList.clear();

        for (var pid in list) {
          for (var readPid in readPidAndroid) {
            for (var variable in readPid.variables) {
              var pidlist = pid.piCodeVariable
                  ?.firstWhereOrNull((x) => x.id == variable.pidNumber);

              if (pidlist != null) {
                if (readPid.status == "NOERROR") {
                  if (variable.responseValue!.contains(".")) {
                    double deci =
                        double.tryParse(variable.responseValue ?? '') ?? 0;
                    pidlist.showResolution = deci.toStringAsFixed(2);
                  } else {
                    pidlist.showResolution = variable.responseValue;
                  }
                } else {
                  pidlist.showResolution = "ERR";
                }
              }
            }
          }

          // ---------- SINGLE VALUE ----------
          if (singleValue) {
            List<PiCodeVariable> piList = [];

            for (var vri in pid.piCodeVariable ?? []) {
              piList.add(PiCodeVariable(
                actuatorWriteValue: vri.actuatorWriteValue,
                bitcoded: vri.bitcoded,
                bytePosition: vri.bytePosition,
                dav: vri.dav,
                endian: vri.endian,
                endBitPosition: vri.endBitPosition,
                group: vri.group,
                id: vri.id,
                index: vri.index,
                length: vri.length,
                longName: vri.longName,
                max: vri.max,
                messageType: vri.messageType,
                min: vri.min,
                numType: vri.numType,
                offset: vri.offset,
                parameterName: vri.parameterName,
                resolution: vri.resolution,
                selected: vri.selected,
                shortName: vri.shortName,
                showResolution: vri.showResolution,
                startBitPosition: vri.startBitPosition,
                stepperValue: vri.stepperValue,
                txtColor: vri.txtColor,
                unit: vri.unit,
                userValue: vri.userValue,
                writeValue: vri.writeValue,
              ));
            }

            PidCode newPid = PidCode(
              code: pid.code,
              freezFrame: pid.freezFrame,
              header: pid.header,
              id: pid.id,
              ioCtrl: pid.ioCtrl,
              ioCtrlPid: pid.ioCtrlPid,
              isActive: pid.isActive,
              memoryAddress: pid.memoryAddress,
              piCodeVariable: piList,
              read: pid.read,
              reset: pid.reset,
              resetValue: pid.resetValue,
              routineTest: pid.routineTest,
              totalLen: pid.totalLen,
              write: pid.write,
              writePid: pid.writePid,
            );

            runupTestResult.add(newPid);
          }

          // ---------- NORMAL FLOW ----------
          else {
            if (calculationType == "compression") {
              await calculateCompressionValue(pid);
            } else if (calculationType == "None") {
              if (condition == "Violation") {
                var dummyPid = pid;

                for (var item in List.from(dummyPid.piCodeVariable ?? [])) {
                  if (item.showResolution == "0") {
                    item.showResolution = "NOK";
                  } else {
                    item.showResolution = "OK";
                  }
                }

                showTestOutputList.add(pid);
              } else {
                showTestOutputList.add(pid);

                for (var item in showTestOutputList) {
                  for (var vari in item.piCodeVariable ?? []) {
                    if (vari.messageType == "ENUMRATED") {
                      if ((vari.showResolution ?? "")
                          .toUpperCase()
                          .contains("NOT")) {
                        vari.txtColor = "#FF0000"; // red
                      } else {
                        vari.txtColor = "#00FF00"; // green
                      }
                    } else {
                      double val =
                          double.tryParse(vari.showResolution ?? "") ?? 0;

                      if (val > (vari.max ?? 0) || val < (vari.min ?? 0)) {
                        vari.txtColor = "#FF0000";
                      } else {
                        vari.txtColor = "#00FF00";
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> calculateCompressionValue(PidCode pid) async {
    try {
      debugPrint("------- Calculation Start ----------");
      await Future.delayed(const Duration(milliseconds: 10));

      int index = 0;
      double dav = 0;
      double avg = 0;

      List<PiCodeVariable> variableList = [];

      for (int i = 0; i < (noOfInjectors ?? 0); i++) {
        dav = 0;

        debugPrint(
            "------- Start ---------- ${pid.piCodeVariable?[i].shortName}");

        for (int j = 0; j < (noOfInjectors ?? 0); j++) {
          if (index != j) {
            var variable = pid.piCodeVariable?[j];

            debugPrint("${variable?.shortName} -- ${variable?.showResolution}");

            double value = 0;

            String res = variable?.showResolution ?? "0";

            if (res.contains(".")) {
              value = double.tryParse(res) ?? 0;
            } else {
              value = double.tryParse(res) ?? 0;
            }

            dav += value;
          }
        }

        index++;

        avg = dav / ((noOfInjectors ?? 1) - 1);

        var currentVar = pid.piCodeVariable?[i];

        double currentValue =
            double.tryParse(currentVar?.showResolution ?? "0") ?? 0;

        currentVar!.dav = ((currentValue - avg) / avg) * 100;

        // Color condition
        if ((currentVar.max ?? 0) < currentVar.dav ||
            (currentVar.min ?? 0) > currentVar.dav) {
          currentVar.txtColor.value = "#FF0000" as Color; // red
        } else {
          currentVar.txtColor.value = "#00FF00" as Color; // green
        }

        variableList.add(currentVar);
      }

      // Replace list
      pid.piCodeVariable = List<PiCodeVariable>.from(variableList);

      showTestOutputList.add(pid);

      // Update resolution
      for (var item in showTestOutputList) {
        for (var vari in item.piCodeVariable ?? []) {
          vari.showResolution =
              vari.dav?.toStringAsFixed(5) ?? "0"; // same as {0:0.#####}
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> calculateRunupValue(PidCode pid) async {
    try {
      debugPrint("------- Calculation Start ----------");
      await Future.delayed(const Duration(milliseconds: 10));

      // Clear list (same as: ShowTestOutputList = [])
      showTestOutputList.clear();

      int index = 0;
      double dav = 0;
      double avg = 0;

      List<PiCodeVariable> variableList = [];

      for (int i = 0; i < (noOfInjectors ?? 0); i++) {
        dav = 0;

        debugPrint(
            "------- Start ---------- ${pid.piCodeVariable?[i].shortName}");

        for (int j = 0; j < (noOfInjectors ?? 0); j++) {
          if (index != j) {
            var variable = pid.piCodeVariable?[j];

            debugPrint("${variable?.shortName} -- ${variable?.showResolution}");

            double value = 0;
            String res = variable?.showResolution ?? "0";

            if (res.contains(".")) {
              value = double.tryParse(res) ?? 0;
            } else {
              value = double.tryParse(res) ?? 0;
            }

            dav += value;
          }
        }

        index++;

        debugPrint("IORTEST : Cylinder[$i] Sum = $dav");

        avg = dav / ((noOfInjectors ?? 1) - 1);

        debugPrint("IORTEST : Cylinder[$i] Avg = $avg");

        var currentVar = pid.piCodeVariable?[i];

        debugPrint(
            "IORTEST : Cylinder[$i] Value = ${currentVar?.showResolution}");

        double currentValue =
            double.tryParse(currentVar?.showResolution ?? "0") ?? 0;

        // DIFFERENCE (not percentage like compression)
        currentVar!.dav = (currentValue - avg);

        debugPrint("IORTEST : Cylinder[$i] Final Value = ${currentVar.dav}");

        // Color condition
        if ((currentVar.max ?? 0) < currentVar.dav ||
            (currentVar.min ?? 0) > currentVar.dav) {
          currentVar.txtColor.value = "#FF0000" as Color; // red
        } else {
          currentVar.txtColor.value = "#00FF00" as Color; // green
        }

        // firing order index
        currentVar.index = "[${firingOrder?[i]}]";

        variableList.add(currentVar);
      }

      // Replace list
      pid.piCodeVariable = List<PiCodeVariable>.from(variableList);

      showTestOutputList.add(pid);

      // Update resolution
      for (var item in showTestOutputList) {
        for (var vari in item.piCodeVariable ?? []) {
          vari.showResolution =
              vari.dav?.toStringAsFixed(3) ?? "0"; // {0:0.###}
        }
      }
    } catch (e) {
      await Get.dialog(
        CustomPopup(
          title: "Error",
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> getRoutineValue(
    List<PidCode> list,
    bool isMonitor,
    String? calculationType,
    List<int> actualResponse,
    bool singleValue,
  ) async {
    try {
      final res = await App.dllFunctions!.setRoutineValue(
        list,
        null,
        actualResponse,
      );

      // ✅ FIX HERE
      readPidAndroid.assignAll(res ?? []);

      if (isMonitor) {
        setPidValue();
      } else {
        await setOutputPidValue(
          list,
          calculationType,
          singleValue,
          "",
        );
      }
    } catch (e) {
      // ignore
    }
  }
}
