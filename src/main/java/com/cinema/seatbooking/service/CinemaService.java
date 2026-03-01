package com.cinema.seatbooking.service;

import com.cinema.seatbooking.entity.Cinema;
import com.cinema.seatbooking.repository.CinemaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CinemaService {
    CinemaRepository cinemaRepo;

    public CinemaService(CinemaRepository cinemaRepo) {
        this.cinemaRepo = cinemaRepo;
    }

    public List<Cinema> getAll() {
        return cinemaRepo.findAll();
    }
}
