Write-Host "=== Reconstruccion completa de Docker ===" -ForegroundColor Yellow

Write-Host "`n[1/6] Accediendo al directorio backend..." -ForegroundColor Green
cd .\backend\

Write-Host "`n[2/6] Ejecutando docker compose down -v..." -ForegroundColor Green
docker compose down -v

Write-Host "`n[3/6] Compilando con Maven..." -ForegroundColor Green
mvn clean package -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en la compilacion de Maven" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "`n[5/6] Reconstruyendo imagenes..." -ForegroundColor Green
docker compose build --no-cache

Write-Host "`n[6/6] Levantando containers..." -ForegroundColor Green
docker compose up -d --force-recreate

Write-Host "`nMostrando logs del backend (presiona Ctrl+C para salir)..." -ForegroundColor Yellow
docker compose logs -f backend