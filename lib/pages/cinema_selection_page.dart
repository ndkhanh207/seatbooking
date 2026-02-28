import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_ticket/model/movie.dart';
import 'package:movie_ticket/model/cinema.dart';
import 'package:movie_ticket/pages/seat_selection_page.dart';

const _bg = Color(0xFF1A1A2E);
const _card = Color(0xFF16213E);
const _accent = Color(0xFFE94560);

class CinemaSelectionPage extends StatefulWidget {
  final Movie movie;

  const CinemaSelectionPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<CinemaSelectionPage> createState() => _CinemaSelectionPageState();
}

class _CinemaSelectionPageState extends State<CinemaSelectionPage> {
  DateTime _selectedDate = DateTime.now();
  Cinema? _selectedCinema;
  Showtime? _selectedShowtime;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Cinema',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.movie.title,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sampleCinemas.length,
              itemBuilder: (context, index) {
                final cinema = sampleCinemas[index];
                final isSelected = _selectedCinema?.id == cinema.id;
                return _buildCinemaCard(cinema, isSelected);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildContinueButton(),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? _accent : _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _accent : Colors.white12,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekday(date.weekday),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getMonth(date.month),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCinemaCard(Cinema cinema, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _accent : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Cinema Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_movies_rounded,
                    color: _accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cinema.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cinema.address,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: _accent,
                      size: 16,
                    ),
                    Text(
                      '${cinema.distance} km',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Showtimes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bg.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Showtimes',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sampleShowtimes.map((showtime) {
                    final isShowtimeSelected =
                        isSelected &&
                        _selectedShowtime?.time == showtime.time &&
                        _selectedShowtime?.format == showtime.format;
                    return GestureDetector(
                      onTap: showtime.isAvailable
                          ? () => setState(() {
                              _selectedCinema = cinema;
                              _selectedShowtime = showtime;
                            })
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isShowtimeSelected
                              ? _accent
                              : showtime.isAvailable
                              ? _card
                              : _card.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isShowtimeSelected
                                ? _accent
                                : showtime.isAvailable
                                ? Colors.white12
                                : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              showtime.time,
                              style: TextStyle(
                                color: isShowtimeSelected
                                    ? Colors.white
                                    : showtime.isAvailable
                                    ? Colors.white
                                    : Colors.white24,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              showtime.format,
                              style: TextStyle(
                                color: isShowtimeSelected
                                    ? Colors.white
                                    : showtime.isAvailable
                                    ? Colors.white54
                                    : Colors.white24,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedCinema != null && _selectedShowtime != null;
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
            if (_selectedShowtime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ticket Price',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    Text(
                      '${_selectedShowtime!.price.toStringAsFixed(0)} VND',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canContinue
                    ? () => Get.to(
                        () => SeatSelectionPage(
                          movie: widget.movie,
                          cinema: _selectedCinema!,
                          showtime: _selectedShowtime!,
                          date: _selectedDate,
                        ),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canContinue ? _accent : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: Colors.grey.shade700,
                  disabledForegroundColor: Colors.white38,
                ),
                child: const Text(
                  'Select Seats',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
