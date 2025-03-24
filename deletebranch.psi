$org = "mi-organizacion"
$branchToDelete = "nombre-de-la-rama"

# Obtener la lista de repositorios de la organización
$repos = gh repo list $org --json name --limit 1000 | ConvertFrom-Json

foreach ($repo in $repos) {
    $repoName = $repo.name
    Write-Host "Verificando $repoName..."

    # Verificar si la rama existe
    $branchExists = gh api repos/$org/$repoName/branches/$branchToDelete --silent

    if ($?) {
        Write-Host " -> La rama '$branchToDelete' existe en '$repoName'. Eliminándola..."
        gh api -X DELETE repos/$org/$repoName/git/refs/heads/$branchToDelete
        if ($?) {
            Write-Host " ✅ Eliminada correctamente."
        } else {
            Write-Host " ❌ Error al eliminar la rama."
        }
    } else {
        Write-Host " -> La rama '$branchToDelete' no existe en '$repoName'."
    }
}
