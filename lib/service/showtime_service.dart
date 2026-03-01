import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_ticket/model/cinema.dart';

class ShowtimeService {
  static const String _baseUrl =
      'https://uncondensable-diplopic-gibson.ngrok-free.dev';

  static Future<List<Showtime>> fetchShowtimes({
    required int movieId,
    String? roomName,
    required DateTime date,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/showtime/$movieId');
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load showtimes (${response.statusCode})');
      }

      final body = jsonDecode(response.body);
      final raw = _extractList(body);

      var parsed = raw
          .map((item) => Showtime.fromJson(item as Map<String, dynamic>))
          .toList();

      // Filter by roomName if provided
      if (roomName != null && roomName.isNotEmpty) {
        parsed = parsed.where((item) => item.roomName == roomName).toList();
      }

      // Filter by date
      parsed =
          parsed
              .where(
                (item) =>
                    item.startTime.year == date.year &&
                    item.startTime.month == date.month &&
                    item.startTime.day == date.day,
              )
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

      return parsed;
    } catch (e) {
      rethrow;
    }
  }

  static List<dynamic> _extractList(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body['result'] ?? body['content'];
      if (data is List) {
        return data;
      }
    }
    return [];
  }
}
