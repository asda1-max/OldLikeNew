import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_login_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';

class AuthLoginController extends GetxController {
  final AuthLoginService service;

  AuthLoginController({required this.service});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;
    try {
      final response = await service.login(email, password);
      final token = response['access_token'];

      // Fetch user profile to get the role
      final authService = Get.find<AuthService>();
      final profile = await service.getUserProfile(token);
      final role = profile['role'] ?? 'buyer';
      final userId = profile['id'];

      authService.setSession(token, role, userId: userId);

      Get.snackbar('Success', 'Login successful as $role');

      // Navigate to Home view after successful login
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Login failed', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.AUTH_REGISTER);
  }
}
