import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../shared/services/auth_service.dart';

class AuctionDetailController extends GetxController {
  final isLoading = false.obs;
  final isPlacingBid = false.obs;
  
  final auction = Rxn<dynamic>();
  final bids = <dynamic>[].obs;
  
  final bidController = TextEditingController();

  late final int auctionId;
  late final String baseUrl;
  
  final userRole = 'buyer'.obs;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    
    final authService = Get.find<AuthService>();
    userRole.value = authService.userRole;

    if (Get.arguments is int) {
      auctionId = Get.arguments as int;
      fetchAuctionDetail();
    } else {
      Get.back();
      Get.snackbar('Error', 'ID lelang tidak valid');
    }
  }

  @override
  void onClose() {
    bidController.dispose();
    super.onClose();
  }

  Future<void> fetchAuctionDetail() async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/auctions/$auctionId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        auction.value = data;
        bids.value = data['bids'] ?? [];
        
        // Auto-fill next minimum bid (current_price + Rp 1.000)
        final currentPrice = (data['current_price'] as num).toDouble();
        bidController.text = (currentPrice + 1000).toStringAsFixed(0);
      } else {
        throw Exception('Gagal memuat detail lelang');
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitBid() async {
    final amountStr = bidController.text.trim();
    if (amountStr.isEmpty) {
      Get.snackbar('Error', 'Masukkan nominal bid Anda');
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Nominal bid harus berupa angka positif');
      return;
    }

    final currentPrice = (auction.value?['current_price'] as num?)?.toDouble() ?? 0.0;
    if (amount <= currentPrice + 1000) {
      Get.snackbar('Error', 'Nominal bid minimal adalah Rp ${(currentPrice + 1000).toStringAsFixed(0)}');
      return;
    }

    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) {
      Get.snackbar('Error', 'Anda harus masuk terlebih dahulu untuk menawar');
      return;
    }

    isPlacingBid.value = true;

    try {
      final url = Uri.parse('$baseUrl/bids/$auctionId');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Sukses', 'Bid Anda berhasil dipasang!');
        await fetchAuctionDetail(); // Refresh page details
      } else {
        String detail = 'Gagal memasang bid';
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          detail = data['detail'] ?? detail;
        } catch (_) {}
        throw Exception(detail);
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isPlacingBid.value = false;
    }
  }
}
