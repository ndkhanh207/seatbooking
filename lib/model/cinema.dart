class Room {
  final int id;
  final String name;
  final int totalSeats;

  const Room({required this.id, required this.name, required this.totalSeats});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      totalSeats:
          (json['totalSeats'] ?? json['total_seat'] as num?)?.toInt() ?? 0,
    );
  }
}

class Cinema {
  final int id;
  final String name;
  final String address;
  final List<Room> rooms;

  const Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.rooms,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    final roomsList = <Room>[];
    final rawRooms = json['rooms'];

    if (rawRooms is List) {
      roomsList.addAll(
        rawRooms.whereType<Map<String, dynamic>>().map(
          (room) => Room.fromJson(room),
        ),
      );
    }

    return Cinema(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      rooms: roomsList,
    );
  }
}

class Showtime {
  final int id;
  final int movieId;
  final String roomName;
  final DateTime startTime;
  final String format;
  final double price;
  final bool isAvailable;

  const Showtime({
    required this.id,
    required this.movieId,
    required this.roomName,
    required this.startTime,
    this.format = '2D',
    required this.price,
    this.isAvailable = true,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    final startTimeRaw =
        (json['startTime'] ?? json['start_time'])?.toString() ?? '';
    final parsedStart = DateTime.tryParse(startTimeRaw) ?? DateTime.now();

    final movie = json['movieId'] ?? json['movie'] ?? json['movie_id'];
    int movieId = 0;
    if (movie is int) {
      movieId = movie;
    } else if (movie is num) {
      movieId = movie.toInt();
    } else if (movie is Map<String, dynamic>) {
      movieId = (movie['id'] as num?)?.toInt() ?? 0;
    }

    return Showtime(
      id: (json['id'] as num?)?.toInt() ?? 0,
      movieId: movieId,
      roomName:
          (json['roomName'] ?? json['room_name'] ?? json['room'] as String?) ??
          '',
      startTime: parsedStart,
      format: (json['format'] as String?) ?? '2D',
      price: (json['price'] as num?)?.toDouble() ?? 100000,
      isAvailable: (json['isAvailable'] as bool?) ?? true,
    );
  }

  String get time {
    final hh = startTime.hour.toString().padLeft(2, '0');
    final mm = startTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
