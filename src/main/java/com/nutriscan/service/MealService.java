package com.nutriscan.service;

import com.nutriscan.dto.request.CreateMealRequest;
import com.nutriscan.dto.response.DailySummaryResponse;
import com.nutriscan.dto.response.MealResponse;
import com.nutriscan.model.Food;
import com.nutriscan.model.Meal;
import com.nutriscan.model.MealItem;
import com.nutriscan.model.User;
import com.nutriscan.repository.FoodRepository;
import com.nutriscan.repository.MealRepository;
import com.nutriscan.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class MealService {

    private final MealRepository mealRepository;
    private final FoodRepository foodRepository;
    private final UserRepository userRepository;

    public MealResponse createMeal(Long userId, CreateMealRequest request) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        Meal meal = new Meal();
        meal.setUser(user);
        meal.setDate(request.getDate());
        meal.setTime(request.getTime());
        meal.setMealType(request.getMealType());
        meal.setSource(request.getSource());

        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;

        List<MealItem> items = new ArrayList<>();

        for (CreateMealRequest.MealItemDto itemDto : request.getItems()) {
            Food food = foodRepository.findById(itemDto.getFoodId())
                    .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + itemDto.getFoodId()));

            double factor = itemDto.getQuantity() / (food.getServingSize() != null && food.getServingSize() > 0 ? food.getServingSize() : 1.0);

            double calories = safe(food.getCaloriesKcal()) * factor;
            double protein = safe(food.getProteinGr()) * factor;
            double carbs   = safe(food.getCarbsGr()) * factor;
            double fat     = safe(food.getFatGr()) * factor;

            totalCalories += calories;
            totalProtein += protein;
            totalCarbs += carbs;
            totalFat += fat;

            MealItem item = MealItem.builder()
                    .meal(meal)
                    .food(food)
                    .quantity(itemDto.getQuantity())
                    .calories(calories)
                    .protein(protein)
                    .carbs(carbs)
                    .fat(fat)
                    .build();

            items.add(item);
        }

        meal.setTotalCalories(totalCalories);
        meal.setTotalProtein(totalProtein);
        meal.setTotalCarbs(totalCarbs);
        meal.setTotalFat(totalFat);
        meal.setItems(items);

        Meal saved = mealRepository.save(meal);
        return mapToMealResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<MealResponse> getMealsForDate(Long userId, LocalDate date) {
        List<Meal> meals = mealRepository.findByUserIdAndDate(userId, date);
        return meals.stream()
                .map(this::mapToMealResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public DailySummaryResponse getDailySummary(Long userId, LocalDate date) {
        List<Meal> meals = mealRepository.findByUserIdAndDate(userId, date);

        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;

        for (Meal meal : meals) {
            totalCalories += safe(meal.getTotalCalories());
            totalProtein  += safe(meal.getTotalProtein());
            totalCarbs    += safe(meal.getTotalCarbs());
            totalFat      += safe(meal.getTotalFat());
        }

        return DailySummaryResponse.builder()
                .date(date)
                .totalCalories(totalCalories)
                .totalProtein(totalProtein)
                .totalCarbs(totalCarbs)
                .totalFat(totalFat)
                .build();
    }

    private MealResponse mapToMealResponse(Meal meal) {
        return MealResponse.builder()
                .id(meal.getId())
                .date(meal.getDate())
                .time(meal.getTime())
                .mealType(meal.getMealType())
                .source(meal.getSource())
                .totalCalories(meal.getTotalCalories())
                .totalProtein(meal.getTotalProtein())
                .totalCarbs(meal.getTotalCarbs())
                .totalFat(meal.getTotalFat())
                .items(
                        meal.getItems().stream()
                                .map(item -> MealResponse.MealItemResponse.builder()
                                        .id(item.getId())
                                        .foodId(item.getFood().getId())
                                        .foodName(item.getFood().getName())
                                        .quantity(item.getQuantity())
                                        .servingUnit(item.getFood().getServingUnit())
                                        .calories(item.getCalories())
                                        .protein(item.getProtein())
                                        .carbs(item.getCarbs())
                                        .fat(item.getFat())
                                        .build()
                                ).toList()
                )
                .build();
    }

    private double safe(Double value) {
        return value == null ? 0.0 : value;
    }
}
