package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
@AllArgsConstructor
public class AuthResponse {

    private String token;
    private String tokenType;
    private Long userId;
    private String email;
    private String fullName;
    private String role;
}
