package com.nutriscan.controller;

import com.nutriscan.dto.request.WeightEntryRequest;
import com.nutriscan.dto.response.WeightHistoryResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.TrackingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/tracking")
@RequiredArgsConstructor
public class TrackingController {

    private final TrackingService trackingService;

    /**
     * Add a new weight entry for the current user.
     * If date is null, uses today's date.
     */
    @PostMapping("/weight")
    public ResponseEntity<WeightHistoryResponse> addWeight(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody WeightEntryRequest request
    ) {
        WeightHistoryResponse response =
                trackingService.addWeightEntry(currentUser.getId(), request);
        return ResponseEntity.status(201).body(response);
    }

    /**
     * Get weight history for the current user.
     * Optional query params: from, to (yyyy-MM-dd).
     */
    @GetMapping("/weight")
    public ResponseEntity<List<WeightHistoryResponse>> getWeightHistory(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        List<WeightHistoryResponse> history =
                trackingService.getWeightHistory(currentUser.getId(), from, to);
        return ResponseEntity.ok(history);
    }

    /**
     * Get weight history - alias endpoint (weight-history instead of weight).
     */
    @GetMapping("/weight-history")
    public ResponseEntity<List<WeightHistoryResponse>> getWeightHistoryAlias(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        List<WeightHistoryResponse> history =
                trackingService.getWeightHistory(currentUser.getId(), startDate, endDate);
        return ResponseEntity.ok(history);
    }
}


