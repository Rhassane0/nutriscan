package com.nutriscan.service;

import com.nutriscan.dto.request.UpdateProfileRequest;
import com.nutriscan.dto.response.UserProfileResponse;
import com.nutriscan.model.User;
import com.nutriscan.repository.UserRepository;
import com.nutriscan.security.CustomUserDetails;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;

    public User save(User user) {
        return userRepository.save(user);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public User findByEmailOrThrow(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email " + email));
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = findByEmailOrThrow(username);
        return new CustomUserDetails(user);
    }

    public UserProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }
        if (request.getAge() != null) {
            user.setAge(request.getAge());
        }
        if (request.getHeightCm() != null) {
            user.setHeightCm(request.getHeightCm());
        }
        if (request.getInitialWeightKg() != null) {
            user.setInitialWeightKg(request.getInitialWeightKg());
        }
        if (request.getGoalType() != null) {
            user.setGoalType(request.getGoalType());
        }
        if (request.getActivityLevel() != null) {
            user.setActivityLevel(request.getActivityLevel());
        }
        if (request.getDietPreferences() != null) {
            user.setDietPreferences(request.getDietPreferences());
        }
        if (request.getAllergies() != null) {
            user.setAllergies(request.getAllergies());
        }

        User saved = userRepository.save(user);
        return mapToUserProfileResponse(saved);
    }

    // If you don't already have this mapper, add it:
    private UserProfileResponse mapToUserProfileResponse(User user) {
        return UserProfileResponse.builder()
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
    }
}

