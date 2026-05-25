import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/security_helper.dart';

class AuthService extends GetxService {
  final token = RxnString();
  final role = RxnString('buyer'); // Default to buyer

  bool get isLoggedIn => token.value != null;
  String get userRole => role.value ?? 'buyer';

  @override
  void onInit() {
    super.onInit();
    // Non-blocking initialization
    initSession();
  }

  /// Explicitly async initialization that can be awaited before runApp
  Future<void> initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedToken = prefs.getString('auth_token');
      final encryptedRole = prefs.getString('auth_role');

      if (encryptedToken != null && encryptedToken.isNotEmpty) {
        token.value = Obfuscator.decrypt(encryptedToken);
      }
      if (encryptedRole != null && encryptedRole.isNotEmpty) {
        role.value = Obfuscator.decrypt(encryptedRole);
      }
      print("Auth session loaded: isLogged=${isLoggedIn}, role=${userRole}");
      
      // If token exists, we could also sync FCM token here if we saved userId
      final userId = prefs.getInt('auth_user_id');
      if (userId != null && token.value != null) {
        _syncFcmToken(userId, token.value!);
      }
    } catch (e) {
      print("Error loading auth session: $e");
    }
  }

  Future<void> setSession(String tokenVal, String roleVal, {int? userId}) async {
    token.value = tokenVal;
    role.value = roleVal;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', Obfuscator.encrypt(tokenVal));
      await prefs.setString('auth_role', Obfuscator.encrypt(roleVal));
      if (userId != null) {
        await prefs.setInt('auth_user_id', userId);
        _syncFcmToken(userId, tokenVal);
      }
    } catch (e) {
      print("Error saving auth session: $e");
    }
  }

  Future<void> _syncFcmToken(int userId, String authToken) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
        final url = Uri.parse('$baseUrl/users/$userId/fcm-token');
        await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'fcm_token': fcmToken}),
        );
      }
      
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';
        final url = Uri.parse('$baseUrl/users/$userId/fcm-token');
        await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'fcm_token': newToken}),
        );
      });
    } catch (e) {
      print("Error syncing FCM token: $e");
    }
  }

  Future<void> logout() async {
    token.value = null;
    role.value = 'buyer';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_role');
      await prefs.remove('profile_cache');
    } catch (e) {
      print("Error clearing auth session: $e");
    }
  }
}
