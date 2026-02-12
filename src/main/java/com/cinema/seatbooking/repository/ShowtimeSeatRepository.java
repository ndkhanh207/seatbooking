package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.Booking;
import com.cinema.seatbooking.entity.Seat;
import com.cinema.seatbooking.entity.Showtime;
import com.cinema.seatbooking.entity.ShowtimeSeat;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.List;

public interface ShowtimeSeatRepository extends JpaRepository<ShowtimeSeat, Long> {
    ShowtimeSeat findBySeatId(Seat seatId);

    ShowtimeSeat findBySeatId_Id(Long seatIdId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    ShowtimeSeat findShowtimeSeatByShowtimeIdAndSeatId(Showtime showtimeId, Seat seatId);

    List<ShowtimeSeat> findByBookingId(Booking bookingId);
}
