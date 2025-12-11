package com.nutriscan.service;

import com.nutriscan.dto.request.AuthLoginRequest;
import com.nutriscan.dto.request.AuthRegisterRequest;
import com.nutriscan.dto.response.AuthResponse;
import com.nutriscan.model.User;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthResponse register(AuthRegisterRequest request) {
        if (userService.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .gender(request.getGender())
                .age(request.getAge())
                .heightCm(request.getHeightCm())
                .initialWeightKg(request.getInitialWeightKg())
                .goalType(request.getGoalType())
                .activityLevel(request.getActivityLevel())
                .dietPreferences(request.getDietPreferences())
                .allergies(request.getAllergies())
                .role("ROLE_USER")
                .build();

        User saved = userService.save(user);
        CustomUserDetails userDetails = new CustomUserDetails(saved);
        String token = jwtTokenProvider.generateToken(userDetails);

        return AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .userId(saved.getId())
                .email(saved.getEmail())
                .fullName(saved.getFullName())
                .role(saved.getRole())
                .build();
    }

    public AuthResponse login(AuthLoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        if (!authentication.isAuthenticated()) {
            throw new UsernameNotFoundException("Invalid email or password");
        }

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        String token = jwtTokenProvider.generateToken(userDetails);

        return AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .userId(userDetails.getId())
                .email(userDetails.getUsername())
                .fullName(userDetails.getFullName())  // ✅ use fullName now
                .role(userDetails.getAuthorities().stream()
                        .findFirst()
                        .map(Object::toString)
                        .orElse("ROLE_USER"))
                .build();
    }

}
