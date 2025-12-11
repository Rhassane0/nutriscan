# RAPPORT DE PROJET - NutriScan

## Application Mobile Intelligente de Suivi Calorique & Recommandations Nutritionnelles

---

### Informations Générales

| | |
|---|---|
| **Établissement** | [Nom de l'établissement] |
| **Formation** | 5ème année Ingénierie Informatique |
| **Année académique** | 2024-2025 |
| **Durée du projet** | 2 mois |
| **Nombre d'étudiants** | 2 |

---

## Table des Matières

1. [Introduction](#1-introduction)
2. [Contexte et Problématique](#2-contexte-et-problématique)
3. [Objectifs du Projet](#3-objectifs-du-projet)
4. [État de l'Art](#4-état-de-lart)
5. [Conception et Architecture](#5-conception-et-architecture)
6. [Technologies Utilisées](#6-technologies-utilisées)
7. [Réalisation](#7-réalisation)
8. [Tests et Validation](#8-tests-et-validation)
9. [Résultats et Démonstration](#9-résultats-et-démonstration)
10. [Limites et Perspectives](#10-limites-et-perspectives)
11. [Conclusion](#11-conclusion)
12. [Annexes](#12-annexes)

---

## 1. Introduction

### 1.1 Présentation du Projet

NutriScan est une application mobile intelligente conçue pour accompagner les utilisateurs dans leur parcours de santé nutritionnelle. L'application combine des technologies modernes de développement mobile, des APIs de données nutritionnelles et l'intelligence artificielle pour offrir une solution complète de suivi calorique et de recommandations personnalisées.

### 1.2 Motivation

Dans un contexte où les problèmes liés à l'alimentation (obésité, malnutrition, troubles alimentaires) touchent une part croissante de la population, l'accès à des outils simples et fiables pour suivre son alimentation devient essentiel. NutriScan répond à ce besoin en proposant :

- Un suivi simple et rapide des repas via scan
- Des recommandations personnalisées basées sur le profil utilisateur
- Des visualisations claires des progrès
- Une génération automatique de plans alimentaires

### 1.3 Périmètre

Le projet couvre le développement complet d'une solution incluant :
- Une application mobile cross-platform (Android/iOS/Web)
- Un backend API REST sécurisé
- L'intégration de services d'IA et d'APIs externes
- Une base de données relationnelle

---

## 2. Contexte et Problématique

### 2.1 Contexte Général

La santé nutritionnelle est devenue un enjeu majeur de santé publique. Selon l'OMS :
- Plus de 1,9 milliard d'adultes sont en surpoids dans le monde
- L'obésité a triplé depuis 1975
- Les maladies liées à l'alimentation représentent un coût significatif pour les systèmes de santé

### 2.2 Besoins Identifiés

Les utilisateurs cibles (sportifs, personnes en perte de poids, soucieux de leur santé) expriment plusieurs besoins :

| Besoin | Description |
|--------|-------------|
| **Simplicité** | Suivi rapide sans saisie fastidieuse |
| **Précision** | Estimation fiable des apports nutritionnels |
| **Personnalisation** | Recommandations adaptées au profil |
| **Visualisation** | Suivi des progrès dans le temps |
| **Planification** | Aide à l'organisation des repas |

### 2.3 Problématique

> Comment concevoir une application mobile qui simplifie le suivi nutritionnel tout en offrant des recommandations personnalisées et fiables, en s'appuyant sur l'intelligence artificielle et des sources de données nutritionnelles validées ?

---

## 3. Objectifs du Projet

### 3.1 Objectifs Fonctionnels

| # | Objectif | Priorité |
|---|----------|----------|
| O1 | Permettre le scan de produits et repas | Haute |
| O2 | Calculer les apports nutritionnels | Haute |
| O3 | Générer des plans alimentaires personnalisés | Haute |
| O4 | Suivre l'évolution du poids et de l'IMC | Moyenne |
| O5 | Proposer des recommandations IA | Moyenne |
| O6 | Générer des listes de courses | Basse |

### 3.2 Objectifs Techniques

| # | Objectif |
|---|----------|
| T1 | Développer une application Flutter cross-platform |
| T2 | Concevoir une API REST avec Spring Boot |
| T3 | Intégrer Google Gemini pour l'analyse d'images |
| T4 | Intégrer OpenFoodFacts et Edamam |
| T5 | Implémenter une authentification JWT sécurisée |
| T6 | Créer une interface utilisateur moderne et intuitive |

### 3.3 Objectifs Pédagogiques

- Maîtriser le développement mobile avec Flutter
- Concevoir une architecture backend scalable
- Intégrer des services d'IA dans une application
- Appliquer les bonnes pratiques de sécurité
- Gérer un projet de développement complet

---

## 4. État de l'Art

### 4.1 Applications Existantes

| Application | Forces | Faiblesses |
|-------------|--------|------------|
| **MyFitnessPal** | Large base d'aliments, Communauté | Interface complexe, Freemium limité |
| **Yazio** | Interface épurée, Plans gratuits | Base d'aliments moins complète |
| **Lose It!** | Scan code-barres efficace | Anglais uniquement |
| **Lifesum** | Design moderne | Fonctionnalités premium payantes |
| **Cronometer** | Données nutritionnelles détaillées | Interface moins intuitive |

### 4.2 Technologies d'IA pour la Reconnaissance Alimentaire

| Technologie | Description | Précision |
|-------------|-------------|-----------|
| **Google Cloud Vision** | Détection d'objets générale | Moyenne |
| **Clarifai Food** | Spécialisé alimentation | Haute |
| **Google Gemini** | Modèle multimodal avancé | Haute |
| **Custom Models** | Modèles entraînés spécifiquement | Variable |

### 4.3 APIs Nutritionnelles

| API | Contenu | Couverture |
|-----|---------|------------|
| **OpenFoodFacts** | Produits emballés | Mondiale, Open Source |
| **USDA FoodData** | Aliments bruts | USA principalement |
| **Edamam** | Recettes + Nutrition | Internationale |
| **Nutritionix** | Complète | USA principalement |

### 4.4 Positionnement de NutriScan

NutriScan se différencie par :
- **Intégration IA avancée** : Utilisation de Google Gemini pour l'analyse d'images et les recommandations
- **Approche hybride** : Combinaison de scan code-barres et analyse photo
- **Planification intégrée** : Génération automatique de plans et listes de courses
- **Interface moderne** : Design épuré avec thème sombre

---

## 5. Conception et Architecture

### 5.1 Architecture Globale

```
┌───────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                    Flutter Application                               │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │  │
│  │  │  Auth   │ │  Home   │ │ Scanner │ │ Planner │ │ Profile │       │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │  │
│  │                              │                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────┐   │  │
│  │  │                      State Management                        │   │  │
│  │  │  AuthProvider │ MealProvider │ PlannerProvider │ ThemeProvider │  │
│  │  └─────────────────────────────────────────────────────────────┘   │  │
│  │                              │                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────┐   │  │
│  │  │                       API Service                            │   │  │
│  │  └─────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS / REST
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                              SERVER LAYER                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                    Spring Boot Application                           │  │
│  │                                                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────┐    │  │
│  │  │                      Controllers                             │    │  │
│  │  │  Auth │ User │ Meal │ AI │ Planner │ Grocery │ Tracking     │    │  │
│  │  └─────────────────────────────────────────────────────────────┘    │  │
│  │                              │                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────┐    │  │
│  │  │                       Services                               │    │  │
│  │  │  AuthService │ MealService │ AIService │ MealPlanService    │    │  │
│  │  │  OpenFoodFactsService │ EdamamService │ TrackingService     │    │  │
│  │  └─────────────────────────────────────────────────────────────┘    │  │
│  │                              │                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────┐    │  │
│  │  │                     Repositories                             │    │  │
│  │  │  UserRepository │ MealRepository │ MealPlanRepository       │    │  │
│  │  └─────────────────────────────────────────────────────────────┘    │  │
│  │                              │                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────┐    │  │
│  │  │                       Security                               │    │  │
│  │  │  JWT Filter │ Security Config │ Password Encoder            │    │  │
│  │  └─────────────────────────────────────────────────────────────┘    │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   PostgreSQL     │  │   Google Gemini  │  │   External APIs  │
│   Database       │  │   AI Service     │  │  OFF │ Edamam   │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

### 5.2 Modèle de Données (Diagramme de Classes UML)

Le diagramme de classes suivant décrit le noyau métier de l'application NutriScan. Il est présenté sous forme textuelle (notation UML) de manière académique.

**Classes principales :**

```text
+----------------------------------+
|            Utilisateur           |
+----------------------------------+
| - id: Long                       |
| - email: String                  |
| - motDePasseHash: String         |
| - nomComplet: String             |
| - genre: Genre                   |
| - age: int                       |
| - tailleCm: int                  |
| - poidsInitialKg: double         |
| - role: RoleUtilisateur          |
| - niveauActivite: NiveauActivite |
| - typeObjectif: TypeObjectif     |
| - preferencesAlimentaires: String|
| - allergies: String              |
| - dateCreation: LocalDateTime    |
+----------------------------------+
| +calculerBMR(): double           |
| +calculerTDEE(): double          |
| +getCibleCaloriesJour(): double  |
+----------------------------------+
```

```text
+-----------------------------+          1        0..*  +---------------------------+
|            Repas            |------------------------>|        ElementRepas       |
+-----------------------------+                         +---------------------------+
| - id: Long                  |                         | - id: Long                |
| - date: LocalDate           |                         | - alimentId: Long?        |
| - heure: LocalTime          |                         | - nomAliment: String      |
| - typeRepas: TypeRepas      |                         | - quantite: double        |
| - source: SourceRepas       |                         | - unite: String           |
| - totalCalories: double     |                         | - calories: double        |
| - totalProteines: double    |                         | - proteines: double       |
| - totalGlucides: double     |                         | - glucides: double        |
| - totalLipides: double      |                         | - lipides: double         |
+-----------------------------+                         +---------------------------+
| +calculerTotaux(): void     |
+-----------------------------+
            ^ 0..*                                   
            |                                         
            |                                         
          1 |                                         
+-----------------------------+
|          Utilisateur        |
+-----------------------------+
```

```text
+-----------------------------+        1        0..*  +---------------------------+
|        HistoriquePoids      |---------------------->|         Utilisateur       |
+-----------------------------+                       +---------------------------+
| - id: Long                  |
| - dateMesure: LocalDate     |
| - poidsKg: double           |
| - imc: double               |
+-----------------------------+
| +calculerIMC(): double      |
+-----------------------------+
```

```text
+-----------------------------+        1        0..*  +---------------------------+
|          PlanRepas          |---------------------->|         RepasPlanifie     |
+-----------------------------+                       +---------------------------+
| - id: Long                  |
| - dateDebut: LocalDate      |
| - dateFin: LocalDate        |
| - typePlan: TypePlan        |
| - typeRegime: String        |
| - caloriesCibleParJour: int |
+-----------------------------+
| +getRepasPourDate(d): List  |
+-----------------------------+

+-----------------------------+
|        ListeCourses         |
+-----------------------------+
| - id: Long                  |
| - dateCreation: LocalDate   |
| - nbArticles: int           |
+-----------------------------+

+-----------------------------+
|        ElementCourse        |
+-----------------------------+
| - id: Long                  |
| - nomIngredient: String     |
| - quantite: String          |
| - categorie: String         |
| - achete: boolean           |
+-----------------------------+
```

Les classes supplémentaires (par exemple `ScanResultat`, `Recette`, `AnalyseNutritionnelle`, etc.) sont définies dans le code de l'application et complètent ce noyau.

### 5.3 Diagrammes de Cas d’Utilisation (UML)

Les cas d’utilisation suivants sont décrits selon une forme académique. **Toutes les actions supposent que l’utilisateur est préalablement authentifié (connexion réussie)** sauf les cas « S’enregistrer » et « Se connecter ».

#### 5.3.1 Acteurs

- **Utilisateur** : personne utilisant l’application pour suivre son alimentation et son poids.
- **Système NutriScan** : application mobile + backend.

#### 5.3.2 Liste des cas d’utilisation principaux

1. UC01 – S’enregistrer
2. UC02 – Se connecter
3. UC03 – Gérer son profil
4. UC04 – Scanner un produit par code-barres
5. UC05 – Scanner un repas par photo
6. UC06 – Ajouter un repas consommé
7. UC07 – Consulter / modifier / supprimer un repas
8. UC08 – Générer un plan de repas
9. UC09 – Consulter / supprimer un plan de repas
10. UC10 – Ajouter un repas planifié au journal
11. UC11 – Générer une liste de courses
12. UC12 – Gérer la liste de courses (cocher / décocher)
13. UC13 – Ajouter une mesure de poids
14. UC14 – Consulter l’historique et les graphiques de poids
15. UC15 – Consulter l’analyse IA de progression
16. UC16 – Rechercher des recettes
17. UC17 – Consulter le détail d’une recette
18. UC18 – Ajouter une recette à un plan de repas
19. UC19 – Modifier les préférences (thème, langue)
20. UC20 – Se déconnecter

#### 5.3.3 Diagramme de cas d’utilisation global (texte UML)

```text
Acteur principal : Utilisateur

Use cases principaux :

- UC01 S’enregistrer
- UC02 Se connecter
- UC03 Gérer son profil
- UC04 Scanner un produit (code-barres)
- UC05 Scanner un repas (photo)
- UC06 Ajouter un repas consommé
- UC07 Gérer un repas (consulter / modifier / supprimer)
- UC08 Générer un plan de repas
- UC09 Gérer un plan de repas (consulter / supprimer)
- UC10 Ajouter un repas planifié au journal
- UC11 Générer une liste de courses
- UC12 Gérer la liste de courses
- UC13 Ajouter une mesure de poids
- UC14 Consulter l’historique et les graphiques de poids
- UC15 Consulter l’analyse IA de progression
- UC16 Rechercher des recettes
- UC17 Consulter le détail d’une recette
- UC18 Ajouter une recette à un plan de repas
- UC19 Modifier les préférences (thème, langue)
- UC20 Se déconnecter

Relations :

UC03, UC04, UC05, UC06, UC07, UC08, UC09, UC10, UC11, UC12, UC13, UC14, UC15,
UC16, UC17, UC18, UC19 et UC20 <<include>> UC02 (Se connecter).

UC08 (Générer un plan de repas) <<include>> UC16 (Rechercher des recettes).
UC09 (Gérer un plan de repas) <<include>> UC08 (Générer un plan de repas) [optionnel, selon scénario].
UC10 (Ajouter un repas planifié au journal) <<include>> UC06 (Ajouter un repas consommé).
UC11 (Générer une liste de courses) <<include>> UC08 (Générer un plan de repas).
UC14 (Consulter l’historique de poids) <<include>> UC13 (Ajouter une mesure de poids).
UC15 (Consulter l’analyse IA de progression) <<include>> UC14 (Consulter l’historique de poids).
UC17 (Consulter le détail d’une recette) <<include>> UC16 (Rechercher des recettes).
UC18 (Ajouter une recette à un plan de repas) <<include>> UC17 (Consulter le détail d’une recette).
```

#### 5.3.4 Fiches de cas d’utilisation détaillées (exemples)

**UC02 – Se connecter**

- **Acteur principal** : Utilisateur
- **Pré-condition** : L’utilisateur possède déjà un compte (créé via UC01).
- **Post-condition** : L’utilisateur est authentifié, un jeton (token) est généré et stocké côté client.
- **Scénario nominal :**
  1. L’utilisateur saisit son email et son mot de passe.
  2. Le système vérifie les identifiants.
  3. En cas de succès, le système génère un token JWT et le retourne au client.
  4. L’utilisateur est redirigé vers l’écran d’accueil (dashboard).
- **Extensions :**
  - 2a. Identifiants incorrects : le système affiche un message d’erreur et propose de réessayer ou de réinitialiser le mot de passe.

---

**UC04 – Scanner un produit (code-barres)**

- **Acteur principal** : Utilisateur
- **Pré-conditions** :
  - L’utilisateur est connecté (UC02).
  - La caméra de l’appareil est disponible.
- **Post-condition** : Les informations détaillées du produit (valeurs nutritionnelles, scores, ingrédients) sont affichées.
- **Scénario nominal :**
  1. L’utilisateur ouvre l’interface de scan de produit.
  2. L’utilisateur pointe la caméra vers le code-barres du produit.
  3. Le système détecte automatiquement le code-barres.
  4. Le système interroge l’API OpenFoodFacts avec le code-barres.
  5. Le système reçoit les informations du produit (nouveau ou déjà connu).
  6. Le système calcule un score de santé et prépare la synthèse nutritionnelle.
  7. Le système affiche les informations détaillées au sein de l’interface (valeurs par portion, Nutri-Score, Eco-Score, NOVA, allergènes, additifs, recommandations).
- **Extensions :**
  - 4a. Le produit n’est pas trouvé : le système propose à l’utilisateur d’encoder manuellement les informations principales.

---

**UC08 – Générer un plan de repas**

- **Acteur principal** : Utilisateur
- **Pré-conditions** :
  - L’utilisateur est connecté (UC02).
  - Le profil (poids, taille, objectif, niveau d’activité) est renseigné (UC03).
- **Post-condition** : Un plan de repas personnalisé est créé et enregistré pour une période donnée.
- **Scénario nominal :**
  1. L’utilisateur ouvre l’interface de planification.
  2. L’utilisateur renseigne la période (date début / date fin) et d’éventuels paramètres (type de régime, calories cibles, allergies).
  3. Le système calcule la cible calorique quotidienne à partir du profil utilisateur.
  4. Le système interroge l’API Edamam pour rechercher des recettes compatibles (<<include>> UC16).
  5. Le système sélectionne et compose un ensemble de repas équilibrés pour chaque jour de la période.
  6. Le système enregistre le plan de repas en base de données.
  7. Le système affiche le plan (jours, repas, détails principaux) dans l’interface.
- **Extensions :**
  - 4a. Aucune recette trouvée avec les critères : le système propose d’assouplir les filtres (calories, type de régime, mots-clés).

---

**UC10 – Ajouter un repas planifié au journal**

- **Acteur principal** : Utilisateur
- **Pré-conditions** :
  - L’utilisateur est connecté (UC02).
  - Un plan de repas existe déjà (UC08).
- **Post-condition** : Le repas planifié sélectionné est ajouté aux repas consommés de l’utilisateur, de manière à être pris en compte dans le suivi calorique.
- **Scénario nominal :**
  1. L’utilisateur ouvre l’interface de plan de repas.
  2. L’utilisateur sélectionne un repas planifié pour un jour donné.
  3. L’utilisateur choisit l’option « Ajouter au journal ».
  4. Le système crée un nouveau repas consommé (repas réel) à partir des informations du repas planifié (<<include>> UC06).
  5. Le système recalcule les totaux journaliers (calories, macros) et met à jour le dashboard.
- **Extensions :**
  - 4a. L’utilisateur modifie la portion avant d’ajouter : le système adapte les quantités et les valeurs nutritionnelles en conséquence.

---

**UC13 – Ajouter une mesure de poids**

- **Acteur principal** : Utilisateur
- **Pré-conditions** :
  - L’utilisateur est connecté (UC02).
- **Post-condition** : Une nouvelle entrée est ajoutée à l’historique de poids, avec recalcul de l’IMC.
- **Scénario nominal :**
  1. L’utilisateur ouvre l’écran de suivi du poids.
  2. L’utilisateur saisit son poids actuel.
  3. Le système enregistre la mesure avec la date du jour.
  4. Le système calcule l’IMC et éventuellement des indicateurs supplémentaires.
  5. Le système met à jour les graphiques et les analyses.

---

Ces descriptions de classes et de cas d’utilisation sont prêtes à être copiées dans un rapport académique ou exportées vers un outil UML (StarUML, Visual Paradigm, etc.) pour produire des diagrammes graphiques.
