# Rutas de los archivos a comparar
$Archivo1 = "mergeable.yml"
$Archivo2 = "mergeable2.yml"

# Comparar el contenido de los archivos
$Diferencias = Compare-Object (Get-Content $Archivo1 -Raw) (Get-Content $Archivo2 -Raw)

# Establecer la bandera
$SonIguales = ($Diferencias -eq $null)

# Mostrar el resultado
Write-Host "Los archivos '$Archivo1' y '$Archivo2' son iguales: $SonIguales"
