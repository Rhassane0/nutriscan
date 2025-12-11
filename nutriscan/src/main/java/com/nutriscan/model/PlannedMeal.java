package com.nutriscan.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "planned_meals")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlannedMeal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "meal_plan_id", nullable = false)
    private MealPlan mealPlan;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false, length = 20)
    private String mealType; // BREAKFAST, LUNCH, DINNER, SNACK

    @Column(nullable = false)
    private String recipeName;

    @Column(length = 500)
    private String recipeUri;

    @Column(length = 500)
    private String recipeImage;

    @Column(length = 500)
    private String recipeUrl;

    private Integer servings;

    private Double calories;
    private Double protein;
    private Double carbs;
    private Double fat;

    @Column(columnDefinition = "TEXT")
    private String ingredients; // JSON array stored as text

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

