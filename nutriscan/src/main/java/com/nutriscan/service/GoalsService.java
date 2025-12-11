package com.nutriscan.service;

import com.nutriscan.dto.request.UpdateGoalsRequest;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.model.DailyTargets;
import com.nutriscan.model.User;
import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.GoalType;
import com.nutriscan.repository.DailyTargetsRepository;
import com.nutriscan.repository.UserRepository;
import com.nutriscan.util.NutritionUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class GoalsService {

    private final DailyTargetsRepository dailyTargetsRepository;
    private final UserRepository userRepository;

    /**
     * Get current daily targets. If they don't exist yet, we compute and save them.
     */
    public GoalsResponse getGoalsForUser(Long userId) {
        try {
            log.info("Getting goals for user: {}", userId);

            DailyTargets targets = dailyTargetsRepository.findByUserId(userId)
                    .orElseGet(() -> {
                        log.info("No existing targets for user {}, creating new ones", userId);
                        return recalculateAndSaveTargets(userId);
                    });

            return mapToResponse(targets, userId);
        } catch (Exception e) {
            log.error("Error getting goals for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to get goals: " + e.getMessage(), e);
        }
    }

    /**
     * Force recalculation from user profile (goal type, activity, etc.).
     */
    public GoalsResponse recalculateGoals(Long userId) {
        try {
            log.info("Recalculating goals for user: {}", userId);
            DailyTargets targets = recalculateAndSaveTargets(userId);
            return mapToResponse(targets, userId);
        } catch (Exception e) {
            log.error("Error recalculating goals for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to recalculate goals: " + e.getMessage(), e);
        }
    }

    /**
     * Manual override of targets.
     * If targets don't exist, create them first.
     */
    public GoalsResponse updateGoals(Long userId, UpdateGoalsRequest request) {
        try {
            log.info("Updating goals for user: {}", userId);

            DailyTargets targets = dailyTargetsRepository.findByUserId(userId)
                    .orElseGet(() -> {
                        log.info("No existing targets for user {}, creating new ones", userId);
                        return recalculateAndSaveTargets(userId);
                    });

            // Update each field if provided
            boolean modified = false;

            if (request.getTargetCalories() != null) {
                targets.setTargetCalories(request.getTargetCalories());
                modified = true;
            }
            if (request.getProteinGr() != null) {
                targets.setProteinGr(request.getProteinGr());
                modified = true;
            }
            if (request.getCarbsGr() != null) {
                targets.setCarbsGr(request.getCarbsGr());
                modified = true;
            }
            if (request.getFatGr() != null) {
                targets.setFatGr(request.getFatGr());
                modified = true;
            }

            // Only save if something was modified
            if (modified) {
                targets.setUpdatedAt(LocalDateTime.now());
                dailyTargetsRepository.save(targets);
                log.info("Goals updated and saved for user: {}", userId);

                // Recharger depuis la BD pour s'assurer que les données sont fraîches
                targets = dailyTargetsRepository.findByUserId(userId)
                        .orElse(targets);
            } else {
                log.warn("No goals fields were provided for update");
            }

            return mapToResponse(targets, userId);
        } catch (Exception e) {
            log.error("Error updating goals for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to update goals: " + e.getMessage(), e);
        }
    }

    /**
     * Delete goals - will reset to recalculated values on next access.
     */
    public void deleteGoals(Long userId) {
        try {
            log.info("Deleting goals for user: {}", userId);
            dailyTargetsRepository.deleteByUserId(userId);
            log.info("Goals deleted for user: {}", userId);
        } catch (Exception e) {
            log.error("Error deleting goals for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to delete goals: " + e.getMessage(), e);
        }
    }

    // ---------- internal helpers ----------

    private DailyTargets recalculateAndSaveTargets(Long userId) {
        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

            // Vérifier que le profil est complet
            if (user.getGender() == null) {
                log.warn("User {} has no gender set", userId);
                throw new IllegalStateException("User gender is required for goal calculation");
            }
            if (user.getInitialWeightKg() == null) {
                log.warn("User {} has no weight set", userId);
                throw new IllegalStateException("User weight is required for goal calculation");
            }
            if (user.getHeightCm() == null) {
                log.warn("User {} has no height set", userId);
                throw new IllegalStateException("User height is required for goal calculation");
            }
            if (user.getAge() == null) {
                log.warn("User {} has no age set", userId);
                throw new IllegalStateException("User age is required for goal calculation");
            }
            if (user.getActivityLevel() == null) {
                log.warn("User {} has no activity level set", userId);
                throw new IllegalStateException("User activity level is required for goal calculation");
            }

            // Calculer TDEE
            double tdee = NutritionUtils.calculateTdee(
                    user.getGender(),
                    user.getInitialWeightKg(),
                    user.getHeightCm(),
                    user.getAge(),
                    user.getActivityLevel()
            );

            // Si pas de goalType, utiliser MAINTAIN comme défaut
            GoalType goalType = user.getGoalType() != null ? user.getGoalType() : GoalType.MAINTAIN;
            double targetCalories = NutritionUtils.adjustCaloriesForGoal(tdee, goalType);

            // Calculer macros
            NutritionUtils.MacroTargets macros = NutritionUtils.calculateMacroTargets(
                    targetCalories,
                    user.getInitialWeightKg(),
                    goalType
            );

            // Chercher ou créer les targets
            DailyTargets targets = dailyTargetsRepository.findByUserId(userId)
                    .orElse(new DailyTargets());

            targets.setUser(user);
            targets.setMaintenanceCalories(round(tdee));
            targets.setTargetCalories(round(macros.getCalories()));
            targets.setProteinGr(round(macros.getProteinGr()));
            targets.setCarbsGr(round(macros.getCarbsGr()));
            targets.setFatGr(round(macros.getFatGr()));
            targets.setUpdatedAt(LocalDateTime.now());

            return dailyTargetsRepository.save(targets);
        } catch (Exception e) {
            log.error("Error in recalculateAndSaveTargets for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to recalculate targets: " + e.getMessage(), e);
        }
    }

    private GoalsResponse mapToResponse(DailyTargets targets, Long userId) {
        try {
            if (targets == null) {
                log.error("Daily targets are null for user {}", userId);
                throw new IllegalStateException("Daily targets not found");
            }

            // Recharger l'utilisateur pour éviter les problèmes de lazy loading
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalStateException("User not found for id: " + userId));

            // Retourner les valeurs de DailyTargets (qui ont pu être mises à jour)
            return GoalsResponse.builder()
                    .goalType(user.getGoalType() != null ? user.getGoalType() : GoalType.MAINTAIN)
                    .activityLevel(user.getActivityLevel() != null ? user.getActivityLevel() : ActivityLevel.MODERATE)
                    .maintenanceCalories(targets.getMaintenanceCalories() != null ? targets.getMaintenanceCalories() : 0.0)
                    .targetCalories(targets.getTargetCalories() != null ? targets.getTargetCalories() : 0.0)
                    .proteinGr(targets.getProteinGr() != null ? targets.getProteinGr() : 0.0)
                    .carbsGr(targets.getCarbsGr() != null ? targets.getCarbsGr() : 0.0)
                    .fatGr(targets.getFatGr() != null ? targets.getFatGr() : 0.0)
                    .build();
        } catch (Exception e) {
            log.error("Error mapping targets to response for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to map response: " + e.getMessage(), e);
        }
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}


