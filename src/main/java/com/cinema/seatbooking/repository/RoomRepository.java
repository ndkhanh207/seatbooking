package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Long> {
    Optional<Room> findRoomById(Long id);
}
