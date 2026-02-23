package com.cinema.seatbooking.entity;

import com.cinema.seatbooking.common.UserRole;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Email(message = "Must be a valid email")
    @NotNull(message = "Email is required")
    private String email;

    @Column(nullable = false)
    @Min(value = 10, message = "Password must be at least 10 characters")
    private String password;

    @Column(nullable = false, unique = true)
    private String full_name;

    @Column(nullable = false, unique = true)
    @Enumerated(EnumType.STRING)
    private UserRole role;
}
