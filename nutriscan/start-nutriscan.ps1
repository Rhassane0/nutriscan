# Script de démarrage NutriScan sur port 8082
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Demarrage NutriScan sur port 8082" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier PostgreSQL
Write-Host "Verification PostgreSQL..." -ForegroundColor Yellow
$pgService = Get-Service postgresql* -ErrorAction SilentlyContinue
if ($pgService) {
    if ($pgService.Status -ne 'Running') {
        Write-Host "PostgreSQL arrete. Demarrage..." -ForegroundColor Yellow
        Start-Service $pgService.Name
        Start-Sleep -Seconds 3
    }
    Write-Host "PostgreSQL: OK" -ForegroundColor Green
} else {
    Write-Host "ATTENTION: PostgreSQL non trouve" -ForegroundColor Red
}

# Arrêter les processus Java existants
Write-Host ""
Write-Host "Nettoyage des processus Java..." -ForegroundColor Yellow
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Write-Host "Processus Java arretes" -ForegroundColor Green

# Vérifier que les ports sont libres
Write-Host ""
Write-Host "Verification du port 8082..." -ForegroundColor Yellow
$portUsed = netstat -ano | findstr :8082
if ($portUsed) {
    Write-Host "ERREUR: Port 8082 occupe!" -ForegroundColor Red
    Write-Host $portUsed
    exit 1
}
Write-Host "Port 8082: Libre" -ForegroundColor Green

# Démarrer l'application
Write-Host ""
Write-Host "Demarrage de l'application..." -ForegroundColor Yellow
Write-Host "URL: http://localhost:8082" -ForegroundColor Cyan
Write-Host ""

cd C:\Users\HP\OneDrive\Desktop\proj\nutriscan
java -jar target/nutriscan-0.0.1-SNAPSHOT.jar --server.port=8082

