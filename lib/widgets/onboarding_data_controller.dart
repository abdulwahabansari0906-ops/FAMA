import 'package:get/get.dart';

class OnboardingDataController extends GetxController {
  String name = '';
  String birthday = ''; // yyyy-MM-dd
  String gender = 'male';

  int? locationId;
  String? locationName;

  int? schoolId;
  String? schoolName;
}