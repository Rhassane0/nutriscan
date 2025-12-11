# Cahier des Charges - Version Finale

## Projet de Fin d'Année

### Application Mobile Intelligente de Suivi Calorique & Recommandations Nutritionnelles

**Nom du projet : NutriScan**

---

## 1. Contexte & Présentation

Dans un contexte où les utilisateurs (sportifs, pratiquants en salle, personnes souhaitant perdre du poids) recherchent des outils simples et fiables pour suivre leur alimentation, ce projet a développé une application mobile intelligente permettant :

- ✅ De scanner un repas (photo) ou un produit (code-barres)
- ✅ D'estimer les apports caloriques et macronutritionnels
- ✅ De proposer un programme alimentaire personnalisé
- ✅ De suivre l'évolution du poids et de l'IMC
- ✅ De fournir des recommandations d'amélioration des repas
- ✅ De générer des listes de courses automatiques
- ✅ De rechercher des recettes adaptées aux préférences

Le projet a été réalisé dans le cadre du projet de fin d'année en 5ème année d'ingénierie informatique, par une équipe de 2 étudiants sur une durée de 2 mois.

---

## 2. Objectifs Réalisés

### 2.1 Objectifs Fonctionnels Atteints

| # | Objectif | Statut |
|---|----------|--------|
| 1 | Scanner des repas et obtenir une estimation des calories et macronutriments | ✅ Réalisé |
| 2 | Générer un plan alimentaire personnalisé selon le profil | ✅ Réalisé |
| 3 | Analyser la qualité nutritionnelle des repas consommés | ✅ Réalisé |
| 4 | Assurer un suivi du poids et de l'IMC via graphiques | ✅ Réalisé |
| 5 | Intégrer une couche IA (Gemini) pour l'analyse d'images | ✅ Réalisé |
| 6 | Offrir une expérience utilisateur professionnelle avec thème sombre | ✅ Réalisé |

### 2.2 Objectifs Pédagogiques Atteints

- ✅ Architecture logicielle complète : Flutter + Spring Boot + PostgreSQL
- ✅ Intégration de modèles d'IA externes (Google Gemini)
- ✅ Intégration d'APIs externes (OpenFoodFacts, Edamam)
- ✅ Respect des bonnes pratiques : sécurité JWT, tests, documentation
- ✅ Conception d'une API REST complète et documentée

---

## 3. Périmètre Réalisé

### 3.1 Fonctionnalités Implémentées

#### 🔐 Authentification & Profil
- Inscription via email + mot de passe avec validation
- Authentification sécurisée avec JWT (JSON Web Token)
- Gestion complète du profil utilisateur :
  - Informations personnelles (âge, sexe, taille, poids)
  - Objectif (perte de poids, maintien, prise de masse)
  - Niveau d'activité physique
  - Préférences alimentaires (halal, végétarien, végan, etc.)
  - Allergies alimentaires

#### 📱 Scan & Ajout des Repas
- **Scan de code-barres** :
  - Intégration OpenFoodFacts (base mondiale de produits)
  - Affichage détaillé : Nutri-Score, Eco-Score, NOVA Score
  - Valeurs nutritionnelles complètes (macros, vitamines, minéraux)
  - Additifs, allergènes, ingrédients
- **Scan photo de repas** :
  - Analyse par Google Gemini AI
  - Estimation des aliments et portions
  - Calcul automatique des macronutriments
- **Ajout manuel** avec recherche dans la base alimentaire

#### 🍽️ Journal Alimentaire
- Historique des repas par jour
- 4 types de repas : Petit-déjeuner, Déjeuner, Dîner, Collation
- Modification et suppression des repas
- Calcul automatique des totaux journaliers
- Comparaison avec les objectifs personnalisés

#### 📊 Planificateur de Repas
- Génération automatique de plans hebdomadaires
- Personnalisation selon :
  - Type de régime (équilibré, low-carb, high-protein, etc.)
  - Allergies et restrictions
  - Objectif calorique journalier
- Ajout des repas planifiés au journal alimentaire
- Génération automatique de listes de courses

#### 🛒 Liste de Courses
- Génération depuis le plan de repas
- Génération depuis une plage de dates
- Gestion des items (achetés/non achetés)
- Organisation par catégories d'aliments

#### 📈 Suivi du Poids
- Enregistrement des pesées
- Calcul automatique de l'IMC
- Graphiques d'évolution
- Analyse de la tendance (perte, maintien, gain)
- Conseils personnalisés IA

#### 🔍 Recherche de Recettes
- Intégration API Edamam
- Filtres par régime alimentaire
- Filtres par restrictions de santé
- Détails nutritionnels complets
- Ingrédients et instructions

#### 🎨 Interface Utilisateur
- Design moderne et épuré
- Thème clair et thème sombre
- Animations fluides
- Interface responsive (mobile et web)
- Langue : Français

---

## 4. Architecture Technique Réalisée

### 4.1 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND                                  │
│                   Flutter (Dart)                                 │
│    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│    │  Screens │ │ Providers│ │ Services │ │  Models  │         │
│    └──────────┘ └──────────┘ └──────────┘ └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        BACKEND                                   │
│               Spring Boot 3.x (Java 17)                         │
│    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│    │Controllers│ │ Services │ │  Repos   │ │ Security │         │
│    └──────────┘ └──────────┘ └──────────┘ └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
          │              │              │
          ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  PostgreSQL  │ │   Gemini AI  │ │  APIs Ext.   │
│   Database   │ │   (Google)   │ │ OFF, Edamam  │
└──────────────┘ └──────────────┘ └──────────────┘
```

### 4.2 Stack Technologique

| Couche | Technologie | Version |
|--------|-------------|---------|
| **Frontend Mobile** | Flutter | 3.x |
| **Langage Frontend** | Dart | 3.x |
| **Backend** | Spring Boot | 3.x |
| **Langage Backend** | Java | 17 |
| **Base de données** | PostgreSQL | 15+ |
| **Sécurité** | Spring Security + JWT | - |
| **IA Vision** | Google Gemini API | 1.5 |
| **API Nutrition** | OpenFoodFacts | v2 |
| **API Recettes** | Edamam Recipe API | v2 |
| **Build Backend** | Maven | 3.9 |
| **Conteneurisation** | Docker | - |

### 4.3 APIs Externes Intégrées

| API | Usage | Fonctionnalités |
|-----|-------|-----------------|
| **Google Gemini** | IA/Vision | Analyse d'images de repas, génération de conseils |
| **OpenFoodFacts** | Produits | Scan code-barres, données nutritionnelles, Nutri-Score |
| **Edamam Recipe** | Recettes | Recherche recettes, filtres régimes, nutrition |
| **Edamam Nutrition** | Analyse | Analyse nutritionnelle des ingrédients |

---

## 5. Modèle de Données

### 5.1 Entités Principales

```
┌─────────────────────────────────────────────────────────────────┐
│                           USER                                   │
├─────────────────────────────────────────────────────────────────┤
│ id, email, password, fullName, gender, age, heightCm,          │
│ initialWeightKg, goalType, activityLevel, dietPreferences,      │
│ allergies, role, createdAt                                       │
└─────────────────────────────────────────────────────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│     MEAL        │  │  WEIGHT_HISTORY │  │   MEAL_PLAN     │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ id, userId,     │  │ id, userId,     │  │ id, userId,     │
│ date, time,     │  │ date, weightKg, │  │ startDate,      │
│ mealType,       │  │ bmi             │  │ endDate,        │
│ source          │  │                 │  │ planType,       │
│                 │  │                 │  │ dietType        │
└────────┬────────┘  └─────────────────┘  └────────┬────────┘
         │ 1:N                                     │ 1:N
         ▼                                         ▼
┌─────────────────┐                      ┌─────────────────┐
│   MEAL_ITEM     │                      │  PLANNED_MEAL   │
├─────────────────┤                      ├─────────────────┤
│ id, mealId,     │                      │ id, mealPlanId, │
│ foodName,       │                      │ date, mealType, │
│ quantity,       │                      │ recipeName,     │
│ calories,       │                      │ recipeUri,      │
│ protein, carbs, │                      │ servings,       │
│ fat             │                      │ calories        │
└─────────────────┘                      └─────────────────┘

┌─────────────────┐                      ┌─────────────────┐
│  GROCERY_LIST   │                      │  DAILY_TARGETS  │
├─────────────────┤                      ├─────────────────┤
│ id, userId,     │──1:N──▶│ GROCERY_   │ id, userId,     │
│ createdAt,      │        │ ITEM       │ date, calories, │
│ totalItems      │        │            │ protein, carbs, │
└─────────────────┘        └────────────┘ fat              │
                                         └─────────────────┘
```

### 5.2 Énumérations

```java
enum Gender { MALE, FEMALE }
enum GoalType { LOSE_WEIGHT, MAINTAIN, GAIN_WEIGHT }
enum ActivityLevel { SEDENTARY, LIGHTLY_ACTIVE, MODERATELY_ACTIVE, VERY_ACTIVE, EXTREMELY_ACTIVE }
enum MealType { BREAKFAST, LUNCH, DINNER, SNACK }
enum MealSource { MANUAL, SCAN, BARCODE, AI_PHOTO, MEAL_PLAN }
enum PlanType { DAILY, WEEKLY }
```

---

## 6. Endpoints API REST

### 6.1 Authentification (`/api/auth`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/register` | Inscription utilisateur |
| POST | `/login` | Connexion (retourne JWT) |

### 6.2 Utilisateur (`/api/user`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/profile` | Récupérer le profil |
| PUT | `/profile` | Mettre à jour le profil |
| PUT | `/password` | Changer le mot de passe |
| DELETE | `/account` | Supprimer le compte |

### 6.3 Repas (`/api/meals`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `?date=YYYY-MM-DD` | Repas du jour |
| POST | `/` | Créer un repas |
| PUT | `/{id}` | Modifier un repas |
| DELETE | `/{id}` | Supprimer un repas |

### 6.4 Scan & IA (`/api/ai`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/scan-barcode?barcode=XXX` | Scanner un code-barres |
| POST | `/analyze-meal` | Analyser une photo de repas |
| GET | `/daily-tips` | Conseils IA personnalisés |

### 6.5 Planificateur (`/api/meal-planner`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/` | Liste des plans |
| GET | `/latest` | Dernier plan |
| POST | `/generate` | Générer un plan |
| DELETE | `/{id}` | Supprimer un plan |
| GET | `/recipes/search` | Rechercher des recettes |

### 6.6 Liste de courses (`/api/grocery-list`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/latest` | Dernière liste |
| POST | `/from-meal-plan/{id}` | Depuis un plan |
| POST | `/from-dates` | Depuis des dates |
| PUT | `/items/{id}/toggle` | Marquer acheté |

### 6.7 Suivi (`/api/tracking`)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/weight/history` | Historique poids |
| POST | `/weight` | Ajouter une pesée |
| GET | `/weight/analysis` | Analyse IA |
| GET | `/daily-summary?date=X` | Résumé journalier |

---

## 7. Sécurité Implémentée

### 7.1 Authentification JWT

- Token JWT signé avec clé secrète
- Expiration configurable (24h par défaut)
- Refresh token non implémenté (perspective)

### 7.2 Protection des Endpoints

- Tous les endpoints (sauf auth) requièrent un token valide
- Vérification du propriétaire des ressources
- Hashage des mots de passe avec BCrypt

### 7.3 Bonnes Pratiques

- Validation des entrées utilisateur
- Gestion centralisée des erreurs
- Logs de sécurité
- Headers CORS configurés

---

## 8. Tests Réalisés

### 8.1 Tests Backend

| Type | Couverture | Outils |
|------|------------|--------|
| Tests unitaires | Services métier | JUnit 5, Mockito |
| Tests d'intégration | API REST | Spring Boot Test |
| Tests API | Endpoints | Postman |

### 8.2 Collection Postman

Une collection complète de tests Postman a été créée couvrant :
- Authentification (inscription, connexion)
- Gestion du profil
- CRUD des repas
- Scan code-barres et photos
- Génération de plans
- Suivi du poids

### 8.3 Tests Frontend

| Type | Couverture |
|------|------------|
| Tests widgets | Composants UI |
| Tests d'intégration | Flux utilisateur |

---

## 9. Limites & Perspectives

### 9.1 Limites Actuelles

| Limite | Description |
|--------|-------------|
| IA Vision | Précision variable selon la qualité de l'image |
| Plats complexes | Difficulté à estimer les portions exactes |
| Base locale | Pas de plats marocains spécifiques (utilise APIs externes) |
| Hors-ligne | Application nécessite une connexion internet |

### 9.2 Perspectives d'Évolution

| Fonctionnalité | Priorité |
|----------------|----------|
| Mode hors-ligne avec sync | Haute |
| Intégration Google Fit / Apple Health | Moyenne |
| Reconnaissance vocale | Moyenne |
| Base d'aliments locale enrichie | Haute |
| Notifications push | Haute |
| Export PDF des rapports | Moyenne |
| Multilingue (Arabe, Anglais) | Basse |
| Version iOS native | Basse |

---

## 10. Livrables

| # | Livrable | Description |
|---|----------|-------------|
| 1 | **Code source** | Frontend Flutter + Backend Spring Boot |
| 2 | **Documentation API** | Collection Postman + README |
| 3 | **Base de données** | Scripts SQL + Modèle de données |
| 4 | **Docker** | Dockerfile + docker-compose |
| 5 | **Tests** | Suite de tests Postman |
| 6 | **Rapport** | Document de présentation du projet |

---

## 11. Conclusion

Le projet NutriScan a atteint l'ensemble des objectifs fixés dans le cahier des charges initial, avec des fonctionnalités supplémentaires :

- ✅ Application mobile complète et fonctionnelle
- ✅ Backend robuste avec API REST
- ✅ Intégration réussie de l'IA (Google Gemini)
- ✅ Intégration d'APIs externes (OpenFoodFacts, Edamam)
- ✅ Interface utilisateur moderne avec thème sombre
- ✅ Fonctionnalités avancées (liste de courses, planificateur)

Le projet démontre une maîtrise des technologies modernes de développement mobile et backend, ainsi qu'une intégration réussie de services d'intelligence artificielle.

---

*Document mis à jour le : 10 Décembre 2025*

