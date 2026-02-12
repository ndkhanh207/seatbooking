package com.cinema.seatbooking.dto;


import com.cinema.seatbooking.common.SeatType;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class SeatResponse {
    Long id;
    String seatName;
    SeatType seatType;
    boolean isActive;
}
