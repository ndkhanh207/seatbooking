package com.cinema.seatbooking.repository;

import com.cinema.seatbooking.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    User findUsersById(Long id);

    User findUserByEmail(String email);
}
