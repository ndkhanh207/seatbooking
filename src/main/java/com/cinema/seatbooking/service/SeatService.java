package com.cinema.seatbooking.service;

import com.cinema.seatbooking.dto.SeatResponse;
import com.cinema.seatbooking.entity.Seat;
import com.cinema.seatbooking.repository.SeatRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class SeatService {
    SeatRepository seatRepo;

    public SeatService(SeatRepository seatRepo) {
        this.seatRepo = seatRepo;
    }

    public List<SeatResponse> getSeatsByRoomId(Long roomId) {
        List<Seat> listSeat = seatRepo.findSeatByRoomId_Id(roomId);
        List<SeatResponse> response = new ArrayList<>();
        listSeat.forEach(seat -> {
            response.add(new SeatResponse(
                    seat.getId(),
                    seat.getRowName() + seat.getSeatNumber(),
                    seat.getSeatType(),
                    seat.getIsActive()
            ));
        });

        return response;
    }
}
