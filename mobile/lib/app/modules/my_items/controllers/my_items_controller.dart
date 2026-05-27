import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../shared/services/auth_service.dart';

class MyItemsController extends GetxController {
  final isLoading = false.obs;
  final items = <dynamic>[].obs;
  final verifiedItemIds = <int>[].obs;
  final auctionedItemIds = <int>[].obs;

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
        final List<dynamic> data = jsonDecode(itemsResponse.body);
        items.value = data;
        verifiedItemIds.value = data
            .where((item) => item['is_verified'] == true)
            .map<int>((item) => item['id'] as int)
            .toList();
      } else {
        throw Exception('Gagal memuat barang');
      }

      // 2. Fetch auctions to see which items already have auctions
      final statuses = ['active', 'closed', 'cancelled'];
      final Set<int> auctioned = {};
      for (final status in statuses) {
        final auctionsUrl = Uri.parse('$baseUrl/auctions/?status=$status');
        final auctionsResponse = await http.get(auctionsUrl);
        if (auctionsResponse.statusCode == 200) {
          final List<dynamic> auctionsData = jsonDecode(auctionsResponse.body);
          for (var auction in auctionsData) {
            if (auction['item'] != null) {
              auctioned.add(auction['item']['id'] as int);
            }
          }
        }
      }
      auctionedItemIds.value = auctioned.toList();
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat barang Anda');
      print('Error fetching my items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAuction({
    required int itemId,
    required double startPrice,
    double? buyoutPrice,
    required int durationHours,
  }) async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) return;

    try {
      final now = DateTime.now().toUtc();
      final endTime = now.add(Duration(hours: durationHours));
      final url = Uri.parse('$baseUrl/auctions/');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
          'start_price': startPrice,
          'buyout_price': buyoutPrice,
          'start_time': now.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Sukses', 'Lelang berhasil dibuat');
        await fetchMyItems();
      } else {
        String detail = 'Gagal membuat lelang';
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          detail = data['detail'] ?? detail;
        } catch (_) {}
        throw Exception(detail);
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    }
  }
}
