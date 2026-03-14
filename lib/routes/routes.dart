import 'package:autopeepal/dev/dev_screen.dart';
import 'package:autopeepal/logic/bindings/allDTCBdetails_bindings.dart';
import 'package:autopeepal/logic/bindings/dashboard_bindings.dart';
import 'package:autopeepal/logic/bindings/diagnosticFunctions_bindings.dart';
import 'package:autopeepal/logic/bindings/drawer_bindings.dart';
import 'package:autopeepal/logic/bindings/dtc_bindings.dart';
import 'package:autopeepal/logic/bindings/ecuFlashing_bindings.dart';
import 'package:autopeepal/logic/bindings/firmwareUpdate_bindings.dart';
import 'package:autopeepal/logic/bindings/liveParameter_bindings.dart';
import 'package:autopeepal/logic/bindings/login_bindings.dart';
import 'package:autopeepal/logic/bindings/register_bindings.dart';
import 'package:autopeepal/logic/bindings/routineTest_bindings.dart';
import 'package:autopeepal/logic/bindings/session_bindings.dart';
import 'package:autopeepal/logic/bindings/terminal_bindings.dart';
import 'package:autopeepal/logic/bindings/writeParameter_bindings.dart';
import 'package:autopeepal/views/screens/auth/login.dart';
import 'package:autopeepal/views/screens/auth/register.dart';
import 'package:autopeepal/views/screens/clicard/createJobCard.dart';
import 'package:autopeepal/views/screens/clicard/vciTypes.dart';
import 'package:autopeepal/views/screens/clicard/jobCard.dart';
import 'package:autopeepal/views/screens/clicard/jobCardDetails.dart';
import 'package:autopeepal/views/screens/clicard/terminalView.dart';
import 'package:autopeepal/views/screens/dashboard/dashboard.dart';
import 'package:autopeepal/views/screens/dashboard/usb_discovery.dart';
import 'package:autopeepal/views/screens/dashboard/use_web_discovery.dart';
import 'package:autopeepal/views/screens/dashboard/wifi_connect_screen.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/allDtcDetails.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/diagnostic_functions.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/dtcScreen.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/ecuFlashing.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/firmwareVersions.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/freezeFramePage.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/gdImageZoomPage.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/getGdInfoPage.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/liveParameter.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/routineTesScreen.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/sessionLogs.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/writeParameter.dart';
import 'package:autopeepal/views/screens/vciConfiguration/vciConfiguration.dart';
import 'package:get/get.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/views/screens/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: Routes.splashScreen, page: () => SplashScreen()),
    GetPage(name: Routes.devScreen, page: () => DevScreen()),
    GetPage(
      name: Routes.loginScreen,
      binding: LoginBindings(),
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.cliCard,
      page: () => CliCard(),
    ),
    GetPage(
      name: Routes.jobCard,
      page: () => JobCardPage(),
    ),
    GetPage(
      name: Routes.jobCardDetails,
      page: () => JobCardDetailsPage(),
    ),
    // GetPage(
    //   name: Routes.blutoothDevices,
    //   //binding: LoginBindings(),
    //  // page: () => BluetoothDevicesPage(),
    // ),
    GetPage(
      name: Routes.dashboardScreen,
      binding: DashboardBinding(),
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: Routes.wifiScreen,
      binding: DrawerBinding(),
      page: () => DeviceList(),
    ),
    GetPage(
      name: Routes.loginScreen,
      page: () => LoginScreen(),
    ),

    GetPage(
      name: Routes.usbWebScreen,
      page: () {
        if (GetPlatform.isWindows) {
          return UsbDeviceList();
        } else {
          return UsbDiscoveryPage();
        }
      },
    ),
    GetPage(
      name: Routes.terminalScreen,
      binding: TerminalBinding(),
      page: () => TerminalView(),
    ),

    GetPage(
      name: Routes.diagnosticScreen,
      binding: DiagnosticfunctionsBindings(),
      page: () => DiagnosticFunctions(),
    ),

    GetPage(
      name: Routes.vciConfigurationScreen,
      //binding: DiagnosticfunctionsBindings(),
      page: () => VCIConfiguration(),
    ),

    GetPage(
      name: Routes.SessionScreen,
      binding: SessionBindings(),
      page: () => SessionLogsScreen(),
    ),

    GetPage(
      name: Routes.firmwareUpdateScreen,
      binding: FirmwareupdateBindings(),
      page: () => FirmwareUpdatePage(),
    ),

    // GetPage(
    //   name: Routes.ecuInformation,
    //   binding: EcuinformationBindings(),
    //   page: () => EcuInformationScreen(),
    // ),

    GetPage(
      name: Routes.dtcScreen,
      binding: DTCBinding(),
      page: () => DTCScreen(),
    ),

    GetPage(
      name: Routes.liveParameter,
      binding: LiveparameterBindings(),
      page: () => LiveParameter(),
    ),

    GetPage(
      name: Routes.writeParameter,
      binding: WriteparameterBindings(),
      page: () => WriteParameter(),
    ),

    GetPage(
      name: Routes.ecuFlashing,
      binding: EcuflashingBindings(),
      page: () => ECUFlashingScreen(),
    ),

    GetPage(
      name: Routes.routineTest,
      binding: RoutinetestBindings(),
      page: () => RoutineTestScreen(),
    ),

    GetPage(
      name: Routes.allDtcDetails,
      binding: AlldtcbdetailsBindings(),
      page: () => AllDTCDetails(),
    ),

     GetPage(
      name: Routes.registerScreen,
      binding: RegisterBindings(),
      page: () => RegisterScreen(),
    ),

    GetPage(
      name: Routes.createJobCardScreen,
      //binding: RegisterBindings(),
      page: () => CreateJobCardScreen(),
    ),
    GetPage(
      name: Routes.gdInfo,
      //binding: RegisterBindings(),
      page: () => GDInfoPage(),
    ),
    GetPage(
      name: Routes.freezeFrame,
      //binding: RegisterBindings(),
      page: () => FreezeFramePage(),
    ),

    GetPage(
      name: Routes.gdZoomImage,
      //binding: RegisterBindings(),
      page: () => GdImageZoomPage(),
    ),
  ];
}
