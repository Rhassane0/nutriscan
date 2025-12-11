package com.nutriscan.service;

import com.nutriscan.dto.response.FoodResponse;
import com.nutriscan.model.Food;
import com.nutriscan.repository.FoodRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FoodService {

    private final FoodRepository foodRepository;

    public FoodResponse getFoodById(Long id) {
        Food food = foodRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + id));
        return mapToResponse(food);
    }

    public List<FoodResponse> searchByName(String query) {
        List<Food> foods = foodRepository.findByNameContainingIgnoreCase(query);
        return foods.stream()
                .map(this::mapToResponse)
                .toList();
    }

    public List<FoodResponse> getAllFoods() {
        List<Food> foods = foodRepository.findAll();
        return foods.stream()
                .map(this::mapToResponse)
                .toList();
    }

    private FoodResponse mapToResponse(Food food) {
        return FoodResponse.builder()
                .id(food.getId())
                .name(food.getName())
                .category(food.getCategory())
                .servingSize(food.getServingSize())
                .servingUnit(food.getServingUnit())
                .caloriesKcal(food.getCaloriesKcal())
                .proteinGr(food.getProteinGr())
                .carbsGr(food.getCarbsGr())
                .fatGr(food.getFatGr())
                .fiberGr(food.getFiberGr())
                .sugarGr(food.getSugarGr())
                .imageUrl(food.getImageUrl())
                .source(food.getSource())
                .build();
    }
}
