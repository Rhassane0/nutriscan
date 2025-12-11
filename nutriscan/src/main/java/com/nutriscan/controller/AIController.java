package com.nutriscan.controller;

import com.nutriscan.dto.request.AIExplanationRequest;
import com.nutriscan.dto.request.VisionAnalysisRequest;
import com.nutriscan.dto.response.AIExplanationResponse;
import com.nutriscan.dto.response.OffProductResponse;
import com.nutriscan.dto.response.VisionAnalysisResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.AIService;
import com.nutriscan.service.VisionService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AIController {

    private final AIService aiService;
    private final VisionService visionService;

    /**
     * Scan product by barcode and get info (GET method).
     */
    @GetMapping("/scan-barcode")
    public ResponseEntity<OffProductResponse> scanByBarcodeGet(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("barcode") @NotBlank String barcode
    ) {
        OffProductResponse response = aiService.scanBarcodeAndAnalyze(barcode);
        return ResponseEntity.ok(response);
    }

    /**
     * Scan product by barcode and get info (POST method for compatibility).
     * Accepts barcode as query param OR in request body.
     */
    @PostMapping("/scan-barcode")
    public ResponseEntity<OffProductResponse> scanByBarcodePost(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(value = "barcode", required = false) String barcodeParam,
            @RequestBody(required = false) java.util.Map<String, String> body
    ) {
        // Accept barcode from query param OR body
        String barcode = barcodeParam;
        if (barcode == null && body != null && body.containsKey("barcode")) {
            barcode = body.get("barcode");
        }

        if (barcode == null || barcode.isBlank()) {
            throw new IllegalArgumentException("Barcode parameter is required (query param or body)");
        }

        OffProductResponse response = aiService.scanBarcodeAndAnalyze(barcode);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/scan/barcode")
    public ResponseEntity<OffProductResponse> scanByBarcode(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("code") @NotBlank String barcode
    ) {
        OffProductResponse response = aiService.scanBarcodeAndAnalyze(barcode);
        return ResponseEntity.ok(response);
    }

    /**
     * Analyse une photo de repas et détecte les aliments
     * POST /api/v1/ai/analyze/meal-photo
     */
    @PostMapping("/analyze/meal-photo")
    public ResponseEntity<VisionAnalysisResponse> analyzeMealPhoto(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody VisionAnalysisRequest request
    ) {
        VisionAnalysisResponse response = visionService.analyzeImage(request);
        return ResponseEntity.ok(response);
    }

    /**
     * Get daily AI explanation via GET (with query param date).
     */
    @GetMapping("/explain/daily")
    public ResponseEntity<AIExplanationResponse> explainDailyGet(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("date") @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) java.time.LocalDate date
    ) {
        AIExplanationResponse response = aiService.generateDailyExplanation(currentUser.getId(), date);
        return ResponseEntity.ok(response);
    }

    /**
     * Génère une explication IA pour le résumé d'une journée (POST).
     */
    @PostMapping("/explain/daily")
    public ResponseEntity<AIExplanationResponse> explainDaily(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody AIExplanationRequest request
    ) {
        AIExplanationResponse response = aiService.generateDailyExplanation(currentUser.getId(), request.getDate());
        return ResponseEntity.ok(response);
    }

    /**
     * Get product AI explanation via GET (with query param barcode).
     */
    @GetMapping("/explain/product")
    public ResponseEntity<AIExplanationResponse> explainProductGet(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("barcode") @NotBlank String barcode
    ) {
        AIExplanationResponse response = aiService.generateProductExplanation(barcode, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    /**
     * Génère une explication IA pour un produit (POST).
     */
    @PostMapping("/explain/product")
    public ResponseEntity<AIExplanationResponse> explainProduct(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("barcode") @NotBlank String barcode
    ) {
        AIExplanationResponse response = aiService.generateProductExplanation(barcode, currentUser.getId());
        return ResponseEntity.ok(response);
    }
}




