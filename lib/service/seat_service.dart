import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_ticket/model/seat.dart';

class SeatService {
  static const String _baseUrl =
      'https://uncondensable-diplopic-gibson.ngrok-free.dev';

  static Future<List<Seat>> fetchSeatsByRoom(int roomId) async {
    final uri = Uri.parse('$_baseUrl/api/seat/$roomId');
    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load seats (${response.statusCode})');
    }

    final body = jsonDecode(response.body);
    final raw = _extractList(body);

    return raw
        .map((item) => Seat.fromJson(item as Map<String, dynamic>))
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
