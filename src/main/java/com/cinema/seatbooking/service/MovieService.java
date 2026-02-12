package com.cinema.seatbooking.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Collections;

import com.cinema.seatbooking.dto.ApiResponse;
import com.cinema.seatbooking.dto.MovieRequest;
import com.cinema.seatbooking.entity.Movie;
import com.cinema.seatbooking.exception.BadRequestException;
import com.cinema.seatbooking.repository.MovieRepository;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collection;
import java.util.List;
import java.util.Optional;


@Service
public class MovieService {
    MovieRepository movieRepo;

    public MovieService(MovieRepository movieRepo) {
        this.movieRepo = movieRepo;
    }

    public List<Movie> getAllMovies() {
        return movieRepo.findAll();
    }

    public Optional<Movie> getMovieById(String id) {
        return movieRepo.findById(Long.parseLong(id));
    }

    public String addMovie(MovieRequest request) {
        Movie movie1 = new Movie();
        if (request.getPosterUrl() == null || request.getPosterUrl().isEmpty()) {
            throw new BadRequestException("Ảnh đại diện sản phẩm là bắt buộc!");
        } else {
            String posterUrl = saveToDisk(request.getPosterUrl());
            movie1.setPosterUrl("/uploads/" + posterUrl);
        }
        movie1.setTitle(request.getTitle());
        movie1.setDescription(request.getDescription());
        movie1.setDuration(request.getDuration());
        movieRepo.save(movie1);
        return "Movie added successfully";
    }

    private String saveToDisk(MultipartFile file) {
        try {
            Path root = Paths.get("uploads");
            if (!Files.exists(root)) {
                Files.createDirectories(root);
            }

            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = root.resolve(fileName);
            Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);
            return fileName;
        } catch (IOException e) {
            throw new RuntimeException("Lỗi lưu file: " + e.getMessage());
        }
    }
}
