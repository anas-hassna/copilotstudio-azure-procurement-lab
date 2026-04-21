<#
.SYNOPSIS
    Runs all setup scripts in order.

.DESCRIPTION
    1. Deploy Terraform infrastructure
    2. Create SharePoint site
    3. Upload documents
    4. Configure AI Search (index + data source + skillset + indexer)

.PARAMETER SubscriptionId
    Azure subscription ID.

.PARAMETER SkipTerraform
    Skip Terraform deployment (if already done).
#>

[CmdletBinding()]
param(
    [string]$SubscriptionId,
    [switch]$SkipTerraform
)

$ErrorActionPreference = 'Stop'
$scriptDir = $PSScriptRoot
$infraDir = Join-Path $scriptDir "..\infra"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Procurement RAG - Full Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- Ensure subscription is set ----
Write-Host "Setting Azure subscription..." -ForegroundColor Gray
az account set --subscription $SubscriptionId 2>$null
if ($LASTEXITCODE -ne 0) {
    # Try by name if ID fails
    az account set --subscription "ME-MngEnvMCAP252980-sikadouc-1" 2>$null
}
$currentSub = az account show --query "{name:name, id:id}" -o tsv 2>$null
Write-Host "Active subscription: $currentSub" -ForegroundColor Green
Write-Host ""

# ---- Step 1: Terraform ----
if (-not $SkipTerraform) {
    Write-Host "=== STEP 1/4: Deploying infrastructure ===" -ForegroundColor Yellow
    Push-Location $infraDir

    if (-not (Test-Path "terraform.tfvars")) {
        if ($SubscriptionId) {
            Copy-Item "terraform.tfvars.example" "terraform.tfvars"
            (Get-Content "terraform.tfvars") -replace '00000000-0000-0000-0000-000000000000', $SubscriptionId | Set-Content "terraform.tfvars"
        } else {
            throw "Provide -SubscriptionId or create infra/terraform.tfvars manually."
        }
    }

    terraform init
    terraform apply -auto-approve
    Pop-Location
    Write-Host ""
} else {
    Write-Host "=== STEP 1/4: Terraform (skipped) ===" -ForegroundColor Gray
}

# ---- Step 2: SharePoint ----
Write-Host "=== STEP 2/4: Creating SharePoint site ===" -ForegroundColor Yellow
& (Join-Path $scriptDir "01-create-sharepoint-site.ps1")
Write-Host ""

# ---- Step 3: Upload docs ----
Write-Host "=== STEP 3/4: Uploading documents ===" -ForegroundColor Yellow
& (Join-Path $scriptDir "02-upload-documents.ps1")
Write-Host ""

# ---- Step 4: AI Search ----
Write-Host "=== STEP 4/4: Configuring AI Search ===" -ForegroundColor Yellow
& (Join-Path $scriptDir "03-configure-ai-search.ps1")
Write-Host ""

# ---- Done ----
Write-Host "========================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Grant admin consent for the App Registration in Entra ID portal"
Write-Host "     (Enterprise Applications -> AI Search - SharePoint Indexer -> Permissions -> Grant admin consent)"
Write-Host "  2. Wait ~15 min for the indexer to process all documents"
Write-Host "  3. Connect Copilot Studio to the AI Search index"
Write-Host "     (Knowledge -> Add knowledge -> Azure AI Search -> use endpoint + key from Terraform outputs)"
Write-Host ""
