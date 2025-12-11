package com.nutriscan.repository;

import com.nutriscan.model.WeightHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface WeightHistoryRepository extends JpaRepository<WeightHistory, Long> {

    List<WeightHistory> findByUserIdOrderByDateAsc(Long userId);

    List<WeightHistory> findByUserIdAndDateBetweenOrderByDateAsc(
            Long userId,
            LocalDate from,
            LocalDate to
    );
}
