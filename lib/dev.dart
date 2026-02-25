import 'package:autopeepal/api/app_envirments.dart';
import 'package:autopeepal/app.dart';

void main() async {
  App.instance.initAndRunApp(
    devMode: false,
    appLog: false,
    apiLog: false,
    setDefault: false,
    samplePayment: false,
    baseURLType: AtomURLType.DEV,
  );
}