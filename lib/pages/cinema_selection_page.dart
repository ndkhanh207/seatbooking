import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_ticket/model/movie.dart';
import 'package:movie_ticket/model/cinema.dart';
import 'package:movie_ticket/pages/seat_selection_page.dart';
import 'package:movie_ticket/service/cinema_service.dart';
import 'package:movie_ticket/service/showtime_service.dart';

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
  List<Cinema> _cinemas = [];
  final Map<int, Map<String, List<Showtime>>> _showtimesByCinemaAndRoom = {};
  int? _loadingShowtimeCinemaId;
  bool _isLoading = true;
  String _error = '';
  String _showtimeError = '';

  @override
  void initState() {
    super.initState();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final cinemas = await CinemaService.fetchAllCinemas();
      setState(() {
        _cinemas = cinemas;
      });

      if (cinemas.isNotEmpty) {
        await _loadShowtimesForCinema(cinemas.first, autoSelectCinema: true);
      }
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

  Future<void> _loadShowtimesForCinema(
    Cinema cinema, {
    bool autoSelectCinema = false,
  }) async {
    setState(() {
      _loadingShowtimeCinemaId = cinema.id;
      _showtimeError = '';
      if (autoSelectCinema || _selectedCinema == null) {
        _selectedCinema = cinema;
      }
      if (_selectedCinema?.id != cinema.id) {
        _selectedShowtime = null;
      }
    });

    try {
      final showtimesByRoom = <String, List<Showtime>>{};

      // Load showtimes for each room in the cinema
      for (final room in cinema.rooms) {
        final showtimes = await ShowtimeService.fetchShowtimes(
          movieId: widget.movie.id,
          roomName: room.name,
          date: _selectedDate,
        );
        showtimesByRoom[room.name] = showtimes;
      }

      setState(() {
        _showtimesByCinemaAndRoom[cinema.id] = showtimesByRoom;

        if (_selectedCinema?.id == cinema.id && _selectedShowtime != null) {
          final currentShowtimes = showtimesByRoom.values
              .expand((list) => list)
              .toList();
          if (!currentShowtimes.any((it) => it.id == _selectedShowtime!.id)) {
            _selectedShowtime = null;
          }
        }
      });
    } catch (e) {
      setState(() {
        _showtimesByCinemaAndRoom[cinema.id] = {};
        _showtimeError = e.toString();
      });
    } finally {
      setState(() {
        _loadingShowtimeCinemaId = null;
      });
    }
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
          Expanded(child: _buildCinemaList()),
        ],
      ),
      bottomNavigationBar: _buildContinueButton(),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 120,
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
            onTap: () async {
              setState(() {
                _selectedDate = date;
                _selectedShowtime = null;
              });
              if (_selectedCinema != null) {
                await _loadShowtimesForCinema(_selectedCinema!);
              }
            },
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

  Widget _buildCinemaList() {
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
                'Could not load cinemas',
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
                onPressed: _loadCinemas,
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

    if (_cinemas.isEmpty) {
      return const Center(
        child: Text(
          'No cinemas found',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCinemas,
      color: _accent,
      backgroundColor: _card,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _cinemas.length,
        itemBuilder: (context, index) {
          final cinema = _cinemas[index];
          final isSelected = _selectedCinema?.id == cinema.id;
          return _buildCinemaCard(cinema, isSelected);
        },
      ),
    );
  }

  Widget _buildCinemaCard(Cinema cinema, bool isSelected) {
    final showtimesByRoom =
        _showtimesByCinemaAndRoom[cinema.id] ?? <String, List<Showtime>>{};
    final isShowtimesLoading = _loadingShowtimeCinemaId == cinema.id;

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
          GestureDetector(
            onTap: () async {
              setState(() {
                _selectedCinema = cinema;
                _selectedShowtime = null;
              });
              await _loadShowtimesForCinema(cinema);
            },
            child: Padding(
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
                        '${cinema.rooms.length} rooms',
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
          ),
          // Showtimes by Room
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
                if (isShowtimesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(color: _accent),
                    ),
                  )
                else if (isSelected && _showtimeError.isNotEmpty)
                  Text(
                    _showtimeError,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  )
                else if (showtimesByRoom.isEmpty)
                  const Text(
                    'No showtimes for selected date',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: showtimesByRoom.entries.map((entry) {
                      final roomName = entry.key;
                      final showtimes = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room: $roomName',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: showtimes.map((showtime) {
                              final isShowtimeSelected =
                                  isSelected &&
                                  _selectedShowtime?.id == showtime.id;
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
                                    children: [
                                      Text(
                                        showtime.time,
                                        style: TextStyle(
                                          color: isShowtimeSelected
                                              ? Colors.white
                                              : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        showtime.format,
                                        style: TextStyle(
                                          color: isShowtimeSelected
                                              ? Colors.white70
                                              : Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
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
