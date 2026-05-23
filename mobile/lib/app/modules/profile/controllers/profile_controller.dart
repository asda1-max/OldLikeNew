import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../shared/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;

  final name = 'Pengguna'.obs;
  final email = 'email@domain.com'.obs;
  final role = 'buyer'.obs;

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    
    if (token == null) {
      // User is not logged in, redirect to login
      Get.offAllNamed(Routes.AUTH_LOGIN);
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse('$baseUrl/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        name.value = data['name'] ?? 'Pengguna';
        email.value = data['email'] ?? '';
        role.value = data['role'] ?? 'buyer';

        // Keep the role updated in the global authService too
        authService.role.value = role.value;
      } else {
        throw Exception('Gagal memuat profil');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat informasi profil: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    final authService = Get.find<AuthService>();
    authService.logout();
    Get.offAllNamed(Routes.AUTH_LOGIN);
    Get.snackbar('Sukses', 'Anda telah berhasil keluar');
  }
}
