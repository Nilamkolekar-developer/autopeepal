import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String clientID = 'clientID';
  static const String userId = 'UserID';
  static const String zipCode = 'zipCode';
  static const String name = 'Name';
  static const String emailId = 'EmailID';
  static const String stripClientId = "StripeClientID";
  static const String referralCode = "ReferralCode";
  static const String locaData = "locaData";
  static const _tokenKey = 'token';
  static const String _selectedVciKey = "selectedVCI";

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setStripClientID(String setStrip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(stripClientId, setStrip);
  }

  static Future<String?> getsetStripClientID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("StripeClientID");
  }

  static Future<void> setClientID(String ClientID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(clientID, ClientID);
  }
  

  static Future<String?> getClientID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("clientID");
  }


  //  locat Storage
  static Future<void> setLocalStorage(List<dynamic> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(locaData, list.toString());
  }

  static Future<String?> getLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("locaData");
  }

    static Future<void> removeLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.remove("locaData");
  } 


  static Future<void> setZipCode(String ZipCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(zipCode, ZipCode);
  }

  static Future<String?> getZipCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(zipCode);
  }

  static Future<void> setName(String Name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(name, Name);
  }

  static Future<void> setEmailId(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(emailId, email);
  }

  static Future<void> setUserId(String userid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userId, userid);
  }

  static Future<void> setReferralCode(String refcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(referralCode, refcode);
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userId) ?? "";
  }

  static Future<String?> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(name) ?? "";
  }

  static Future<String?> getEmailId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailId) ?? "";
  }

  static Future<String?> getReferralCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(referralCode) ?? "";
  }

  // Save selected VCI
static Future<void> setSelectedVCI(String vci) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_selectedVciKey, vci);
}

// Get saved VCI
static Future<String?> getSelectedVCI() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_selectedVciKey);
}

  static Future<void> clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
