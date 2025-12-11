package com.nutriscan.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class ImportFoodsRequest {

    @NotEmpty
    private List<CreateFoodRequest> foods;

    private String source; // Default source if not specified in each food

    @NotBlank
    @Size(max = 100)
    private String importLabel; // For tracking purposes
}

