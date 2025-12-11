package com.nutriscan.repository;

import com.nutriscan.model.DailyTargets;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DailyTargetsRepository extends JpaRepository<DailyTargets, Long> {

    Optional<DailyTargets> findByUserId(Long userId);

    void deleteByUserId(Long userId);
}


