import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_ticket/model/cinema.dart';

class CinemaService {
  static const String _baseUrl =
      'https://uncondensable-diplopic-gibson.ngrok-free.dev';

  static Future<List<Cinema>> fetchAllCinemas() async {
    final uri = Uri.parse('$_baseUrl/api/cinema/');
    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cinemas (${response.statusCode})');
    }

    final body = jsonDecode(response.body);
    final raw = _extractList(body);

    return raw
        .map((item) => Cinema.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<dynamic> _extractList(dynamic body) {
    if (body is List) {
      return body;
    }
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body['result'] ?? body['content'];
      if (data is List) {
        return data;
      }
    }
    return [];
  }
}
