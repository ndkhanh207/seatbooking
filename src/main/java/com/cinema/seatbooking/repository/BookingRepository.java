package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.common.BookingStatus;
import com.cinema.seatbooking.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByStatusAndBookingDateBefore(BookingStatus status, LocalDateTime bookingDate);
}
