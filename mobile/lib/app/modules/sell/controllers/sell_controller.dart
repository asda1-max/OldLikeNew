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
  final selectedCategory = 'Elektronik'.obs;
  final selectedCondition = 'Baru'.obs;

  final imageFile = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;

  final categories = ['Elektronik', 'Furnitur', 'Fashion', 'Hobi', 'Otomotif', 'Lainnya'];
  final conditions = ['Baru', 'Bekas - Sangat Baik', 'Bekas - Baik', 'Bekas - Cukup'];

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

    if (title.isEmpty) {
      Get.snackbar('Error', 'Nama barang harus diisi');
      return;
    }

    if (imageFile.value == null) {
      Get.snackbar('Error', 'Foto barang harus diisi');
      return;
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

      Get.snackbar('Sukses', 'Barang berhasil diunggah dan menunggu verifikasi!');
      
      // Clean up fields
      titleController.clear();
      descriptionController.clear();
      selectedCategory.value = 'Elektronik';
      selectedCondition.value = 'Baru';
      imageFile.value = null;

      // Redirect to Profile view or My Items (we will redirect to Profile or MyItems)
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
