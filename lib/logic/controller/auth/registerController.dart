import 'package:get/get.dart';

class Registercontroller extends GetxController{

  // Selected values for dropdowns
    final selectedOEM = "".obs;
    final selectedWorkshopGroup = "".obs;
    final selectedCity = "".obs;
    final selectedWorkshop = "".obs;

    // Dropdown items
    final oemList = ["OEM A", "OEM B", "OEM C"];
    final workshopGroupList = ["Group 1", "Group 2", "Group 3"];
    final cityList = ["Pune", "Mumbai", "Ahmednagar"];
    final workshopList = ["Workshop 1", "Workshop 2", "Workshop 3"];
  
}