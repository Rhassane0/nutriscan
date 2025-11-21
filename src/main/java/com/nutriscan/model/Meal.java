package com.nutriscan.model;

import com.nutriscan.model.enums.MealSource;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "meals")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Meal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // User who owns this meal
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    private LocalDate date;        // date of the meal
    private LocalTime time;        // time of the meal

    @Column(length = 50)
    private String mealType;       // "BREAKFAST", "LUNCH", "DINNER", "SNACK"

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private MealSource source;     // SCAN_PHOTO, MANUAL, BARCODE

    // Totals (precomputed for faster queries)
    private Double totalCalories;
    private Double totalProtein;
    private Double totalCarbs;
    private Double totalFat;

    @OneToMany(mappedBy = "meal", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<MealItem> items = new ArrayList<>();
}
