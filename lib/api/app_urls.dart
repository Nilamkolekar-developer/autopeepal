class AppURLs {
  static String get login => "accounts/login/";
  static String allModels(int? Id) => "models/get-models/?oem=${Id}";
  static String get workShopData => "oem/get-workshop";
  static String getLatestFirmwareVersion(String? partNumber) =>
      "http://143.244.142.0/api/v1/pipo/firmware_manager/list/?part_no=$partNumber";
  static String get updateFirmware => "devices/fotax/latest/firmware";
  static String get existPasswordCheck => "accounts/login/";
  static String get changePassword => "accounts/password/change/";
  static String get getJobCardNumber => "analyze/gen-name";
  static String get getJobCard => "analyze/my-job-card/";
  static String get sendJobCard => "analyze/job-card/";
  static String existingJobCard(String? jobCardNumber) =>
      "analyze/job-card/?job_card_name=$jobCardNumber";
  static String PostJobCardSession(String? jobCardId) =>
      "analyze/job-card/$jobCardId/job-card-session/";
  static String get getOnlineExpert => "user/online-expert-users/?format=json";
  static String createRemoteJobCard(String? sessionId) =>
      "analyze/job-card-session/$sessionId/remote-session/";
  static String updateRemoteJobCard(
          String? sessionId, String? remote_session_id) =>
      "analyze/job-card-session/$sessionId/remote-session/${remote_session_id}/";
  static String getRemoteSession(String? GetRemoteSessionid) =>
      "analyze/job-card-session/${GetRemoteSessionid}/remote-session/";
  static String expertUser(String? expert_user) =>
      "analyze/expert-user-status-list/?expert_user=${expert_user}";
  static String acceptRemoteRequest(
          String? jobCardRequestId, String? remoteSessionId) =>
      "analyze/job-card-session/$jobCardRequestId/remote-session/$remoteSessionId/";
  static String get getDongleList => "devices/list/obd-dongles/active/";
  static String get getRegisterDongleList => "devices/register/odb-device/";
  static String get getData => "oem/get-data/";
  static String getIvnDtc(int? id) => "ivn/get-ivn-dtc-datasets/?id=$id";
  static String getIVNPidDataset(int? datasetId) =>
      "ivn/get-ivn-pid-datasets/?id=${datasetId}";
  static String get getDTCMask => "dtc_mask/dtc-mask/";
  static String getDtcs(int? datasetId) =>
      "datasets/get-dtc-datasets/?id=${datasetId}";
  static String get getECUUnlockData => "models/unlock-list/";
  static String getGD(int? submodelId) =>
      "gdauthor/gd/gd-by-year_id-dtc_id/?name=${submodelId}";
  static String dtcRecord(String? jobCardId) =>
      "analyze/job-card-session/${jobCardId.toString()}/dtc-record/";
       static String clearDtcRecord(String? jobCardId) =>
      "analyze/job-card-session/${jobCardId.toString()}/clear-record/";
}
