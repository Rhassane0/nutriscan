package com.nutriscan.service;

import com.nutriscan.dto.response.PatternDetectionResponse;
import com.nutriscan.dto.response.MealScoreResponse;
import com.nutriscan.model.Meal;
import com.nutriscan.model.MealItem;
import com.nutriscan.repository.MealRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class NutritionPatternAnalysisService {

    private final MealRepository mealRepository;
    private final GoalsService goalsService;

    /**
     * Détecte les patterns nutritionnels sur les 7 derniers jours
     */
    public List<PatternDetectionResponse> detectPatterns(Long userId) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // 7 derniers jours

        List<Meal> meals = mealRepository.findByUserIdAndDateBetween(userId, startDate, endDate);
        List<PatternDetectionResponse> patterns = new ArrayList<>();

        if (meals.isEmpty()) {
            return patterns;
        }

        // Détection : sucres élevés le soir
        detectHighSugarEvening(meals, patterns);

        // Détection : protéines basses au petit-déjeuner
        detectLowProteinBreakfast(meals, userId, patterns);

        // Détection : repas très tard le soir
        detectLateMeals(meals, patterns);

        // Détection : calories très instables d'un jour à l'autre
        detectCalorieInstability(meals, patterns);

        return patterns;
    }

    /**
     * Génère un score personnalisé pour chaque repas de la journée
     */
    public List<MealScoreResponse> generateMealScores(Long userId, LocalDate date) {
        List<Meal> meals = mealRepository.findByUserIdAndDate(userId, date);
        List<MealScoreResponse> scores = new ArrayList<>();

        if (meals.isEmpty()) {
            return scores;
        }

        var goals = goalsService.getGoalsForUser(userId);
        // Diviser les objectifs par 4 (petit-déj, déj, dîner, snack - en moyenne)
        double caloriesPerMeal = goals.getTargetCalories() / 4;
        double proteinPerMeal = goals.getProteinGr() / 4;

        for (Meal meal : meals) {
            MealScoreResponse mealScore = scoreMeal(meal, caloriesPerMeal, proteinPerMeal);
            scores.add(mealScore);
        }

        return scores;
    }

    /**
     * Score un repas spécifique
     */
    private MealScoreResponse scoreMeal(Meal meal, double targetCalories, double targetProtein) {
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        for (MealItem item : meal.getItems()) {
            // Utiliser les valeurs precomputed de l'item si disponibles
            if (item.getCalories() != null) {
                totalCalories += item.getCalories();
                totalProtein += item.getProtein() != null ? item.getProtein() : 0;
                totalCarbs += item.getCarbs() != null ? item.getCarbs() : 0;
                totalFat += item.getFat() != null ? item.getFat() : 0;
            } else if (item.getFood() != null) {
                // Sinon calculer à partir du food et de la quantité
                totalCalories += item.getQuantity() * item.getFood().getCaloriesKcal() / 100;
                totalProtein += item.getQuantity() * item.getFood().getProteinGr() / 100;
                totalCarbs += item.getQuantity() * item.getFood().getCarbsGr() / 100;
                totalFat += item.getQuantity() * item.getFood().getFatGr() / 100;
            }
        }

        double score = 100.0;
        StringBuilder feedback = new StringBuilder();

        // Évaluation calories
        double calDiff = Math.abs(totalCalories - targetCalories);
        double calDiffPct = targetCalories > 0 ? calDiff / targetCalories : 0;

        if (calDiffPct <= 0.15) {
            feedback.append("✓ Calories correctes. ");
        } else if (calDiffPct <= 0.30) {
            score -= 10;
            if (totalCalories > targetCalories) {
                feedback.append("⚠ Repas un peu riche. ");
            } else {
                feedback.append("⚠ Repas un peu léger. ");
            }
        } else {
            score -= 25;
            if (totalCalories > targetCalories) {
                feedback.append("✗ Repas très riche. Attention aux portions. ");
            } else {
                feedback.append("✗ Repas très léger. Ajoute des aliments. ");
            }
        }

        // Évaluation protéines
        if (totalProtein >= 0.9 * targetProtein && totalProtein <= 1.2 * targetProtein) {
            feedback.append("✓ Protéines ok. ");
        } else if (totalProtein < 0.8 * targetProtein) {
            score -= 15;
            feedback.append("⚠ Protéines insuffisantes. Ajoute œuf, yaourt ou viande. ");
        } else {
            score -= 5;
            feedback.append("✓ Protéines élevées. ");
        }

        // Clamp score
        if (score < 0) score = 0;
        if (score > 100) score = 100;

        return MealScoreResponse.builder()
                .mealType(meal.getMealType())
                .time(meal.getTime())
                .score(Math.round(score * 10.0) / 10.0)
                .caloriesActual(Math.round(totalCalories * 10.0) / 10.0)
                .caloriesTarget(Math.round(targetCalories * 10.0) / 10.0)
                .proteinActual(Math.round(totalProtein * 10.0) / 10.0)
                .proteinTarget(Math.round(targetProtein * 10.0) / 10.0)
                .feedback(feedback.toString())
                .build();
    }


    // ---------- Pattern detection helpers ----------

    private void detectHighSugarEvening(List<Meal> meals, List<PatternDetectionResponse> patterns) {
        LocalTime eveningStart = LocalTime.of(19, 0);

        meals.stream()
                .filter(m -> m.getTime() != null && m.getTime().isAfter(eveningStart))
                .forEach(meal -> {
                    double totalCarbs = meal.getItems().stream()
                            .mapToDouble(item -> {
                                if (item.getCarbs() != null) {
                                    return item.getCarbs();
                                } else if (item.getFood() != null && item.getQuantity() != null) {
                                    return item.getQuantity() * item.getFood().getCarbsGr() / 100;
                                }
                                return 0;
                            })
                            .sum();

                    if (totalCarbs > 80) {
                        patterns.add(PatternDetectionResponse.builder()
                                .patternType("HIGH_CARBS_EVENING")
                                .description("Apport élevé en glucides en fin de soirée (" + Math.round(totalCarbs) + "g)")
                                .recommendation("Les glucides élevés le soir peuvent impacter le sommeil. Préfère des aliments moins énergétiques en soirée.")
                                .severity(2)
                                .build());
                    }
                });
    }

    private void detectLowProteinBreakfast(List<Meal> meals, Long userId, List<PatternDetectionResponse> patterns) {
        LocalTime morningEnd = LocalTime.of(11, 0);

        long breakfastWithLowProtein = meals.stream()
                .filter(m -> m.getTime() != null && m.getTime().isBefore(morningEnd))
                .filter(m -> {
                    double protein = m.getItems().stream()
                            .mapToDouble(item -> {
                                if (item.getProtein() != null) {
                                    return item.getProtein();
                                } else if (item.getFood() != null && item.getQuantity() != null) {
                                    return item.getQuantity() * item.getFood().getProteinGr() / 100;
                                }
                                return 0;
                            })
                            .sum();
                    return protein < 10; // Moins de 10g de protéines
                })
                .count();

        if (breakfastWithLowProtein > 0) {
            patterns.add(PatternDetectionResponse.builder()
                    .patternType("LOW_PROTEIN_BREAKFAST")
                    .description("Petit-déjeuners souvent pauvres en protéines")
                    .recommendation("Un petit-déjeuner riche en protéines (œufs, yaourt, fromage) améliore la satiété et évite les fringales.")
                    .severity(2)
                    .build());
        }
    }

    private void detectLateMeals(List<Meal> meals, List<PatternDetectionResponse> patterns) {
        LocalTime veryLateTime = LocalTime.of(22, 0);

        long lateMeals = meals.stream()
                .filter(m -> m.getTime() != null && m.getTime().isAfter(veryLateTime))
                .count();

        if (lateMeals > 0) {
            patterns.add(PatternDetectionResponse.builder()
                    .patternType("LATE_EATING")
                    .description("Des repas très tard le soir (" + lateMeals + " fois)")
                    .recommendation("Manger trop tard peut perturber la digestion et le sommeil. Essaie de manger au moins 2-3h avant le coucher.")
                    .severity(1)
                    .build());
        }
    }

    private void detectCalorieInstability(List<Meal> meals, List<PatternDetectionResponse> patterns) {
        // Grouper par date
        Map<LocalDate, Double> dailyCalories = new LinkedHashMap<>();
        for (Meal meal : meals) {
            double calories = meal.getItems().stream()
                    .mapToDouble(item -> {
                        if (item.getCalories() != null) {
                            return item.getCalories();
                        } else if (item.getFood() != null && item.getQuantity() != null) {
                            return item.getQuantity() * item.getFood().getCaloriesKcal() / 100;
                        }
                        return 0;
                    })
                    .sum();
            dailyCalories.put(meal.getDate(), dailyCalories.getOrDefault(meal.getDate(), 0.0) + calories);
        }

        if (dailyCalories.size() < 3) {
            return; // Besoin d'au moins 3 jours
        }

        double avg = dailyCalories.values().stream().mapToDouble(Double::doubleValue).average().orElse(0);
        double maxDeviation = dailyCalories.values().stream()
                .mapToDouble(cal -> avg > 0 ? Math.abs(cal - avg) / avg : 0)
                .max()
                .orElse(0);

        if (maxDeviation > 0.40) { // Plus de 40% de déviation
            patterns.add(PatternDetectionResponse.builder()
                    .patternType("CALORIE_INSTABILITY")
                    .description("Calories très instables d'un jour à l'autre (écart de " + Math.round(maxDeviation * 100) + "%)")
                    .recommendation("Une consommation irrégulière rend difficile la prédiction du poids. Essaie d'être plus régulier dans tes portions.")
                    .severity(2)
                    .build());
        }
    }
}

