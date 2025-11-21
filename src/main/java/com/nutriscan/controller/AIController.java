package com.nutriscan.controller;

import com.nutriscan.dto.response.OffProductResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.AIService;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AIController {

    private final AIService aiService;

    @GetMapping("/scan/barcode")
    public ResponseEntity<OffProductResponse> scanByBarcode(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("code") @NotBlank String barcode
    ) {
        OffProductResponse response = aiService.scanBarcodeAndAnalyze(barcode);
        return ResponseEntity.ok(response);
    }
}
