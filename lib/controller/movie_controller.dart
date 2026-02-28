import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_ticket/model/movie.dart';
import 'package:movie_ticket/service/movie_service.dart';

class MovieController extends GetxController {
  static MovieController get instance => Get.find();

  final RxList<Movie> movies = <Movie>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt cacheKey = 0.obs; // Increment on each fetch to bust cache

  @override
  void onInit() {
    super.onInit();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    isLoading.value = true;
    error.value = '';
    try {
      // Clear Flutter's image cache to force reload
      imageCache.clear();
      imageCache.clearLiveImages();

      final result = await MovieService.fetchAllMovies();
      movies.assignAll(result);

      // Increment cache key to force image reload
      cacheKey.value++;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// First 3 movies shown in the featured carousel
  List<Movie> get featuredMovies => movies.take(3).toList();

  /// The rest shown in the grid
  List<Movie> get popularMovies =>
      movies.length > 3 ? movies.skip(3).toList() : movies.toList();
}
