# Script de démarrage NutriScan Frontend
# Version: 1.2.0

Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🥗 NutriScan Frontend - Démarrage" -ForegroundColor Green
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Vérifier que nous sommes dans le bon répertoire
$currentDir = Get-Location
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Erreur: Ce script doit être exécuté depuis le répertoire nutriscan_front" -ForegroundColor Red
    Write-Host "   Répertoire actuel: $currentDir" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Répertoire: $currentDir" -ForegroundColor Green
Write-Host ""

# Vérifier Flutter
Write-Host "🔍 Vérification de Flutter..." -ForegroundColor Cyan
$flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Flutter installé: $flutterVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Flutter n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "   Installez Flutter depuis: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Vérifier le backend
Write-Host "🔍 Vérification du backend..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -ErrorAction SilentlyContinue
    Write-Host "✓ Backend accessible sur http://localhost:8082" -ForegroundColor Green
} catch {
    Write-Host "⚠ Backend non accessible sur http://localhost:8082" -ForegroundColor Yellow
    Write-Host "  Assurez-vous que le backend est lancé avec:" -ForegroundColor Yellow
    Write-Host "  cd ..\nutriscan" -ForegroundColor White
    Write-Host "  .\start-nutriscan.ps1" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continuer quand même? (O/N)"
    if ($continue -ne "O" -and $continue -ne "o") {
        exit 0
    }
}
Write-Host ""

# Installer les dépendances
Write-Host "📦 Installation des dépendances..." -ForegroundColor Cyan
flutter pub get | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dépendances installées avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Choisir le mode de lancement
Write-Host "🚀 Mode de lancement:" -ForegroundColor Cyan
Write-Host "  1. Web (Chrome) - Port 8080" -ForegroundColor White
Write-Host "  2. Web (Edge) - Port 8080" -ForegroundColor White
Write-Host "  3. Android (si connecté)" -ForegroundColor White
Write-Host "  4. Analyse du code seulement" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Choisissez une option (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🌐 Lancement sur Chrome..." -ForegroundColor Green
        Write-Host "   URL: http://localhost:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Identifiants de test:" -ForegroundColor Yellow
        Write-Host "  Email: ahmed@example.com" -ForegroundColor White
        Write-Host "  Mot de passe: Password123" -ForegroundColor White
        Write-Host ""
        Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Gray
        Write-Host ""
        flutter run -d chrome --web-port=8080
    }
    "2" {
        Write-Host ""
        Write-Host "🌐 Lancement sur Edge..." -ForegroundColor Green
        Write-Host "   URL: http://localhost:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Identifiants de test:" -ForegroundColor Yellow
        Write-Host "  Email: ahmed@example.com" -ForegroundColor White
        Write-Host "  Mot de passe: Password123" -ForegroundColor White
        Write-Host ""
        Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Gray
        Write-Host ""
        flutter run -d edge --web-port=8080
    }
    "3" {
        Write-Host ""
        Write-Host "📱 Recherche de périphériques Android..." -ForegroundColor Green
        flutter devices
        Write-Host ""
        $deviceId = Read-Host "Entrez l'ID du périphérique (ou Entrée pour annuler)"
        if ($deviceId) {
            flutter run -d $deviceId
        }
    }
    "4" {
        Write-Host ""
        Write-Host "🔍 Analyse du code..." -ForegroundColor Green
        flutter analyze
        Write-Host ""
        Write-Host "✓ Analyse terminée" -ForegroundColor Green
    }
    default {
        Write-Host ""
        Write-Host "❌ Option invalide" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ✨ Merci d'utiliser NutriScan!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan

