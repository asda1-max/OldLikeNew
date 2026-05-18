import 'package:get/get.dart';

import '../controllers/auth_register_controller.dart';
import '../services/auth_register_service.dart';

class AuthRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRegisterService>(() => AuthRegisterService());
    Get.lazyPut<AuthRegisterController>(
      () => AuthRegisterController(service: Get.find<AuthRegisterService>()),
    );
  }
}
