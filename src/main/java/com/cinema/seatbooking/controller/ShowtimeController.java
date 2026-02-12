package com.cinema.seatbooking.controller;

import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.dto.ShowtimeRequest;
import com.cinema.seatbooking.dto.ShowtimeResponse;
import com.cinema.seatbooking.service.ShowtimeService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/showtime")
public class ShowtimeController {
    ShowtimeService showtimeService;

    public ShowtimeController(ShowtimeService showtimeService) {
        this.showtimeService = showtimeService;
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/add")
    public ApiResponse<String> addShowtime(@RequestBody ShowtimeRequest request) {
        showtimeService.addShowtime(request);
        return ApiResponse.ok("Showtime added successfully");
    }

    @GetMapping("/{movieId}")
    public ApiResponse<List<ShowtimeResponse>> getShowtimeByMovie(@PathVariable Long movieId) {
        return ApiResponse.ok(showtimeService.getShowtimeByMovieId(movieId));
    }


}

