package com.cinema.seatbooking.controller;


import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.dto.MovieRequest;
import com.cinema.seatbooking.entity.Movie;
import com.cinema.seatbooking.exception.NotFoundException;
import com.cinema.seatbooking.service.MovieService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.awt.*;
import java.util.List;

@RestController
@RequestMapping("/api/movies")
public class MovieController {
    @Autowired
    private final MovieService movieService;

    public MovieController(MovieService movieService) {
        this.movieService = movieService;
    }

    @GetMapping("/")
    public ApiResponse<List<Movie>> getAllMovies() {
        return ApiResponse.ok(movieService.getAllMovies());
    }

    @GetMapping("/{id}")
    public ApiResponse<Movie> getMovieById(@PathVariable String id) {
        return ApiResponse.ok(movieService.getMovieById(id).orElseThrow(() -> new NotFoundException("Movie not found with id = " + id)));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping(value = "/add", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<String> addMovie(@ModelAttribute MovieRequest request) {

        String result = movieService.addMovie(request);
        return ApiResponse.ok(result);
    }

}
