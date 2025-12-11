package com.nutriscan.service;

import com.nutriscan.dto.response.OffProductResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class OpenFoodFactsService {

    private final RestTemplate restTemplate;

    private static final String BASE_URL = "https://world.openfoodfacts.net/api/v2";
    private static final String SEARCH_BASE_URL = "https://world.openfoodfacts.net/cgi/search.pl";

    /**
     * Get product by barcode
     */
    public OffProductResponse getProductByBarcode(String barcode) {
        try {
            String fields = "product_name,brands,nutriments,nutrition_grades,image_url";
            String url = BASE_URL + "/product/" + barcode + "?fields=" + fields;

            log.info("Getting product by barcode from OpenFoodFacts: {}", url);

            OffProductResponse response = restTemplate.getForObject(url, OffProductResponse.class);

            if (response == null || response.getStatus() == 0 || response.getProduct() == null) {
                log.warn("Product not found for barcode: {}", barcode);
                // Retourner une réponse vide au lieu de lancer une exception
                OffProductResponse emptyResponse = new OffProductResponse();
                emptyResponse.setStatus(0); // 0 = not found
                emptyResponse.setCode(barcode);
                emptyResponse.setStatusVerbose("product not found");
                return emptyResponse;
            }

            log.info("Successfully fetched product for barcode: {}", barcode);
            return response;

        } catch (Exception e) {
            log.error("Failed to fetch product from OpenFoodFacts for barcode {}: {}", barcode, e.getMessage());
            // Retourner une réponse d'erreur au lieu de propager l'exception
            OffProductResponse errorResponse = new OffProductResponse();
            errorResponse.setStatus(0);
            errorResponse.setCode(barcode);
            errorResponse.setStatusVerbose("error: " + e.getMessage());
            return errorResponse;
        }
    }

    /**
     * Search for products by query (text search)
     * This uses the search.pl endpoint which returns a list of products
     */
    public List<OffProductResponse> searchProducts(String query, int pageSize) {
        List<OffProductResponse> results = new ArrayList<>();

        try {
            // OpenFoodFacts search endpoint - use search.pl
            String encodedQuery = query.replace(" ", "%20");
            String url = String.format(
                    "%s?search_terms=%s&page_size=%d&json=1&action=process",
                    SEARCH_BASE_URL,
                    encodedQuery,
                    pageSize
            );

            log.info("Searching products from OpenFoodFacts: {}", url);

            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> response = restTemplate.getForObject(url, Map.class);

                if (response == null) {
                    log.warn("Null response from OpenFoodFacts search for query: {}", query);
                    return results;
                }

                log.debug("API Response keys: {}", response.keySet());

                // Check for error in response
                if (response.containsKey("error")) {
                    log.error("API Error: {}", response.get("error"));
                    return results;
                }

                // OpenFoodFacts returns "products" array
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> products = (List<Map<String, Object>>) response.get("products");

                if (products == null) {
                    log.warn("No 'products' key in response. Available keys: {}", response.keySet());
                    return results;
                }

                if (products.isEmpty()) {
                    log.warn("Empty products list for query: {}", query);
                    return results;
                }

                log.info("Found {} products for query: {}", products.size(), query);

                // Convert each product to OffProductResponse
                for (Map<String, Object> product : products) {
                    try {
                        OffProductResponse offResponse = convertToOffProductResponse(product);
                        if (offResponse != null && offResponse.getProduct() != null) {
                            results.add(offResponse);
                            log.debug("Added product: {}", product.get("product_name"));
                        }
                    } catch (Exception e) {
                        log.warn("Could not convert product: {}", e.getMessage());
                    }
                }

                log.info("Returning {} products for query: {}", results.size(), query);

            } catch (org.springframework.web.client.HttpClientErrorException e) {
                log.error("HTTP Error calling OpenFoodFacts: {} - {}", e.getStatusCode(), e.getMessage());
            } catch (org.springframework.web.client.HttpServerErrorException e) {
                log.error("OpenFoodFacts Server Error: {} - {}", e.getStatusCode(), e.getMessage());
            } catch (Exception e) {
                log.error("Error parsing response: {}", e.getMessage(), e);
            }

        } catch (Exception e) {
            log.error("Failed to search products: {}", e.getMessage(), e);
        }

        return results;
    }

    /**
     * Convert OpenFoodFacts product data to OffProductResponse format
     */
    private OffProductResponse convertToOffProductResponse(Map<String, Object> product) {
        try {
            OffProductResponse response = new OffProductResponse();

            Object code = product.get("code");
            if (code != null) {
                response.setCode(code.toString());
            }
            response.setStatus(1); // 1 = found

            OffProductResponse.OffProduct offProduct = new OffProductResponse.OffProduct();
            offProduct.setProductName((String) product.get("product_name"));
            offProduct.setBrands((String) product.get("brands"));
            offProduct.setImageUrl((String) product.get("image_url"));

            String nutritionGrades = (String) product.get("nutrition_grades");
            if (nutritionGrades == null) {
                nutritionGrades = (String) product.get("nutrition_grade");
            }
            offProduct.setNutritionGrades(nutritionGrades);

            @SuppressWarnings("unchecked")
            Map<String, Object> nutriments = (Map<String, Object>) product.get("nutriments");
            if (nutriments != null) {
                offProduct.setNutriments(nutriments);
            } else {
                // Try to extract basic nutrient values
                Map<String, Object> basicNutrients = new HashMap<>();
                if (product.containsKey("energy_value")) {
                    basicNutrients.put("energy", product.get("energy_value"));
                }
                if (product.containsKey("carbohydrates_value")) {
                    basicNutrients.put("carbs", product.get("carbohydrates_value"));
                }
                if (product.containsKey("proteins_value")) {
                    basicNutrients.put("protein", product.get("proteins_value"));
                }
                if (product.containsKey("fat_value")) {
                    basicNutrients.put("fat", product.get("fat_value"));
                }
                if (!basicNutrients.isEmpty()) {
                    offProduct.setNutriments(basicNutrients);
                }
            }

            response.setProduct(offProduct);
            return response;

        } catch (Exception e) {
            log.warn("Error converting product: {}", e.getMessage(), e);
            return null;
        }
    }
}

