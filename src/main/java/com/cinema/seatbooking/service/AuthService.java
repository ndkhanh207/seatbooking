package com.cinema.seatbooking.service;

import com.cinema.seatbooking.dto.*;
import com.cinema.seatbooking.entity.User;
import com.cinema.seatbooking.repository.UserRepository;
import com.cinema.seatbooking.service.JwtService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Objects;

@Service
public class AuthService {
    @Value("${jwt.refreshExperation}")
    private long refreshExpirationMs;

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepo,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public Map<String, Object> login(LoginRequest request) {
        User u = userRepo.findUserByEmail(request.getEmail());

        if (!Objects.equals(request.getPassword(), u.getPassword())){
            throw new RuntimeException("Mật khẩu không chính xác!");
        }
        String accessToken = jwtService.generateAccessToken(u);
        return Map.of(
                "accessToken", accessToken,
                "userId", u.getId(),
                "username", u.getFull_name()
        );
    }

}