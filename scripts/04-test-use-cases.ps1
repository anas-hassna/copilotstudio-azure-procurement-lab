<#
.SYNOPSIS
    Test prompts for each use case - use these to demo the agent in Copilot Studio.
    Run this script to test directly against AI Search + GPT-5.1 via REST API.
#>
param()
$ErrorActionPreference = 'Stop'

Write-Host "Reading Terraform outputs..." -ForegroundColor Yellow
Push-Location (Join-Path $PSScriptRoot "..\infra")
$searchEndpoint  = terraform output -raw search_service_endpoint
$searchKey       = terraform output -raw search_admin_key
$foundryEndpoint = (terraform output -raw openai_endpoint).TrimEnd('/')
$foundryKey      = terraform output -raw openai_key
$gptDeployment   = terraform output -raw gpt51_deployment_name
Pop-Location

$searchHeaders = @{ "api-key" = $searchKey; "Content-Type" = "application/json" }
$gptHeaders    = @{ "api-key" = $foundryKey; "Content-Type" = "application/json" }

function Search-Index([string]$Query, [int]$Top = 5) {
    $body = @{ search = $Query; top = $Top; select = "title,chunk"; queryType = "simple" } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$searchEndpoint/indexes/marches-index/docs/search?api-version=2024-05-01-preview" -Method POST -Headers $searchHeaders -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    return ($r.value | ForEach-Object { "[$($_.title)]`n$($_.chunk)" }) -join "`n---`n"
}

function Ask-GPT([string]$SystemPrompt, [string]$UserPrompt) {
    $body = @{
        messages = @(
            @{ role = "system"; content = $SystemPrompt }
            @{ role = "user"; content = $UserPrompt }
        )
        temperature = 0.3
        max_completion_tokens = 2000
    } | ConvertTo-Json -Depth 5
    $r = Invoke-RestMethod -Uri "$foundryEndpoint/openai/deployments/$gptDeployment/chat/completions?api-version=2024-10-21" -Method POST -Headers $gptHeaders -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    return $r.choices[0].message.content
}

$systemPrompt = @"
Tu es l'Assistant Marchés Publics du GHT Contoso. Tu aides les acheteurs hospitaliers.
Règles :
- Cite TOUJOURS la référence du marché et le document source
- Structure avec des tableaux quand pertinent
- Ne fabrique JAMAIS de données
- Réponds en français
"@

# ============================================================================
# USE CASE 1: Recherche de marché existant
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " UC1: RECHERCHE MARCHE EXISTANT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$q1 = "gants chirurgicaux examen candidats attribution"
Write-Host "Recherche: $q1" -ForegroundColor Gray
$context1 = Search-Index $q1
$answer1 = Ask-GPT $systemPrompt "Voici des extraits de marchés publics :`n$context1`n`nQuestion de l'acheteur : Est-ce qu'on a un marché existant pour les gants chirurgicaux ? Donne-moi la référence, les candidats et le titulaire."
Write-Host $answer1

# ============================================================================
# USE CASE 2: Étude de marché et conformité
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " UC2: ETUDE DE MARCHE ET CONFORMITE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$q2 = "étude marché réactifs laboratoire conformité normes"
Write-Host "Recherche: $q2" -ForegroundColor Gray
$context2 = Search-Index $q2
$answer2 = Ask-GPT $systemPrompt "Voici des extraits de marchés publics :`n$context2`n`nQuestion de l'acheteur : Quels sont les critères de conformité et les normes exigées pour les marchés de réactifs de laboratoire ? Fais une synthèse de l'étude de marché si disponible."
Write-Host $answer2

# ============================================================================
# USE CASE 3: Vérification SLA et pénalités
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " UC3: SLA ET PENALITES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$q3 = "SLA pénalités délai livraison maintenance disponibilité"
Write-Host "Recherche: $q3" -ForegroundColor Gray
$context3 = Search-Index $q3
$answer3 = Ask-GPT $systemPrompt "Voici des extraits de marchés publics :`n$context3`n`nQuestion de l'acheteur : Quels sont les SLA, les pénalités de retard et les conditions de maintenance dans nos marchés ? Compare les engagements entre différents marchés si possible."
Write-Host $answer3

# ============================================================================
# USE CASE 4: Challenge du choix candidats
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " UC4: CHALLENGE CHOIX CANDIDATS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$q4 = "candidats notation critères attribution choix score classement"
Write-Host "Recherche: $q4" -ForegroundColor Gray
$context4 = Search-Index $q4
$answer4 = Ask-GPT $systemPrompt "Voici des extraits de marchés publics :`n$context4`n`nQuestion de l'acheteur : Analyse les candidats et leurs notations. Est-ce que toi, en tant qu'IA, tu aurais fait le même choix d'attribution ? Si non, explique pourquoi et donne ton propre classement avec tes arguments."
Write-Host $answer4

# ============================================================================
# USE CASE 5: Comparaison inter-marchés
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " UC5: COMPARAISON INTER-MARCHES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$q5 = "montant budget prix marché attribution fournisseur"
Write-Host "Recherche: $q5" -ForegroundColor Gray
$context5 = Search-Index $q5
$answer5 = Ask-GPT $systemPrompt "Voici des extraits de marchés publics :`n$context5`n`nQuestion de l'acheteur : Fais-moi un tableau récapitulatif des marchés que tu trouves avec la référence, la catégorie, le montant et le titulaire. Identifie les fournisseurs qui reviennent plusieurs fois."
Write-Host $answer5

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " TESTS TERMINES" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
