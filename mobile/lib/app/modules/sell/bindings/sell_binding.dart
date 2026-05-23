import 'package:get/get.dart';

import '../controllers/sell_controller.dart';

class SellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellController>(
      () => SellController(),
    );
  }
}
