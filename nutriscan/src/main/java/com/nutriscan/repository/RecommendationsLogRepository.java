package com.nutriscan.repository;

import com.nutriscan.model.RecommendationsLog;
import com.nutriscan.model.enums.RecommendationType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface RecommendationsLogRepository extends JpaRepository<RecommendationsLog, Long> {

    List<RecommendationsLog> findByUserIdAndTypeOrderByCreatedAtDesc(Long userId, RecommendationType type);

    List<RecommendationsLog> findByUserIdAndTypeAndDateOrderByCreatedAtDesc(
            Long userId,
            RecommendationType type,
            LocalDate date
    );
}
