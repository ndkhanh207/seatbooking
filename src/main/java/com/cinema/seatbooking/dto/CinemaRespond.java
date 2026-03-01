package com.cinema.seatbooking.dto;

import com.cinema.seatbooking.entity.Room;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class CinemaRespond {
    Long id;
    String name;
    List<Room> roomId;
    String address;
}
