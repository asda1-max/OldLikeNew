import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_items_controller.dart';

class MyItemsView extends GetView<MyItemsController> {
  const MyItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Kelola Barang Saya',
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

        if (controller.items.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyItems,
          color: const Color(0xFFB8865A),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return _buildItemCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada barang yang diunggah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai jual barang Anda sekarang!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final int itemId = item['id'] as int;
    final bool isVerified = controller.verifiedItemIds.contains(itemId);
    final bool hasAuction = controller.auctionedItemIds.contains(itemId);
    final imageUrls = item['image_urls'] as List<dynamic>? ?? [];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';
    
    // Construct valid backend image URL
    final baseUrl = controller.baseUrl;
    final fullImageUrl = imageUrl.isNotEmpty 
        ? (imageUrl.startsWith('http') ? imageUrl : '$baseUrl/$imageUrl')
        : '';

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
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFFF9F5F0),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        )
                      : const Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['category'] ?? 'Tanpa Kategori',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            isVerified ? Icons.check_circle_outline : Icons.pending_outlined,
                            size: 16,
                            color: isVerified ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified ? 'Sudah Diverifikasi' : 'Menunggu Verifikasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isVerified ? Colors.green : Colors.orange,
                            ),
                          ),
                          if (isVerified && !hasAuction) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Siap Lelang',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8865A),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isVerified && !hasAuction) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCreateAuctionDialog(itemId),
                            icon: const Icon(Icons.gavel_rounded, size: 16, color: Colors.white),
                            label: const Text(
                              'Buat Lelang',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8865A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateAuctionDialog(int itemId) {
    final startPriceController = TextEditingController();
    final buyoutPriceController = TextEditingController();
    final durationOptions = [12, 24, 48, 72];
    final selectedDuration = 24.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Buat Lelang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Start Price (Rp)'),
            ),
            TextField(
              controller: buyoutPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Buyout Price (Opsional)'),
            ),
            const SizedBox(height: 8),
            Obx(() {
              return DropdownButtonFormField<int>(
                value: selectedDuration.value,
                decoration: const InputDecoration(labelText: 'Durasi (Jam)'),
                items: durationOptions
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value Jam'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedDuration.value = value;
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final startPrice = double.tryParse(startPriceController.text.trim());
              if (startPrice == null || startPrice <= 0) {
                Get.snackbar('Error', 'Start price tidak valid');
                return;
              }

              final buyoutText = buyoutPriceController.text.trim();
              final buyoutPrice = buyoutText.isEmpty ? null : double.tryParse(buyoutText);

              if (buyoutText.isNotEmpty && (buyoutPrice == null || buyoutPrice <= 0)) {
                Get.snackbar('Error', 'Buyout price tidak valid');
                return;
              }

              controller.createAuction(
                itemId: itemId,
                startPrice: startPrice,
                buyoutPrice: buyoutPrice,
                durationHours: selectedDuration.value,
              );
              Get.back();
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }
}
