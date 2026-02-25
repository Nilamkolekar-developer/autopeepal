import 'package:get/get.dart';

class Liveparametercontroller extends GetxController{
   final List<String> parameters =
      List.generate(20, (index) => "Parameter ${index + 1}");

  var selectedParameters = <String>[].obs;

  void toggleSelection(String item, bool value) {
    if (value) {
      selectedParameters.add(item);
    } else {
      selectedParameters.remove(item);
    }
  }
}