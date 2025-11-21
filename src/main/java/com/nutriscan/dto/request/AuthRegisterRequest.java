package com.nutriscan.dto.request;

import com.nutriscan.model.enums.Gender;
import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.GoalType;
import jakarta.validation.constraints.*;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuthRegisterRequest {

    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 6, max = 100)
    private String password;

    @NotBlank
    @Size(min = 2, max = 100)
    private String fullName;

    private Gender gender;

    @Min(10)
    @Max(120)
    private Integer age;

    @Min(100)
    @Max(250)
    private Integer heightCm;

    @DecimalMin("20.0")
    @DecimalMax("300.0")
    private Double initialWeightKg;

    private GoalType goalType;

    private ActivityLevel activityLevel;

    private String dietPreferences;

    private String allergies;
}
