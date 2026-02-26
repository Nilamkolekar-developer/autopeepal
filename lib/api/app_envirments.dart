import 'package:autopeepal/app.dart';

class AtomURLType {
  static const String LOCAL = "LOCAL";
  static const String DEV = 'DEV';
  static const String PROD = 'PROD';
}

class AppEnvironment {
  static const String _localUrl = "https://uatcustapi.allish.co.uk/";
  static const String _devUrl = 'http://165.232.189.202/api/v1/';
  static const String _prodUrl = 'https://custapi.allish.co.uk/';

  static bool get baseProdInstance {
    if (baseUrl == _prodUrl) {
      return true;
    } else {
      return false;
    }
  }

  static String get baseUrl {
    switch (App.instance.baseURLType) {
      case AtomURLType.DEV:
        return _devUrl;
      case AtomURLType.PROD:
        return _prodUrl;
      case AtomURLType.LOCAL:
        return _localUrl;
    }

    return "http://43.204.117.226:3000/api/v1";
  }
}
