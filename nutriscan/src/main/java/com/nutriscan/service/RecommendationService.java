package com.nutriscan.service;

import com.nutriscan.dto.response.DailySummaryResponse;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.dto.response.RecommendationResponse;
import com.nutriscan.model.RecommendationsLog;
import com.nutriscan.model.User;
import com.nutriscan.model.enums.RecommendationType;
import com.nutriscan.repository.RecommendationsLogRepository;
import com.nutriscan.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class RecommendationService {

    private final MealService mealService;
    private final GoalsService goalsService;
    private final UserRepository userRepository;
    private final RecommendationsLogRepository recommendationsLogRepository;

    public RecommendationResponse getDailyRecommendation(Long userId, LocalDate date) {
        LocalDate targetDate = (date != null) ? date : LocalDate.now();

        // 1) Daily intake
        DailySummaryResponse summary = mealService.getDailySummary(userId, targetDate);

        if (summary == null || (summary.getTotalCalories() == null || summary.getTotalCalories() == 0)) {
            // No meals → no score, just message
            RecommendationResponse response = RecommendationResponse.builder()
                    .date(targetDate)
                    .score(null)
                    .totalCalories(0.0)
                    .messages(List.of("Aucun repas enregistré pour ce jour. Pense à scanner ou saisir tes repas."))
                    .build();

            logRecommendation(userId, targetDate, null, response.getMessages());
            return response;
        }

        // 2) Goals
        GoalsResponse goals = goalsService.getGoalsForUser(userId);

        Double targetCalories = goals.getTargetCalories();
        Double targetProtein = goals.getProteinGr();
        Double targetCarbs = goals.getCarbsGr();
        Double targetFat = goals.getFatGr();

        if (targetCalories == null || targetProtein == null || targetCarbs == null || targetFat == null) {
            throw new IllegalStateException("Daily targets not defined for this user");
        }

        double totalCalories = safe(summary.getTotalCalories());
        double totalProtein = safe(summary.getTotalProtein());
        double totalCarbs = safe(summary.getTotalCarbs());
        double totalFat = safe(summary.getTotalFat());

        // 3) Compute score & messages
        List<String> messages = new ArrayList<>();
        double score = 100.0;

        // --- Calories ---
        double calorieDiff = Math.abs(totalCalories - targetCalories);
        double calorieDiffPct = calorieDiff / targetCalories;

        boolean caloriesOnTarget = calorieDiffPct <= 0.1; // ≤10%

        if (caloriesOnTarget) {
            messages.add("Les calories sont proches de l'objectif, bien joué !");
        } else if (calorieDiffPct <= 0.2) {
            score -= 10;
            messages.add("Les calories sont un peu éloignées de l'objectif. Essaie d'ajuster légèrement les portions.");
        } else {
            score -= 20;
            if (totalCalories > targetCalories) {
                messages.add("Tu es largement au-dessus des calories prévues. Réduis les portions ou les aliments très énergétiques.");
            } else {
                messages.add("Tu es largement en-dessous des calories prévues. Attention à ne pas trop restreindre ton apport.");
            }
        }

        // --- Protein ---
        boolean proteinOnTarget = totalProtein >= 0.9 * targetProtein && totalProtein <= 1.2 * targetProtein;
        if (proteinOnTarget) {
            messages.add("L'apport en protéines est correct par rapport à ton objectif.");
        } else if (totalProtein < 0.8 * targetProtein) {
            score -= 20;
            messages.add("L'apport en protéines est trop bas. Ajoute des sources protéinées (œufs, yaourt, poulet, poissons, légumineuses...).");
        } else if (totalProtein > 1.4 * targetProtein) {
            score -= 5;
            messages.add("Les protéines sont bien au-dessus de l'objectif. Ce n'est pas dramatique, mais pas forcément nécessaire.");
        } else {
            score -= 5;
            messages.add("Les protéines ne sont pas parfaitement alignées, mais restent acceptables.");
        }

        // --- Fat ---
        boolean fatOk = totalFat <= 1.2 * targetFat;
        if (fatOk) {
            messages.add("Les lipides restent dans une zone raisonnable.");
        } else if (totalFat <= 1.5 * targetFat) {
            score -= 10;
            messages.add("Les lipides sont un peu élevés. Limite les fritures et les produits très gras.");
        } else {
            score -= 15;
            messages.add("Les lipides sont très élevés. Réduis franchement les aliments frits et très gras.");
        }

        // You can add extra rules for carbs if you want, but it's optional.

        // Clamp score
        if (score < 0) score = 0;
        if (score > 100) score = 100;

        RecommendationResponse response = RecommendationResponse.builder()
                .date(targetDate)
                .score(round(score))
                .totalCalories(round(totalCalories))
                .targetCalories(round(targetCalories))
                .totalProtein(round(totalProtein))
                .targetProtein(round(targetProtein))
                .totalCarbs(round(totalCarbs))
                .targetCarbs(round(targetCarbs))
                .totalFat(round(totalFat))
                .targetFat(round(targetFat))
                .caloriesOnTarget(caloriesOnTarget)
                .proteinOnTarget(proteinOnTarget)
                .fatOk(fatOk)
                .messages(messages)
                .build();

        logRecommendation(userId, targetDate, response.getScore(), messages);
        return response;
    }

    // ---------- helpers ----------

    private void logRecommendation(Long userId, LocalDate date, Double score, List<String> messages) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        String joined = String.join("\n", messages != null ? messages : List.of());

        RecommendationsLog log = RecommendationsLog.builder()
                .user(user)
                .date(date)
                .type(RecommendationType.DAILY_SUMMARY)
                .score(score)
                .details(joined)
                .createdAt(LocalDateTime.now())
                .build();

        recommendationsLogRepository.save(log);
    }

    private double safe(Double value) {
        return value != null ? value : 0.0;
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
