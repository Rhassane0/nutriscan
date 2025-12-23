# Test script for NutriScan API
Write-Host "=== Test API NutriScan ===" -ForegroundColor Green

# Test 1: Health check
Write-Host "`nTest 1: Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/health" -TimeoutSec 5 -UseBasicParsing
    Write-Host "  Status: $($response.StatusCode) - OK" -ForegroundColor Green
} catch {
    Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Login pour obtenir token
Write-Host "`nTest 2: Login" -ForegroundColor Yellow
$loginBody = @{
    usernameOrEmail = "testuser"
    password = "Test@123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8082/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -TimeoutSec 10
    $token = $loginResponse.token
    Write-Host "  Login OK - Token: $($token.Substring(0, 20))..." -ForegroundColor Green

    # Test 3: Créer un repas
    Write-Host "`nTest 3: Créer un repas" -ForegroundColor Yellow
    $mealBody = @{
        date = (Get-Date -Format "yyyy-MM-dd")
        mealType = "LUNCH"
        source = "RECIPE_SEARCH"
        items = @(
            @{
                foodName = "Poulet grillé"
                apiSource = "EDAMAM"
                quantity = 100.0
                servingUnit = "g"
                calories = 165
                protein = 31
                carbs = 0
                fat = 3.6
            }
        )
    } | ConvertTo-Json -Depth 5

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    try {
        $mealResponse = Invoke-RestMethod -Uri "http://localhost:8082/api/meals" -Method Post -Body $mealBody -Headers $headers -TimeoutSec 10
        Write-Host "  Repas créé avec succès - ID: $($mealResponse.id)" -ForegroundColor Green
    } catch {
        Write-Host "  Erreur création repas: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Response: $responseBody" -ForegroundColor Red
        }
    }

} catch {
    Write-Host "  Erreur login: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Green

