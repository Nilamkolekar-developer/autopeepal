import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  // 🔑 Keys
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _firmwareVersionKey = 'firmwareVersion';
  static const String _localDataKey = 'localData';
  static const String _selectedVciKey = 'selectedVCI';
  static const String _licencesKey = 'licences';
  static const String _vehicleModelsKey = 'vehicleModels';
  static const String ConnectedVia = 'ConnectedVia';
  static const String _lastIpKey = 'lastDongleIp';
  static const String _channelIdKey = 'channelId';
  static const String _connectedViaKey = 'connectedVia';
  static const String _rememberMeKey = 'RememberIsChecked';
  static const String _savedUserKey = 'user_id';
  static const String _savedPassKey = 'password';

// ================= GD DATA =================

  static Future<void> saveGDLocalList(
      int subModelId, Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();

    String key = "GD_LocalList_$subModelId";

    await prefs.setString(key, jsonEncode(json));

    print("✅ GD data saved with key: $key");
  }

  static Future<String?> getGDLocalList(int subModelId) async {
    final prefs = await SharedPreferences.getInstance();

    String key = "GD_LocalList_$subModelId";

    return prefs.getString(key);
  }

  static Future<void> setConnectedVia(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_connectedViaKey, value);
  }

  static Future<String?> getConnectedVia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_connectedViaKey);
  }

  static Future<void> saveRememberMe(
      bool value, String user, String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
    if (value) {
      await prefs.setString(_savedUserKey, user);
      await prefs.setString(_savedPassKey, pass);
    } else {
      await prefs.remove(_savedUserKey);
      await prefs.remove(_savedPassKey);
    }
  }

  static Future<Map<String, dynamic>> getRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "isChecked": prefs.getBool(_rememberMeKey) ?? false,
      "user": prefs.getString(_savedUserKey) ?? "",
      "pass": prefs.getString(_savedPassKey) ?? "",
    };
  }

  // ================= TOKENS =================

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> setStringValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getStringValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setFirmwareVersion(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firmwareVersionKey, value);
  }

  static Future<String?> getFirmwareVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firmwareVersionKey);
  }

  static Future<void> setLastDongleIp(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastIpKey, value);
  }

  static Future<String?> getLastDongleIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastIpKey);
  }

  static Future<void> setChannelId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_channelIdKey, value);
  }

  static Future<String?> getChannelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_channelIdKey);
  }

  // ================= USER =================

  static Future<void> saveUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // ================= LOCAL DATA =================

  static Future<void> setLocalData(List<dynamic> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localDataKey, jsonEncode(list));
  }

  static Future<List<dynamic>> getLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_localDataKey);
    return data == null ? [] : jsonDecode(data);
  }

  static Future<void> removeLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localDataKey);
  }

  // ================= VCI =================

  static Future<void> setSelectedVCI(String vci) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedVciKey, vci);
  }

  static Future<String?> getSelectedVCI() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedVciKey);
  }

  // ================= LICENCES =================

  static Future<void> saveLicences(Map<String, dynamic> licencesJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licencesKey, jsonEncode(licencesJson));
  }

  static Future<Map<String, dynamic>?> getLicences() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_licencesKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

// ================= VEHICLE MODELS =================

  static Future<void> saveVehicleModels(
      List<Map<String, dynamic>> modelsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehicleModelsKey, jsonEncode(modelsJson));
  }

  static Future<List<dynamic>> getVehicleModels() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_vehicleModelsKey);
    return data == null ? [] : jsonDecode(data);
  }

// ================= INT =================
  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // Save login request (username + password) for offline use
  static Future<void> saveOfflineLoginRequest(
      Map<String, dynamic> jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserRequest_LocalData', jsonEncode(jsonData));
  }

// Get offline login request
  static Future<Map<String, dynamic>?> getOfflineLoginRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('UserRequest_LocalData');
    return data == null ? null : jsonDecode(data);
  }

  // ================= CLEAR =================

  /// ⚠️ Clears everything EXCEPT selected VCI
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final vci = prefs.getString(_selectedVciKey);
    await prefs.clear();
    if (vci != null) {
      await prefs.setString(_selectedVciKey, vci);
    }
    // Do NOT delete RememberIsChecked.txt here if you want remember me
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> clearExceptCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final username = prefs.getString('user_id'); // ✅ FIXED
    final password = prefs.getString('password');

    await prefs.clear();

    if (username != null && username.isNotEmpty) {
      await prefs.setString('user_id', username);
    }
    if (password != null && password.isNotEmpty) {
      await prefs.setString('password', password);
    }
  }
}
