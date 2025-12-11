package com.nutriscan.model;

import com.nutriscan.model.enums.Gender;
import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.GoalType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 180)
    private String email;

    @Column(nullable = false, length = 120)
    private String password; // hashed

    @Column(nullable = false, length = 100)
    private String fullName;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Gender gender;

    private Integer age;        // years
    private Integer heightCm;   // cm

    private Double initialWeightKg;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private GoalType goalType; // LOSE_WEIGHT, MAINTAIN, GAIN_WEIGHT

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private ActivityLevel activityLevel;

    @Column(length = 255)
    private String dietPreferences; // e.g. halal, vegetarian, etc.

    @Column(length = 255)
    private String allergies; // simple text for MVP

    @Column(nullable = false, length = 30)
    private String role; // e.g. "ROLE_USER", "ROLE_ADMIN"

    @CreationTimestamp
    private LocalDateTime createdAt;
}
