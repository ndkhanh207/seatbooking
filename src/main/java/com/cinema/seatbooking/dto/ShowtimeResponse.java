package com.cinema.seatbooking.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class ShowtimeResponse {
    Long id;
    Long movieId;
    String roomName;
    String startTime;
}
