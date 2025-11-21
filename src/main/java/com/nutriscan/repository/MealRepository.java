package com.nutriscan.repository;

import com.nutriscan.model.Meal;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface MealRepository extends JpaRepository<Meal, Long> {

    List<Meal> findByUserIdAndDate(Long userId, LocalDate date);
}
