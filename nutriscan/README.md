# 🍎 NutriScan - Nutrition Coach API v1.1.4

[![Build Status](https://github.com/your-org/nutriscan/workflows/CI/badge.svg)](https://github.com/your-org/nutriscan/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.8-brightgreen.svg)](https://spring.io/projects/spring-boot)

Une API backend moderne pour une application mobile de coaching nutritionnel, conçue pour aider les utilisateurs à atteindre leurs objectifs de santé et de forme physique.

> **Version actuelle** : v1.1.4 (29 novembre 2025)  
> **Port** : 8082  
> **Status** : ✅ Production Ready

---

## 🆕 Nouveautés v1.1.4

- 🔧 **POST scan-barcode** - Support body JSON en plus de query param
- ✅ **GET /latest** - Retourne le dernier créé (tri corrigé)
- 📮 **Postman** - Section Recommendations supprimée (36 requêtes au lieu de 39)

## 🆕 Nouveautés v1.1.3

- 🔧 **Erreur "2 results" corrigée** - Grocery List from dates fonctionne maintenant
- 🎯 **GET /latest endpoints** - Récupération automatique sans IDs
- ✨ **Meilleure UX** - Plus besoin de copier/coller les IDs
- 🛡️ **Gestion des meal plans qui se chevauchent** - Sélection automatique du plus récent

## 🆕 Nouveautés v1.1.1

- 🔧 **Système de Fallback** - 15 recettes statiques intégrées
- ✅ **Haute disponibilité** - Fonctionne sans clés API Edamam
- 🛡️ **Résilience** - Plus d'erreur 500 pour Search Recipes/Meal Planner
- 📦 **Out-of-the-box** - Application fonctionnelle immédiatement

## 🆕 Nouveautés v1.1.0

- ✨ **Meal Planner** - Planification automatique de repas
- 🛒 **Grocery List Generator** - Listes de courses automatiques
- 📮 **37 tests Postman** - Collection complète
- 🔧 **Code optimisé** - 0 erreurs de compilation

---

## ✨ Fonctionnalités

### 🎯 Gestion des Objectifs
- Calcul automatique des besoins caloriques (TDEE)
- Répartition des macronutriments personnalisée
- Suivi de la progression

### 🍽️ Journalisation des Repas
- Recherche d'aliments naturels via **Edamam API**
- Scanner de codes-barres avec **OpenFoodFacts**
- Calcul automatique des valeurs nutritionnelles
- Support des repas composés

### 🍴 Meal Planner ⭐ **v1.1.0**
- Planification automatique de repas (journaliers/hebdomadaires)
- Recherche de recettes par critères (calories, régime, cuisine)
- Distribution intelligente des calories (breakfast 25%, lunch 35%, dinner 30%, snack 10%)
- Support des restrictions alimentaires (vegan, gluten-free, low-carb, etc.)
- Intégration Edamam Recipe Search API

### 🛒 Grocery List Generator ⭐ **v1.1.0**
- Génération automatique de listes de courses
- Agrégation intelligente des ingrédients
- Catégorisation automatique (légumes, fruits, protéines, etc.)
- Gestion du statut "acheté/non acheté"
- Génération depuis un plan de repas ou une plage de dates
### 🛒 Grocery List Generator ⭐ **NOUVEAU**
- Génération automatique de liste de courses
- Agrégation intelligente des ingrédients
- Catégorisation automatique (légumes, fruits, protéines, etc.)
- Gestion du statut "acheté/non acheté"

### 📊 Analyse Nutritionnelle
- Scores quotidiens de qualité nutritionnelle
- Détection de patterns alimentaires
- Recommandations personnalisées
- Analyse détaillée avec IA (Gemini)

### ⚖️ Suivi du Poids
- Historique de poids avec calcul BMI
- Graphiques de progression
- Prédictions de tendance

### 🤖 Intelligence Artificielle
- Analyse de photos de repas
- Estimations nutritionnelles automatiques
- Recommandations contextuelles
- Coach virtuel conversationnel

---

## 🏗️ Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile/Web)   │
└────────┬────────┘
         │ REST API
         │
┌────────▼────────┐      ┌──────────────┐
│  Spring Boot    │◄────►│  PostgreSQL  │
│  Backend API    │      │   Database   │
└────────┬────────┘      └──────────────┘
         │
         ├──► Edamam API (Aliments)
         ├──► OpenFoodFacts (Produits)
         └──► Gemini AI (Analyse)
```

---

## 🚀 Démarrage Rapide

### Option 1 : Docker (Recommandé)

```bash
# Cloner le projet
git clone https://github.com/your-org/nutriscan.git
cd nutriscan

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos clés API

# Démarrer tous les services
docker-compose up -d

# Vérifier la santé
curl http://localhost:8082/actuator/health
```

### Option 2 : Maven Local

```bash
# Prérequis: Java 21, PostgreSQL en cours d'exécution

# Configurer la base de données
psql -U postgres -c "CREATE DATABASE nutriscan_dev;"

# Configurer application.properties
cp src/main/resources/application.properties.example src/main/resources/application.properties
# Éditer avec vos configurations

# Compiler et lancer
mvn clean install
mvn spring-boot:run
```

### Option 3 : Scripts de Démarrage Rapide

**Windows (PowerShell)** :
```powershell
.\nutriscan-quick-start.ps1 -Command start
```

**Linux/Mac (Bash)** :
```bash
./nutriscan-quick-start.sh start
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [README.md](docs/README.md) | Vue d'ensemble complète |
| [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) | Guide de déploiement |
| [FRONTEND_INTEGRATION_GUIDE.md](docs/FRONTEND_INTEGRATION_GUIDE.md) | Intégration frontend |
| [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) | Guide de tests |
| [RECOMMENDATIONS_AND_IMPROVEMENTS.md](docs/RECOMMENDATIONS_AND_IMPROVEMENTS.md) | Améliorations suggérées |
| [API_FIRST_COMPLETE.md](docs/API_FIRST_COMPLETE.md) | Architecture API-First |

---

## 🔌 Endpoints Principaux

### Authentification
```http
POST   /api/v1/auth/register       # Créer un compte
POST   /api/v1/auth/login          # Se connecter
```

### Repas
```http
GET    /api/v1/nutrition/search    # Rechercher aliments
POST   /api/v1/meals               # Créer un repas
GET    /api/v1/meals               # Lister les repas
GET    /api/v1/meals/summary       # Résumé quotidien
```

### Meal Planner ⭐ **NOUVEAU**
```http
GET    /api/v1/meal-planner/recipes/search  # Rechercher recettes
POST   /api/v1/meal-planner/generate        # Générer plan de repas
GET    /api/v1/meal-planner                 # Lister plans
DELETE /api/v1/meal-planner/{id}            # Supprimer plan
```

### Grocery List ⭐ **NOUVEAU**
```http
POST   /api/v1/grocery-list/from-meal-plan/{id}  # Générer depuis plan
POST   /api/v1/grocery-list/from-dates           # Générer depuis dates
GET    /api/v1/grocery-list                      # Lister listes
PATCH  /api/v1/grocery-list/{listId}/items/{id}  # Marquer acheté
```

### Analyse
```http
GET    /api/v1/analysis/meal-scores    # Scores des repas
GET    /api/v1/analysis/patterns       # Patterns nutritionnels
```

### IA
```http
POST   /api/v1/ai/scan-barcode         # Scanner code-barres
POST   /api/v1/ai/analyze-photo        # Analyser photo de repas
```

📖 **Documentation complète** : [Postman Collection](POSTMAN_COMPLETE_TESTS.json) ou `/swagger-ui.html` (quand l'app tourne)

---

## 🛠️ Stack Technique

### Backend
- **Framework** : Spring Boot 3.5.8
- **Langage** : Java 21
- **Sécurité** : Spring Security + JWT
- **Base de données** : PostgreSQL 15
- **Cache** : Redis / Caffeine
- **Migrations** : Flyway

### APIs Externes
- **Edamam** : Base de données alimentaires
- **OpenFoodFacts** : Produits packagés
- **Gemini 2.0** : Intelligence artificielle

### DevOps
- **Conteneurisation** : Docker + Docker Compose
- **CI/CD** : GitHub Actions
- **Monitoring** : Spring Boot Actuator + Prometheus
- **Logs** : SLF4J + Logback

---

## 🔧 Configuration

### Variables d'Environnement Essentielles

```env
# Base de données
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/nutriscan_dev
DB_PASSWORD=your_secure_password

# Sécurité
JWT_SECRET=your-256-bit-secret

# APIs
EDAMAM_NUTRITION_APP_ID=your_app_id
EDAMAM_NUTRITION_APP_KEY=your_app_key
GEMINI_API_KEY=your_gemini_key
```

Voir [.env.example](.env.example) pour la liste complète.

---

## 🧪 Tests

### Avec Postman
```bash
# Importer la collection
# Fichier: POSTMAN_COMPLETE_TESTS.json

# Configurer les variables:
# - BASE_URL: http://localhost:8082/api/v1
# - token: (obtenu après login)
```

### Avec curl
```bash
# Login
curl -X POST http://localhost:8082/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Créer un repas
curl -X POST http://localhost:8082/api/v1/meals \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d @meal-example.json
```

### Tests Automatisés
```bash
# Tests unitaires
mvn test

# Tests d'intégration
mvn verify

# Avec couverture
mvn test jacoco:report
```

---

## 📊 État du Projet

| Composant | Statut | Version |
|-----------|--------|---------|
| Backend API | ✅ Complet | 1.0 |
| Base de données | ✅ Prête | - |
| Authentification | ✅ Fonctionnelle | JWT |
| Intégrations API | ✅ Actives | Edamam, OFF |
| Documentation | ✅ Complète | 20+ docs |
| Tests | ⚠️ Basiques | En cours |
| Frontend Mobile | ⏳ Planifié | Flutter |
| Déploiement | ⏳ En cours | Heroku/AWS |

---

## 🗺️ Roadmap

### Phase 1 : MVP Backend ✅ (Terminé)
- [x] Architecture API-First
- [x] Authentification JWT
- [x] CRUD des repas
- [x] Intégration Edamam
- [x] Analyse nutritionnelle
- [x] Documentation complète

### Phase 2 : Frontend Mobile 🚧 (En cours)
- [ ] Application Flutter
- [ ] Intégration des endpoints
- [ ] UI/UX moderne
- [ ] Tests utilisateurs

### Phase 3 : Features Avancées 📅 (Planifié)
- [ ] Computer Vision (analyse photos)
- [ ] Gamification (badges, défis)
- [ ] Rapports PDF
- [ ] Notifications push
- [ ] Partage social

### Phase 4 : Production 🎯 (Q1 2026)
- [ ] Déploiement cloud
- [ ] CI/CD automatisé
- [ ] Monitoring complet
- [ ] Tests de charge
- [ ] App stores (iOS/Android)

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Conventions de Code
- Java : Google Java Style Guide
- Commits : Conventional Commits
- Branches : `feature/`, `bugfix/`, `hotfix/`

---

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Équipe

- **Backend** : Développement Spring Boot
- **Frontend** : À venir (Flutter)
- **DevOps** : CI/CD et infrastructure
- **QA** : Tests et qualité

---

## 📞 Contact

- **Email** : support@nutriscan.com
- **Website** : https://nutriscan.com
- **Documentation** : https://docs.nutriscan.com

---

## 🙏 Remerciements

- [Spring Boot](https://spring.io/projects/spring-boot) - Framework backend
- [Edamam](https://www.edamam.com/) - Base de données alimentaires
- [OpenFoodFacts](https://world.openfoodfacts.org/) - Données produits
- [Google Gemini](https://ai.google.dev/) - Intelligence artificielle

---

<p align="center">
  Fait avec ❤️ pour une meilleure santé nutritionnelle
</p>

<p align="center">
  <sub>NutriScan v1.0 - 2025</sub>
</p>

