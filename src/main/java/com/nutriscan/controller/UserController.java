package com.nutriscan.controller;

import com.nutriscan.dto.response.UserProfileResponse;
import com.nutriscan.model.User;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        // Option 1: we already have everything in currentUser.getUser()
        User user = userService.findByEmailOrThrow(currentUser.getUsername());

        UserProfileResponse response = UserProfileResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .gender(user.getGender())
                .age(user.getAge())
                .heightCm(user.getHeightCm())
                .initialWeightKg(user.getInitialWeightKg())
                .goalType(user.getGoalType())
                .activityLevel(user.getActivityLevel())
                .dietPreferences(user.getDietPreferences())
                .allergies(user.getAllergies())
                .createdAt(user.getCreatedAt())
                .build();

        return ResponseEntity.ok(response);
    }
}
