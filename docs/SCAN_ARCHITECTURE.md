# 🏗️ Architecture Technique NutriScan - Module Scan

## 📋 Vue d'Ensemble

Le module de scan NutriScan permet d'analyser les repas via plusieurs méthodes :

### Fonctionnalités Principales
1. **Scan de code-barres** - Utilise OpenFoodFacts API pour récupérer les informations produit
2. **Analyse de photo de repas** - Utilise Gemini Vision AI pour détecter et identifier les aliments
3. **Estimation nutritionnelle** - Calcule les valeurs nutritionnelles à partir des aliments détectés

---

## 🎨 Architecture Frontend (Flutter)

### Structure des Écrans
```
lib/screens/scanner/
├── scanner_hub_screen.dart       # Hub principal avec choix du mode de scan
├── barcode_scanner_screen.dart   # Scanner code-barres avec caméra
├── barcode_scan_result_screen.dart # Résultats du scan code-barres
├── meal_photo_scanner_screen.dart  # Capture/sélection photo repas
└── meal_analysis_result_screen.dart # Résultats de l'analyse IA
```

### Services
```dart
// lib/services/ai_service.dart
class AiService {
  // Scan un code-barres et retourne les infos produit
  Future<ScanBarcodeResponse> scanBarcode(String barcode);
  
  // Analyse une photo de repas avec l'IA Vision
  Future<MealPhotoAnalysisResponse> analyzeMealPhoto({
    required String imageBase64,
    String? mealType,
  });
}
```

### Modèles de Données
```dart
// lib/models/scan_result.dart
class ScanBarcodeResponse {
  final String productName;
  final String? brand;
  final String barcode;
  final String? nutriScore;    // A, B, C, D, E
  final String? ecoScore;      // A, B, C, D, E
  final NutritionInfo nutritionInfo;
  final bool isOrganic;
  final List<String> allergens;
  final String? ingredients;
}

class NutritionInfo {
  final double? calories;
  final double? proteins;
  final double? carbs;
  final double? fats;
  final double? sugars;
  final double? fiber;
  final double? sodium;
  final double? saturatedFats;
}
```

---

## 🔧 API Backend (Spring Boot)

### Endpoints du Scan

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/api/ai/scan-barcode?barcode={code}` | Scan rapide par code-barres |
| `POST` | `/api/ai/scan-barcode` | Scan par code-barres (body) |
| `POST` | `/api/ai/analyze/meal-photo` | Analyse photo de repas via IA |
| `GET` | `/api/ai/explain/daily?date={date}` | Explication IA journalière |

### Request/Response

#### Scan Code-Barres
```json
// GET /api/ai/scan-barcode?barcode=3017620422003
// Response: Format OpenFoodFacts
{
  "code": "3017620422003",
  "product": {
    "product_name": "Nutella",
    "brands": "Ferrero",
    "nutrition_grades": "e",
    "nutriments": {
      "energy-kcal_100g": 539,
      "proteins_100g": 6.3,
      "carbohydrates_100g": 57.5,
      "fat_100g": 30.9
    },
    "allergens_tags": ["en:milk", "en:nuts"],
    "ingredients_text": "..."
  }
}
```

#### Analyse Photo Repas
```json
// POST /api/ai/analyze/meal-photo
// Request
{
  "imageUrl": "data:image/jpeg;base64,/9j/4AAQ...",
  "mealType": "LUNCH"  // optionnel
}

// Response
{
  "detectedFoods": [
    {
      "name": "Salade César",
      "confidence": 85.0,
      "estimatedQuantityGrams": 250,
      "matchStatus": "AUTO_MATCHED",
      "suggestedFoodId": 123
    }
  ],
  "analysisText": "Ce repas contient une salade...",
  "confidenceScore": 85.0
}
```

---

## 🔄 Flux de Traitement

### Scan Code-Barres
```
┌─────────────┐     ┌─────────────────┐     ┌───────────────────┐
│   Flutter   │────>│  AIController   │────>│ OpenFoodFactsAPI  │
│  (Caméra)   │     │  /scan-barcode  │     │                   │
└─────────────┘     └─────────────────┘     └───────────────────┘
                              │
                              v
                    ┌─────────────────┐
                    │ Parse Response  │
                    │ (Frontend)      │
                    └─────────────────┘
```

### Analyse Photo Repas
```
┌─────────────┐     ┌─────────────────┐     ┌───────────────────┐
│   Flutter   │────>│  AIController   │────>│  VisionService    │
│(Photo/Galerie)    │/analyze/meal-photo    │  (Gemini API)     │
└─────────────┘     └─────────────────┘     └───────────────────┘
                              │
                              v
                    ┌─────────────────┐
                    │ DetectedFoods   │
                    │ + Estimation    │
                    └─────────────────┘
```

---

## 🎯 Design UI/UX

### Palette de Couleurs
- **Primaire**: Vert (#00C853) - Santé et fraîcheur
- **Secondaire**: Orange (#FF6F00) - Énergie et dynamisme  
- **Accent**: Violet (#7C4DFF) - Innovation IA
- **Background**: Dégradés sombres pour un look moderne

### Animations
- Ligne de scan animée sur le scanner
- Pulsation du cadre de scan
- Particules flottantes en arrière-plan
- Transitions fluides entre écrans

### Composants Clés
1. **Scanner Hub** - Interface de choix entre les modes
2. **Scan Overlay** - Cadre de scan avec coins stylisés
3. **Score Cards** - Affichage Nutri-Score/Eco-Score animé
4. **Nutrition Grid** - Grille des macronutriments colorée

---

## 📚 Dépendances

### Flutter
```yaml
dependencies:
  mobile_scanner: ^3.5.5    # Scan code-barres
  image_picker: ^1.0.7      # Sélection photo
  camera: ^0.10.5           # Accès caméra
  provider: ^6.1.2          # State management
```

### Backend
- Spring Boot 3.x
- Gemini API (Vision AI)
- OpenFoodFacts API
- Edamam API (optionnel)
