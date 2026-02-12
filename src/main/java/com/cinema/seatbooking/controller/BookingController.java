package com.cinema.seatbooking.controller;

import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.dto.BookingRequest;
import com.cinema.seatbooking.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/booking")
public class BookingController {
    @Autowired
    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @PostMapping("/book-seat")
    public ApiResponse<String> bookingSeat(@RequestBody BookingRequest request) {
        String result = bookingService.bookingSeat(request);
        return ApiResponse.ok(result);
    }

}
