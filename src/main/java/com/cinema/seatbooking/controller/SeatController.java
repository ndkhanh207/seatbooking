package com.cinema.seatbooking.controller;

import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.dto.SeatResponse;
import com.cinema.seatbooking.entity.Seat;
import com.cinema.seatbooking.service.SeatService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/seat")
public class SeatController {
    SeatService seatService;

    public SeatController(SeatService seatService) {
        this.seatService = seatService;
    }

    @GetMapping("/{roomId}")
    public ApiResponse<List<SeatResponse>> getSeatsByRoom(@PathVariable Long roomId) {
        return ApiResponse.ok(seatService.getSeatsByRoomId(roomId));
    }
}
