package com.nutriscan.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
public class OffProductResponse {

    private String code;      // barcode
    private Integer status;

    @JsonProperty("status_verbose")
    private String statusVerbose;

    private OffProduct product;

    @Getter
    @Setter
    public static class OffProduct {
        @JsonProperty("product_name")
        private String productName;

        private String brands;

        @JsonProperty("image_url")
        private String imageUrl;

        @JsonProperty("nutrition_grades")
        private String nutritionGrades;

        private Map<String, Object> nutriments;
    }
}
