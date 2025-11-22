package com.nutriscan.dto.response;

import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.GoalType;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class GoalsResponse {

    private GoalType goalType;
    private ActivityLevel activityLevel;

    private Double maintenanceCalories;
    private Double targetCalories;

    private Double proteinGr;
    private Double carbsGr;
    private Double fatGr;
}
