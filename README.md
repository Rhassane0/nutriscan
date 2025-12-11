# 🥗 NutriScan - Application de Nutrition Intelligente

> Système complet de scan nutritionnel, planification de repas et analyse IA

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B)](https://flutter.dev)
[![Java](https://img.shields.io/badge/Java-17-orange)](https://www.oracle.com/java/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📋 Vue d'Ensemble

NutriScan est une application complète permettant de :
- 📱 Scanner des codes-barres de produits alimentaires
- 🔍 Analyser les informations nutritionnelles
- 🤖 Obtenir des recommandations IA personnalisées
- 📅 Planifier ses repas de façon intelligente
- 🛒 Générer des listes de courses automatiques
- 📊 Suivre ses apports nutritionnels quotidiens

## 🏗️ Architecture

Le projet est composé de deux parties principales :

### 🔧 Backend - Spring Boot (`nutriscan/`)
API REST Java avec Spring Boot, Spring Security, PostgreSQL

### 📱 Frontend - Flutter (`nutriscan_front/`)
Application mobile cross-platform (Android/iOS)

## 🚀 Démarrage Rapide

### Backend
```bash
cd nutriscan
./start-nutriscan.ps1
# ou
./mvnw spring-boot:run
```

### Frontend
```bash
cd nutriscan_front
flutter pub get
flutter run
```
flutter run
## 📚 Documentation

### Documentation Générale (`/docs`)
- 📖 [Guide Complet Flutter](docs/FLUTTER_FRONTEND_COMPLETE_GUIDE.md)
- ⚡ [Démarrage Rapide Flutter](docs/FLUTTER_QUICK_START.md)
- 🔧 [Configuration Flutter](docs/FLUTTER_SETUP_GUIDE.md)
- 📋 [Checklist Flutter](docs/FLUTTER_CHECKLIST.md)
- 🔌 [Référence API](docs/FLUTTER_API_REFERENCE.md)
- 🏗️ [Structure du Projet](docs/PROJECT_STRUCTURE.md)
- 📦 [Projet Complet](docs/FLUTTER_PROJECT_COMPLETE.md)

### Documentation Backend (`/nutriscan/docs`)
- 🚀 [Guide de Démarrage](nutriscan/START_HERE.md)
- 📘 [Guide de Déploiement](nutriscan/docs/DEPLOYMENT_GUIDE.md)
- 🧪 [Guide de Tests](nutriscan/docs/TESTING_GUIDE.md)
- 📮 [Tests Postman](nutriscan/docs/POSTMAN_TESTING_GUIDE.md)
- 🍽️ [Guide du Planificateur](nutriscan/docs/MEAL_PLANNER_GUIDE.md)
- 🔧 [Dépannage](nutriscan/docs/TROUBLESHOOTING_GUIDE.md)
- 🔄 [Changelog](nutriscan/CHANGELOG.md)

### Documentation Frontend (`/nutriscan_front/docs`)
- 📖 [Guide Complet](nutriscan_front/docs/COMPLETE_GUIDE.md)
- ⚡ [Démarrage Rapide](nutriscan_front/docs/QUICK_START.md)
- 🎨 [Guide des Composants UI](nutriscan_front/docs/UI_COMPONENTS_GUIDE.md)
- ✅ [État Final](nutriscan_front/docs/FINAL_STATUS.md)
- 🎯 [Résumé du Projet](nutriscan_front/docs/PROJECT_SUMMARY.md)
- 🎨 [Améliorations Design](nutriscan_front/docs/DESIGN_IMPROVEMENTS.md)
- 🔧 [Corrections Design](nutriscan_front/docs/DESIGN_FIXES_COMPLETE.md)
- 📊 [Rapport Final](nutriscan_front/docs/FINAL_REPORT.md)

## 🛠️ Technologies

### Backend
- **Framework**: Spring Boot 3.2.0
- **Langage**: Java 17
- **Base de données**: PostgreSQL
- **Sécurité**: Spring Security + JWT
- **API**: RESTful
- **ORM**: Spring Data JPA
- **Build**: Maven

### Frontend
- **Framework**: Flutter 3.0+
- **Langage**: Dart 3.0+
- **State Management**: Provider
- **HTTP**: http package
- **Scanner**: mobile_scanner
- **Design**: Material Design 3

## 📦 Structure du Projet

```
proj/
├── docs/                           # Documentation générale
│   ├── FLUTTER_*.md               # Guides Flutter
│   └── PROJECT_STRUCTURE.md       # Structure complète
│
├── nutriscan/                      # Backend Spring Boot
│   ├── src/                       # Code source Java
│   ├── docs/                      # Documentation backend
│   ├── pom.xml                    # Configuration Maven
│   └── start-nutriscan.ps1       # Script de démarrage
│
├── nutriscan_front/               # Frontend Flutter
│   ├── lib/                       # Code source Dart
│   ├── docs/                      # Documentation frontend
│   ├── assets/                    # Images et ressources
│   ├── pubspec.yaml              # Configuration Flutter
│   └── start-nutriscan-flutter.ps1
│
└── README.md                      # Ce fichier
```

## 🔑 Fonctionnalités Principales

### ✅ Authentification & Sécurité
- Inscription et connexion utilisateur
- JWT tokens avec refresh
- Gestion des rôles et permissions

### 📱 Scanner de Produits
- Scan de codes-barres
- Intégration Open Food Facts
- Informations nutritionnelles détaillées
- NutriScore et EcoScore

### 🍽️ Gestion des Repas
- Ajout/modification/suppression de repas
- Catégorisation (petit-déjeuner, déjeuner, dîner, collation)
- Statistiques nutritionnelles quotidiennes
- Historique des repas

### 📅 Planificateur Intelligent
- Génération automatique de plans hebdomadaires
- Personnalisation selon préférences alimentaires
- Gestion des allergies et restrictions
- Calculs nutritionnels automatiques

### 🛒 Listes de Courses
- Génération automatique depuis les plans de repas
- Organisation par catégories
- Marquage des articles achetés
- Partage de listes

### 🤖 Intelligence Artificielle
- Analyse nutritionnelle des produits
- Recommandations personnalisées
- Suggestions d'alternatives plus saines
- Prédictions basées sur l'historique

## 🔧 Configuration

### Variables d'Environnement Backend
```properties
# Base de données
spring.datasource.url=jdbc:postgresql://localhost:5432/nutriscan
spring.datasource.username=postgres
spring.datasource.password=your_password

# JWT
jwt.secret=your_secret_key
jwt.expiration=86400000
```

### Configuration Frontend
```dart
// lib/config/app_config.dart
static const String apiBaseUrl = 'http://localhost:8080/api';
```

## 🧪 Tests

### Backend
```bash
cd nutriscan
./mvnw test
```

### Frontend
```bash
cd nutriscan_front
flutter test
```

## 🚢 Déploiement

### Backend (Docker)
```bash
cd nutriscan
docker-compose up -d
```

### Frontend (APK)
```bash
cd nutriscan_front
flutter build apk --release
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](nutriscan/CONTRIBUTING.md) pour plus de détails.

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe

Développé avec ❤️ par l'équipe NutriScan

## 📞 Support

Pour toute question ou problème :
- 📧 Email: support@nutriscan.com
- 📚 Documentation: `/docs`
- 🐛 Issues: GitHub Issues

---

**Version**: 1.0.0  
**Dernière mise à jour**: 30 Novembre 2024  
**Statut**: ✅ Production Ready

## 🎯 Roadmap

- [ ] Application Web (React)
- [ ] Intégration avec montres connectées
- [ ] Mode hors-ligne complet
- [ ] Partage social
- [ ] Coaching nutritionnel IA avancé
- [ ] Reconnaissance d'images de plats

---

**Bon développement ! 🚀**

