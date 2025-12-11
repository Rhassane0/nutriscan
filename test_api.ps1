# NutriScan API Tests
# Tests for Meal Planner and Scanning features

$BaseUrl = "http://localhost:8082/api"
$Email = "ahmed@example.com"
$Password = "Password123"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    NUTRISCAN API TESTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Login
Write-Host "Authenticating..." -ForegroundColor Yellow
try {
    $loginBody = @{ email = $Email; password = $Password } | ConvertTo-Json
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    $token = $loginResponse.token
    $headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
    Write-Host "[OK] Authenticated successfully" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    TEST 1: BARCODE SCANNING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1a: Scan Nutella barcode
Write-Host ""
Write-Host "1a. Scanning Nutella (3017620422003)..." -ForegroundColor Yellow
try {
    $scan = Invoke-RestMethod -Uri "$BaseUrl/ai/scan-barcode?barcode=3017620422003" -Method GET -Headers $headers
    Write-Host "[OK] Product: $($scan.product.productName)" -ForegroundColor Green
    Write-Host "     Brand: $($scan.product.brands)" -ForegroundColor White
    Write-Host "     Calories: $($scan.product.nutriments.'energy-kcal_100g') kcal/100g" -ForegroundColor White
    Write-Host "     Nutrition Grade: $($scan.product.nutritionGrades)" -ForegroundColor White
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

# Test 1b: Scan Coca-Cola barcode
Write-Host ""
Write-Host "1b. Scanning Coca-Cola (5449000000996)..." -ForegroundColor Yellow
try {
    $scan = Invoke-RestMethod -Uri "$BaseUrl/ai/scan-barcode?barcode=5449000000996" -Method GET -Headers $headers
    Write-Host "[OK] Product: $($scan.product.productName)" -ForegroundColor Green
    Write-Host "     Brand: $($scan.product.brands)" -ForegroundColor White
    Write-Host "     Calories: $($scan.product.nutriments.'energy-kcal_100g') kcal/100g" -ForegroundColor White
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    TEST 2: FOOD SEARCH" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 2: Search organic foods
Write-Host ""
Write-Host "2. Searching for 'chocolate' in OpenFoodFacts..." -ForegroundColor Yellow
try {
    $foods = Invoke-RestMethod -Uri "$BaseUrl/foods/search/organic?query=chocolate&limit=3" -Method GET -Headers $headers
    Write-Host "[OK] Found $($foods.Count) products" -ForegroundColor Green
    foreach ($f in $foods) {
        $name = if ($f.product.productName) { $f.product.productName } else { $f.product.product_name }
        Write-Host "     - $name ($($f.product.brands))" -ForegroundColor White
    }
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    TEST 3: RECIPE SEARCH" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 3: Search recipes
Write-Host ""
Write-Host "3. Searching recipes for 'pasta'..." -ForegroundColor Yellow
try {
    $recipes = Invoke-RestMethod -Uri "$BaseUrl/meal-planner/recipes/search?query=pasta&limit=3" -Method GET -Headers $headers
    Write-Host "[OK] Found $($recipes.Count) recipes" -ForegroundColor Green
    foreach ($r in $recipes) {
        Write-Host "     - $($r.label) ($([math]::Round($r.calories)) cal)" -ForegroundColor White
    }
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    TEST 4: MEAL PLAN MANAGEMENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 4a: Get latest meal plan
Write-Host ""
Write-Host "4a. Getting latest meal plan..." -ForegroundColor Yellow
try {
    $plan = Invoke-RestMethod -Uri "$BaseUrl/meal-planner/latest" -Method GET -Headers $headers
    Write-Host "[OK] Found plan ID=$($plan.id)" -ForegroundColor Green
    Write-Host "     Period: $($plan.startDate) to $($plan.endDate)" -ForegroundColor White
    Write-Host "     Meals: $($plan.meals.Count)" -ForegroundColor White
    Write-Host "     Total Calories: $($plan.totalCalories)" -ForegroundColor White
    $planId = $plan.id
} catch {
    Write-Host "[INFO] No meal plan found" -ForegroundColor Yellow
    $planId = $null
}

# Test 4b: Get all meal plans
Write-Host ""
Write-Host "4b. Getting all meal plans..." -ForegroundColor Yellow
try {
    $plans = Invoke-RestMethod -Uri "$BaseUrl/meal-planner" -Method GET -Headers $headers
    Write-Host "[OK] Found $($plans.Count) plan(s)" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    TEST 5: CREATE MEAL FROM PLAN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 5: Create meal (simulating adding from meal plan)
Write-Host ""
Write-Host "5. Creating meal from plan..." -ForegroundColor Yellow
try {
    $today = Get-Date -Format "yyyy-MM-dd"
    $mealBody = @{
        date = $today
        time = "13:00:00"
        mealType = "LUNCH"
        items = @(
            @{
                foodName = "Test Recipe from Plan"
                quantity = 200
                servingUnit = "g"
                calories = 450
                protein = 22.5
                carbs = 56.25
                fat = 15
            }
        )
    } | ConvertTo-Json -Depth 3

    $meal = Invoke-RestMethod -Uri "$BaseUrl/meals" -Method POST -Headers $headers -Body $mealBody
    Write-Host "[OK] Created meal ID=$($meal.id)" -ForegroundColor Green
    Write-Host "     Date: $($meal.date), Type: $($meal.mealType)" -ForegroundColor White
    Write-Host "     Calories: $($meal.totalCalories)" -ForegroundColor White
    $mealId = $meal.id
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5b: Delete the test meal
if ($mealId) {
    Write-Host ""
    Write-Host "5b. Cleaning up test meal..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri "$BaseUrl/meals/$mealId" -Method DELETE -Headers $headers
        Write-Host "[OK] Test meal deleted" -ForegroundColor Green
    } catch {
        Write-Host "[INFO] Could not delete: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    TEST 6: DELETE MEAL PLAN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Get oldest plan to delete
Write-Host ""
Write-Host "6. Testing meal plan deletion..." -ForegroundColor Yellow
try {
    $plans = Invoke-RestMethod -Uri "$BaseUrl/meal-planner" -Method GET -Headers $headers
    if ($plans.Count -gt 1) {
        $oldestPlan = $plans | Sort-Object startDate | Select-Object -First 1
        Write-Host "   Deleting oldest plan (ID=$($oldestPlan.id))..." -ForegroundColor Yellow
        Invoke-RestMethod -Uri "$BaseUrl/meal-planner/$($oldestPlan.id)" -Method DELETE -Headers $headers
        Write-Host "[OK] Plan deleted successfully" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Only one plan exists, skipping deletion test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    ALL TESTS COMPLETED" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

