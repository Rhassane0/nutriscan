package com.nutriscan.controller;

import com.nutriscan.dto.request.MealScanRequest;
import com.nutriscan.dto.response.MealScanResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.MealScanService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Base64;

/**
 * Contrôleur pour le scan de repas (code-barres et images)
 *
 * Endpoints:
 * - POST /api/v1/scan/meal - Scan général (barcode ou image)
 * - GET /api/v1/scan/barcode?code={code} - Scan rapide code-barres
 * - POST /api/v1/scan/image - Upload d'image de repas
 */
@RestController
@RequestMapping("/api/v1/scan")
@RequiredArgsConstructor
@Slf4j
public class ScanController {

    private final MealScanService mealScanService;

    /**
     * Scan général d'un repas (supporte barcode, image URL, ou image base64)
     *
     * POST /api/v1/scan/meal
     * Body: {
     *   "scanType": "BARCODE" | "IMAGE_URL" | "IMAGE_BASE64",
     *   "data": "...",
     *   "mealType": "BREAKFAST" | "LUNCH" | "DINNER" | "SNACK" (optionnel),
     *   "estimatedQuantityGrams": 150 (optionnel)
     * }
     */
    @PostMapping("/meal")
    public ResponseEntity<MealScanResponse> scanMeal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody MealScanRequest request
    ) {
        log.info("Scan meal request received: type={}", request.getScanType());
        MealScanResponse response = mealScanService.scanMeal(request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    /**
     * Scan rapide par code-barres (GET pour facilité d'utilisation)
     *
     * GET /api/v1/scan/barcode?code=3017620422003
     */
    @GetMapping("/barcode")
    public ResponseEntity<MealScanResponse> scanBarcode(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("code") @NotBlank String barcode,
            @RequestParam(value = "quantity", required = false) Double quantity
    ) {
        log.info("Barcode scan request: {}", barcode);

        MealScanRequest request = MealScanRequest.builder()
                .scanType("BARCODE")
                .data(barcode)
                .estimatedQuantityGrams(quantity)
                .build();

        MealScanResponse response = mealScanService.scanMeal(request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    /**
     * Upload d'image de repas pour analyse
     *
     * POST /api/v1/scan/image
     * Content-Type: multipart/form-data
     * - file: image du repas
     * - mealType: BREAKFAST | LUNCH | DINNER | SNACK (optionnel)
     */
    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<MealScanResponse> scanImage(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "mealType", required = false) String mealType
    ) {
        log.info("Image scan request received: filename={}, size={}", file.getOriginalFilename(), file.getSize());

        try {
            // Vérifier le type de fichier
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body(
                        MealScanResponse.builder()
                                .status("ERROR")
                                .errorMessage("Le fichier doit être une image (JPEG, PNG, etc.)")
                                .build()
                );
            }

            // Vérifier la taille (max 10MB)
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(
                        MealScanResponse.builder()
                                .status("ERROR")
                                .errorMessage("L'image ne doit pas dépasser 10MB")
                                .build()
                );
            }

            // Convertir en base64
            byte[] imageBytes = file.getBytes();
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);

            MealScanRequest request = MealScanRequest.builder()
                    .scanType("IMAGE_BASE64")
                    .data(base64Image)
                    .mealType(mealType)
                    .build();

            MealScanResponse response = mealScanService.scanMeal(request, currentUser.getId());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("Error processing image upload", e);
            return ResponseEntity.internalServerError().body(
                    MealScanResponse.builder()
                            .status("ERROR")
                            .errorMessage("Erreur lors du traitement de l'image: " + e.getMessage())
                            .build()
            );
        }
    }

    /**
     * Scan d'image via URL
     *
     * POST /api/v1/scan/image-url
     * Body: {
     *   "imageUrl": "https://...",
     *   "mealType": "LUNCH" (optionnel)
     * }
     */
    @PostMapping("/image-url")
    public ResponseEntity<MealScanResponse> scanImageUrl(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestBody ImageUrlRequest request
    ) {
        log.info("Image URL scan request: {}", request.getImageUrl());

        MealScanRequest scanRequest = MealScanRequest.builder()
                .scanType("IMAGE_URL")
                .data(request.getImageUrl())
                .mealType(request.getMealType())
                .build();

        MealScanResponse response = mealScanService.scanMeal(scanRequest, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    /**
     * DTO interne pour la requête d'URL d'image
     */
    @lombok.Data
    public static class ImageUrlRequest {
        @NotBlank(message = "L'URL de l'image est requise")
        private String imageUrl;
        private String mealType;
    }
}

