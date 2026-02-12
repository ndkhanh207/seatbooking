package com.cinema.seatbooking.dto;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter

public class MovieRequest {
    private String title;
    private String description;
    private Integer duration;
    private MultipartFile posterUrl;
}
