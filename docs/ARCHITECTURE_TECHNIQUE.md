# Architecture Technique - NutriScan

## 1. Vue d'Ensemble de l'Architecture

### 1.1 Architecture en Couches

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COUCHE PRÉSENTATION                                  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    Application Flutter                                  │ │
│  │                                                                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │ │
│  │  │   Screens    │  │   Widgets    │  │   Dialogs    │                 │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘                 │ │
│  │           │                │                │                          │ │
│  │           ▼                ▼                ▼                          │ │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │ │
│  │  │                    State Management (Providers)                  │  │ │
│  │  │  AuthProvider │ MealProvider │ PlannerProvider │ ThemeProvider  │  │ │
│  │  └─────────────────────────────────────────────────────────────────┘  │ │
│  │                              │                                         │ │
│  │                              ▼                                         │ │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │ │
│  │  │                      Services Layer                              │  │ │
│  │  │              ApiService │ AIService │ ScanService               │  │ │
│  │  └─────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTP/REST + JSON
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          COUCHE API GATEWAY                                  │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                     Spring Security Filter Chain                        │ │
│  │                                                                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │ │
│  │  │ CORS Filter  │─>│  JWT Filter  │─>│ Auth Filter  │                 │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘                 │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          COUCHE MÉTIER                                       │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         REST Controllers                                │ │
│  │                                                                         │ │
│  │  AuthController │ UserController │ MealController │ AIController      │ │
│  │  MealPlannerController │ GroceryListController │ TrackingController   │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      ▼                                       │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                          Business Services                              │ │
│  │                                                                         │ │
│  │  AuthService │ UserService │ MealService │ AIService                   │ │
│  │  MealPlanService │ GroceryListService │ TrackingService                │ │
│  │  OpenFoodFactsService │ EdamamRecipeService │ VisionService           │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          COUCHE DONNÉES                                      │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         Spring Data JPA                                 │ │
│  │                                                                         │ │
│  │  UserRepository │ MealRepository │ MealItemRepository                  │ │
│  │  MealPlanRepository │ PlannedMealRepository │ GroceryListRepository   │ │
│  │  WeightHistoryRepository │ DailyTargetsRepository                      │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      ▼                                       │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                           PostgreSQL                                    │ │
│  │                                                                         │ │
│  │  users │ meals │ meal_items │ meal_plans │ planned_meals              │ │
│  │  grocery_lists │ grocery_items │ weight_history │ daily_targets       │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Intégration des Services Externes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SERVICES EXTERNES                                     │
│                                                                              │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐ │
│  │    Google Gemini    │  │   OpenFoodFacts     │  │      Edamam         │ │
│  │                     │  │                     │  │                     │ │
│  │  ┌───────────────┐  │  │  ┌───────────────┐  │  │  ┌───────────────┐  │ │
│  │  │ Vision API    │  │  │  │ Product API   │  │  │  │ Recipe API    │  │ │
│  │  │ - Analyze img │  │  │  │ - Get by code │  │  │  │ - Search      │  │ │
│  │  │ - Detect food │  │  │  │ - Search      │  │  │  │ - Get details │  │ │
│  │  └───────────────┘  │  │  └───────────────┘  │  │  └───────────────┘  │ │
│  │  ┌───────────────┐  │  │                     │  │  ┌───────────────┐  │ │
│  │  │ Text API      │  │  │  Data returned:    │  │  │ Nutrition API │  │ │
│  │  │ - Generate    │  │  │  - Product name    │  │  │ - Analyze     │  │ │
│  │  │ - Recommend   │  │  │  - Nutrition       │  │  │ - Get macros  │  │ │
│  │  └───────────────┘  │  │  - Nutri-Score     │  │  └───────────────┘  │ │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘ │
│             │                       │                       │              │
│             └───────────────────────┼───────────────────────┘              │
│                                     │                                       │
│                                     ▼                                       │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                        Backend NutriScan                                │ │
│  │                                                                         │ │
│  │  ┌─────────────┐  ┌─────────────────┐  ┌─────────────────────────┐    │ │
│  │  │ AIService   │  │ OpenFoodFacts   │  │ EdamamRecipeService     │    │ │
│  │  │             │  │ Service         │  │                         │    │ │
│  │  └─────────────┘  └─────────────────┘  └─────────────────────────┘    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Diagrammes de Classes Détaillés

### 2.1 Module Utilisateur

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                    User                                     │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - email: String                                                             │
│ - password: String                                                          │
│ - fullName: String                                                          │
│ - gender: Gender                                                            │
│ - age: Integer                                                              │
│ - heightCm: Integer                                                         │
│ - initialWeightKg: Double                                                   │
│ - goalType: GoalType                                                        │
│ - activityLevel: ActivityLevel                                              │
│ - dietPreferences: String                                                   │
│ - allergies: String                                                         │
│ - role: String                                                              │
│ - createdAt: LocalDateTime                                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ + getActivityFactor(): Double                                               │
│ + getAllergiesList(): List<String>                                          │
│ + getDietPreferencesList(): List<String>                                    │
└────────────────────────────────────────────────────────────────────────────┘
                                     △
                                     │ uses
                                     │
┌────────────────────────────────────────────────────────────────────────────┐
│                               «service»                                     │
│                               UserService                                   │
├────────────────────────────────────────────────────────────────────────────┤
│ - userRepository: UserRepository                                            │
│ - passwordEncoder: PasswordEncoder                                          │
├────────────────────────────────────────────────────────────────────────────┤
│ + findByEmail(email: String): Optional<User>                                │
│ + updateProfile(userId: Long, request: UpdateProfileRequest): User          │
│ + changePassword(userId: Long, request: ChangePasswordRequest): void        │
│ + deleteAccount(userId: Long): void                                         │
└────────────────────────────────────────────────────────────────────────────┘

┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐
│     «enum»        │  │     «enum»        │  │     «enum»        │
│     Gender        │  │    GoalType       │  │  ActivityLevel    │
├───────────────────┤  ├───────────────────┤  ├───────────────────┤
│ MALE              │  │ LOSE_WEIGHT       │  │ SEDENTARY         │
│ FEMALE            │  │ MAINTAIN          │  │ LIGHTLY_ACTIVE    │
└───────────────────┘  │ GAIN_WEIGHT       │  │ MODERATELY_ACTIVE │
                       └───────────────────┘  │ VERY_ACTIVE       │
                                              │ EXTREMELY_ACTIVE  │
                                              └───────────────────┘
```

### 2.2 Module Repas

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                    Meal                                     │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - user: User                                                                │
│ - date: LocalDate                                                           │
│ - time: LocalTime                                                           │
│ - mealType: MealType                                                        │
│ - source: MealSource                                                        │
│ - items: List<MealItem>                                                     │
│ - totalCalories: Double                                                     │
│ - totalProtein: Double                                                      │
│ - totalCarbs: Double                                                        │
│ - totalFat: Double                                                          │
├────────────────────────────────────────────────────────────────────────────┤
│ + calculateTotals(): void                                                   │
│ + addItem(item: MealItem): void                                             │
│ + removeItem(itemId: Long): void                                            │
└────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ 1:N
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                  MealItem                                   │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - meal: Meal                                                                │
│ - foodId: Long                                                              │
│ - foodName: String                                                          │
│ - quantity: Double                                                          │
│ - servingUnit: String                                                       │
│ - calories: Double                                                          │
│ - protein: Double                                                           │
│ - carbs: Double                                                             │
│ - fat: Double                                                               │
├────────────────────────────────────────────────────────────────────────────┤
│ + calculateNutrition(): void                                                │
└────────────────────────────────────────────────────────────────────────────┘

┌───────────────────┐  ┌───────────────────┐
│     «enum»        │  │     «enum»        │
│    MealType       │  │   MealSource      │
├───────────────────┤  ├───────────────────┤
│ BREAKFAST         │  │ MANUAL            │
│ LUNCH             │  │ SCAN              │
│ DINNER            │  │ BARCODE           │
│ SNACK             │  │ AI_PHOTO          │
└───────────────────┘  │ MEAL_PLAN         │
                       └───────────────────┘
```

### 2.3 Module Planification

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                  MealPlan                                   │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - user: User                                                                │
│ - startDate: LocalDate                                                      │
│ - endDate: LocalDate                                                        │
│ - planType: PlanType                                                        │
│ - dietType: String                                                          │
│ - caloriesPerDay: Integer                                                   │
│ - meals: List<PlannedMeal>                                                  │
│ - createdAt: LocalDateTime                                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ + getTotalCalories(): Double                                                │
│ + getMealsForDate(date: LocalDate): List<PlannedMeal>                       │
│ + getNumberOfDays(): Integer                                                │
└────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ 1:N
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                PlannedMeal                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - mealPlan: MealPlan                                                        │
│ - date: LocalDate                                                           │
│ - mealType: MealType                                                        │
│ - recipeName: String                                                        │
│ - recipeUri: String                                                         │
│ - recipeImage: String                                                       │
│ - servings: Integer                                                         │
│ - calories: Double                                                          │
│ - protein: Double                                                           │
│ - carbs: Double                                                             │
│ - fat: Double                                                               │
│ - ingredients: List<String>                                                 │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│                               «service»                                     │
│                             MealPlanService                                 │
├────────────────────────────────────────────────────────────────────────────┤
│ - mealPlanRepository: MealPlanRepository                                    │
│ - edamamRecipeService: EdamamRecipeService                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ + generateMealPlan(request: GenerateMealPlanRequest): MealPlan              │
│ + getLatestMealPlan(userId: Long): Optional<MealPlan>                       │
│ + getMealPlans(userId: Long): List<MealPlan>                                │
│ + deleteMealPlan(planId: Long): void                                        │
│ + searchRecipes(query: String, diet: String, health: List): List<Recipe>    │
└────────────────────────────────────────────────────────────────────────────┘
```

### 2.4 Module Liste de Courses

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                GroceryList                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - user: User                                                                │
│ - name: String                                                              │
│ - createdAt: LocalDateTime                                                  │
│ - items: List<GroceryItem>                                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ + getTotalItems(): Integer                                                  │
│ + getPurchasedCount(): Integer                                              │
│ + getProgress(): Double                                                     │
└────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ 1:N
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                                  «entity»                                   │
│                                GroceryItem                                  │
├────────────────────────────────────────────────────────────────────────────┤
│ - id: Long                                                                  │
│ - groceryList: GroceryList                                                  │
│ - ingredientName: String                                                    │
│ - quantity: String                                                          │
│ - category: String                                                          │
│ - isPurchased: Boolean                                                      │
├────────────────────────────────────────────────────────────────────────────┤
│ + togglePurchased(): void                                                   │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Diagrammes de Séquence

### 3.1 Authentification

```
┌──────┐          ┌─────────┐          ┌─────────┐          ┌────────┐
│ User │          │ Flutter │          │ Backend │          │ DB     │
└──┬───┘          └────┬────┘          └────┬────┘          └───┬────┘
   │                   │                    │                   │
   │  Enter credentials│                    │                   │
   │──────────────────>│                    │                   │
   │                   │                    │                   │
   │                   │ POST /auth/login   │                   │
   │                   │───────────────────>│                   │
   │                   │                    │                   │
   │                   │                    │ Find user by email│
   │                   │                    │──────────────────>│
   │                   │                    │                   │
   │                   │                    │     User data     │
   │                   │                    │<──────────────────│
   │                   │                    │                   │
   │                   │                    │ Verify password   │
   │                   │                    │ Generate JWT      │
   │                   │                    │                   │
   │                   │   { token, user }  │                   │
   │                   │<───────────────────│                   │
   │                   │                    │                   │
   │                   │ Store token        │                   │
   │                   │ Update state       │                   │
   │                   │                    │                   │
   │  Navigate to home │                    │                   │
   │<──────────────────│                    │                   │
   │                   │                    │                   │
```

### 3.2 Scan Code-barres

```
┌──────┐    ┌─────────┐    ┌─────────┐    ┌────────────────┐    ┌────────┐
│ User │    │ Flutter │    │ Backend │    │ OpenFoodFacts  │    │ Gemini │
└──┬───┘    └────┬────┘    └────┬────┘    └───────┬────────┘    └───┬────┘
   │             │              │                  │                 │
   │ Scan barcode│              │                  │                 │
   │────────────>│              │                  │                 │
   │             │              │                  │                 │
   │             │ GET /scan-barcode?barcode=XXX   │                 │
   │             │─────────────>│                  │                 │
   │             │              │                  │                 │
   │             │              │ GET /product/XXX │                 │
   │             │              │─────────────────>│                 │
   │             │              │                  │                 │
   │             │              │   Product data   │                 │
   │             │              │<─────────────────│                 │
   │             │              │                  │                 │
   │             │              │ Analyze with AI (optional)         │
   │             │              │────────────────────────────────────>│
   │             │              │                  │                 │
   │             │              │           AI insights              │
   │             │              │<────────────────────────────────────│
   │             │              │                  │                 │
   │             │ { product, nutrition, scores }  │                 │
   │             │<─────────────│                  │                 │
   │             │              │                  │                 │
   │ Show results│              │                  │                 │
   │<────────────│              │                  │                 │
   │             │              │                  │                 │
```

### 3.3 Génération Plan Repas

```
┌──────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌────────┐
│ User │    │ Flutter │    │ Backend │    │ Edamam  │    │   DB   │
└──┬───┘    └────┬────┘    └────┬────┘    └────┬────┘    └───┬────┘
   │             │              │              │              │
   │ Configure   │              │              │              │
   │ plan params │              │              │              │
   │────────────>│              │              │              │
   │             │              │              │              │
   │             │ POST /meal-planner/generate │              │
   │             │─────────────>│              │              │
   │             │              │              │              │
   │             │              │ Loop: for each day & meal type      │
   │             │              │──────────────────────────────────── │
   │             │              │              │              │       │
   │             │              │ Search recipes│              │       │
   │             │              │─────────────>│              │       │
   │             │              │              │              │       │
   │             │              │  Recipes list│              │       │
   │             │              │<─────────────│              │       │
   │             │              │              │              │       │
   │             │              │ Select best match            │       │
   │             │              │──────────────────────────────────── │
   │             │              │              │              │
   │             │              │ Save meal plan│              │
   │             │              │─────────────────────────────>│
   │             │              │              │              │
   │             │              │         OK   │              │
   │             │              │<─────────────────────────────│
   │             │              │              │              │
   │             │  { mealPlan }│              │              │
   │             │<─────────────│              │              │
   │             │              │              │              │
   │ Show plan   │              │              │              │
   │<────────────│              │              │              │
   │             │              │              │              │
```

---

## 4. Diagramme de Déploiement

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ENVIRONNEMENT LOCAL                               │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         Poste Développeur                            │    │
│  │                                                                       │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐            │    │
│  │  │   Android     │  │    Chrome     │  │   iOS Sim     │            │    │
│  │  │   Emulator    │  │   (Web)       │  │  (optionnel)  │            │    │
│  │  │               │  │               │  │               │            │    │
│  │  │  Flutter App  │  │  Flutter Web  │  │  Flutter App  │            │    │
│  │  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘            │    │
│  │          │                  │                  │                     │    │
│  │          └──────────────────┼──────────────────┘                     │    │
│  │                             │                                         │    │
│  │                             │ HTTP :8082                              │    │
│  │                             ▼                                         │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │                    Spring Boot Server                          │  │    │
│  │  │                    localhost:8082                              │  │    │
│  │  │                                                                │  │    │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │  │    │
│  │  │  │   Auth   │  │   Meal   │  │    AI    │  │ Planner  │      │  │    │
│  │  │  │ Service  │  │ Service  │  │ Service  │  │ Service  │      │  │    │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘      │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  │                             │                                         │    │
│  │                             │ JDBC :5432                              │    │
│  │                             ▼                                         │    │
│  │  ┌───────────────────────────────────────────────────────────────┐  │    │
│  │  │                     PostgreSQL                                 │  │    │
│  │  │                   localhost:5432                               │  │    │
│  │  │                                                                │  │    │
│  │  │              Database: nutriscan                               │  │    │
│  │  └───────────────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SERVICES CLOUD                                     │
│                                                                              │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                   │
│  │ Google Cloud  │  │ OpenFoodFacts │  │    Edamam     │                   │
│  │    Gemini     │  │     API       │  │     API       │                   │
│  │               │  │               │  │               │                   │
│  │  AI Vision    │  │  Products DB  │  │  Recipes DB   │                   │
│  │  AI Text      │  │  (Open Data)  │  │  Nutrition    │                   │
│  └───────────────┘  └───────────────┘  └───────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Structure des Packages

### 5.1 Backend (Spring Boot)

```
com.nutriscan/
├── NutriscanApplication.java          # Point d'entrée
│
├── config/                             # Configuration
│   ├── SecurityConfig.java            # Spring Security
│   ├── CorsConfig.java                # CORS
│   ├── WebClientConfig.java           # HTTP Client
│   └── JwtConfig.java                 # JWT Settings
│
├── controller/                         # REST Controllers
│   ├── AuthController.java            # /api/auth/*
│   ├── UserController.java            # /api/user/*
│   ├── MealController.java            # /api/meals/*
│   ├── AIController.java              # /api/ai/*
│   ├── MealPlannerController.java     # /api/meal-planner/*
│   ├── GroceryListController.java     # /api/grocery-list/*
│   ├── TrackingController.java        # /api/tracking/*
│   └── FoodController.java            # /api/foods/*
│
├── dto/                                # Data Transfer Objects
│   ├── request/                        # Request DTOs
│   │   ├── LoginRequest.java
│   │   ├── RegisterRequest.java
│   │   ├── CreateMealRequest.java
│   │   └── GenerateMealPlanRequest.java
│   └── response/                       # Response DTOs
│       ├── AuthResponse.java
│       ├── MealResponse.java
│       └── MealPlanResponse.java
│
├── model/                              # Entités JPA
│   ├── User.java
│   ├── Meal.java
│   ├── MealItem.java
│   ├── MealPlan.java
│   ├── PlannedMeal.java
│   ├── GroceryList.java
│   ├── GroceryItem.java
│   ├── WeightHistory.java
│   ├── DailyTargets.java
│   └── enums/
│       ├── Gender.java
│       ├── GoalType.java
│       ├── ActivityLevel.java
│       ├── MealType.java
│       └── MealSource.java
│
├── repository/                         # Spring Data JPA
│   ├── UserRepository.java
│   ├── MealRepository.java
│   ├── MealItemRepository.java
│   ├── MealPlanRepository.java
│   └── ...
│
├── service/                            # Business Logic
│   ├── AuthService.java
│   ├── UserService.java
│   ├── MealService.java
│   ├── AIService.java
│   ├── MealPlanService.java
│   ├── GroceryListService.java
│   ├── TrackingService.java
│   ├── OpenFoodFactsService.java
│   ├── EdamamRecipeService.java
│   └── VisionService.java
│
├── security/                           # Security
│   ├── JwtTokenProvider.java
│   ├── JwtAuthenticationFilter.java
│   └── UserDetailsServiceImpl.java
│
├── exception/                          # Exception Handling
│   ├── GlobalExceptionHandler.java
│   ├── ResourceNotFoundException.java
│   └── UnauthorizedException.java
│
└── util/                               # Utilities
    ├── NutritionCalculator.java
    └── DateUtils.java
```

### 5.2 Frontend (Flutter)

```
lib/
├── main.dart                           # Point d'entrée
│
├── config/                             # Configuration
│   ├── app_config.dart                 # URLs, constantes
│   └── theme.dart                      # Thèmes clair/sombre
│
├── models/                             # Modèles de données
│   ├── user.dart
│   ├── meal.dart
│   ├── meal_plan.dart
│   ├── recipe.dart
│   ├── scan_result.dart
│   ├── grocery_list.dart
│   └── weight_entry.dart
│
├── providers/                          # State Management
│   ├── auth_provider.dart
│   ├── meal_provider.dart
│   ├── planner_provider.dart
│   ├── weight_tracking_provider.dart
│   └── theme_provider.dart
│
├── services/                           # API Services
│   ├── api_service.dart                # HTTP Client
│   └── ai_service.dart                 # AI endpoints
│
├── screens/                            # Écrans
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── scanner/
│   │   ├── scanner_hub_screen.dart
│   │   ├── barcode_scanner_screen.dart
│   │   ├── meal_photo_scanner_screen.dart
│   │   └── barcode_scan_result_screen.dart
│   ├── meals/
│   │   ├── meals_screen.dart
│   │   └── add_meal_screen.dart
│   ├── planner/
│   │   └── planner_screen.dart
│   ├── recipes/
│   │   └── recipe_search_screen.dart
│   ├── tracking/
│   │   └── weight_tracking_screen.dart
│   └── profile/
│       └── profile_screen.dart
│
├── widgets/                            # Composants réutilisables
│   ├── loading_indicator.dart
│   ├── nutrition_card.dart
│   └── meal_card.dart
│
└── utils/                              # Utilitaires
    ├── validators.dart
    └── formatters.dart
```

---

## 6. Sécurité

### 6.1 Flux d'Authentification JWT

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUX JWT                                           │
│                                                                              │
│  1. LOGIN                                                                    │
│  ┌──────────┐    { email, password }    ┌──────────┐                        │
│  │  Client  │ ───────────────────────> │  Server  │                         │
│  └──────────┘                           └──────────┘                         │
│       │                                      │                               │
│       │                                      │ Validate credentials          │
│       │                                      │ Generate JWT                  │
│       │                                      │                               │
│       │       { token, refreshToken }        │                               │
│       │ <─────────────────────────────────── │                               │
│       │                                      │                               │
│  2. STORE TOKEN                                                              │
│  ┌──────────┐                                                                │
│  │  Client  │ ─── Store in SharedPreferences                                │
│  └──────────┘                                                                │
│                                                                              │
│  3. API REQUESTS                                                             │
│  ┌──────────┐    Authorization: Bearer <token>    ┌──────────┐              │
│  │  Client  │ ───────────────────────────────── > │  Server  │              │
│  └──────────┘                                      └──────────┘              │
│       │                                                │                     │
│       │                                                │ Validate JWT        │
│       │                                                │ Extract user        │
│       │                                                │                     │
│       │              { response data }                 │                     │
│       │ <──────────────────────────────────────────── │                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Configuration Spring Security

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        return http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated())
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
```

---

*Document technique généré le : 10 Décembre 2025*

