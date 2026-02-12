package com.cinema.seatbooking.dto;

import com.cinema.seatbooking.entity.Movie;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter

public class MovieResponse {
    List<Movie> movies;
}
