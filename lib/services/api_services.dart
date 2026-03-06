import 'dart:convert';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/api/app_envirments.dart';
import 'package:autopeepal/api/app_urls.dart';
import 'package:autopeepal/models/actuatorTest_model.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/checkJobCard_model.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/expert_model.dart';
import 'package:autopeepal/models/flashRecord_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/iotTest_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/listNumber_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/pidLiveRecord_model.dart';
import 'package:autopeepal/models/registerDongle_model.dart';
import 'package:autopeepal/models/remoteJobCard_model.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/updateFirmware_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as client;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthApiService {
//   static Future<UserResModel> login(UserModel model) async {
//     final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.login);

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(model.toJson()),
//       );

//       print("""
// LOGIN API
// URL: $url
// REQUEST:
// ${jsonEncode(model.toJson())}
// RESPONSE:
// ${response.body}
// """);

//       if (response.statusCode == 200) {
//         // Parse response directly into UserResModel
//         final userResModel = UserResModel.fromJson(jsonDecode(response.body));

//         // Save tokens if present
//         if (userResModel.token != null) {
//           await AppPreferences.saveTokens(
//             accessToken: userResModel.token!.access ?? '',
//             refreshToken: userResModel.token!.refresh ?? '',
//           );
//         }

//         // Save basic user info
//         await AppPreferences.saveUser(
//           userId: userResModel.userId.toString(),
//           name:
//               "${userResModel.firstName ?? ''} ${userResModel.lastName ?? ''}",
//           email: userResModel.user ?? '',
//         );

//         return userResModel;
//       }

//       if (response.statusCode == 401) {
//         throw Exception('Invalid username or password');
//       }

//       if (response.statusCode == 403) {
//         throw Exception('Device not authorized');
//       }

//       throw Exception('Login failed (${response.statusCode})');
//     } catch (e) {
//       throw Exception('Login API Error: $e');
//     }
//   }

//   static Future<UserResModel> login(UserModel model) async {
//     final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.login);

//     UserResModel loginResponse = UserResModel();

//     try {
//       final jsonBody = jsonEncode(model.toJson());
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonBody,
//       );

//       debugPrint("""
// LOGIN API
// URL: $url
// REQUEST:
// $jsonBody
// RESPONSE:
// ${response.body}
// """);

//       if (response.statusCode == 200) {
//         loginResponse = UserResModel.fromJson(jsonDecode(response.body));

//         // Save tokens if available
//         if (loginResponse.token != null) {
//           await AppPreferences.saveTokens(
//             accessToken: loginResponse.token!.access ?? '',
//             refreshToken: loginResponse.token!.refresh ?? '',
//           );
//         }

//         // Save basic user info
//         await AppPreferences.saveUser(
//           userId: loginResponse.userId.toString(),
//           name:
//               "${loginResponse.firstName ?? ''} ${loginResponse.lastName ?? ''}",
//           email: loginResponse.user ?? '',
//         );

//         loginResponse.message = "success";
//       } else if (response.statusCode == 401) {
//         loginResponse.message = 'Invalid username or password';
//       } else if (response.statusCode == 403) {
//         loginResponse.message = 'Device not authorized';
//       } else {
//         loginResponse.message = 'Login failed (${response.statusCode})';
//       }
//     } catch (e) {
//       // Network or other exception
//       loginResponse.message = "Exception @AuthApiService.login(): $e";
//     }

//     return loginResponse;
//   }

  static Future<UserResModel> login(UserModel model) async {
    final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.login);
    UserResModel loginResponse = UserResModel();

    try {
      // Serialize request body
      final jsonBody = jsonEncode(model.toJson());

      // HTTP POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      // Debug log
      print("""
LOGIN API
URL: $url
REQUEST:
$jsonBody
RESPONSE:
${response.body}
""");

      if (response.statusCode == 200) {
        // Deserialize response
        loginResponse = UserResModel.fromJson(jsonDecode(response.body));

        // Save token in SharedPreferences
        if (loginResponse.token != null) {
          await AppPreferences.saveTokens(
            accessToken: loginResponse.token?.access ?? '',
            refreshToken: loginResponse.token?.refresh ?? '',
          );
        }

        // Save basic user info
        await AppPreferences.saveUser(
          userId: loginResponse.userId.toString(),
          name: "${loginResponse.firstName ?? ''} ${loginResponse.lastName ?? ''}",
          email: loginResponse.user ?? '',
        );

        // Set message as success
        loginResponse.message = "success";
      } else if (response.statusCode == 401) {
        loginResponse.message = 'Invalid username or password';
      } else if (response.statusCode == 403) {
        loginResponse.message = 'Device not authorized';
      } else {
        loginResponse.message = 'Login failed (${response.statusCode})';
      }
    } catch (e) {
      loginResponse.message = "Exception @AuthApiService.login(): $e";
    }

    return loginResponse;
  }


  static Future<AllModelsModel> getAllModels([int? oemId]) async {
    final allModels = AllModelsModel();
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        allModels.message = "Please check internet connection.";
        return allModels;
      }

      // If oemId is null, fetch from saved preferences
      oemId ??= await AppPreferences.getInt("oemId");

      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.allModels(oemId));

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
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

  Future<List<JobCardModel>?> getJobCard(String filename) async {
  try {
    final token = await AppPreferences.getAccessToken();
    final prefs = await SharedPreferences.getInstance();

    List<JobCardModel>? jobCards;
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      final response = await http.get(
        Uri.parse(AppEnvironment.baseUrl + AppURLs.getJobCard),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
      );

      final data = response.body;

      if (response.statusCode == 401) {
        print("Unauthorized: Login again");
        Get.offAll(Routes.loginScreen);
        return null;
      } 
      else if (response.statusCode == 200) {

        final decoded = jsonDecode(data) as List;

        jobCards = decoded
            .map((e) => JobCardModel.fromJson(e))
            .toList();
        await prefs.setString('JsonList', data);

        return jobCards;
      } 
      else {
        final detail = jsonDecode(data)['detail'];
        print("Error: $detail");
        return null;
      }
    } 
    else {
      /// Offline mode → Load from local storage
      final jsonListData = prefs.getString('JsonList');

      if (jsonListData != null) {
        final decoded = jsonDecode(jsonListData) as List;

        jobCards = decoded
            .map((e) => JobCardModel.fromJson(e))
            .toList();

        return jobCards;
      }

      return null;
    }
  } 
  catch (ex) {
    print("Session Expired: $ex");

    Get.offAll(Routes.loginScreen);

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
      final url = Uri.parse(
          '${AppEnvironment.baseUrl}ivn/get-ivn-dtc-datasets/?id=$id');
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
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

  Future<DtcMainModel> getDtcs(int datasetId) async {
    DtcMainModel results = DtcMainModel(message: ''); // default empty
    final token = await AppPreferences.getAccessToken();
    try {
      final client = http.Client();
      final url = AppEnvironment.baseUrl + AppURLs.getDtcs(datasetId);

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT $token',
        },
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

  // Future<GdModelGD> getGD(int submodelId) async {
  //   GdModelGD result = GdModelGD();
  //   final token =await AppPreferences.getAccessToken();
  //   try {
      
  //       final url =
  //           Uri.parse(AppEnvironment.baseUrl + AppURLs.getGD(submodelId));
  //       final response = await http.get(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'JWT $token',
  //         },
  //       );

  //       final data = response.body;

  //       if (response.statusCode == 200) {
  //         result = GdModelGD.fromJson(json.decode(data));
  //         result.message = "success";
  //       } else {
  //         result.message = "${response.statusCode}\n$data";
  //       }
      
  //     return result;
  //   } catch (ex) {
  //     result.message = "Exception in getGD(): ${ex.toString()}";
  //     return result;
  //   }
  // }

  Future<GdModelGD> getGD(int submodelId) async {
  GdModelGD result = GdModelGD(message: ''); // initialize message safely
  final token = await AppPreferences.getAccessToken();

  try {
    final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.getGD(submodelId));
    print("🔹 GET URL: $url"); // print URL

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'JWT $token',
      },
    );

    print("🔹 Response Status: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    final data = response.body;

    if (response.statusCode == 200) {
      result = GdModelGD.fromJson(json.decode(data));
      result.message = "success";
      print("✅ GD parsed successfully: ${result.results?.length ?? 0} items");
    } else {
      result.message = "${response.statusCode}\n$data";
      print("❌ Error fetching GD: ${result.message}");
    }

    return result;
  } catch (ex) {
    result.message = "Exception in getGD(): ${ex.toString()}";
    print("⚠️ Exception in getGD(): ${ex.toString()}");
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
      final url =
          Uri.parse(AppEnvironment.baseUrl + AppURLs.clearDtcRecord(jobCardId));

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

  Future<bool> pidWriteRecord({
    required List<PidWriteRecordItem> records,
    required String token,
    required String jobCardId,
    required String baseUrl,
  }) async {
    try {
      final url =
          Uri.parse(AppEnvironment.baseUrl + AppURLs.pidWriteRecord(jobCardId));

      // Wrap the list in a parent object
      final payload = PidWriteRecord(pidWriteRecords: records);
      final body = jsonEncode(payload.toJson());

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to write PID: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception while writing PID: $e');
      return false;
    }
  }

  /// Returns true if API call is successful, false otherwise
  Future<bool> pidLiveRecord(
    List<PIDLiveRecord> plr,
    String token,
    String jobCardId,
  ) async {
    try {
      final uri = Uri.parse(
        AppEnvironment.baseUrl + AppURLs.pidliveRecord(jobCardId),
      );

      // Serialize list to JSON
      String jsonString = jsonEncode(plr.map((e) => e.toJson()).toList());

      // ---- IMPORTANT ----
      // C# logic:
      // JsonConvert.SerializeObject(PLR).Substring(1)
      // then remove last char
      //
      // This converts: [ {...} ]  -->  {...}
      //
      // Doing the same in Dart:
      if (jsonString.startsWith('[') && jsonString.endsWith(']')) {
        jsonString = jsonString.substring(1, jsonString.length - 1);
      }

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: jsonString,
      );

      print('RECORD RESPONSE ${response.body}');

      if (response.statusCode == 400) {
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print(stackTrace);
      return false;
    }
  }

  Future<bool> pidSnapshotRecord(
    List<SnapshotRecord> snapshotRecords,
    String token,
    String jobCardId,
  ) async {
    try {
      final uri = Uri.parse(
        AppEnvironment.baseUrl + AppURLs.pidSnapShotRecord(jobCardId),
      );

      // Create object same as C#
      final bodyObject = {
        'pid_snapshot': snapshotRecords.map((e) => e.toJson()).toList(),
      };

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyObject),
      );

      print('SNAPSHOT RESPONSE ${response.body}');

      // C# checks for HttpStatusCode.Created (201)
      return response.statusCode == 201;
    } catch (e, stackTrace) {
      print('PID SNAPSHOT ERROR: $e');
      print(stackTrace);
      return false;
    }
  }

  /// Returns true on success (same behavior as intended C#)
  Future<bool> flashRecord(
    List<FlashRecord> records,
    String token,
    String jobCardId,
  ) async {
    try {
      final uri = Uri.parse(
        AppEnvironment.baseUrl + AppURLs.flashRecord(jobCardId),
      );

      // Serialize list to JSON
      String jsonString = jsonEncode(records.map((e) => e.toJson()).toList());

      // ---- SAME AS C# ----
      // JsonConvert.SerializeObject(FR).Replace("]", "").Replace("[", "")
      if (jsonString.startsWith('[') && jsonString.endsWith(']')) {
        jsonString = jsonString.substring(1, jsonString.length - 1);
      }

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: jsonString,
      );

      print('FLASH RECORD RESPONSE: ${response.body}');

      // Success if HTTP 200 or 201
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, stackTrace) {
      print('FLASH RECORD ERROR: $e');
      print(stackTrace);
      return false;
    }
  }

  Future<bool> closeJobCard(
    List<ResCloseSession> resCloses,
    String token,
    String jobCardId,
  ) async {
    try {
      // ✅ Same URI for PUT and GET (as in C#)
      final uri = Uri.parse(
        AppEnvironment.baseUrl + AppURLs.closeJobCard(jobCardId),
      );

      // Serialize list → JSON
      String jsonString = jsonEncode(resCloses.map((e) => e.toJson()).toList());

      // SAME trimming logic as C#
      if (jsonString.startsWith('[') && jsonString.endsWith(']')) {
        jsonString = jsonString.substring(1, jsonString.length - 1);
      }

      // ---------- PUT: close session ----------
      await http.put(
        uri,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
        body: jsonString,
      );

      // ---------- GET: verify close session ----------
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'JWT $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('CLOSE SESSION RESPONSE: ${response.body}');
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      print('CLOSE JOB CARD ERROR: $e');
      print(stackTrace);
      return false;
    }
  }

  Future<FlashRecordModel> getFlashRecord() async {
    FlashRecordModel result = FlashRecordModel();
    final token = AppPreferences.getAccessToken();
    try {
      // ✅ Check internet connectivity (equivalent to Connectivity.Current.NetworkAccess)
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        result.message = 'Please check internet connection.';
        return result;
      }

      final uri = Uri.parse(
        '${AppEnvironment.baseUrl}flash/flash/',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      final data = response.body;

      print('$uri\n\nRESPONSE:\n$data');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        result = FlashRecordModel.fromJson(jsonDecode(data));
        result.message = 'success';
      } else {
        result.message =
            '${response.statusCode}\n${deserializeErrorModel(data)}';
      }

      return result;
    } catch (e) {
      result.message = e.toString();
      return result;
    }
  }

  String deserializeErrorModel(String data) {
    try {
      final json = jsonDecode(data);
      final errorModel = ErrorModel.fromJson(json);
      return errorModel.error ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<IorTestModel> getIorTest() async {
    IorTestModel result = IorTestModel();
    final token = await AppPreferences.getAccessToken();
    try {
      // ✅ Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        result.message = 'Please check internet connection.';
        return result;
      }

      final uri = Uri.parse(
        '${AppEnvironment.baseUrl}ior-test/ior-test-list/',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'JWT $token',
          'Content-Type': 'application/json',
        },
      );

      final data = response.body;

      print('$uri\n\nRESPONSE:\n$data');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        result = IorTestModel.fromJson(jsonDecode(data));
        result.message = 'success';
      } else {
        result.message =
            '${response.statusCode}\n${deserializeErrorModel(data)}';
      }

      return result;
    } catch (e) {
      result.message = e.toString();
      return result;
    }
  }

  Future<ActuatorTestModel> getActuatorTest() async {
    ActuatorTestModel model = ActuatorTestModel();
    final token = await AppPreferences.getAccessToken();
    try {
      // 🌐 Check Internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        model.message = "Please check internet connection.";
        return model;
      }

      final url = Uri.parse(
        AppEnvironment.baseUrl + AppURLs.getActuatorIorTest,
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "JWT $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("URL: $url");
      debugPrint("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        model = ActuatorTestModel.fromJson(jsonDecode(response.body));
        model.message = "success";
      } else {
        model.message =
            "${response.statusCode} - ${deserializeErrorModel(response.body)}";
      }
    } catch (e) {
      debugPrint("GetActuatorTest Exception: $e");
      model.message = e.toString();
    }

    return model;
  }

  Future<FreezeFrameModel> getFreezeFrameList() async {
    FreezeFrameModel results = FreezeFrameModel();
    final token = await AppPreferences.getAccessToken();
    try {
      // 🌐 Internet check
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        results.message = "Please check internet connection.";
        return results;
      }

      final url =
          Uri.parse(AppEnvironment.baseUrl + AppURLs.getFreezeFrameList);

      final response = await http.get(
        url,
        headers: {
          "Authorization": "JWT $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("$url\n\nRESPONSE:\n${response.body}");

      if (response.statusCode == 200) {
        results = FreezeFrameModel.fromJson(
          jsonDecode(response.body),
        );
        results.message = "success";
      } else {
        results.message =
            "ApiServices.getFreezeFrameList() : ${response.statusCode}\n"
            "${deserializeErrorModel(response.body)}";
      }
    } catch (e) {
      results.message = "Exception in ApiServices.getFreezeFrameList() : $e";
      debugPrint(results.message);
    }

    return results;
  }

  Future<ListNumberRootModel> getListNumbers() async {
    ListNumberRootModel results = ListNumberRootModel();
    final token = await AppPreferences.getAccessToken();
    try {
      // 🌐 Internet check
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        results.message = "Please check internet connection.";
        return results;
      }

      final url = Uri.parse(AppEnvironment.baseUrl + AppURLs.getListNumbers);

      final response = await http.get(
        url,
        headers: {
          "Authorization": "JWT $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("$url\n\nRESPONSE:\n${response.body}");

      if (response.statusCode == 200) {
        results = ListNumberRootModel.fromJson(
          jsonDecode(response.body),
        );
        results.message = "success";
      } else {
        results.message =
            "${response.statusCode}\n${deserializeErrorModel(response.body)}";
      }
    } catch (e) {
      results.message = "Exception : $e";
      debugPrint(results.message);
    }

    return results;
  }

  Future<DoipConfigRootModel> getDoipConfiguration() async {
    DoipConfigRootModel results = DoipConfigRootModel();
    final token = await AppPreferences.getAccessToken();
    try {
      // 🌐 Internet check
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        results.message = "Please check internet connection.";
        return results;
      }

      final url =
          Uri.parse(AppEnvironment.baseUrl + AppURLs.getDoipConfiguration);

      final response = await http.get(
        url,
        headers: {
          "Authorization": "JWT $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("$url\n\nRESPONSE:\n${response.body}");

      if (response.statusCode == 200) {
        results = DoipConfigRootModel.fromJson(
          jsonDecode(response.body),
        );
        results.message = "success";
      } else {
        results.message =
            "${response.statusCode}\n${deserializeErrorModel(response.body)}";
      }
    } catch (e) {
      results.message = "Exception : $e";
      debugPrint(results.message);
    }

    return results;
  }

  Future<Root> getPids(int? datasetId) async {
    Root root = Root();
    final token = await AppPreferences.getAccessToken();

    debugPrint(
        "DEBUG: Token value is -> '$token'"); // Look for null or empty string here
    try {
      // 🌐 Internet check
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        root.message = "Please check internet connection.";
        return root;
      }

      final url =
          Uri.parse(AppEnvironment.baseUrl + AppURLs.getPids(datasetId));

      final response = await http.get(
        url,
        headers: {
          // ✅ FIX 2: Ensure token is not null before sending
          "Authorization": "JWT ${token ?? ''}",
          "Content-Type": "application/json",
        },
      );

      debugPrint("$url\nRESPONSE:\n${response.body}");

      if (response.statusCode == 200) {
        root = Root.fromJson(
          jsonDecode(response.body),
        );
        root.message = "success";
      } else {
        root.message =
            "${response.statusCode}\n${deserializeErrorModel(response.body)}";
      }
    } catch (e) {
      root.message = "Exception in ApiServices.getPids() : $e";
      debugPrint(root.message);
    }

    return root;
  }
}

class ErrorModel {
  String? error;

  ErrorModel({this.error});

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {
        'error': error,
      };
}
