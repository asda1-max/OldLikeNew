import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuctionsController extends GetxController {
  final isLoading = false.obs;
  final auctions = <dynamic>[].obs;
  final selectedFilterIndex = 0.obs; // 0 = Semua/Aktif, 1 = Selesai/Closed

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    fetchAuctions();
  }

  Future<void> fetchAuctions() async {
    isLoading.value = true;
    try {
      String statusParam = 'active';
      if (selectedFilterIndex.value == 3) {
        // "Selesai" chip
        statusParam = 'closed';
      }

      final url = Uri.parse('$baseUrl/auctions/?status=$statusParam');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        auctions.value = data;
      } else {
        throw Exception('Gagal memuat daftar lelang');
      }
    } catch (e) {
      print('Error fetching auctions list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
    fetchAuctions();
  }
}
