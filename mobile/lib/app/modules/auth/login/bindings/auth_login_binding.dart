import 'package:get/get.dart';

import '../controllers/auth_login_controller.dart';
import '../services/auth_login_service.dart';

class AuthLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthLoginService>(() => AuthLoginService());
    Get.lazyPut<AuthLoginController>(
      () => AuthLoginController(service: Get.find<AuthLoginService>()),
    );
  }
}
