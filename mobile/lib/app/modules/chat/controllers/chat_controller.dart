import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/auth_service.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final isSending = false.obs;
  final isLoadingThreads = false.obs;
  final isLoadingMessages = false.obs;
  final userId = RxnInt();
  final userName = 'Pengguna'.obs;
  final userRole = 'buyer'.obs;

  final chatId = RxnString();
  final buyerId = RxnInt();
  final sellerId = RxnInt();
  final buyerName = 'Pembeli'.obs;
  final sellerName = 'Penjual'.obs;
  final threads = <Map<String, dynamic>>[].obs;
  final messages = <Map<String, dynamic>>[].obs;

  late final String baseUrl;
  Timer? _threadsTimer;
  Timer? _messagesTimer;

  @override
  void onInit() {
    super.onInit();
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
    final authService = Get.find<AuthService>();
    userRole.value = authService.userRole;
    _loadProfile().then((_) {
      _initFromArgs();
      _startThreadsPolling();
    });
  }

  @override
  void onClose() {
    _threadsTimer?.cancel();
    _messagesTimer?.cancel();
    messageController.dispose();
    super.onClose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId.value = prefs.getInt('auth_user_id');

      final cachedProfile = prefs.getString('profile_cache');
      if (cachedProfile != null && cachedProfile.isNotEmpty) {
        final data = jsonDecode(cachedProfile) as Map<String, dynamic>;
        final name = data['name'] as String?;
        if (name != null && name.isNotEmpty) {
          userName.value = name;
        }
      }
    } catch (e) {
      debugPrint('[Chat] Failed to load profile: $e');
    }
  }

  Map<String, String> _authHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  void _startThreadsPolling() {
    _threadsTimer?.cancel();
    fetchThreads();
    _threadsTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchThreads();
    });
  }

  void _startMessagesPolling() {
    _messagesTimer?.cancel();
    fetchMessages();
    _messagesTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchMessages();
    });
  }

  void _stopMessagesPolling() {
    _messagesTimer?.cancel();
    _messagesTimer = null;
  }

  void _initFromArgs() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final argChatId = args['chat_id'] as String?;
      if (argChatId != null && argChatId.isNotEmpty) {
        chatId.value = argChatId;
        _startMessagesPolling();
        return;
      }

      final argSellerId = args['seller_id'] as int?;
      final argSellerName = args['seller_name'] as String?;

      if (argSellerId != null) {
        sellerId.value = argSellerId;
        if (argSellerName != null && argSellerName.isNotEmpty) {
          sellerName.value = argSellerName;
        }

        final currentUserId = userId.value;
        if (currentUserId != null) {
          buyerId.value = currentUserId;
          buyerName.value = userName.value;
          chatId.value = _buildChatId(currentUserId, argSellerId);
          _startMessagesPolling();
        }
      }
    }
  }

  void openChatFromThread(Map<String, dynamic> thread) {
    chatId.value = thread['id'] as String?;
    buyerId.value = thread['buyer_id'] as int?;
    sellerId.value = thread['seller_id'] as int?;
    final storedBuyerName = thread['buyer_name'] as String?;
    final storedSellerName = thread['seller_name'] as String?;

    if (storedBuyerName != null && storedBuyerName.isNotEmpty) {
      buyerName.value = storedBuyerName;
    }
    if (storedSellerName != null && storedSellerName.isNotEmpty) {
      sellerName.value = storedSellerName;
    }

    _startMessagesPolling();
  }

  void closeChat() {
    chatId.value = null;
    messages.clear();
    _stopMessagesPolling();
  }

  String _buildChatId(int buyer, int seller) {
    return 'buyer_${buyer}_seller_${seller}';
  }

  Future<void> fetchThreads() async {
    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) return;

    isLoadingThreads.value = true;
    try {
      final url = Uri.parse('$baseUrl/chat/threads?limit=50');
      final response = await http.get(url, headers: _authHeaders(token));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        threads.value = data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat chat');
      }
    } catch (e) {
      debugPrint('[Chat] Failed to fetch threads: $e');
    } finally {
      isLoadingThreads.value = false;
    }
  }

  Future<void> fetchMessages() async {
    final currentChatId = chatId.value;
    if (currentChatId == null) return;

    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) return;

    isLoadingMessages.value = true;
    try {
      final url = Uri.parse('$baseUrl/chat/threads/$currentChatId/messages?limit=50');
      final response = await http.get(url, headers: _authHeaders(token));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        messages.value = data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat pesan');
      }
    } catch (e) {
      debugPrint('[Chat] Failed to fetch messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final currentBuyerId = buyerId.value;
    final currentSellerId = sellerId.value;
    final currentUserId = userId.value;

    if (currentUserId == null) {
      Get.snackbar('Gagal', 'Sesi pengguna tidak ditemukan.');
      return;
    }

    if (currentBuyerId == null || currentSellerId == null) {
      Get.snackbar('Gagal', 'Data chat belum lengkap.');
      return;
    }

    final authService = Get.find<AuthService>();
    final token = authService.token.value;
    if (token == null) {
      Get.snackbar('Gagal', 'Anda harus masuk terlebih dahulu.');
      return;
    }

    final int? otherUserId = userRole.value == 'seller' ? currentBuyerId : currentSellerId;
    if (otherUserId == null) {
      Get.snackbar('Gagal', 'Lawan chat tidak ditemukan.');
      return;
    }

    isSending.value = true;

    try {
      final url = Uri.parse('$baseUrl/chat/threads/messages');
      final response = await http.post(
        url,
        headers: _authHeaders(token),
        body: jsonEncode({
          'text': text,
          'other_user_id': otherUserId,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[Chat] Send failed: ${response.statusCode} ${response.body}');
        throw Exception('Gagal mengirim pesan');
      }

      messageController.clear();
      debugPrint('[Chat] Message sent by ${userId.value}');
      await fetchMessages();
      await fetchThreads();
    } catch (e) {
      debugPrint('[Chat] Failed to send message: $e');
      Get.snackbar('Gagal', 'Pesan tidak terkirim. Coba lagi.');
    } finally {
      isSending.value = false;
    }
  }
}
