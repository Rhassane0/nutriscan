# 🍎 NutriScan - Nutrition Coach API

**Bienvenue dans NutriScan** - Une API backend pour une application mobile de coaching nutritionnel.

> 📱 **Frontend Flutter** (à développer)  
> 🔌 **Backend Spring Boot** (100% fonctionnel)  
> 📊 **Base de données** PostgreSQL  
> 🤖 **AI** Gemini + Edamam APIs

---

## ✨ État du Projet

```
✅ Backend API        : v1.1.0 PRÊT
✅ Endpoints          : 37+ endpoints fonctionnels
✅ Authentification   : JWT implémentée
✅ Meal Planner       : Nouveau v1.1.0 ⭐
✅ Grocery List       : Nouveau v1.1.0 ⭐
✅ Analyse            : Edamam intégrée
✅ Documentation      : Complète
✅ Tests Postman      : 37 requêtes avec tests auto ⭐
⏳ Frontend Flutter   : À développer
```

---

## 🚀 Démarrage Rapide

### Windows (PowerShell) ⭐
```powershell
# Démarrer le serveur
.\nutriscan-quick-start.ps1 -Command start

# Tester les endpoints (dans une autre fenêtre)
.\nutriscan-quick-start.ps1 -Command test

# Arrêter le serveur
.\nutriscan-quick-start.ps1 -Command stop
```

### Linux/Mac (Bash)
```bash
# Démarrer le serveur
./nutriscan-quick-start.sh start

# Tester les endpoints
./nutriscan-quick-start.sh test

# Arrêter le serveur
./nutriscan-quick-start.sh stop
```

### Manual (Maven)
```bash
cd C:\Users\HP\OneDrive\Desktop\nutriscan
mvn spring-boot:run -DskipTests
```

**Le serveur sera disponible** : `http://localhost:8081`

---

## 📚 Documentation

### Pour les Développeurs Backend
- 📖 **[MODIFICATIONS_SUMMARY.md](MODIFICATIONS_SUMMARY.md)** - Résumé des changements
- 📖 **[EDAMAM_INTEGRATION_GUIDE.md](EDAMAM_INTEGRATION_GUIDE.md)** - Intégration Edamam
- 📖 **[FILES_OVERVIEW.md](FILES_OVERVIEW.md)** - Liste des fichiers modifiés/créés

### Pour les QA / Testeurs
- 🧪 **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Plan de test complet
- 📮 **[POSTMAN_V1.1.0_TESTING_GUIDE.md](POSTMAN_V1.1.0_TESTING_GUIDE.md)** - Guide Postman v1.1.0 ⭐ NOUVEAU
- 📋 **[POSTMAN_UPDATE_SUMMARY.md](POSTMAN_UPDATE_SUMMARY.md)** - Résumé tests v1.1.0 ⭐ NOUVEAU
- 📋 **[../POSTMAN_COMPLETE_TESTS.json](../POSTMAN_COMPLETE_TESTS.json)** - Collection Postman (37 requêtes)

### Pour l'Équipe Développement
- 🍽️ **[MEAL_PLANNER_GUIDE.md](MEAL_PLANNER_GUIDE.md)** - Guide Meal Planner v1.1.0 ⭐ NOUVEAU
- 📖 **[MODIFICATIONS_SUMMARY.md](MODIFICATIONS_SUMMARY.md)** - Résumé des changements
- 📖 **[EDAMAM_INTEGRATION_GUIDE.md](EDAMAM_INTEGRATION_GUIDE.md)** - Intégration Edamam
- 📖 **[FILES_OVERVIEW.md](FILES_OVERVIEW.md)** - Liste des fichiers modifiés/créés
- 📊 **[FINAL_STATUS_REPORT.md](FINAL_STATUS_REPORT.md)** - Vue d'ensemble globale
- 💡 **[RECOMMENDATIONS_AND_IMPROVEMENTS.md](RECOMMENDATIONS_AND_IMPROVEMENTS.md)** - Améliorations suggérées ⭐
- 📝 **[IMPROVEMENTS_SUMMARY.md](IMPROVEMENTS_SUMMARY.md)** - Résumé des améliorations apportées ⭐
- 📋 **[PROJECT_CHECKLIST.md](PROJECT_CHECKLIST.md)** - Checklist de progression ⭐
- 🚀 **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Guide de déploiement complet ⭐

### Fichiers à la Racine du Projet
- 📖 **[QUICK_START.md](../QUICK_START.md)** - Démarrage rapide (5 min) ⭐
- 📝 **[CHANGELOG.md](../CHANGELOG.md)** - Historique des versions ⭐
- 🤝 **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Guide de contribution ⭐

---

## 📋 Endpoints Disponibles

### 🔐 Authentification
```
POST   /api/v1/auth/register       - Créer un compte
POST   /api/v1/auth/login          - Se connecter
```

### 👤 Profil Utilisateur
```
GET    /api/v1/users/profile       - Récupérer le profil
PUT    /api/v1/users/profile       - Mettre à jour le profil
```

### 🎯 Objectifs
```
GET    /api/v1/goals               - Récupérer les objectifs
POST   /api/v1/goals               - Définir les objectifs
```

### 🍽️ Aliments & Repas
```
GET    /api/v1/nutrition/search    - Rechercher aliments (Edamam)
GET    /api/v1/foods/search        - Rechercher produits (OpenFoodFacts)
POST   /api/v1/meals               - Créer un repas
GET    /api/v1/meals               - Lister les repas
PUT    /api/v1/meals/{id}          - Modifier un repas
DELETE /api/v1/meals/{id}          - Supprimer un repas
```

### 📊 Analyse & Scores ⭐ **NOUVELLEMENT FIXÉ**
```
GET    /api/v1/analysis/meal-scores       - Scores des repas
GET    /api/v1/analysis/patterns          - Patterns nutritionnels
```

### ⚖️ Suivi du Poids
```
POST   /api/v1/tracking/weight           - Ajouter poids
GET    /api/v1/tracking/weight-history   - Historique poids
```

### 💡 Recommandations
```
GET    /api/v1/recommendations           - Recommandation du jour
GET    /api/v1/recommendations/history   - Historique
```

### 🤖 IA & Scans
```
POST   /api/v1/ai/scan-barcode           - Scanner code-barres
GET    /api/v1/ai/explain/daily          - Explication IA du jour
```

### 🍽️ Meal Planner ⭐ **v1.1.0 NOUVEAU**
```
GET    /api/v1/meal-planner/recipes/search  - Rechercher recettes
POST   /api/v1/meal-planner/generate        - Générer plan de repas
GET    /api/v1/meal-planner                 - Lister plans
GET    /api/v1/meal-planner/{id}            - Détails plan
DELETE /api/v1/meal-planner/{id}            - Supprimer plan
```

### 🛒 Grocery List ⭐ **v1.1.0 NOUVEAU**
```
POST   /api/v1/grocery-list/from-meal-plan/{id}  - Générer depuis plan
POST   /api/v1/grocery-list/from-dates           - Générer depuis dates
GET    /api/v1/grocery-list                      - Lister listes
GET    /api/v1/grocery-list/{id}                 - Détails liste
PATCH  /api/v1/grocery-list/{listId}/items/{id}  - Marquer acheté
DELETE /api/v1/grocery-list/{id}                 - Supprimer liste
```

---

## 🔧 Configuration

### Prérequis
- ✅ Java 17+
- ✅ Maven 3.8+
- ✅ PostgreSQL 12+
- ✅ Postman (optionnel, pour tester)

### Base de Données
```bash
# PostgreSQL doit être en cours d'exécution
psql -U postgres -c "CREATE DATABASE nutriscan_dev;"
```

### Variables d'Environnement
Dans `src/main/resources/application.properties` :

```properties
# Database
spring.datasource.url=jdbc:postgresql://localhost:5432/nutriscan_dev
spring.datasource.username=postgres
spring.datasource.password=root

# APIs externes
edamam.nutrition.app-id=2f1a97ee
edamam.nutrition.app-key=a142242e62efb0ad2b8f7ecfd48d81f5
gemini.api.key=your-key-here  # Optionnel

# JWT
jwt.secret=your-secret-key
```

---

## ✅ Récemment Corrigé

### Erreurs 500 (Résolues ✅)
```
❌ GET /api/v1/analysis/meal-scores?date=... → 500 Internal Error
❌ GET /api/v1/analysis/patterns → 500 Internal Error
```

### Solutions Appliquées
✅ Correction du repository MealRepository  
✅ Nettoyage du code NutritionPatternAnalysisService  
✅ Ajout de null safety complet  
✅ Intégration Edamam Nutrition Analysis API  

**Tous les endpoints sont maintenant 200 OK** ✅

---

## 🧪 Tester Rapidement

### Avec curl
```bash
# 1. Login
curl -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# 2. Récupérer le token (visible dans la réponse)

# 3. Récupérer les scores (avec le token)
curl -X GET "http://localhost:8081/api/v1/analysis/meal-scores?date=2025-11-28" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Avec Postman
1. Importer : `POSTMAN_COMPLETE_TESTS.json`
2. Configurer les variables : `BASE_URL`, `token`
3. Exécuter les requêtes dans l'ordre

### Avec les Scripts
```powershell
# Windows
.\nutriscan-quick-start.ps1 -Command test
```

---

## 📝 Modèle de Donnée Principal

### Meal (Repas)
```json
{
  "id": 1,
  "date": "2025-11-28",
  "time": "12:30:00",
  "mealType": "LUNCH",
  "source": "MANUAL",
  "totalCalories": 450.5,
  "totalProtein": 25.3,
  "totalCarbs": 50.1,
  "totalFat": 15.2,
  "items": [
    {
      "foodName": "apple raw",
      "quantity": 100,
      "servingUnit": "g",
      "calories": 52,
      "protein": 0.26,
      "carbs": 13.81,
      "fat": 0.17
    }
  ]
}
```

### Meal Score (Analyse)
```json
{
  "mealType": "LUNCH",
  "time": "12:30:00",
  "score": 85.5,
  "caloriesActual": 450.5,
  "caloriesTarget": 500,
  "proteinActual": 25.3,
  "proteinTarget": 30,
  "feedback": "✓ Calories correctes. ⚠ Protéines insuffisantes."
}
```

---

## 🎯 Roadmap

### ✅ Complété (v1.0)
- Authentification JWT
- Profil utilisateur
- Objectifs nutritionnels
- Création/modification repas
- Analyse des repas (Edamam)
- Détection de patterns
- Suivi du poids
- Recommandations

### ⏳ Prévu (v2.0)
- Recognition photo (Vision API)
- Explications IA (Gemini)
- Graphiques de progression
- Gamification & Défis
- Intégration Wearables

### 🔮 Futur (v3.0)
- Push notifications
- Export PDF/CSV
- Partage de repas
- Communauté

---

## 🐛 Dépannage

### Port 8080 déjà utilisé
```powershell
# Arrêter le processus
Get-Process java | Stop-Process -Force
```

### Base de données introuvable
```bash
# Créer la base de données
createdb -U postgres nutriscan_dev

# Ou depuis PostgreSQL shell
CREATE DATABASE nutriscan_dev;
```

### Edamam API indisponible
- Vérifier les clés API dans `application.properties`
- Le système utilise un fallback automatique
- Vérifier les logs du serveur

**Consultez [TESTING_GUIDE.md](TESTING_GUIDE.md) pour plus de solutions**

---

## 📞 Support

### Documentation
- 📖 [TESTING_GUIDE.md](TESTING_GUIDE.md) - Guide de test
- 📖 [EDAMAM_INTEGRATION_GUIDE.md](EDAMAM_INTEGRATION_GUIDE.md) - Intégration Edamam
- 📖 [FINAL_STATUS_REPORT.md](FINAL_STATUS_REPORT.md) - Vue d'ensemble

### Logs
```bash
# Voir les logs du serveur
tail -f logs/nutriscan.log
```

---

## 📄 Licence

Ce projet est développé à titre d'exemple éducatif.

---

## 🎉 Prêt à Commencer ?

```bash
# 1. Cloner/Télécharger le projet
cd C:\Users\HP\OneDrive\Desktop\nutriscan

# 2. Démarrer le serveur
mvn spring-boot:run -DskipTests

# 3. Importer Postman
# POSTMAN_COMPLETE_TESTS.json

# 4. Lancer les tests
# .\nutriscan-quick-start.ps1 -Command test

# 5. Consulter la documentation
# FINAL_STATUS_REPORT.md
```

**Bienvenue à bord !** 🚀

---

**Version** : 1.0.0  
**Date** : 28 novembre 2025  
**Status** : ✅ Production-Ready

