# CONFIGURACIÓN INICIAL
$githubToken     = "ghp_xxx"             # ← Reemplaza con tu token de GitHub
$organization    = "mi-organizacion"     # ← Reemplaza con tu nombre de organización
$referenceFile   = "reference.yml"
$replacementFile = "replacement.yml"
$tempDir         = "temp-repos"
$logFile         = "log.txt"
$branchPrefix    = "update-mergeable"

$headers = @{ Authorization = "Bearer $githubToken" }

# Crear carpetas necesarias
if (-Not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Limpiar logs anteriores
if (Test-Path $logFile) {
    Remove-Item $logFile
}

# Cargar contenido del archivo de referencia
$referenceContent = Get-Content $referenceFile -Raw
$replacementContent = Get-Content $replacementFile -Raw

# PASO 1: OBTENER REPOSITORIOS
Write-Host "`n🔍 Buscando repositorios 'tf-az*' en la organización '$organization'..."
$repos = @()
$page = 1
do {
    $url = "https://api.github.com/orgs/$organization/repos?per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    $filtered = $response | Where-Object { $_.name -like "tf-az*" }
    $repos += $filtered
    $page++
} while ($response.Count -eq 100)

Write-Host "✅ Se encontraron $($repos.Count) repositorios."

# PASO 2–4: PROCESAR CADA REPOSITORIO
foreach ($repo in $repos) {
    $repoName       = $repo.name
    $repoFullName   = $repo.full_name
    $cloneUrl       = $repo.clone_url
    $repoPath       = Join-Path $tempDir $repoName
    $mergeablePath  = Join-Path $repoPath ".github\mergeable"
    $defaultBranch  = $repo.default_branch
    $timestamp      = Get-Date -Format 'yyyyMMddHHmmss'
    $branchName     = "$branchPrefix-$timestamp"

    Write-Host "`n📥 Procesando '$repoName'..."

    # Clonar repositorio
    git clone --quiet $cloneUrl $repoPath
    if (-Not (Test-Path $repoPath)) {
        Write-Warning "❌ Fallo al clonar $repoName"
        Add-Content -Path $logFile -Value "$repoName - error al clonar"
        continue
    }

    # Verificar existencia del archivo
    if (-Not (Test-Path $mergeablePath)) {
        Write-Warning "🚫 No se encontró .github/mergeable"
        Add-Content -Path $logFile -Value "$repoName - no tiene .github/mergeable"
        continue
    }

    # Comparar contenido
    $repoMergeableContent = Get-Content $mergeablePath -Raw
    if ($repoMergeableContent -ne $referenceContent) {
        Write-Warning "⚠️ Archivo diferente al de referencia"
        Add-Content -Path $logFile -Value "$repoName - archivo diferente, no se reemplaza"
        continue
    }

    # Reemplazar archivo
    Write-Host "✅ Reemplazando archivo .github/mergeable"
    Set-Content -Path $mergeablePath -Value $replacementContent

    # Git: crear rama, commit y push
    Set-Location -Path $repoPath
    git checkout -b $branchName
    git add ".github/mergeable"
    git commit -m "chore: reemplazo automático del archivo mergeable"
    git push origin $branchName

    # Crear Pull Request con gh CLI
    Write-Host "📬 Creando Pull Request..."
    gh pr create `
        --repo $repoFullName `
        --head $branchName `
        --base $defaultBranch `
        --title "chore: reemplazo automático del archivo mergeable" `
        --body "Este PR reemplaza el archivo \`.github/mergeable\` con una versión estandarizada." `
        --label "automation"

    Set-Location -Path "..\.."
}

Write-Host "`n🏁 Proceso finalizado. Revisa '$logFile' para ver los repos donde no se aplicó el cambio."
