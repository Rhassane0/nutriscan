package com.nutriscan.service;

import com.nutriscan.dto.request.UpdateGoalsRequest;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.model.DailyTargets;
import com.nutriscan.model.User;
import com.nutriscan.model.enums.GoalType;
import com.nutriscan.repository.DailyTargetsRepository;
import com.nutriscan.repository.UserRepository;
import com.nutriscan.util.NutritionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class GoalsService {

    private final DailyTargetsRepository dailyTargetsRepository;
    private final UserRepository userRepository;

    /**
     * Get current daily targets. If they don't exist yet, we compute and save them.
     */
    public GoalsResponse getGoalsForUser(Long userId) {
        DailyTargets targets = dailyTargetsRepository.findByUserId(userId)
                .orElseGet(() -> recalculateAndSaveTargets(userId));

        return mapToResponse(targets);
    }

    /**
     * Force recalculation from user profile (goal type, activity, etc.).
     */
    public GoalsResponse recalculateGoals(Long userId) {
        DailyTargets targets = recalculateAndSaveTargets(userId);
        return mapToResponse(targets);
    }

    /**
     * Manual override of targets.
     */
    public GoalsResponse updateGoals(Long userId, UpdateGoalsRequest request) {
        DailyTargets targets = dailyTargetsRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Daily targets not found for user"));

        if (request.getTargetCalories() != null) {
            targets.setTargetCalories(request.getTargetCalories());
        }
        if (request.getProteinGr() != null) {
            targets.setProteinGr(request.getProteinGr());
        }
        if (request.getCarbsGr() != null) {
            targets.setCarbsGr(request.getCarbsGr());
        }
        if (request.getFatGr() != null) {
            targets.setFatGr(request.getFatGr());
        }

        targets.setUpdatedAt(LocalDateTime.now());
        dailyTargetsRepository.save(targets);

        return mapToResponse(targets);
    }

    // ---------- internal helpers ----------

    private DailyTargets recalculateAndSaveTargets(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        if (user.getGender() == null ||
                user.getInitialWeightKg() == null ||
                user.getHeightCm() == null ||
                user.getAge() == null ||
                user.getActivityLevel() == null) {
            throw new IllegalStateException("User profile is incomplete for goal calculation");
        }

        double tdee = NutritionUtils.calculateTdee(
                user.getGender(),
                user.getInitialWeightKg(),
                user.getHeightCm(),
                user.getAge(),
                user.getActivityLevel()
        );

        GoalType goalType = user.getGoalType();
        double targetCalories = NutritionUtils.adjustCaloriesForGoal(tdee, goalType);

        NutritionUtils.MacroTargets macros = NutritionUtils.calculateMacroTargets(
                targetCalories,
                user.getInitialWeightKg(),
                goalType
        );

        DailyTargets targets = dailyTargetsRepository.findByUserId(userId)
                .orElseGet(DailyTargets::new);

        targets.setUser(user);
        targets.setMaintenanceCalories(round(tdee));
        targets.setTargetCalories(round(macros.getCalories()));
        targets.setProteinGr(round(macros.getProteinGr()));
        targets.setCarbsGr(round(macros.getCarbsGr()));
        targets.setFatGr(round(macros.getFatGr()));
        targets.setUpdatedAt(LocalDateTime.now());

        return dailyTargetsRepository.save(targets);
    }

    private GoalsResponse mapToResponse(DailyTargets targets) {
        User user = targets.getUser();
        return GoalsResponse.builder()
                .goalType(user.getGoalType())
                .activityLevel(user.getActivityLevel())
                .maintenanceCalories(targets.getMaintenanceCalories())
                .targetCalories(targets.getTargetCalories())
                .proteinGr(targets.getProteinGr())
                .carbsGr(targets.getCarbsGr())
                .fatGr(targets.getFatGr())
                .build();
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
