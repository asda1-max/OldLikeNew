import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchAuctions(forceRefresh: true),
          color: const Color(0xFFB8865A),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategories(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Lelang Aktif', 'Lihat Semua'),
                    const SizedBox(height: 12),
                    _buildActiveAuctions(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Berakhir Segera', ''),
                    const SizedBox(height: 12),
                    _buildEndingSoon(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2C1810),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C1810), Color(0xFF4A2C1A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'OldLikeNew',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4A574),
                        ),
                      ),
                      Text(
                        'Pelelangan Barang Bekas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildIconButton(Icons.notifications_outlined),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.shopping_cart_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.3)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFFD4A574)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Get.offNamed(Routes.AUCTIONS, arguments: {'search': value});
            }
          },
          decoration: const InputDecoration(
            hintText: 'Cari barang lelang...',
            prefixIcon: Icon(Icons.search, color: Color(0xFFB8865A)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.devices, 'label': 'Elektronik'},
      {'icon': Icons.chair, 'label': 'Furnitur'},
      {'icon': Icons.checkroom, 'label': 'Fashion'},
      {'icon': Icons.sports_esports, 'label': 'Hobi'},
      {'icon': Icons.directions_car, 'label': 'Otomotif'},
      {'icon': Icons.more_horiz, 'label': 'Lainnya'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Get.offNamed(Routes.AUCTIONS, arguments: {'category': cat['label']});
              },
              child: Column(
                children: [
                  Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8DDD3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: const Color(0xFFB8865A),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A2C1A),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1810),
            ),
          ),
          if (actionText.isNotEmpty)
            GestureDetector(
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB8865A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveAuctions() {
    return Obx(() {
      if (controller.isLoading.value && controller.activeAuctions.isEmpty) {
        return const SizedBox(
          height: 240,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
            ),
          ),
        );
      }

      if (controller.activeAuctions.isEmpty) {
        return const SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Tidak ada lelang aktif saat ini',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        );
      }

      return SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.activeAuctions.length,
          itemBuilder: (context, index) {
            final auction = controller.activeAuctions[index];
            final item = auction['item'] ?? {};
            final title = item['title'] ?? 'Barang Lelang';
            final currentPrice = (auction['current_price'] as num).toDouble();
            final condition = item['condition'] ?? 'Bekas';
            final endTime = auction['end_time'] ?? '';
            final imageList = item['image_urls'] as List<dynamic>? ?? [];
            final image = imageList.isNotEmpty
                ? '${controller.baseUrl}/${imageList[0]}'
                : '';

            return GestureDetector(
              onTap: () => Get.toNamed(Routes.AUCTION_DETAIL, arguments: auction['id']),
              child: _buildAuctionCard(
                title: title,
                currentBid: formatPrice(currentPrice),
                bids: 0,
                timeLeft: getTimeLeft(endTime),
                image: image,
                condition: condition,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAuctionCard({
    required String title,
    required String currentBid,
    required int bids,
    required String timeLeft,
    required String image,
    required String condition,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.network(
                  image,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    width: double.infinity,
                    color: const Color(0xFFE8DDD3),
                    child: const Icon(
                      Icons.image,
                      color: Color(0xFFB8865A),
                      size: 40,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1810),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 12,
                        color: Color(0xFFD4A574),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeLeft,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4A574),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C1810),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bid Saat Ini',
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                        Text(
                          currentBid,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8865A),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$bids bid',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A2C1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndingSoon() {
    return Obx(() {
      if (controller.isLoading.value && controller.endingSoonAuctions.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
            ),
          ),
        );
      }

      if (controller.endingSoonAuctions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Tidak ada lelang berakhir segera',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(controller.endingSoonAuctions.length, (index) {
            final auction = controller.endingSoonAuctions[index];
            final item = auction['item'] ?? {};
            final title = item['title'] ?? 'Barang Lelang';
            final currentPrice = (auction['current_price'] as num).toDouble();
            final condition = item['condition'] ?? 'Bekas';
            final endTime = auction['end_time'] ?? '';
            final imageList = item['image_urls'] as List<dynamic>? ?? [];
            final image = imageList.isNotEmpty
                ? '${controller.baseUrl}/${imageList[0]}'
                : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.AUCTION_DETAIL, arguments: auction['id']),
                child: _buildHorizontalCard(
                  title: title,
                  currentBid: formatPrice(currentPrice),
                  bids: 0,
                  timeLeft: getTimeLeft(endTime),
                  image: image,
                  condition: condition,
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildHorizontalCard({
    required String title,
    required String currentBid,
    required int bids,
    required String timeLeft,
    required String image,
    required String condition,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Image.network(
              image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: const Color(0xFFE8DDD3),
                child: const Icon(Icons.image, color: Color(0xFFB8865A)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1810),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    condition,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentBid,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB8865A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 12,
                              color: Color(0xFFFF9800),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              timeLeft,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  String formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String getTimeLeft(String endTimeStr) {
    if (endTimeStr.isEmpty) return 'Berakhir';
    final endTime = DateTime.parse(endTimeStr).toLocal();
    final difference = endTime.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Berakhir';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}j ${difference.inMinutes.remainder(60)}m';
    }
    return '${difference.inMinutes}m';
  }
}
