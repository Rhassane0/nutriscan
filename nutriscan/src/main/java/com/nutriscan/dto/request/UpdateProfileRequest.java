package com.nutriscan.dto.request;

import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.Gender;
import com.nutriscan.model.enums.GoalType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateProfileRequest {

    @Size(min = 2, max = 100)
    private String fullName;

    private Gender gender;                // MALE, FEMALE, etc.

    @Min(10)
    @Max(120)
    private Integer age;

    @Min(100)
    @Max(250)
    private Integer heightCm;             // in cm

    @DecimalMin("20.0")
    @DecimalMax("300.0")
    private Double initialWeightKg;       // in kg

    private GoalType goalType;           // LOSE_WEIGHT, MAINTAIN, GAIN_WEIGHT

    private ActivityLevel activityLevel;  // SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE

    private String dietPreferences;       // e.g. "Halal, Vegetarian"

    private String allergies;             // free text list
}
