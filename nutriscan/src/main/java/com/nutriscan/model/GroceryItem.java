package com.nutriscan.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "grocery_items")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grocery_list_id", nullable = false)
    private GroceryList groceryList;

    @Column(nullable = false)
    private String name;

    private Double quantity;

    @Column(length = 50)
    private String unit;

    @Column(length = 50)
    private String category; // VEGETABLES, FRUITS, PROTEIN, DAIRY, GRAINS, OTHER

    @Column(nullable = false)
    @Builder.Default
    private Boolean purchased = false;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

