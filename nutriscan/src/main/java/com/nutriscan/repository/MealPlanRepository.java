package com.nutriscan.repository;

import com.nutriscan.model.MealPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface MealPlanRepository extends JpaRepository<MealPlan, Long> {

    @Query("SELECT mp FROM MealPlan mp WHERE mp.user.id = :userId ORDER BY mp.createdAt DESC, mp.id DESC")
    List<MealPlan> findByUserId(@Param("userId") Long userId);

    @Query("SELECT mp FROM MealPlan mp WHERE mp.user.id = :userId AND mp.startDate <= :date AND mp.endDate >= :date ORDER BY mp.createdAt DESC")
    List<MealPlan> findByUserIdAndDateRange(@Param("userId") Long userId, @Param("date") LocalDate date);

    @Query("SELECT mp FROM MealPlan mp WHERE mp.user.id = :userId AND mp.startDate >= :startDate AND mp.endDate <= :endDate")
    List<MealPlan> findByUserIdAndDateBetween(@Param("userId") Long userId,
                                                @Param("startDate") LocalDate startDate,
                                                @Param("endDate") LocalDate endDate);
}

