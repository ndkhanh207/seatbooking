package com.cinema.seatbooking.security;

import com.cinema.seatbooking.entity.User;
import com.cinema.seatbooking.repository.UserRepository; // Import Repository của bạn
import com.cinema.seatbooking.service.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtUtils;
    private final UserRepository userRepository; // <--- Dùng Repository trực tiếp

    // Inject Repository vào đây
    public JwtAuthenticationFilter(JwtService jwtUtils, UserRepository userRepository) {
        this.jwtUtils = jwtUtils;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            String jwt = parseJwt(request);

            if (jwt != null && jwtUtils.validateJwtToken(jwt)) {
                String email = jwtUtils.getEmailFromJwtToken(jwt);

                // 1. Tìm User trong DB
                User user = userRepository.findUserByEmail(email);

                if (user != null) {
                    // 2. Lấy Role từ DB (Bạn bảo trong DB đã là "ROLE_ADMIN" rồi nên dùng luôn)
                    SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getRole().toString());

                    // 3. Tạo Authentication với quyền vừa lấy được
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    user, // Principal (Lưu cả object User để sau này dùng nếu cần)
                                    null,
                                    Collections.singletonList(authority) // <--- QUAN TRỌNG NHẤT: Nạp quyền vào đây
                            );

                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    // 4. Set vào Context
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    System.out.println("User: " + email + " | Role: " + user.getRole()); // Log check chơi
                }
            }
        } catch (Exception e) {
            System.out.println("Auth Error: " + e.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        return null;
    }
}