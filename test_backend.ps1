# Test script for NutriScan Backend
Write-Host "=== NutriScan Backend Test ===" -ForegroundColor Cyan

# Test 1: Check if server is running
Write-Host "`n1. Testing server connectivity..." -ForegroundColor Yellow
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("localhost", 8082)
    Write-Host "   OK - Server is listening on port 8082" -ForegroundColor Green
    $tcp.Close()
} catch {
    Write-Host "   FAILED - Server not responding on port 8082" -ForegroundColor Red
    exit 1
}

# Test 2: Test login endpoint
Write-Host "`n2. Testing login endpoint..." -ForegroundColor Yellow
$loginBody = '{"email":"ahmed@example.com","password":"Password123"}'
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8082/api/v1/auth/login" -Method POST -ContentType "application/json" -Body $loginBody -ErrorAction Stop
    Write-Host "   OK - Login successful" -ForegroundColor Green
    Write-Host "   Token: $($response.token.Substring(0,50))..." -ForegroundColor Gray
    $global:TOKEN = $response.token
} catch {
    Write-Host "   FAILED - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# Test 3: Test Gemini API directly
Write-Host "`n3. Testing Gemini API (gemma-3-27b)..." -ForegroundColor Yellow
$geminiUri = "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b:generateContent?key=AIzaSyBJu_hF8kOmnDnkaXLlq_7Qh492JYJZTPk"
$geminiBody = '{"contents":[{"parts":[{"text":"Say OK"}]}]}'
try {
    $geminiResp = Invoke-RestMethod -Uri $geminiUri -Method POST -ContentType "application/json" -Body $geminiBody -ErrorAction Stop
    Write-Host "   OK - Gemini API responding" -ForegroundColor Green
    $text = $geminiResp.candidates[0].content.parts[0].text
    Write-Host "   Response: $text" -ForegroundColor Gray
} catch {
    Write-Host "   FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan

