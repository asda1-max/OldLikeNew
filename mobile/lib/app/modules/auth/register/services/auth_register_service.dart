import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRegisterService {
  final String baseUrl;
  AuthRegisterService()
    : baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:8000';

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // Try to extract detail if backend sends JSON
      String message = 'Registration failed';
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('detail')) {
          message = data['detail'];
        } else if (data.containsKey('detail')) {
          message = data['detail'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
