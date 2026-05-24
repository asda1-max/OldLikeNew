import 'package:get/get.dart';
import '../controllers/my_items_controller.dart';

class MyItemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyItemsController>(
      () => MyItemsController(),
    );
  }
}
