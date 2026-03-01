import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_ticket/model/movie.dart';
import 'package:movie_ticket/model/cinema.dart';
import 'package:movie_ticket/model/seat.dart';
import 'package:movie_ticket/service/seat_service.dart';
import 'package:intl/intl.dart';

const _bg = Color(0xFF1A1A2E);
const _card = Color(0xFF16213E);
const _accent = Color(0xFFE94560);

enum SeatStatus { available, selected, occupied }

class SeatSelectionPage extends StatefulWidget {
  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;
  final DateTime date;

  const SeatSelectionPage({
    Key? key,
    required this.movie,
    required this.cinema,
    required this.showtime,
    required this.date,
  }) : super(key: key);

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final Map<String, SeatStatus> seats = {};
  final Map<String, Seat> seatMeta = {};
  List<String> rows = [];
  List<int> columns = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Find the room by matching the showtime's roomName with cinema's rooms
      final room = widget.cinema.rooms.firstWhere(
        (r) => r.name == widget.showtime.roomName,
        orElse: () =>
            throw Exception('Room not found: ${widget.showtime.roomName}'),
      );

      final apiSeats = await SeatService.fetchSeatsByRoom(room.id);

      final rowSet = <String>{};
      final colSet = <int>{};

      seats.clear();
      seatMeta.clear();

      for (final apiSeat in apiSeats) {
        if (apiSeat.row.isEmpty || apiSeat.number == 0) {
          continue;
        }

        final key = '${apiSeat.row}${apiSeat.number}';
        rowSet.add(apiSeat.row);
        colSet.add(apiSeat.number);
        seatMeta[key] = apiSeat;
        seats[key] = apiSeat.isActive
            ? SeatStatus.available
            : SeatStatus.occupied;
      }

      setState(() {
        rows = rowSet.toList()..sort();
        columns = colSet.toList()..sort();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> get selectedSeats => seats.entries
      .where((e) => e.value == SeatStatus.selected)
      .map((e) => e.key)
      .toList();

  double get totalPrice => selectedSeats.length * widget.showtime.price;

  void _toggleSeat(String seatId) {
    if (!seats.containsKey(seatId)) return;
    if (seats[seatId] == SeatStatus.occupied) return;
    setState(() {
      seats[seatId] = seats[seatId] == SeatStatus.selected
          ? SeatStatus.available
          : SeatStatus.selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select Seats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildMovieInfo(),
          const SizedBox(height: 20),
          _buildScreen(),
          const SizedBox(height: 30),
          Expanded(child: _buildSeatContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMovieInfo() {
    final dateFormat = DateFormat('EEE, MMM d, y');
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cinema.name,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.showtime.format,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoItem(
                Icons.calendar_today_rounded,
                dateFormat.format(widget.date),
              ),
              const SizedBox(width: 16),
              _infoItem(Icons.access_time_rounded, widget.showtime.time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildScreen() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _accent.withOpacity(0.1),
                _accent,
                _accent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'SCREEN',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white38,
                size: 52,
              ),
              const SizedBox(height: 12),
              const Text(
                'Could not load seats',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _loadSeats,
                style: ElevatedButton.styleFrom(backgroundColor: _accent),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (seats.isEmpty) {
      return const Center(
        child: Text(
          'No seats found for this room',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeats,
      color: _accent,
      backgroundColor: _card,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildSeatingChart(),
            const SizedBox(height: 20),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatingChart() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row label
                  SizedBox(
                    width: 20,
                    child: Text(
                      row,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Seats
                  ...columns.map((col) {
                    final seatId = '$row$col';
                    final status = seats[seatId];

                    if (status == null) {
                      return const SizedBox(width: 32);
                    }

                    // Add aisle space at center
                    final spacer = col == (columns.length ~/ 2)
                        ? const SizedBox(width: 16)
                        : const SizedBox(width: 8);

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleSeat(seatId),
                          child: _buildSeat(status),
                        ),
                        spacer,
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSeat(SeatStatus status) {
    Color color;
    IconData icon = Icons.event_seat_rounded;

    switch (status) {
      case SeatStatus.available:
        color = _card;
        break;
      case SeatStatus.selected:
        color = _accent;
        break;
      case SeatStatus.occupied:
        color = Colors.white24;
        break;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: status == SeatStatus.available
              ? Colors.white12
              : Colors.transparent,
        ),
      ),
      child: Icon(
        icon,
        size: 14,
        color: status == SeatStatus.occupied
            ? Colors.white12
            : status == SeatStatus.selected
            ? Colors.white
            : Colors.white38,
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(SeatStatus.available, 'Available'),
          const SizedBox(width: 20),
          _legendItem(SeatStatus.selected, 'Selected'),
          const SizedBox(width: 20),
          _legendItem(SeatStatus.occupied, 'Occupied'),
        ],
      ),
    );
  }

  Widget _legendItem(SeatStatus status, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSeat(status),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final hasSelection = selectedSeats.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSelection)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Seats',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedSeats.join(', '),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalPrice.toStringAsFixed(0)} VND',
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: hasSelection
                    ? () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: _card,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Booking Confirmed!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie: ${widget.movie.title}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Cinema: ${widget.cinema.name}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Date: ${DateFormat('EEE, MMM d').format(widget.date)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Time: ${widget.showtime.time}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Seats: ${selectedSeats.join(", ")}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Total: ${totalPrice.toStringAsFixed(0)} VND',
                                  style: const TextStyle(
                                    color: _accent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  Get.until((route) => route.isFirst);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Back to Home'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection
                      ? _accent
                      : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: Colors.grey.shade700,
                  disabledForegroundColor: Colors.white38,
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
