package com.cinema.seatbooking.controller;

import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.entity.Cinema;
import com.cinema.seatbooking.service.CinemaService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/cinema")
public class CinemaController {
    CinemaService cinemaService;

    public CinemaController(CinemaService cinemaService) {
        this.cinemaService = cinemaService;
    }

    @GetMapping("/")
    public ResponseEntity<ApiResponse<List<Cinema>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok(cinemaService.getAll()));
    }
}
