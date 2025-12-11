# Simple test for meal creation
$ErrorActionPreference = "Stop"

$body = @{
    email = "ahmed@example.com"
    password = "Password123"
} | ConvertTo-Json

$login = Invoke-RestMethod -Uri "http://localhost:8082/api/auth/login" -Method POST -ContentType "application/json" -Body $body
Write-Output "Token: $($login.token.Substring(0,20))..."

$headers = @{
    "Authorization" = "Bearer $($login.token)"
    "Content-Type" = "application/json"
}

# Create meal
$mealBody = @{
    date = "2025-12-10"
    time = "15:00:00"
    mealType = "SNACK"
    items = @(
        @{
            foodName = "Apple"
            quantity = 150
            servingUnit = "g"
            calories = 78
            protein = 0.4
            carbs = 21
            fat = 0.2
        }
    )
} | ConvertTo-Json -Depth 3

Write-Output "Creating meal..."
try {
    $meal = Invoke-RestMethod -Uri "http://localhost:8082/api/meals" -Method POST -Headers $headers -Body $mealBody
    Write-Output "SUCCESS: Created meal ID=$($meal.id), Calories=$($meal.totalCalories)"
} catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    if ($_.ErrorDetails) {
        Write-Output "Details: $($_.ErrorDetails.Message)"
    }
}

