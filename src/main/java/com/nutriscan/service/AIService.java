package com.nutriscan.service;

import com.nutriscan.dto.response.OffProductResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AIService {

    private final OpenFoodFactsService openFoodFactsService;

    public OffProductResponse scanBarcodeAndAnalyze(String barcode) {
        OffProductResponse product = openFoodFactsService.getProductByBarcode(barcode);
        // Later: call AI API and build richer response
        return product;
    }
}
