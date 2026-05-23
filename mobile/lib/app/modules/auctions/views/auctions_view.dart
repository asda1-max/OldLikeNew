import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auctions_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';

class AuctionsView extends GetView<AuctionsController> {
  const AuctionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Daftar Lelang',
          style: TextStyle(
            color: Color(0xFFD4A574),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4A574)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.3)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari barang lelang...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFD4A574)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.auctions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
                  ),
                );
              }

              if (controller.auctions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8DDD3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
                          size: 40,
                          color: Color(0xFFB8865A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak Ada Lelang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Barang lelang yang dicari tidak ditemukan.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchAuctions,
                color: const Color(0xFFB8865A),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.auctions.length,
                  itemBuilder: (context, index) {
                    final auction = controller.auctions[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed(Routes.AUCTION_DETAIL, arguments: auction['id']),
                      child: _buildAuctionListItem(auction),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Aktif', 'Akan Datang', 'Selesai'];
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedFilterIndex.value == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4A2C1A),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => controller.changeFilter(index),
                backgroundColor: const Color(0xFFF9F5F0),
                selectedColor: const Color(0xFFB8865A),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : const Color(0xFFE8DDD3),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildAuctionListItem(dynamic auction) {
    final item = auction['item'] ?? {};
    final title = item['title'] ?? 'Barang Lelang';
    final currentPrice = (auction['current_price'] as num).toDouble();
    final condition = item['condition'] ?? 'Bekas';
    final endTime = auction['end_time'] ?? '';
    final status = auction['status'] ?? 'active';
    final imageList = item['image_urls'] as List<dynamic>? ?? [];
    final image = imageList.isNotEmpty
        ? '${controller.baseUrl}/${imageList[0]}'
        : '';

    final formattedPrice = 'Rp ${currentPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 120,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 140,
                      color: const Color(0xFFE8DDD3),
                      child: const Icon(Icons.image, color: Color(0xFFB8865A)),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 140,
                    color: const Color(0xFFE8DDD3),
                    child: const Icon(Icons.image, color: Color(0xFFB8865A)),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'closed' ? Colors.red[50] : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status == 'closed' ? 'Selesai' : 'Berlangsung',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: status == 'closed' ? Colors.red[800] : const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                      const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1810),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kondisi: $condition',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'closed' ? 'Harga Akhir' : 'Bid Tertinggi',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            formattedPrice,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB8865A),
                            ),
                          ),
                        ],
                      ),
                      if (status != 'closed')
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              getTimeLeft(endTime),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4A2C1A),
                              ),
                            ),
                          ],
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
