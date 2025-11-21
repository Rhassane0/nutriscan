package com.nutriscan.service;

import com.nutriscan.dto.response.OffProductResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class OpenFoodFactsService {

    private final RestTemplate restTemplate;

    private static final String BASE_URL = "https://world.openfoodfacts.net/api/v2";

    public OffProductResponse getProductByBarcode(String barcode) {
        try {
            String fields = "product_name,brands,nutriments,nutrition_grades,image_url";
            String url = BASE_URL + "/product/" + barcode + "?fields=" + fields;

            OffProductResponse response =
                    restTemplate.getForObject(url, OffProductResponse.class);

            if (response == null) {
                throw new IllegalStateException("Empty response from OpenFoodFacts");
            }

            return response;
        } catch (RestClientException e) {
            throw new IllegalStateException("Failed to fetch product from OpenFoodFacts", e);
        }
    }
}
