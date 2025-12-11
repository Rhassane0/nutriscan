package com.nutriscan.controller;

import com.nutriscan.dto.request.UpdateProfileRequest;
import com.nutriscan.dto.response.UserProfileResponse;
import com.nutriscan.model.User;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * Get current user profile (alias: /me)
     */
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
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

    /**
     * Get current user profile (alias: same as /me)
     */
    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getProfile(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        return getCurrentUser(currentUser);
    }

    /**
     * Update current user profile (alias: /me)
     */
    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateProfile(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        UserProfileResponse response = userService.updateProfile(currentUser.getId(), request);
        return ResponseEntity.ok(response);
    }

    /**
     * Update current user profile (alias: same as /me)
     */
    @PutMapping("/profile")
    public ResponseEntity<UserProfileResponse> updateProfileAlias(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return updateProfile(currentUser, request);
    }
}

