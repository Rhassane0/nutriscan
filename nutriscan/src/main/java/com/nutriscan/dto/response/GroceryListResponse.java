package com.nutriscan.dto.response;

import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryListResponse {
    private Long id;
    private Long userId;
    private LocalDate generatedDate;
    private LocalDate startDate;
    private LocalDate endDate;
    private List<GroceryItem> items;
    private Integer totalItems;

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GroceryItem {
        private Long id;  // ID nécessaire pour les mises à jour
        private String name;
        private Double quantity;
        private String unit;
        private String category; // VEGETABLES, FRUITS, PROTEIN, DAIRY, GRAINS, etc.
        private Boolean purchased;
    }
}

