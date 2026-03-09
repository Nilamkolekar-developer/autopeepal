import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:get/get.dart';

class JobardController extends GetxController {
  final AuthApiService apiServices = AuthApiService();
  late String vciName;

  List<ModelResult> modelList = [];
  RxBool isBusy = false.obs;
  RxList<JobCardListModel> jobCardList = <JobCardListModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getJobCardList();
    var args = Get.arguments;
    if (args != null && args is List<ModelResult>) {
      modelList = args;
      print("ModelList received: ${modelList.length} items");
    } else {
      modelList = [];
      print("No ModelList received!");
    }
  }

  Future<void> jobcardSelect(JobCardListModel item) async {
    try {
      print("---- jobcardSelect START ----");

      isBusy.value = true;

      App.sessionId = item.id!;
      App.subModelId = item.subModelId!;

      print("Selected JobCard ID: ${item.id}");
      print("Selected SubModel ID: ${item.subModelId}");
      print("ModelList length: ${modelList.length}");

      String selectedModel = "";
      SubModel? selectedSubModel;

      for (var model in modelList) {
        print("Checking Model: ${model.name}");

        for (var subModel in model.subModels ?? []) {
          print("SubModel ID: ${subModel.id}  Name: ${subModel.name}");

          if (subModel.id == item.subModelId) {
            print("✔ MATCH FOUND");

            selectedModel = model.name ?? '';
            selectedSubModel = subModel;
            break;
          }
        }

        if (selectedSubModel != null) break;
      }

      if (selectedSubModel != null) {
        print("Selected Model: $selectedModel");
        print("Selected SubModel: ${selectedSubModel.name}");

        StaticData.ecuInfo = [];

        for (var ecu in selectedSubModel.ecus ?? []) {
          print("ECU Name: ${ecu.name}  ID: ${ecu.id}");

          StaticData.ecuInfo.add(
            EcuDataSet(
              readDtcIndex: ecu.readDtcFnIndex?.value,
              pidDatasetId:
                  (ecu.pidDatasets != null && ecu.pidDatasets!.isNotEmpty)
                      ? ecu.pidDatasets!.first.id
                      : null,
              dtcDatasetId: (ecu.datasets != null && ecu.datasets!.isNotEmpty)
                  ? ecu.datasets!.first.id
                  : null,
              ecu2: (ecu.ecu != null && ecu.ecu!.isNotEmpty)
                  ? ecu.ecu!.first
                  : null,
              clearDtcIndex: ecu.clearDtcFnIndex?.value,
              ecuName: ecu.name ?? '',
              seedKeyIndex: ecu.seedkeyalgoFnIndex?.value,
              writePidIndex: ecu.writeDataFnIndex?.value,
              txHeader: ecu.txHeader,
              rxHeader: ecu.rxHeader,
              protocol: ecu.protocol,
              ecuID: ecu.id ?? 0,
              iorTestFnIndex: ecu.iorTestFnIndex?.value,
              channelId: ecu.channel,
              modelName: selectedModel,
              submodelName: selectedSubModel.name,
              modelYear: selectedSubModel.modelYear,
              ffSet: ecu.ffSet,
              firingSequence: ecu.firingSequence,
              noOfInjectors: ecu.noOfInjectors,
            ),
          );
        }

        print("Total ECU Added: ${StaticData.ecuInfo.length}");

        Get.toNamed(Routes.jobCardDetails, arguments: item);
      } else {
        print("❌ Selected model not found");

        Get.dialog(
          CustomPopup(
            title: "Error",
            message: "Selected model not found",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
      }
    } catch (ex) {
      print("❌ Exception in jobcardSelect: $ex");

      Get.dialog(
        CustomPopup(
          title: "Exception",
          message: "@JobcardSelectCommand : $ex",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } finally {
      isBusy.value = false;
      print("---- jobcardSelect END ----");
    }
  }

  Future<void> newJobcard() async {
    try {
      isBusy.value = true;

      Get.toNamed(Routes.createJobCardScreen, arguments: modelList);
    } catch (ex) {
      Get.dialog(
        CustomPopup(
          title: "Exception",
          message: "@NewJobcardCommand : $ex",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> getJobCardList() async {
    try {
      print("---- getJobCardList START ----");
      isBusy.value = true;

      print("Fetching Job Cards from API...");
      var result = await apiServices.getJobCard("JbCardJson.txt");

      if (result != null && result.isNotEmpty) {
        print("Job Cards fetched: ${result.length}");
        List<JobCardListModel> list = [];

        for (var item in result) {
          print("Processing JobCard: ${item.jobCardName}");

          if (item.jobCardSession != null && item.jobCardSession!.isNotEmpty) {
            var session = item.jobCardSession!.first;

            print(
                "Session ID: ${session.sessionId}, Status: ${session.status}");

            if (session.status != "closed") {
              try {
                String modelWithSubmodel = "";

                if (session.vehicleModel?.name != null &&
                    session.vehicleModel!.name != "NA") {
                  modelWithSubmodel =
                      "${session.vehicleModel!.parent!.name}-${session.vehicleModel!.name}";
                } else {
                  modelWithSubmodel =
                      session.vehicleModel!.parent!.name ?? "Unknown";
                }

                print("Model with Submodel: $modelWithSubmodel");

                list.add(
                  JobCardListModel(
                    jobcardName: item.jobCardName,
                    chasisId: item.chasisId,
                    registrationNo: item.registrationNo,
                    complaints: item.complaints,
                    fertCode: item.fertCode,
                    jobcardStatus: item.status,
                    vehicleSegment: item.vehicleSegment,
                    modified: item.modified,
                    kmCovered: item.kmCovered,
                    sessionId: session.sessionId,
                    status: session.status,
                    sessionType: session.sessionType,
                    source: session.source,
                    endDate: session.endDate,
                    startDate: session.startDate,
                    jobCard: session.jobCard,
                    id: session.id,
                    vehicleModel:
                        session.vehicleModel?.parent?.name ?? "Unknown",
                    modelYear: session.vehicleModel?.modelYear,
                    subModel: session.vehicleModel?.name,
                    showStartDate: session.startDate,
                    subModelId: session.vehicleModel?.id,
                    modelWithSubmodel: modelWithSubmodel,
                    workshop:
                        item.createdBy?.usUser?.workshop?.name ?? "Unknown",
                    city: item.createdBy?.usUser?.workshop?.city ?? "Unknown",
                    state: item.createdBy?.usUser?.workshop?.state ?? "Unknown",
                  ),
                );

                print("✅ JobCard added: ${item.jobCardName}");
              } catch (e) {
                print("❌ Error processing JobCard ${item.jobCardName}: $e");
              }
            } else {
              print("Skipping closed session: ${session.sessionId}");
            }
          } else {
            print("❌ No sessions found for JobCard: ${item.jobCardName}");
          }
        }

        jobCardList.value = list;
        // ignore: invalid_use_of_protected_member
        print("Total JobCards loaded: ${jobCardList.value.length}");
      } else {
        print("❌ No JobCards returned from API.");
      }
    } catch (ex) {
      print("GetJobCardList Exception : $ex");
    } finally {
      isBusy.value = false;
      print("---- getJobCardList END ----");
    }
  }
}
