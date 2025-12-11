package com.nutriscan.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "weight_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WeightHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Date of the measurement
     */
    @Column(nullable = false)
    private LocalDate date;

    /**
     * Weight in kg
     */
    @Column(nullable = false)
    private Double weightKg;

    /**
     * BMI (IMC) at that moment. Optional if height missing.
     */
    private Double bmi;
}
