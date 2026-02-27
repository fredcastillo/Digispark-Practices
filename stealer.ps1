# ========== SCRIPT DE DIAGNÓSTICO EXTREMO ==========
# Escribe archivos en TODAS partes para ver dónde funciona

# 1. Archivo en el escritorio (ruta normal)
$desktop = "$env:USERPROFILE\Desktop\test1.txt"
"1. Escritorio normal - $(Get-Date)" | Out-File $desktop

# 2. Archivo en el escritorio (ruta alternativa)
$desktop2 = [Environment]::GetFolderPath("Desktop") + "\test2.txt"
"2. Escritorio por API - $(Get-Date)" | Out-File $desktop2

# 3. Archivo en Temp
$temp = "$env:temp\test3.txt"
"3. Temp - $(Get-Date)" | Out-File $temp

# 4. Archivo en la raíz de C:
$croot = "C:\test4.txt"
"4. C:\ - $(Get-Date)" | Out-File $croot

# 5. Archivo en Documentos
$docs = "$env:USERPROFILE\Documents\test5.txt"
"5. Documentos - $(Get-Date)" | Out-File $docs

# 6. Crear un directorio y un archivo dentro
$newDir = "$env:temp\test_dir"
New-Item -ItemType Directory -Path $newDir -Force | Out-Null
$newFile = "$newDir\test6.txt"
"6. Directorio nuevo - $(Get-Date)" | Out-File $newFile

# 7. Mostrar en pantalla (solo para depuración visual)
Write-Host "Script ejecutado correctamente" -ForegroundColor Green
Write-Host "Hora: $(Get-Date)" -ForegroundColor Yellow

# Pausa para que podamos ver el resultado si la ventana no se cierra
Start-Sleep -Seconds 5
