# NutriScan - Démarrage Flutter Web
# Ce script lance l'application Flutter en mode web avec le renderer HTML
# Le renderer HTML supporte mieux les emojis que CanvasKit

Write-Host "🥗 Démarrage de NutriScan Web..." -ForegroundColor Green
Write-Host ""

# Vérifier si flutter est disponible
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "❌ Flutter n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Récupération des dépendances..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "🌐 Lancement de l'application web..." -ForegroundColor Cyan
Write-Host "   Renderer: HTML (meilleur support des emojis)" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:8080" -ForegroundColor Yellow
Write-Host ""

# Lancer Flutter Web avec le renderer HTML pour le support des emojis
flutter run -d chrome --web-renderer html

Write-Host ""
Write-Host "✅ Application arrêtée" -ForegroundColor Green

