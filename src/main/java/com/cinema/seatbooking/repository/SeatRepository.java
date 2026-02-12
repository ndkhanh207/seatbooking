package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.Seat;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SeatRepository extends JpaRepository<Seat, Long> {
    List<Seat> findSeatByRoomId_Id(Long roomId);

    Seat findSeatById(Long id);

    List<Seat> findAllByRoomId(Long id);
}
