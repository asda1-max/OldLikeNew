import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_register_controller.dart';

class AuthRegisterView extends GetView<AuthRegisterController> {
  const AuthRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2C1810),
              const Color(0xFF4A2C1A),
              const Color(0xFF5D3A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.3), width: 2),
                            ),
                            child: const Icon(
                              Icons.person_add_outlined,
                              size: 44,
                              color: Color(0xFFD4A574),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Buat Akun Baru',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4A574),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bergabung dan mulai bertransaksi',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTextField(
                                  controller: controller.nameController,
                                  label: 'Nama Lengkap',
                                  hint: 'Masukkan nama lengkap Anda',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: controller.emailController,
                                  label: 'Email',
                                  hint: 'nama@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                _buildTextField(
                                  controller: controller.passwordController,
                                  label: 'Password',
                                  hint: 'Minimal 6 karakter',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                ),
                                const SizedBox(height: 14),
                                _buildRoleDropdown(),
                                const SizedBox(height: 24),
                                Obx(() {
                                  return Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFD4A574), Color(0xFFB8865A)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4A574).withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : controller.register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Daftar',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Sudah punya akun? ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    GestureDetector(
                                      onTap: controller.goToLogin,
                                      child: const Text(
                                        'Masuk di sini',
                                        style: TextStyle(
                                          color: Color(0xFFB8865A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A2C1A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F5F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8DDD3), width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon, color: const Color(0xFFB8865A)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Sebagai',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A2C1A),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8DDD3), width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: controller.role.value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB8865A)),
                onChanged: (String? newValue) {
                  if (newValue != null) controller.role.value = newValue;
                },
                items: const [
                  DropdownMenuItem(
                    value: 'buyer',
                    child: Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFFB8865A)),
                        SizedBox(width: 10),
                        Text('Buyer', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'seller',
                    child: Row(
                      children: [
                        Icon(Icons.storefront_outlined, size: 20, color: Color(0xFFB8865A)),
                        SizedBox(width: 10),
                        Text('Seller', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 20, color: Color(0xFFB8865A)),
                        SizedBox(width: 10),
                        Text('Admin', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
