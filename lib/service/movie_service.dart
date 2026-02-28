import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_ticket/model/movie.dart';

class MovieService {
  // ── Change this to your machine's IP when running on a real device ─────────
  // Android emulator  → 10.0.2.2
  // iOS simulator     → 127.0.0.1
  // Real device       → your local network IP (e.g. 192.168.1.x)
  static const String _baseUrl = 'https://uncondensable-diplopic-gibson.ngrok-free.dev';

  static Future<List<Movie>> fetchAllMovies() async {
    final uri = Uri.parse('$_baseUrl/api/movies/');
    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Handle ApiResponse<List<Movie>> wrapper or a plain list
      List<dynamic> raw;
      if (body is List) {
        raw = body;
      } else if (body is Map) {
        // Spring Boot common wrapper keys: data / result / content
        raw = (body['data'] ?? body['result'] ?? body['content'] ?? []) as List;
      } else {
        raw = [];
      }

      return raw.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load movies (${response.statusCode})');
    }
  }
}
