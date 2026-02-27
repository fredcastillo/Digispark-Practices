# Script de prueba - Crea un archivo en el escritorio
$testFile = "$env:USERPROFILE\Desktop\test.txt"
"Prueba exitosa - $(Get-Date)" | Out-File $testFile
