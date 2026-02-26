import 'dart:convert';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/api/app_envirments.dart';
import 'package:autopeepal/api/app_urls.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/checkJobCard_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/expert_model.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/registerDongle_model.dart';
import 'package:autopeepal/models/remoteJobCard_model.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/updateFirmware_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as client;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthApiService {
  static Future<UserResModel> login(UserModel model) async {
    final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.login);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(model.toJson()),
      );

      print("""
LOGIN API
URL: $url
REQUEST:
${jsonEncode(model.toJson())}
RESPONSE:
${response.body}
""");

      if (response.statusCode == 200) {
        // Parse response directly into UserResModel
        final userResModel = UserResModel.fromJson(jsonDecode(response.body));

        // Save tokens if present
        if (userResModel.token != null) {
          await AppPreferences.saveTokens(
            accessToken: userResModel.token!.access ?? '',
            refreshToken: userResModel.token!.refresh ?? '',
          );
        }

        // Save basic user info
        await AppPreferences.saveUser(
          userId: userResModel.userId.toString(),
          name:
              "${userResModel.firstName ?? ''} ${userResModel.lastName ?? ''}",
          email: userResModel.user ?? '',
        );

        return userResModel;
      }

      if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      }

      if (response.statusCode == 403) {
        throw Exception('Device not authorized');
      }

      throw Exception('Login failed (${response.statusCode})');
    } catch (e) {
      throw Exception('Login API Error: $e');
    }
  }

  static Future<AllModelsModel> getAllModels(int? oemId) async {
    final allModels = AllModelsModel();
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        allModels.message = "Please check internet connection.";
        return allModels;
      }
      final oemId = await AppPreferences.getInt("oemId"); // fetch saved OEM ID
      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.allModels(oemId));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("""
GetAllModels API
URL: $url
RESPONSE:
${response.body}
""");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AllModelsModel.fromJson(jsonData)..message = "success";
      } else {
        allModels.message =
            "${response.statusCode}\n${_deserializeError(response.body)}";
      }
    } catch (e) {
      allModels.message = "Exception in getAllModels(): $e";
    }
    return allModels;
  }

  static String _deserializeError(String data) {
    try {
      final jsonData = jsonDecode(data);
      if (jsonData['error'] != null) return jsonData['error'].toString();
      if (jsonData['detail'] != null) return jsonData['detail'].toString();
    } catch (e) {
      return data;
    }
    return data;
  }

  static Future<Map<bool, String>> getWorkShopData() async {
    final Map<bool, String> retResponse = {};
    try {
      final response = await http
          .get(Uri.parse(AppEnvironment.baseUrl + AppURLs.workShopData));

      if (response.statusCode == 200) {
        retResponse[true] = response.body;
      } else {
        // You can implement deserializeErrorModel in Dart if needed
        retResponse[false] = '${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      retResponse[false] = 'Exception @ApiService.getWorkShopData(): $e';
    }

    return retResponse;
  }

  static Future<FirmwareUpdateModel> getLatestFirmwareVersion(
      String? partNumber) async {
    FirmwareUpdateModel results = FirmwareUpdateModel(); // default empty object
    try {
      final url = Uri.parse(AppURLs.getLatestFirmwareVersion(partNumber));
      final response = await http.get(url);

      print(
          'GET Latest Firmware Version API:\nURL: $url\nRESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        results = FirmwareUpdateModel.fromJson(jsonDecode(response.body));
        results.message = "success";
      } else {
        results.message = 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      results.message = e.toString();
    }

    return results;
  }

  static Future<FirmwareUpdateResponseModel> updateFirmware(
      FirmwareUpdateModel model, String baseUrl) async {
    final url = Uri.parse('$baseUrl/devices/fotax/latest/firmware');
    FirmwareUpdateResponseModel responseModel = FirmwareUpdateResponseModel();

    try {
      // Check network connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isReachable = connectivityResult != ConnectivityResult.none;

      if (isReachable) {
        final jsonBody = jsonEncode(model.toJson());
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonBody,
        );

        print(
            "POST $url\nRequest Body:\n$jsonBody\nResponse:\n${response.body}");

        if (response.statusCode == 200) {
          responseModel =
              FirmwareUpdateResponseModel.fromJson(jsonDecode(response.body));
        } else {
          responseModel.error = 'HTTP ${response.statusCode}';
        }
      } else {
        responseModel.error = 'No internet connection';
      }
    } catch (e) {
      responseModel.error = 'Exception: $e';
    }

    return responseModel;
  }

  static Future<bool> existPasswordCheck(UserModel model) async {
    try {
      final url =
          Uri.parse(AppEnvironment.baseUrl + AppURLs.existPasswordCheck);

      // Convert model to JSON string
      final body = jsonEncode(model.toJson());

      // Make POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("""
EXIST PASSWORD CHECK
URL: $url
REQUEST: $body
RESPONSE: ${response.body}
STATUS CODE: ${response.statusCode}
""");

      // Return true if HTTP 200, else false
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e, stackTrace) {
      // Replace this with your own error handling / toast / dialog
      print("Error in existPasswordCheck: $e\n$stackTrace");
      return false;
    }
  }

  /// Changes the user's password using the JWT token for authorization
  static Future<bool> changePassword(ChangePassword model, String token) async {
    try {
      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.changePassword);

      // Convert model to JSON
      final body = jsonEncode(model.toJson());

      // Make POST request with JWT authorization header
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: body,
      );

      print("""
CHANGE PASSWORD
URL: $url
REQUEST: $body
RESPONSE: ${response.body}
STATUS CODE: ${response.statusCode}
""");

      // Return true if HTTP 200 OK, else false
      return response.statusCode == 200;
    } catch (e, stackTrace) {
      // Replace this with your own error handling / toast / dialog
      print("Error in changePassword: $e\n$stackTrace");
      return false;
    }
  }

  /// Fetches a new Job Card number from the server
  static Future<AutoNewJobCard> getJobCardNumber() async {
    AutoNewJobCard jobCardNumber = AutoNewJobCard();
    final token = await AppPreferences.getAccessToken();
    try {
      // Check network access here (replace with your own connectivity check)
      // For example: using connectivity_plus package
      bool hasInternet = true; // Replace with actual check
      // ignore: dead_code
      if (!hasInternet) {
        jobCardNumber.message = "Please check internet connection.";
        return jobCardNumber;
      }

      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.getJobCardNumber);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      print("""
GET JOB CARD NUMBER
URL: $url
RESPONSE: ${response.body}
STATUS CODE: ${response.statusCode}
""");

      if (response.statusCode == 200) {
        jobCardNumber = AutoNewJobCard.fromJson(jsonDecode(response.body));
        jobCardNumber.message = "success";
      } else {
        // If the server returns an error
        jobCardNumber.message =
            "${response.statusCode}\n${response.body}"; // You can parse error JSON if needed
      }
    } catch (e, stackTrace) {
      jobCardNumber.message =
          "Exception in getJobCardNumber(): $e\n$stackTrace";
    }

    return jobCardNumber;
  }

  Future<List<JobCardModel>?> getJobCard({String? filename}) async {
    try {
      final token = await SharedPreferences.getInstance();
      List<JobCardModel>? jobCards;

      // Check internet connectivity (simple approach)
      bool isOnline = true; // Replace with connectivity check if needed

      if (isOnline) {
        final response = await http.get(
          Uri.parse(AppEnvironment.baseUrl + AppURLs.getJobCard),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'JWT $token',
          },
        );

        if (response.statusCode == 401) {
          // Unauthorized
          print("Unauthorized: You need to login again.");
          return null;
        } else if (response.statusCode == 200) {
          final data = response.body;
          jobCards = (jsonDecode(data) as List)
              .map((e) => JobCardModel.fromJson(e))
              .toList();

          // Save locally for offline use
          await token.setString('JsonList', data);

          return jobCards;
        } else {
          final data = response.body;
          final detail = jsonDecode(data)['detail'];
          print("Error: $detail");
          return null;
        }
        // ignore: dead_code
      } else {
        // Offline: load from local storage
        final jsonListData = token.getString('JsonList') ?? '[]';
        jobCards = (jsonDecode(jsonListData) as List)
            .map((e) => JobCardModel.fromJson(e))
            .toList();
        return jobCards;
      }
    } catch (e) {
      print("Exception: $e");
      // Navigate to login page or handle session expiration
      return null;
    }
  }

  Future<CheckJobCardModel?> checkJobCard(String jobCardNumber) async {
    try {
      final username = 'uptime_user';
      final password = 'data1234';
      final authHeader =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      final url = Uri.parse(
          "https://udaanapprovals.vecv.net/sap/opu/odata/sap/ZODATA_FIR_SRV/ES_HEADER(JobCrd='$jobCardNumber')?\$format=json");

      final response = await http.get(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CheckJobCardModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<List<JobcardModelSecond>?> checkJobCardSecondAPI(
      String jobCardNumber) async {
    try {
      // Construct the URL with credentials
      final url = Uri.parse(
          "http://eos.eicher.in:8082/Api/Ticket/$jobCardNumber?Username=pbhujbal@vecv.in&password=eicher@123");

      // Make the GET request
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse JSON into a list of JobcardModelSecond
        List<dynamic> data = json.decode(response.body);
        List<JobcardModelSecond> jobCards =
            data.map((e) => JobcardModelSecond.fromJson(e)).toList();
        return jobCards;
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<MainResultClass?> sendJobCard(
      SendJobcardData model, String token) async {
    try {
      final mainResultClass = MainResultClass();

      // Check internet connectivity if needed using connectivity_plus
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) return mainResultClass;

      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.sendJobCard);

      // Convert model to JSON
      final body = jsonEncode(model.toJson());

      // Make POST request with JWT token
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: body,
      );

      if (response.statusCode == 400) {
        // Deserialize into SameJobcard when BadRequest
        final sameJobcard = SameJobcard.fromJson(jsonDecode(response.body));
        mainResultClass.sameJobcard = sameJobcard;
        mainResultClass.createJobcard = null;
      } else if (response.statusCode == 200) {
        // Deserialize into JobCardModel for success
        final jobCard = JobCardModel.fromJson(jsonDecode(response.body));
        mainResultClass.sameJobcard = null;
        mainResultClass.createJobcard = jobCard;
      } else {
        print('Unexpected status code: ${response.statusCode}');
      }

      return mainResultClass;
    } catch (e, stackTrace) {
      print('Exception in sendJobCard: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<List<ExistJobCardResult>?> getExistJobCard(
      String token, String jobCardNumber) async {
    try {
      final url = Uri.parse(
          AppEnvironment.baseUrl + AppURLs.existingJobCard(jobCardNumber));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token', // pass your token here
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final existJobCard = ExistJobCard.fromJson(data);
        return existJobCard.results;
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<Result?> postJobCardSession(PostJobCardSession postJobCardSession,
      String token, String jobCardId) async {
    try {
      final url = Uri.parse(
          AppEnvironment.baseUrl + AppURLs.PostJobCardSession(jobCardId));

      // Convert the object to JSON
      final body = jsonEncode(postJobCardSession.toJson());

      // Make the POST request with JWT authorization
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Deserialize response to Result object
        return Result.fromJson(jsonDecode(response.body));
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<OnlineExpertModel?> getOnlineExpert(String token) async {
    try {
      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.getOnlineExpert);

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OnlineExpertModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getOnlineExpert: $e');
      return null;
    }
  }

  Future<MainResponseModel?> createRemoteJobCard(
      RemoteJobCardModel model, String sessionId, String token) async {
    try {
      final url = Uri.parse(
          AppEnvironment.baseUrl + AppURLs.createRemoteJobCard(sessionId));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode(model.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 400) {
        // Bad request -> Already exists
        return MainResponseModel(
          status: "Already Exist",
          badRequestResponseModel: BadRequestResponseModel.fromJson(data),
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        // New job card created
        return MainResponseModel(
          status: "New",
          newRequestResponseModel: ResponseJobCardModel.fromJson(data),
        );
      } else {
        // Other errors
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<ResponseJobCardModel?> updateRemoteJobCard(RemoteJobCardModel model,
      String sessionId, String remoteSessionId, String jwtToken) async {
    try {
      final String url = AppEnvironment.baseUrl +
          AppURLs.updateRemoteJobCard(sessionId, remoteSessionId);

      // Serialize model to JSON
      final String jsonBody = jsonEncode(model.toJson());

      // Make HTTP PUT request with JWT Authorization
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $jwtToken',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Deserialize JSON response to ResponseJobCardModel
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ResponseJobCardModel.fromJson(data);
      } else {
        // Handle errors
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<ResponseRoot?> getRemoteSession(
      String getRemoteSessionId, String jwtToken) async {
    try {
      final String url =
          AppEnvironment.baseUrl + AppURLs.getRemoteSession(getRemoteSessionId);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ResponseRoot.fromJson(data);
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<ResponseRoot?> getExpertRequestList(
      String expertUser, String jwtToken) async {
    try {
      final String url =
          AppEnvironment.baseUrl + AppURLs.expertUser(expertUser);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ResponseRoot.fromJson(data);
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<ResponseJobCardModel?> acceptRemoteRequest(
    ResponseJobCardModel acceptOrDeclineModel,
    String jobCardRequestId,
    String remoteSessionId,
    String jwtToken,
  ) async {
    try {
      final String url = AppEnvironment.baseUrl +
          AppURLs.acceptRemoteRequest(jobCardRequestId, remoteSessionId);

      final body = jsonEncode(acceptOrDeclineModel.toJson());

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $jwtToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ResponseJobCardModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<String?> getDongleList(String jwtToken) async {
    try {
      final String url = AppEnvironment.baseUrl + AppURLs.getDongleList;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Return the raw JSON string
        return response.body;
      } else {
        print('Error fetching dongle list: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<RegisterDongleResponse?> registerDongle(
      RegisterDongleModel model, String token) async {
    try {
      final String url = AppEnvironment.baseUrl + AppURLs.getRegisterDongleList;
      final jsonBody = jsonEncode(model.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 403) {
        // Handle forbidden case if needed
        print('Forbidden: ${response.body}');
        return null;
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final dongleResp = RegDongleResponse.fromJson(data);
        return RegisterDongleResponse(errorRes: dongleResp);
      } else {
        print('Unexpected status: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<dynamic> getData(String token) async {
    try {
      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.getData);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        // Token expired
        print("Token has expired");
        return null;
      }

      // Parse response dynamically
      final data = json.decode(response.body);
      return data;
    } catch (e, stackTrace) {
      print("Error in getData: $e\n$stackTrace");
      return null;
    }
  }

  Future<List<IVNResult>?> getIvnDtc(String token, int id) async {
    try {
      final url = Uri.parse('YOUR_BASE_URL/ivn/get-ivn-dtc-datasets/?id=$id');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return IvnDtc.fromJson(data).results;
      } else if (response.statusCode == 401) {
        print("Token has expired");
        return null;
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, stackTrace) {
      print("Exception in getIvnDtc: $e\n$stackTrace");
      return null;
    }
  }

  Future<PIDModel> getIVNPidDataset(int datasetId, String jwtToken) async {
    final pidModel = PIDModel();
    try {
      final url = Uri.parse(
          AppEnvironment.baseUrl + AppURLs.getIVNPidDataset(datasetId));

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'JWT $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      final data = response.body;

      if (response.statusCode == 200) {
        return PIDModel.fromJson(json.decode(data));
      } else {
        pidModel.message = "${response.statusCode} : ${data}";
        return pidModel;
      }
    } catch (e) {
      pidModel.message = "Exception in getIVNPidDataset: $e";
      return pidModel;
    }
  }

  Future<DTCMaskRoot?> getDTCMask(String token, String baseUrl) async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse(AppEnvironment.baseUrl + AppURLs.getDTCMask),
        headers: {'Authorization': 'JWT $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DTCMaskRoot.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<DtcMainModel> getDtcs(
      String token, int datasetId, String baseUrl) async {
    DtcMainModel results = DtcMainModel(message: ''); // default empty
    try {
      final client = http.Client();
      final url = AppEnvironment.baseUrl + AppURLs.getDtcs(datasetId);

      final response = await client.get(
        Uri.parse(url),
        headers: {'Authorization': 'JWT $token'},
      );

      final data = response.body;
      print('Get All Dtcs API\n$url\nResponse: $data');

      if (response.statusCode == 200) {
        results = DtcMainModel.fromJson(jsonDecode(data));
        results.message = 'success';
      } else {
        results.message = '${response.statusCode}\n${data}';
      }

      return results;
    } catch (e) {
      results.message = 'Exception in getDtcs(): $e';
      return results;
    }
  }

  Future<List<ResultUnlock>?> getUnlockData() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return null;
      }

      final response = await client
          .get(Uri.parse(AppEnvironment.baseUrl + AppURLs.getECUUnlockData));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UnlockEcuModel.fromJson(data).results;
      } else {
        return null;
      }
    } catch (e) {
      print('Error in getUnlockData: $e');
      return null;
    }
  }

  Future<GdModelGD> getGD(int submodelId) async {
    GdModelGD result = GdModelGD();
    final token = AppPreferences.getAccessToken();
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        final url =
            Uri.parse(AppEnvironment.baseUrl + AppURLs.getGD(submodelId));
        final response = await http.get(
          url,
          headers: {'Authorization': 'JWT $token'},
        );

        final data = response.body;

        if (response.statusCode == 200) {
          result = GdModelGD.fromJson(json.decode(data));
          result.message = "success";
        } else {
          result.message = "${response.statusCode}\n$data";
        }
      } else {
        result.message = "Please check internet connection.";
      }
      return result;
    } catch (ex) {
      result.message = "Exception in getGD(): ${ex.toString()}";
      return result;
    }
  }

  Future<String> readTextFile(String fileName) async {
    try {
      // Make sure your file is in the assets folder and declared in pubspec.yaml
      String text = await rootBundle.loadString('assets/json_files/$fileName');
      return text;
    } catch (e) {
      // In case of error, return empty string
      return '';
    }
  }

  void showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<String> downloadFileContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        throw Exception("Failed to download file: ${response.body}");
      }
    } catch (e) {
      // You can log the error or show a message
      print("Exception in downloadFileContent: $e");
      return "";
    }
  }

  Future<void> dtcRecord(
      List<PostDtcRecord> pdr, String token, String jobCardId) async {
    try {
      // Create request body
      final obg = {'dtc': pdr.map((e) => e.toJson()).toList()};

      final jsonBody = jsonEncode(obg);

      // POST request
      final response = await http.post(
        Uri.parse(AppEnvironment.baseUrl + AppURLs.dtcRecord(jobCardId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Successfully sent
        print("DTC Record posted successfully");
        print("Response: ${response.body}");
      } else {
        print("Failed to post DTC record: ${response.body}");
      }
    } catch (e, stacktrace) {
      // Show message equivalent
      print("Exception in dtcRecord: $e");
      print(stacktrace);
    }
  }

  Future<void> clearDtcRecord({
    required List<ClearDtcRecord> records,
    required String token,
    required String jobCardId,
    required String baseUrl,
  }) async {
    try {
      final url = Uri.parse(
          AppEnvironment.baseUrl+AppURLs.clearDtcRecord(jobCardId));

      // Wrap list in an object if API expects it
      final payload = {'dtc': records.map((e) => e.toJson()).toList()};
      final body = jsonEncode(payload);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('DTC cleared successfully: ${response.body}');
      } else {
        print('Failed to clear DTC: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Exception while clearing DTC: $e');
    }
  }
}
