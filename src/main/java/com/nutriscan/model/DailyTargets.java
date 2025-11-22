package com.nutriscan.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "daily_targets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyTargets {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    /**
     * TDEE (maintenance) in kcal
     */
    private Double maintenanceCalories;

    /**
     * Calories actually targeted (after deficit/surplus)
     */
    private Double targetCalories;

    private Double proteinGr;
    private Double carbsGr;
    private Double fatGr;

    private LocalDateTime updatedAt;
}
