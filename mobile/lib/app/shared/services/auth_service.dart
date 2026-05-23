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
    } catch (e) {
      print("Error loading auth session: $e");
    }
  }

  Future<void> setSession(String tokenVal, String roleVal) async {
    token.value = tokenVal;
    role.value = roleVal;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', Obfuscator.encrypt(tokenVal));
      await prefs.setString('auth_role', Obfuscator.encrypt(roleVal));
    } catch (e) {
      print("Error saving auth session: $e");
    }
  }

  Future<void> logout() async {
    token.value = null;
    role.value = 'buyer';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_role');
    } catch (e) {
      print("Error clearing auth session: $e");
    }
  }
}
