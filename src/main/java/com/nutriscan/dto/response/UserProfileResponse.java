package com.nutriscan.dto.response;

import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.Gender;
import com.nutriscan.model.enums.GoalType;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
public class UserProfileResponse {

    private Long id;
    private String email;
    private String fullName;

    private Gender gender;
    private Integer age;
    private Integer heightCm;
    private Double initialWeightKg;

    private GoalType goalType;
    private ActivityLevel activityLevel;

    private String dietPreferences;
    private String allergies;

    private LocalDateTime createdAt;
}
