import 'package:get/get.dart';

class Ecuflashingcontroller extends GetxController{
  RxString selectedFile = "".obs;

  final List<String> Files = [
    "Hex File",
    "Json File",
  ];
}