import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthLoginService {
  final String baseUrl;

  AuthLoginService()
    : baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    // FastAPI's OAuth2PasswordRequestForm expects x-www-form-urlencoded
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      String message = 'Login failed';
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('detail')) {
          message = data['detail'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
