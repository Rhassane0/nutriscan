package com.nutriscan.repository;

import com.nutriscan.model.GroceryList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface GroceryListRepository extends JpaRepository<GroceryList, Long> {

    @Query("SELECT gl FROM GroceryList gl WHERE gl.user.id = :userId ORDER BY gl.createdAt DESC, gl.id DESC")
    List<GroceryList> findByUserId(@Param("userId") Long userId);

    @Query("SELECT gl FROM GroceryList gl WHERE gl.user.id = :userId AND gl.generatedDate = :date")
    Optional<GroceryList> findByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    @Query("SELECT gl FROM GroceryList gl WHERE gl.mealPlan.id = :mealPlanId")
    Optional<GroceryList> findByMealPlanId(@Param("mealPlanId") Long mealPlanId);
}

