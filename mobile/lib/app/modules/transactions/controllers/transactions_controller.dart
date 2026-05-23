import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../shared/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class TransactionsController extends GetxController {
  final isLoading = false.obs;
  final transactions = <dynamic>[].obs;
  final userRole = 'buyer'.obs;

  late final String baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    final authService = Get.find<AuthService>();
    userRole.value = authService.userRole;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;

    if (token == null) {
      Get.offAllNamed(Routes.AUTH_LOGIN);
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse('$baseUrl/transactions/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        transactions.value = data;
      } else {
        throw Exception('Gagal mengambil daftar transaksi');
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateShippingStatus(int transactionId, String status) async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;

    if (token == null) return;

    isLoading.value = true;

    try {
      final url = Uri.parse('$baseUrl/transactions/$transactionId/status');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'shipping_status': status,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Sukses', 'Status pengiriman berhasil diubah menjadi: $status');
        await fetchTransactions(); // Refresh the list
      } else {
        String detail = 'Gagal mengubah status pengiriman';
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          detail = data['detail'] ?? detail;
        } catch (_) {}
        throw Exception(detail);
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePaymentStatus(int transactionId, String status) async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;

    if (token == null) return;

    isLoading.value = true;

    try {
      final url = Uri.parse('$baseUrl/transactions/$transactionId/status');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'payment_status': status,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Sukses', 'Status pembayaran berhasil diubah menjadi: $status');
        await fetchTransactions(); // Refresh the list
      } else {
        String detail = 'Gagal mengubah status pembayaran';
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          detail = data['detail'] ?? detail;
        } catch (_) {}
        throw Exception(detail);
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
