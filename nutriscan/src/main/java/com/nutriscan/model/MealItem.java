package com.nutriscan.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "meal_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Parent meal
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "meal_id")
    private Meal meal;

    // Food reference
    // NOTE: Can be NULL for API foods (Edamam, OpenFoodFacts)
    // Only populated for local database foods
    @ManyToOne(fetch = FetchType.LAZY, optional = true)
    @JoinColumn(name = "food_id", nullable = true)
    private Food food;

    // Food name (for API foods or as fallback for local foods)
    private String foodName;

    // Quantity consumed in same unit as Food.servingUnit (or custom unit for API foods)
    private Double quantity;

    // Serving unit (for API foods when food is null)
    // Can be: "g", "ml", "piece", etc.
    private String servingUnit;

    // Precomputed values for this item
    private Double calories;
    private Double protein;
    private Double carbs;
    private Double fat;
}
