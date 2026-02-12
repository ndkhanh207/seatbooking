package com.cinema.seatbooking.service;


import com.cinema.seatbooking.common.BookingStatus;
import com.cinema.seatbooking.common.SeatStatus;
import com.cinema.seatbooking.dto.BookingRequest;
import com.cinema.seatbooking.entity.*;
import com.cinema.seatbooking.exception.BadRequestException;
import com.cinema.seatbooking.exception.NotFoundException;
import com.cinema.seatbooking.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class BookingService {
    private final SeatRepository seatRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final ShowtimeRepository showtimeRepository;
    private final ShowtimeSeatRepository showtimeSeatRepository;

    public BookingService(SeatRepository seatRepository, BookingRepository bookingRepository, UserRepository userRepository, ShowtimeRepository showtimeRepository, ShowtimeSeatRepository showtimeSeatRepository) {
        this.seatRepository = seatRepository;
        this.bookingRepository = bookingRepository;
        this.userRepository = userRepository;
        this.showtimeRepository = showtimeRepository;
        this.showtimeSeatRepository = showtimeSeatRepository;
    }


    @Transactional
    public String bookingSeat(BookingRequest request) {
        if (request.getSeatIds() == null || request.getSeatIds().isEmpty()) {
            throw new BadRequestException("Seat list is empty");
        }
        Booking booking = new Booking();
        User user = userRepository.findUsersById(request.getUserId());
        if (user == null) {
            throw new NotFoundException("User not found");
        }

        Showtime showtime = showtimeRepository.findShowtimesById((request.getShowtimeId()));
        if (showtime == null) {
            throw new NotFoundException("Showtime not found");
        }
        List<ShowtimeSeat> showtimeSeats = new ArrayList<>();

        for (Long seatId : request.getSeatIds()) {

            Seat seat = seatRepository.findSeatById(seatId);
            if (seat == null) {
                throw new NotFoundException("Seat not found: " + seatId);
            }

            ShowtimeSeat ss = showtimeSeatRepository
                    .findShowtimeSeatByShowtimeIdAndSeatId(showtime, seat);

            if (ss == null) {
                throw new NotFoundException("Seat " + seatId + " not found in this showtime");
            }

            showtimeSeats.add(ss);
        }

        for (ShowtimeSeat ss : showtimeSeats) {
            if (ss.getStatus() != SeatStatus.AVAILABLE) {
                throw new BadRequestException(
                        "Seat " + ss.getSeatId().getId() + " is not available (" + ss.getStatus() + ")"
                );
            }
        }


        double totalPrice = 0.0;
        for (ShowtimeSeat ss : showtimeSeats) {
            totalPrice += ss.getPrice();
        }

        booking.setUserId(user);
        booking.setShowtimeId(showtime);
        booking.setTotalPrice(totalPrice);
        booking.setBookingDate(LocalDateTime.now());
        booking.setStatus(BookingStatus.PENDING);

        bookingRepository.save(booking);

        for (ShowtimeSeat ss : showtimeSeats) {
            ss.setStatus(SeatStatus.HOLD); // hoặc "BOOKED"
            ss.setBookingId(booking);
        }

        showtimeSeatRepository.saveAll(showtimeSeats);

        return "Waiting for payment";
    }

}
