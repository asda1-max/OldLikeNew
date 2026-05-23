import 'package:get/get.dart';

import '../controllers/auction_detail_controller.dart';

class AuctionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionDetailController>(
      () => AuctionDetailController(),
    );
  }
}
