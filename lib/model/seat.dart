class Seat {
  final int id;
  final String seatName;
  final String seatType;
  final bool isActive;

  const Seat({
    required this.id,
    required this.seatName,
    required this.seatType,
    required this.isActive,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seatName: (json['seatName'] as String?) ?? '',
      seatType: (json['seatType'] as String?) ?? 'NORMAL',
      isActive: (json['isActive'] as bool?) ?? false,
    );
  }

  String get row {
    final match = RegExp(r'^[A-Za-z]+').firstMatch(seatName);
    return (match?.group(0) ?? '').toUpperCase();
  }

  int get number {
    final match = RegExp(r'(\d+)$').firstMatch(seatName);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }
}
