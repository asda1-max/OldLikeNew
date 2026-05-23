import 'package:get/get.dart';

import '../controllers/auctions_controller.dart';

class AuctionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionsController>(
      () => AuctionsController(),
    );
  }
}
