import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:old_like_new/app/routes/app_pages.dart';

import '../services/auth_register_service.dart';

class AuthRegisterController extends GetxController {
  final AuthRegisterService service;

  AuthRegisterController({required this.service});

  // Text editing controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final role = 'buyer'.obs; // default role
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;
    try {
      final payload = {
        'name': name,
        'email': email,
        'password': password,
        'role': role.value,
      };
      await service.register(payload);
      Get.snackbar('Success', 'Registration successful');
    } catch (e) {
      print("error $e");
      Get.snackbar('Registration failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.toNamed(Routes.AUTH_LOGIN);
  }
}
