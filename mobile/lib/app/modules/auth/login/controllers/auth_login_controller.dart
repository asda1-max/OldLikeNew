import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_login_service.dart';
import '../../../../routes/app_pages.dart';

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

      Get.snackbar('Success', 'Login successful');

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
