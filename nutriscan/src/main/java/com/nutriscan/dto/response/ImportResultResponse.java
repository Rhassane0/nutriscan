package com.nutriscan.dto.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImportResultResponse {
    private int totalProcessed;
    private int successCount;
    private int errorCount;
    private String message;
    private java.util.List<String> errors;
}

