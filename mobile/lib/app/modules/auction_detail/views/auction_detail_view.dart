import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auction_detail_controller.dart';

class AuctionDetailView extends GetView<AuctionDetailController> {
  const AuctionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Detail Barang Lelang',
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
        final data = controller.auction.value;

        if (controller.isLoading.value && data == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
            ),
          );
        }

        if (data == null) {
          return const Center(
            child: Text(
              'Gagal memuat informasi lelang',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final item = data['item'] ?? {};
        final title = item['title'] ?? 'Barang Lelang';
        final description = item['description'] ?? 'Tidak ada deskripsi.';
        final category = item['category'] ?? 'Lainnya';
        final condition = item['condition'] ?? 'Bekas';
        final startPrice = (data['start_price'] as num).toDouble();
        final currentPrice = (data['current_price'] as num).toDouble();
        final buyoutPrice = data['buyout_price'] != null ? (data['buyout_price'] as num).toDouble() : null;
        final endTimeStr = data['end_time'] ?? '';
        final status = data['status'] ?? 'active';
        final imageList = item['image_urls'] as List<dynamic>? ?? [];
        final image = imageList.isNotEmpty ? '${controller.baseUrl}/${imageList[0]}' : '';

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), // Space for bottom bidding sheet
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageBanner(image, status),
                  const SizedBox(height: 20),
                  _buildProductHeader(title, category, condition),
                  const SizedBox(height: 16),
                  _buildTimerCard(endTimeStr, status),
                  const SizedBox(height: 20),
                  _buildPriceSection(startPrice, currentPrice, buyoutPrice),
                  const SizedBox(height: 20),
                  _buildDescriptionCard(description),
                  const SizedBox(height: 24),
                  _buildBidsHistorySection(),
                ],
              ),
            ),
            if (status == 'active' && controller.userRole.value == 'buyer')
              _buildBiddingPanel(currentPrice),
          ],
        );
      }),
    );
  }

  Widget _buildImageBanner(String image, String status) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE8DDD3),
                      child: const Icon(Icons.image, color: Color(0xFFB8865A), size: 60),
                    ),
                  )
                : Container(
                    color: const Color(0xFFE8DDD3),
                    child: const Icon(Icons.image, color: Color(0xFFB8865A), size: 60),
                  ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'closed' ? Colors.red[800] : const Color(0xFF2C1810),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status == 'closed' ? 'TUTUP' : 'AKTIF',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4A574),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(String title, String category, String condition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8DDD3)),
              ),
              child: Text(
                condition,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2C1A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C1810),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard(String endTimeStr, String status) {
    final timeLeft = getTimeLeft(endTimeStr);
    final isEnded = status == 'closed' || timeLeft == 'Berakhir';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isEnded ? Colors.red[50] : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEnded ? Colors.red[100]! : Colors.yellow[200]!),
      ),
      child: Row(
        children: [
          Icon(
            isEnded ? Icons.lock_clock_outlined : Icons.timer,
            color: isEnded ? Colors.red[800] : Colors.amber[800],
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnded ? 'Pelelangan Telah Berakhir' : 'Waktu Tersisa',
                style: TextStyle(
                  fontSize: 11,
                  color: isEnded ? Colors.red[800] : Colors.amber[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isEnded) ...[
                const SizedBox(height: 2),
                Text(
                  timeLeft,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1810),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double startPrice, double currentPrice, double? buyoutPrice) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga Awal',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(startPrice),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A574).withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bid Tertinggi',
                  style: TextStyle(fontSize: 10, color: Color(0xFFB8865A), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(currentPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8865A),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (buyoutPrice != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga Buyout',
                    style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(buyoutPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes, color: Color(0xFFB8865A), size: 18),
              SizedBox(width: 6),
              Text(
                'Deskripsi Barang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF4A2C1A), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBidsHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, color: Color(0xFFB8865A), size: 18),
            const SizedBox(width: 8),
            const Text(
              'Riwayat Penawaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8DDD3)),
              ),
              child: Text(
                '${controller.bids.length} Bid',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4A2C1A)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (controller.bids.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
            ),
            child: const Center(
              child: Text(
                'Belum ada penawaran. Jadilah yang pertama!',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.bids.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFFE8DDD3), height: 1),
              itemBuilder: (context, index) {
                final bid = controller.bids[index];
                final double amount = (bid['amount'] as num).toDouble();
                final int bidderId = bid['bidder_id'] ?? 0;
                final timestamp = bid['created_at'] != null ? DateTime.parse(bid['created_at']).toLocal() : DateTime.now();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF9F5F0),
                    child: Icon(Icons.gavel_rounded, color: index == 0 ? const Color(0xFFB8865A) : Colors.grey, size: 18),
                  ),
                  title: Text(
                    'Penaung #$bidderId',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
                  ),
                  subtitle: Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} - ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                    style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                  ),
                  trailing: Text(
                    formatPrice(amount),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: index == 0 ? const Color(0xFFB8865A) : const Color(0xFF4A2C1A),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBiddingPanel(double currentPrice) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8DDD3), width: 1.2),
                    ),
                    child: TextFormField(
                      controller: controller.bidController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.gavel_rounded, color: Color(0xFFB8865A), size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F5F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8DDD3)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      final currentVal = double.tryParse(controller.bidController.text) ?? currentPrice;
                      controller.bidController.text = (currentVal + 10000).toStringAsFixed(0);
                    },
                    child: const Text(
                      '+ Rp 10rb',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFB8865A)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A574), Color(0xFFB8865A)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: controller.isPlacingBid.value ? null : controller.submitBid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isPlacingBid.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Bid Sekarang',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
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
