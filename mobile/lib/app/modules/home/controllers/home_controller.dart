import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final activeAuctions = <dynamic>[].obs;
  final endingSoonAuctions = <dynamic>[].obs;

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    fetchAuctions();
  }

  Future<void> fetchAuctions({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'home_auctions_cache';
      
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        activeAuctions.value = data;
        endingSoonAuctions.value = data.take(3).toList();
        
        if (!forceRefresh) {
          return; // Skip fetching from backend if we already have cache
        }
      } else {
        isLoading.value = true;
      }

      final url = Uri.parse('$baseUrl/auctions/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        activeAuctions.value = data;
        endingSoonAuctions.value = data.take(3).toList();
        prefs.setString(cacheKey, response.body);
      } else {
        if (cachedData == null) {
          throw Exception('Gagal memuat lelang');
        }
      }
    } catch (e) {
      print('Error fetching auctions on home: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
