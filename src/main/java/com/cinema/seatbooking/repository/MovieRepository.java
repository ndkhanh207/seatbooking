package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.Movie;
import org.jspecify.annotations.NullMarked;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MovieRepository extends JpaRepository<Movie, Long> {
    Optional<Movie> findMoviesById(Long id);
}
