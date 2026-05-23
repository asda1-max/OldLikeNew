import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Daftar Transaksi lelang',
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
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8865A)),
            ),
          );
        }

        if (controller.transactions.isEmpty) {
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
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: Color(0xFFB8865A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Transaksi lelang Anda akan muncul di sini.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchTransactions,
          color: const Color(0xFFB8865A),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final trx = controller.transactions[index];
              return _buildTransactionCard(context, trx);
            },
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final currentRole = controller.userRole.value;
        return CustomBottomNavBar(currentIndex: currentRole == 'seller' ? 3 : 2);
      }),
    );
  }

  Widget _buildTransactionCard(BuildContext context, dynamic trx) {
    final int trxId = trx['id'];
    final int auctionId = trx['auction_id'];
    final double finalPrice = (trx['final_price'] as num).toDouble();
    final String paymentStatus = trx['payment_status'] ?? 'pending';
    final String shippingStatus = trx['shipping_status'] ?? 'pending';
    final String isSeller = controller.userRole.value;

    final formattedPrice = 'Rp ${finalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

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
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F5F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 16, color: Color(0xFFB8865A)),
                    const SizedBox(width: 6),
                    Text(
                      'TRX #$trxId',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2C1A),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Lelang #$auctionId',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Body of card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Akhir Terlelang',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8865A),
                          ),
                        ),
                      ],
                    ),
                    _buildRoleBadge(),
                  ],
                ),
                const Divider(color: Color(0xFFE8DDD3), height: 24),
                
                // Statuses
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Pembayaran',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(
                            paymentStatus,
                            isPayment: true,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Pengiriman',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(
                            shippingStatus,
                            isPayment: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Action Buttons for statuses
                if (isSeller == 'seller') ...[
                  const SizedBox(height: 16),
                  _buildSellerActions(trxId, shippingStatus),
                ] else ...[
                  if (paymentStatus == 'pending') ...[
                    const SizedBox(height: 16),
                    _buildBuyerActions(trxId),
                  ]
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    final isSeller = controller.userRole.value == 'seller';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSeller ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isSeller ? 'Penjual' : 'Pembeli',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: isSeller ? Colors.orange[800] : Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, {required bool isPayment}) {
    Color bg = const Color(0xFFF9F5F0);
    Color fg = Colors.grey;
    String label = status.toUpperCase();

    if (status == 'pending') {
      bg = const Color(0xFFFFF9C4);
      fg = Colors.orange[900]!;
      label = isPayment ? 'Belum Bayar' : 'Belum Dikirim';
    } else if (status == 'paid' || status == 'completed' || status == 'shipped' || status == 'delivered') {
      bg = const Color(0xFFE8F5E9);
      fg = Colors.green[800]!;
      if (status == 'paid') label = 'Lunas';
      if (status == 'shipped') label = 'Sedang Dikirim';
      if (status == 'delivered') label = 'Telah Diterima';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildSellerActions(int trxId, String currentShippingStatus) {
    if (currentShippingStatus == 'pending') {
      return Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A574), Color(0xFFB8865A)],
          ),
        ),
        child: ElevatedButton.icon(
          onPressed: () => controller.updateShippingStatus(trxId, 'shipped'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 16),
          label: const Text(
            'Kirim Barang Sekarang',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    } else if (currentShippingStatus == 'shipped') {
      return Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFB8865A), width: 1.5),
        ),
        child: OutlinedButton.icon(
          onPressed: () => controller.updateShippingStatus(trxId, 'delivered'),
          style: OutlinedButton.styleFrom(
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.done_all_rounded, color: Color(0xFFB8865A), size: 16),
          label: const Text(
            'Konfirmasi Pengiriman Diterima',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB8865A)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBuyerActions(int trxId) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () => controller.updatePaymentStatus(trxId, 'paid'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
        label: const Text(
          'Bayar Sekarang (Pelunasan)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
