package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.Showtime;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


public interface ShowtimeRepository extends JpaRepository<Showtime, Long> {
    List<Showtime> findShowtimeByMovieId_Id(Long aLong);

    Showtime findShowtimesById(Long id);
}
