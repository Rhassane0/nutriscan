package com.nutriscan.service;

import com.nutriscan.dto.request.WeightEntryRequest;
import com.nutriscan.dto.response.WeightHistoryResponse;
import com.nutriscan.model.User;
import com.nutriscan.model.WeightHistory;
import com.nutriscan.repository.UserRepository;
import com.nutriscan.repository.WeightHistoryRepository;
import com.nutriscan.util.NutritionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class TrackingService {

    private final UserRepository userRepository;
    private final WeightHistoryRepository weightHistoryRepository;

    public WeightHistoryResponse addWeightEntry(Long userId, WeightEntryRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        LocalDate date = request.getDate() != null ? request.getDate() : LocalDate.now();

        Double bmi = null;
        if (user.getHeightCm() != null) {
            bmi = NutritionUtils.calculateBmi(request.getWeightKg(), user.getHeightCm());
            bmi = round(bmi);
        }

        WeightHistory entity = WeightHistory.builder()
                .user(user)
                .date(date)
                .weightKg(request.getWeightKg())
                .bmi(bmi)
                .build();

        WeightHistory saved = weightHistoryRepository.save(entity);
        return mapToResponse(saved);
    }

    public List<WeightHistoryResponse> getWeightHistory(Long userId, LocalDate from, LocalDate to) {
        List<WeightHistory> list;

        if (from != null && to != null) {
            list = weightHistoryRepository.findByUserIdAndDateBetweenOrderByDateAsc(userId, from, to);
        } else {
            list = weightHistoryRepository.findByUserIdOrderByDateAsc(userId);
        }

        return list.stream()
                .map(this::mapToResponse)
                .toList();
    }

    // ---------- helpers ----------

    private WeightHistoryResponse mapToResponse(WeightHistory entity) {
        return WeightHistoryResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())
                .weightKg(entity.getWeightKg())
                .bmi(entity.getBmi())
                .build();
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
