import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_ticket/controller/auth_controller.dart';
import 'package:movie_ticket/controller/movie_controller.dart';
import 'package:movie_ticket/model/movie.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _bg = Color(0xFF1A1A2E);
const _card = Color(0xFF16213E);
const _accent = Color(0xFFE94560);

const _genres = [
  'All',
  'Action',
  'Sci-Fi',
  'Drama',
  'Thriller',
  'Crime',
  'Comedy',
];

// ─── Color palette cycling for cards without a poster ────────────────────────
const _cardColors = [
  Color(0xFF0F3460),
  Color(0xFF1B1B2F),
  Color(0xFF162447),
  Color(0xFF4A3728),
  Color(0xFF2C2C54),
  Color(0xFF1E3A2F),
];

// ─── HomePage ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedGenreIndex = 0;
  int _bottomNavIndex = 0;
  final PageController _featuredController = PageController(
    viewportFraction: 0.88,
  );
  int _featuredPage = 0;

  MovieController get ctrl => MovieController.instance;

  @override
  void initState() {
    super.initState();
    // Register MovieController if not already done
    if (!Get.isRegistered<MovieController>()) {
      Get.put(MovieController());
    }
    _featuredController.addListener(() {
      final page = _featuredController.page?.round() ?? 0;
      if (page != _featuredPage) setState(() => _featuredPage = page);
    });
  }

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  String get _userEmail =>
      AuthController.instance.auth.currentUser?.email ?? 'Guest';

  String get _userName {
    final email = _userEmail;
    final name = email.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          if (ctrl.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white38,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not reach server',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ctrl.error.value,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: ctrl.fetchMovies,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              if (ctrl.featuredMovies.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionLabel('Now Playing', onSeeAll: () {}),
                ),
                SliverToBoxAdapter(child: _buildFeaturedCarousel()),
                SliverToBoxAdapter(child: _buildPageIndicator()),
              ],
              SliverToBoxAdapter(child: _buildGenreChips()),
              SliverToBoxAdapter(
                child: _buildSectionLabel('All Movies', onSeeAll: () {}),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildMovieCard(ctrl.popularMovies[index], index),
                    childCount: ctrl.popularMovies.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_userName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Find your perfect movie',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          // Notification
          _iconButton(Icons.notifications_outlined, () {}),
          const SizedBox(width: 8),
          // Avatar + logout
          GestureDetector(
            onTap: () => _showLogoutDialog(),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: _accent,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search movies, genres...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search_rounded, color: _accent),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: _accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured Carousel ──────────────────────────────────────────────────────

  Widget _buildFeaturedCarousel() {
    final featured = ctrl.featuredMovies;
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _featuredController,
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final movie = featured[index];
          final isActive = index == _featuredPage;
          final bgColor = _cardColors[index % _cardColors.length];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: isActive ? 0 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: bgColor,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _accent.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Poster image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _posterImage(
                    movie.posterUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NOW PLAYING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white54,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              movie.durationFormatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Page Indicator ─────────────────────────────────────────────────────────

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(ctrl.featuredMovies.length, (i) {
          final active = i == _featuredPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? _accent : Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  // ── Genre Chips ────────────────────────────────────────────────────────────

  Widget _buildGenreChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final selected = index == _selectedGenreIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedGenreIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _accent : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _accent : Colors.white12),
              ),
              child: Text(
                _genres[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Movie Card ─────────────────────────────────────────────────────────────

  Widget _buildMovieCard(Movie movie, int index) {
    final bgColor = _cardColors[index % _cardColors.length];
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster area
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _posterImage(
                      movie.posterUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      fallbackColor: bgColor,
                    ),
                    // Gradient overlay at bottom
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ),
                    // Bookmark button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      movie.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white38,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.durationFormatted,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _accent.withOpacity(0.4),
                              ),
                            ),
                            child: const Text(
                              'Book',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tries to load a network image; shows a coloured placeholder on error
  Widget _posterImage(
    String url, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Color fallbackColor = const Color(0xFF0F3460),
  }) {
    if (url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: fallbackColor,
        child: const Icon(Icons.movie_rounded, color: Colors.white12, size: 48),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: fallbackColor,
              child: const Center(
                child: CircularProgressIndicator(
                  color: _accent,
                  strokeWidth: 2,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        color: fallbackColor,
        child: const Icon(
          Icons.broken_image_rounded,
          color: Colors.white24,
          size: 48,
        ),
      ),
    );
  }

  // ── Bottom Navigation ──────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.explore_rounded, 'label': 'Explore'},
      {'icon': Icons.local_activity_rounded, 'label': 'Tickets'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: _card,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final isSelected = i == _bottomNavIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i == 3) {
                  _showLogoutDialog();
                } else {
                  setState(() => _bottomNavIndex = i);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _accent.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        items[i]['icon'] as IconData,
                        color: isSelected ? _accent : Colors.white38,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? _accent : Colors.white38,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AuthController.instance.auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
