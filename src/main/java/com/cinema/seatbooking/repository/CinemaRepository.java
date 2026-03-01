package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.Cinema;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CinemaRepository extends JpaRepository<Cinema, Long> {

}
