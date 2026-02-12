package com.cinema.seatbooking.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class ShowtimeRequest {
    Long movieId;
    Long roomId;
    LocalDateTime startTime;
}
