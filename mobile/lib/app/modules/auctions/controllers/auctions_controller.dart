import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuctionsController extends GetxController {
  final isLoading = false.obs;
  final auctions = <dynamic>[].obs;
  final allAuctions = <dynamic>[].obs;
  final selectedFilterIndex = 0.obs; // 0 = Semua/Aktif, 1 = Selesai/Closed
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final searchController = TextEditingController();

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args['search'] != null) {
        searchQuery.value = args['search'];
        searchController.text = args['search'];
      }
      if (args['category'] != null) {
        selectedCategory.value = args['category'];
      }
    }
    
    fetchAuctions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAuctions({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String statusParam = 'active';
      if (selectedFilterIndex.value == 3) {
        statusParam = 'closed';
      }

      String urlStr = '$baseUrl/auctions/?status=$statusParam';
      if (selectedCategory.value.isNotEmpty) {
        urlStr += '&category=${selectedCategory.value}';
      }

      final cacheKey = 'auctions_cache_$urlStr';
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        allAuctions.value = data;
        applySearch();
        
        if (!forceRefresh) {
          return; // Skip fetching from backend if we already have cache
        }
      } else {
        isLoading.value = true;
      }

      final url = Uri.parse(urlStr);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        allAuctions.value = data;
        applySearch();
        prefs.setString(cacheKey, response.body);
      } else {
        if (cachedData == null) {
          throw Exception('Gagal memuat daftar lelang');
        }
      }
    } catch (e) {
      print('Error fetching auctions list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applySearch();
  }

  void applySearch() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      auctions.value = allAuctions;
    } else {
      auctions.value = allAuctions.where((auction) {
        final item = auction['item'] ?? {};
        final title = (item['title'] ?? '').toString().toLowerCase();
        return title.contains(query);
      }).toList();
    }
  }

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
    fetchAuctions();
  }
}
