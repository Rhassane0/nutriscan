package com.nutriscan.service;

import com.nutriscan.dto.request.CreateFoodRequest;
import com.nutriscan.dto.request.ImportFoodsRequest;
import com.nutriscan.dto.request.UpdateFoodRequest;
import com.nutriscan.dto.response.FoodResponse;
import com.nutriscan.dto.response.ImportResultResponse;
import com.nutriscan.exception.NotFoundException;
import com.nutriscan.model.Food;
import com.nutriscan.repository.FoodRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AdminFoodService {

    private final FoodRepository foodRepository;

    /**
     * Crée un nouvel aliment
     */
    public FoodResponse createFood(CreateFoodRequest request) {
        Food food = Food.builder()
                .name(request.getName())
                .category(request.getCategory())
                .servingSize(request.getServingSize())
                .servingUnit(request.getServingUnit())
                .caloriesKcal(request.getCalories())
                .proteinGr(request.getProtein())
                .carbsGr(request.getCarbs())
                .fatGr(request.getFat())
                .imageUrl(request.getImageUrl())
                .source(request.getSource() != null ? request.getSource() : "MANUAL")
                .build();

        Food saved = foodRepository.save(food);
        log.info("Food created: {}", saved.getId());
        return mapToFoodResponse(saved);
    }

    /**
     * Met à jour un aliment existant
     */
    public FoodResponse updateFood(Long foodId, UpdateFoodRequest request) {
        Food food = foodRepository.findById(foodId)
                .orElseThrow(() -> new NotFoundException("Aliment non trouvé avec l'ID: " + foodId));

        if (request.getName() != null) {
            food.setName(request.getName());
        }
        if (request.getCategory() != null) {
            food.setCategory(request.getCategory());
        }
        if (request.getServingSize() != null) {
            food.setServingSize(request.getServingSize());
        }
        if (request.getServingUnit() != null) {
            food.setServingUnit(request.getServingUnit());
        }
        if (request.getCalories() != null) {
            food.setCaloriesKcal(request.getCalories());
        }
        if (request.getProtein() != null) {
            food.setProteinGr(request.getProtein());
        }
        if (request.getCarbs() != null) {
            food.setCarbsGr(request.getCarbs());
        }
        if (request.getFat() != null) {
            food.setFatGr(request.getFat());
        }
        if (request.getImageUrl() != null) {
            food.setImageUrl(request.getImageUrl());
        }

        Food updated = foodRepository.save(food);
        log.info("Food updated: {}", updated.getId());
        return mapToFoodResponse(updated);
    }

    /**
     * Supprime un aliment
     */
    public void deleteFood(Long foodId) {
        Food food = foodRepository.findById(foodId)
                .orElseThrow(() -> new NotFoundException("Aliment non trouvé avec l'ID: " + foodId));

        foodRepository.delete(food);
        log.info("Food deleted: {}", foodId);
    }

    /**
     * Importe en masse des aliments
     */
    public ImportResultResponse importFoods(ImportFoodsRequest request) {
        List<String> errors = new ArrayList<>();
        int successCount = 0;

        for (int i = 0; i < request.getFoods().size(); i++) {
            CreateFoodRequest foodReq = request.getFoods().get(i);
            try {
                Food food = Food.builder()
                        .name(foodReq.getName())
                        .category(foodReq.getCategory())
                        .servingSize(foodReq.getServingSize())
                        .servingUnit(foodReq.getServingUnit())
                        .caloriesKcal(foodReq.getCalories())
                        .proteinGr(foodReq.getProtein())
                        .carbsGr(foodReq.getCarbs())
                        .fatGr(foodReq.getFat())
                        .imageUrl(foodReq.getImageUrl())
                        .source(foodReq.getSource() != null ? foodReq.getSource() : request.getSource())
                        .build();

                foodRepository.save(food);
                successCount++;
            } catch (Exception e) {
                String errorMsg = String.format("Ligne %d: %s - %s", i + 1, foodReq.getName(), e.getMessage());
                errors.add(errorMsg);
                log.error(errorMsg, e);
            }
        }

        int errorCount = errors.size();
        String message = String.format("Import complété: %d réussis, %d erreurs sur %d aliments",
                successCount, errorCount, request.getFoods().size());

        log.info(message);

        return ImportResultResponse.builder()
                .totalProcessed(request.getFoods().size())
                .successCount(successCount)
                .errorCount(errorCount)
                .message(message)
                .errors(errors.isEmpty() ? null : errors)
                .build();
    }

    /**
     * Récupère tous les aliments avec un filtre optionnel par catégorie
     */
    public List<FoodResponse> getAllFoods(String category, String tag) {
        List<Food> foods;

        if (category != null && !category.isEmpty()) {
            foods = foodRepository.findByCategory(category);
        } else {
            foods = foodRepository.findAll();
        }

        return foods.stream()
                .map(this::mapToFoodResponse)
                .collect(Collectors.toList());
    }

    // ---------- Helper methods ----------

    private FoodResponse mapToFoodResponse(Food food) {
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
                .imageUrl(food.getImageUrl())
                .source(food.getSource())
                .build();
    }
}

