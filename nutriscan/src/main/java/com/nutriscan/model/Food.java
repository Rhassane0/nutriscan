package com.nutriscan.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "foods")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Food {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 180)
    private String name;

    @Column(length = 100)
    private String category; // e.g. "Fruit", "Cereal", "Meat"...

    // Nutritional values per serving
    private Double servingSize;      // e.g. grams
    @Column(length = 50)
    private String servingUnit;      // "g", "ml", "piece", etc.

    private Double caloriesKcal;
    private Double proteinGr;
    private Double carbsGr;
    private Double fatGr;
    private Double fiberGr;
    private Double sugarGr;

    @Column(length = 255)
    private String imageUrl;         // optional, for later use

    @Column(length = 255)
    private String source;           // e.g. "CIQUAL", "USDA", manual entry, etc.
}
