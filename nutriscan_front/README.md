# 🥗 NutriScan - Application Mobile Flutter

> Application mobile de scan nutritionnel et planification de repas

![Flutter](https://img.shields.io/badge/Flutter-3.5.4+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Material](https://img.shields.io/badge/Material-3-6200EE)
![Version](https://img.shields.io/badge/version-1.2.1-green)

## ✨ Fonctionnalités

### Disponibles
- 📱 **Scanner de codes-barres** - Scan instantané (mobile uniquement)
- 🍽️ **Gestion des repas** - Suivi quotidien de votre alimentation
- 📅 **Planificateur intelligent** - Génération automatique de plans de repas
- 🛒 **Listes de courses** - Création automatique depuis vos plans ✅ v1.2.1
- 🔍 **Recherche de recettes** - Filtres avancés et détails nutritionnels ⭐ NOUVEAU
- ⚖️ **Suivi du poids** - Graphiques et statistiques d'évolution ⭐ NOUVEAU
- 📊 **Statistiques nutritionnelles** - Suivi calories et macronutriments
- 🎨 **Interface moderne** - Design Material 3 épuré

## 🚀 Démarrage Rapide

### Option 1: Script automatique (Recommandé)
```powershell
.\start-nutriscan-flutter.ps1
```

### Option 2: Manuel
```bash
# Installer les dépendances
flutter pub get

# Lancer sur web
flutter run -d chrome --web-port=8080

# Lancer sur mobile
flutter run
```

### Identifiants de test
- **Email**: `ahmed@example.com`
- **Mot de passe**: `Password123`

## 📖 Documentation

- 📖 [Guide de Démarrage Rapide](GUIDE_DEMARRAGE_RAPIDE.md) - Utilisation complète ⭐ NOUVEAU
- 🎯 [Corrections v1.2.0](CORRECTIONS_FONCTIONNALITES.md) - Changelog détaillé ⭐ NOUVEAU
- 🔧 [Corrections v1.2.1](CORRECTIONS_v1.2.1.md) - Corrections backend ⭐ NOUVEAU
- 📋 [Résumé Final v1.2.1](FINAL_SUMMARY_v1.2.1.md) - Vue d'ensemble complète ⭐ NOUVEAU
- 📚 [Documentation Complète](docs/COMPLETE_GUIDE.md) - Guide exhaustif
- 🎨 [Guide UI](docs/UI_COMPONENTS_GUIDE.md) - Composants et design system
- ✅ [État Final](docs/FINAL_STATUS.md) - Résumé des corrections

## 🏗️ Architecture

```
lib/
├── config/           # Configuration et thème
├── models/          # Modèles de données
├── services/        # Services API
├── providers/       # Gestion d'état (Provider)
├── screens/         # Écrans de l'application
├── widgets/         # Composants réutilisables
└── utils/           # Utilitaires
```

## 🎨 Design System

### Couleurs
- **Primaire**: Vert #00C853
- **Secondaire**: Orange #FF6F00
- **Accent**: Violet #7C4DFF

### Typographie
- **Police**: Poppins (Google Fonts)
- **Styles**: Material Design 3

## 🛠️ Technologies

- **Framework**: Flutter 3.0+
- **Langage**: Dart 3.0+
- **State Management**: Provider
- **HTTP**: http package
- **Scanner**: mobile_scanner
- **Fonts**: google_fonts

## 📱 Écrans Principaux

1. **Authentification** - Login/Register
2. **Dashboard** - Vue d'ensemble quotidienne
3. **Scanner** - Scan de codes-barres
4. **Repas** - Gestion des repas
5. **Planificateur** - Plans hebdomadaires
6. **Profil** - Paramètres utilisateur

## 🔧 Commandes Utiles

```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Nettoyer le projet
flutter clean

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📦 Dépendances

```yaml
dependencies:
  provider: ^6.0.0
  http: ^1.1.0
  shared_preferences: ^2.2.0
  google_fonts: ^6.1.0
  mobile_scanner: ^3.5.0
  intl: ^0.18.0
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

## 📄 License

MIT License - voir [LICENSE](LICENSE)

## 👥 Équipe

Développé avec ❤️ par l'équipe NutriScan

---

**Version**: 1.0.0 | **Statut**: ✅ Production Ready
