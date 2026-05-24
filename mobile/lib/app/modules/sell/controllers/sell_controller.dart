import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SellController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final startPriceController = TextEditingController();
  final buyoutPriceController = TextEditingController();

  final selectedCategory = 'Elektronik'.obs;
  final selectedCondition = 'Baru'.obs;
  final durationHours = 24.obs;

  final imageFile = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;

  final categories = ['Elektronik', 'Furnitur', 'Fashion', 'Hobi', 'Otomotif', 'Lainnya'];
  final conditions = ['Baru', 'Bekas - Sangat Baik', 'Bekas - Baik', 'Bekas - Cukup'];
  final durations = [
    {'label': '1 Jam', 'hours': 1},
    {'label': '12 Jam', 'hours': 12},
    {'label': '24 Jam (1 Hari)', 'hours': 24},
    {'label': '48 Jam (2 Hari)', 'hours': 48},
    {'label': '72 Jam (3 Hari)', 'hours': 72},
  ];

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    startPriceController.dispose();
    buyoutPriceController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        imageFile.value = image;
      }
    } catch (e) {
      print("Error saat mengambil gambar : $e");
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  Future<void> submitSell() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final startPriceStr = startPriceController.text.trim();
    final buyoutPriceStr = buyoutPriceController.text.trim();

    if (title.isEmpty || startPriceStr.isEmpty) {
      Get.snackbar('Error', 'Nama barang dan Harga awal harus diisi');
      return;
    }

    if (imageFile.value == null) {
      Get.snackbar('Error', 'Foto barang harus diisi');
      return;
    }

    final startPrice = double.tryParse(startPriceStr);
    if (startPrice == null || startPrice <= 0) {
      Get.snackbar('Error', 'Harga awal lelang harus berupa angka lebih besar dari 0');
      return;
    }

    double? buyoutPrice;
    if (buyoutPriceStr.isNotEmpty) {
      buyoutPrice = double.tryParse(buyoutPriceStr);
      if (buyoutPrice == null || buyoutPrice <= startPrice) {
        Get.snackbar('Error', 'Harga Buyout harus berupa angka lebih besar dari harga awal');
        return;
      }
    }

    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) {
      Get.snackbar('Error', 'Anda harus masuk terlebih dahulu');
      return;
    }

    isLoading.value = true;

    try {
      // Step 1: Create Item (Multipart form data)
      final itemUrl = Uri.parse('$baseUrl/items/');
      final itemRequest = http.MultipartRequest('POST', itemUrl);
      itemRequest.headers['Authorization'] = 'Bearer $token';
      
      itemRequest.fields['title'] = title;
      itemRequest.fields['description'] = description;
      itemRequest.fields['category'] = selectedCategory.value;
      itemRequest.fields['condition'] = selectedCondition.value;

      itemRequest.files.add(await http.MultipartFile.fromPath(
        'images',
        imageFile.value!.path,
      ));

      final itemStreamedResponse = await itemRequest.send();
      final itemResponse = await http.Response.fromStream(itemStreamedResponse);

      if (itemResponse.statusCode != 200 && itemResponse.statusCode != 201) {
        String detail = 'Gagal membuat barang';
        try {
          final Map<String, dynamic> data = jsonDecode(itemResponse.body);
          detail = data['detail'] ?? detail;
        } catch (_) {}
        throw Exception(detail);
      }

      final itemData = jsonDecode(itemResponse.body);
      final itemId = itemData['id'];

      // Step 2: Create Auction
      final auctionUrl = Uri.parse('$baseUrl/auctions/');
      final endTime = DateTime.now().add(Duration(hours: durationHours.value));
      print("Membuat auction: $endTime");
      final auctionResponse = await http.post(
        auctionUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
          'start_price': startPrice,
          'buyout_price': buyoutPrice,
          'end_time': endTime.toUtc().toIso8601String().split('.').first,
        }),
      );

      if (auctionResponse.statusCode != 200 && auctionResponse.statusCode != 201) {
        String detail = 'Gagal membuat pelelangan';
        try {
          final Map<String, dynamic> data = jsonDecode(auctionResponse.body);
          detail = data['detail'] ?? detail;
        } catch (_) {}
        throw Exception(detail);
      }

      Get.snackbar('Sukses', 'Barang dan Lelang berhasil dibuat!');
      
      // Clean up fields
      titleController.clear();
      descriptionController.clear();
      startPriceController.clear();
      buyoutPriceController.clear();
      selectedCategory.value = 'Elektronik';
      selectedCondition.value = 'Baru';
      durationHours.value = 24;
      imageFile.value = null;

      // Redirect to Home view or Auctions view
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
