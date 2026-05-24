import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../shared/services/auth_service.dart';

class MyItemsController extends GetxController {
  final isLoading = false.obs;
  final items = <dynamic>[].obs;
  final verifiedItemIds = <int>[].obs;

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    fetchMyItems();
  }

  Future<void> fetchMyItems() async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) return;

    isLoading.value = true;
    try {
      // 1. Fetch seller's items
      final itemsUrl = Uri.parse('$baseUrl/items/');
      final itemsResponse = await http.get(
        itemsUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (itemsResponse.statusCode == 200) {
        items.value = jsonDecode(itemsResponse.body);
      } else {
        throw Exception('Gagal memuat barang');
      }

      // 2. Fetch auctions to see which items are verified (in an auction)
      // The backend returns all active/closed auctions
      final auctionsUrl = Uri.parse('$baseUrl/auctions/');
      final auctionsResponse = await http.get(auctionsUrl);

      if (auctionsResponse.statusCode == 200) {
        final List<dynamic> auctionsData = jsonDecode(auctionsResponse.body);
        final List<int> verified = [];
        for (var auction in auctionsData) {
          if (auction['item'] != null) {
            verified.add(auction['item']['id'] as int);
          }
        }
        verifiedItemIds.value = verified;
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat barang Anda');
      print('Error fetching my items: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
