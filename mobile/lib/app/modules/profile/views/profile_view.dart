import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Color(0xFFD4A574),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4A574)),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informasi Akun', Icons.account_box_outlined),
                      const SizedBox(height: 12),
                      _buildAccountInfoCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Aktivitas Saya', Icons.history_rounded),
                      const SizedBox(height: 12),
                      _buildActivityCard(),
                      const SizedBox(height: 32),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final currentRole = controller.role.value;
        return CustomBottomNavBar(currentIndex: currentRole == 'seller' ? 4 : 3);
      }),
    );
  }

  Widget _buildProfileHeader() {
    final roleText = controller.role.value.toUpperCase();
    final isSeller = controller.role.value == 'seller';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C1810), Color(0xFF4A2C1A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4A574), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 54,
                color: Color(0xFFD4A574),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.name.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.email.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSeller ? const Color(0xFFD4A574) : const Color(0xFF4A2C1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4A574).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSeller ? Icons.storefront_outlined : Icons.shopping_bag_outlined,
                  size: 14,
                  color: isSeller ? const Color(0xFF2C1810) : const Color(0xFFD4A574),
                ),
                const SizedBox(width: 6),
                Text(
                  roleText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSeller ? const Color(0xFF2C1810) : const Color(0xFFD4A574),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB8865A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C1810),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow('Nama Lengkap', controller.name.value, Icons.badge_outlined),
          const Divider(color: Color(0xFFE8DDD3), height: 24),
          _buildInfoRow('Alamat Email', controller.email.value, Icons.mail_outline),
          const Divider(color: Color(0xFFE8DDD3), height: 24),
          _buildInfoRow('Status Akun', 'Aktif', Icons.check_circle_outline, valueColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F5F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFB8865A), size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF2C1810),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard() {
    final isSeller = controller.role.value == 'seller';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          if (isSeller) ...[
            _buildActivityRow('Kelola Barang Saya', 'Lihat daftar dagangan Anda', Icons.inventory_2_outlined),
            const Divider(color: Color(0xFFE8DDD3), height: 1),
            _buildActivityRow('Lelang Aktif Saya', 'Pantau jalannya lelang', Icons.gavel_outlined),
          ] else ...[
            _buildActivityRow('Riwayat Bid Lelang', 'Daftar penawaran yang Anda ikuti', Icons.gavel_outlined),
            const Divider(color: Color(0xFFE8DDD3), height: 1),
            _buildActivityRow('Daftar Transaksi', 'Riwayat pembelian & pelunasan lelang', Icons.receipt_long_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityRow(String title, String subtitle, IconData icon) {
    return ListTile(
      onTap: () {
        Get.snackbar(
          title,
          'Detail aktivitas ini akan segera tersedia.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2C1810),
          colorText: const Color(0xFFD4A574),
          margin: const EdgeInsets.all(15),
          borderRadius: 12,
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFFF9800), size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C1810),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4C2B3), width: 1.5),
      ),
      child: OutlinedButton(
        onPressed: controller.logout,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFB8865A), size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar Akun',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8865A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
