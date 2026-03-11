import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/utils/get_device_unique_id.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateJobcardController extends GetxController {
  // Selected values for dropdowns
  final selectedOEM = "".obs;
  final selectedWorkshopGroup = "".obs;
  final selectedCity = "".obs;
  final selectedWorkshop = "".obs;
  RxBool isBusy = false.obs;

  Rx<TextEditingController> regNo = TextEditingController().obs;
  Rx<TextEditingController> chassisNo = TextEditingController().obs;
  Rx<TextEditingController> engineNo = TextEditingController().obs;
  Rx<TextEditingController> kmCovered = TextEditingController().obs;
  Rx<TextEditingController> complaint = TextEditingController().obs;
  Rx<TextEditingController> jobCardId = TextEditingController().obs;
  final AuthApiService services = AuthApiService();
  final GetDeviceUniqueId getDeviceUniqueId = GetDeviceUniqueId();
  final SaveLocalData saveLocalData = SaveLocalData();
  RxList<SubModel> subModelList = <SubModel>[].obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    init();
    initModelList();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // Selected dropdown values
  RxString selectedModel = ''.obs;
  RxString selectedRegulation = ''.obs;

// Selected objects
  Rx<ModelResult?> selectedModelObj = Rx<ModelResult?>(null);
  Rx<SubModel?> selectedSubModel = Rx<SubModel?>(null);

// Lists
  RxList<ModelResult> modelList = <ModelResult>[].obs;
  RxList<SubModel> filteredSubModels = <SubModel>[].obs;

// Extra info
  RxString selectedSubModelName = ''.obs;
  RxString selectedSubModelYear = ''.obs;

  Future<void> initModelList() async {
    try {
      print("🔹 initModelList() started");

      String? localData = await saveLocalData.getData('MODEL_LocalList');
      print("📦 Local Data from storage: $localData");

      if (localData.isEmpty) {
        print("⚠️ No local data found. Calling API...");

        AllModelsModel apiData = await AuthApiService.getAllModels();

        print("🌐 API Response Message: ${apiData.message}");
        print("🌐 API Results Count: ${apiData.results?.length}");

        if (apiData.message == "success" && apiData.results != null) {
          print("✅ API success. Saving to local storage...");

          await saveLocalData.saveData(
            'MODEL_LocalList',
            jsonEncode(apiData.toJson()),
          );

          localData = jsonEncode(apiData.toJson());
          print("💾 Data saved locally.");
        } else {
          print("❌ API failed: ${apiData.message}");
          return;
        }
      } else {
        print("✅ Loaded models from local storage.");
      }

      print("🔄 Parsing JSON to AllModelsModel...");

      AllModelsModel allModels = AllModelsModel.fromJson(jsonDecode(localData));

      print("📊 Parsed Model Count: ${allModels.results?.length}");

      modelList.value = allModels.results ?? [];

      print("🎯 modelList updated. Total models: ${modelList.length}");
    } catch (e, stackTrace) {
      print("❌ Error loading model list: $e");
      print("📍 StackTrace: $stackTrace");
    }
  }

  void selectModel(String modelName) {
    print("🚗 Selected Model: $modelName");

    selectedModel.value = modelName;

    final model = modelList.firstWhere(
      (m) => m.name?.toLowerCase() == modelName.toLowerCase(),
      orElse: () => ModelResult(name: '', subModels: []),
    );

    filteredSubModels.value = model.subModels ?? [];

    print("📊 SubModels Found: ${filteredSubModels.length}");

    // reset regulation when model changes
    selectedRegulation.value = '';
    selectedSubModel.value = null;
  }

  Future<void> init() async {
    try {
      isBusy.value = true;

      final response = await AuthApiService.getJobCardNumber();

      if (response.message == "success") {
        jobCardId.value.text = response.name!.toUpperCase();
      } else {
        Get.dialog(
          CustomPopup(
            title: "Error",
            message: "${response.message}",
            onButtonPressed: () {
              print("Closed Failed dialog");
              Get.back();
            },
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> submitJobCard() async {
    try {
      isBusy.value = true;

      String? modelWithSubmodel = "";

      // ignore: unnecessary_null_comparison
      if (selectedModel.value == null) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please select Model",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      if (selectedSubModel.value == null) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please select SubModel",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      RegExp pattern = RegExp(r'^[a-zA-Z0-9]*$');

      if (regNo.value.text.length < 10 || !pattern.hasMatch(regNo.value.text)) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please enter valid Registration Number",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      if (chassisNo.value.text.length < 17 ||
          !pattern.hasMatch(chassisNo.value.text)) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please enter valid Chassis Numberr",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      if (engineNo.value.text.isEmpty ||
          !pattern.hasMatch(engineNo.value.text)) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please enter valid Engine Number",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      if (kmCovered.value.text.isEmpty ||
          int.tryParse(kmCovered.value.text) == null) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please enter valid distance covered",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      if (complaint.value.text.isEmpty) {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please enter Complaint",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        return;
      }

      /// NETWORK CHECK
      var connectivity = await Connectivity().checkConnectivity();

      if (connectivity != ConnectivityResult.none) {
        String deviceId = await getDeviceUniqueId.getId();

        SendJobcardData sendJobcardData = SendJobcardData(
          chasisId: chassisNo.value.text,
          complaints: complaint.value.text,
          date: DateTime.now().toString(),
          engineNo: engineNo.value.text,
          kmCovered: kmCovered.value.text,
          vehicleModelId: selectedSubModel.value!.id.toString(),
          model: selectedModel.value,
          vehModDes: "test",
          status: "new",
          jobCardName: jobCardId.value.text,
          submodel: "Na",
          vehicleSegment: "Na",
          jobCardStatus: "new",
          deviceMacId: deviceId,
          fertCode: "1233",
          registrationNo: regNo.value.text,
          sessionType: "regular",
          source: "gen",
        );

        var createJobCard = await services.sendJobCard(sendJobcardData);

        if (createJobCard != null) {
          if (createJobCard.createJobcard != null) {
            var item = createJobCard.createJobcard;

            formatDate(item!.jobCardSession![0].startDate);

            if (item.jobCardSession![0].vehicleModel?.name != "NA") {
              modelWithSubmodel =
                  "${item.jobCardSession![0].vehicleModel!.parent!.name}-${item.jobCardSession![0].vehicleModel!.name}";
            } else {
              modelWithSubmodel =
                  item.jobCardSession![0].vehicleModel!.parent?.name!;
            }

            JobCardListModel jobCardListModel = JobCardListModel(
              jobcardName: item.jobCardName,
              workshop: item.createdBy!.usUser!.workshop!.name,
              chasisId: item.chasisId,
              registrationNo: item.registrationNo,
              complaints: item.complaints,
              fertCode: item.fertCode,
              jobcardStatus: item.status,
              vehicleSegment: item.vehicleSegment,
              modified: item.modified,
              kmCovered: item.kmCovered,
              sessionId: item.jobCardSession![0].sessionId,
              status: item.jobCardSession![0].status,
              sessionType: item.jobCardSession![0].sessionType,
              source: item.jobCardSession![0].source,
              endDate: item.jobCardSession![0].endDate,
              startDate: item.jobCardSession![0].startDate,
              jobCard: item.jobCardSession![0].jobCard,
              id: item.jobCardSession![0].id,
              vehicleModel: item.jobCardSession![0].vehicleModel!.parent!.name,
              modelYear: item.jobCardSession![0].vehicleModel?.modelYear,
              subModel: item.jobCardSession![0].vehicleModel!.name,
              // showStartDate: date??,
              modelId: 0,
              subModelId: item.jobCardSession![0].vehicleModel!.id,
              modelWithSubmodel: modelWithSubmodel,
              city: item.createdBy!.usUser!.workshop!.city,
              state: item.createdBy!.usUser!.workshop!.state,
            );

            App.sessionId = item.jobCardSession![0].id!;

            /// ECU DATA
            StaticData.ecuInfo = [];
            final subModel = selectedSubModel.value;
            for (var ecu in subModel!.ecus!) {
              StaticData.ecuInfo.add(EcuDataSet(
                readDtcIndex: ecu.readDtcFnIndex?.value,
                pidDatasetId: ecu.pidDatasets?.firstOrNull?.id,
                clearDtcIndex: ecu.clearDtcFnIndex?.value,
                dtcDatasetId: ecu.datasets?.firstOrNull?.id,
                ecuName: ecu.name ?? 'Unknown ECU',
                seedKeyIndex: ecu.seedkeyalgoFnIndex?.value,
                writePidIndex: ecu.writeDataFnIndex?.value,
                txHeader: ecu.txHeader,
                rxHeader: ecu.rxHeader,
                protocol: ecu.protocol,
                ecuID: ecu.id ?? 0,
                iorTestFnIndex: ecu.iorTestFnIndex?.value,
                channelId: ecu.channel,
                modelName: selectedModel.value,
                submodelName: subModel.name ?? 'Unknown Submodel',
                modelYear: subModel.modelYear,
                ecu2: ecu.ecu?.firstOrNull,
                ffSet: ecu.ffSet,
                firingSequence: ecu.firingSequence,
                noOfInjectors: ecu.noOfInjectors,
              ));
            }
            Get.dialog(
              CustomPopup(
                title: "Alert",
                message: "Jobcard created successfully",
                onButtonPressed: () => Get.back(),
              ),
              barrierDismissible: false,
            );

            Get.toNamed(
              Routes.jobCardDetails,
              arguments: jobCardListModel,
            );
          } else if (createJobCard.sameJobcard != null) {
            Get.dialog(
              CustomPopup(
                title: "Alert",
                message: "This jobcard number is already exist",
                onButtonPressed: () => Get.back(),
              ),
              barrierDismissible: false,
            );
          }
        } else {
          Get.dialog(
            CustomPopup(
              title: "Alert",
              message: "Please Check Server API!! Job Card Not Created",
              onButtonPressed: () => Get.back(),
            ),
            barrierDismissible: false,
          );
        }
      } else {
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Please connect to internet",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      Get.dialog(
        CustomPopup(
          title: "Exception @CreateJobcard",
          message: e.toString(),
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      isBusy.value = false;
    }
  }
}
