import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../../routes/app_pages.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Obx(() {
      final role = authService.userRole;

      List<BottomNavItemData> items = [];

      if (role == 'seller') {
        items = [
          BottomNavItemData(icon: Icons.home_rounded, label: 'Home', route: Routes.HOME),
          BottomNavItemData(icon: Icons.gavel_outlined, label: 'Lelang', route: Routes.AUCTIONS),
          BottomNavItemData(icon: Icons.add_circle_outline, label: 'Jual', route: Routes.SELL),
          BottomNavItemData(icon: Icons.chat_bubble_outline, label: 'Chat', route: Routes.CHAT),
          BottomNavItemData(icon: Icons.receipt_long_outlined, label: 'Transaksi', route: Routes.TRANSACTIONS),
          BottomNavItemData(icon: Icons.person_outline, label: 'Profil', route: Routes.PROFILE),
        ];
      } else {
        // buyer or guest
        items = [
          BottomNavItemData(icon: Icons.home_rounded, label: 'Home', route: Routes.HOME),
          BottomNavItemData(icon: Icons.gavel_outlined, label: 'Lelang', route: Routes.AUCTIONS),
          BottomNavItemData(icon: Icons.chat_bubble_outline, label: 'Chat', route: Routes.CHAT),
          BottomNavItemData(icon: Icons.receipt_long_outlined, label: 'Transaksi', route: Routes.TRANSACTIONS),
          BottomNavItemData(icon: Icons.person_outline, label: 'Profil', route: Routes.PROFILE),
        ];
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = currentIndex == index;
                return GestureDetector(
                  onTap: () {
                    if (!isActive) {
                      if (item.route.isNotEmpty) {
                        Get.offNamed(item.route);
                      } else {
                        Get.snackbar(
                          item.label,
                          'Fitur ${item.label} sebagai $role akan segera hadir!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF2C1810),
                          colorText: const Color(0xFFD4A574),
                          margin: const EdgeInsets.all(15),
                          borderRadius: 12,
                        );
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isActive ? const Color(0xFFB8865A) : Colors.grey,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? const Color(0xFFB8865A) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}

class BottomNavItemData {
  final IconData icon;
  final String label;
  final String route;

  BottomNavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
