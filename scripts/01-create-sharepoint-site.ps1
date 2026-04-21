<#
.SYNOPSIS
    Creates a SharePoint Online site and document library for the procurement POC.

.DESCRIPTION
    Uses Microsoft Graph API to:
    1. Create a SharePoint team site
    2. Create custom columns (Categorie, Reference, Annee, TypeMarche, Attributaire, MontantHT)
    3. Create category folders

.PARAMETER SiteName
    Display name of the SharePoint site.

.PARAMETER SiteAlias
    URL alias (no spaces, no special chars).
#>

[CmdletBinding()]
param(
    [string]$SiteName = "Marches GHT Contoso",
    [string]$SiteAlias = "marches-ght-contoso"
)

$ErrorActionPreference = 'Stop'

# ---- Auth via Azure CLI token ----
Write-Host "[1/4] Getting Graph API token..." -ForegroundColor Yellow
$token = az account get-access-token --resource "https://graph.microsoft.com" --query accessToken -o tsv
if (-not $token) { throw "Failed to get Graph token. Run 'az login' first." }
$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }

# ---- Create Team Site ----
Write-Host "[2/4] Creating SharePoint site '$SiteName'..." -ForegroundColor Yellow

$siteBody = @{
    displayName     = $SiteName
    mailNickname    = $SiteAlias
    mailEnabled     = $true
    securityEnabled = $false
    groupTypes      = @("Unified")
    visibility      = "Private"
} | ConvertTo-Json

try {
    $group = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups" -Method POST -Headers $headers -Body $siteBody
    $groupId = $group.id
    Write-Host "  Group created: $groupId" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409 -or $_.ToString() -match "already exists|MailNickname") {
        Write-Host "  Site may already exist, looking up..." -ForegroundColor Cyan
        $existing = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=mailNickname eq '$SiteAlias'" -Headers $headers
        if ($existing.value.Count -gt 0) {
            $groupId = $existing.value[0].id
            Write-Host "  Found existing group: $groupId" -ForegroundColor Green
        } else {
            throw "Group creation failed and no existing group found: $($_.Exception.Message)"
        }
    } else { throw }
}

# Wait for site provisioning
Write-Host "  Waiting for site provisioning..." -ForegroundColor Gray
$siteId = $null
for ($i = 0; $i -lt 12; $i++) {
    try {
        $site = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/sites/root" -Headers $headers
        $siteId = $site.id
        break
    } catch {
        Start-Sleep -Seconds 10
    }
}
if (-not $siteId) { throw "Site provisioning timed out." }
Write-Host "  Site ID: $siteId" -ForegroundColor Green

# ---- Get default document library (Documents/Shared Documents) ----
Write-Host "[3/4] Getting document library..." -ForegroundColor Yellow
$drives = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/drives" -Headers $headers
$driveId = $drives.value[0].id
Write-Host "  Drive ID: $driveId" -ForegroundColor Green

# ---- Create category folders ----
Write-Host "[4/4] Creating category folders..." -ForegroundColor Yellow
$categories = @("BIOMEDICAL", "DISPOSITIFS-MEDICAUX", "EQUIPEMENTS-GENERAUX", "HOTELLERIE", "INFORMATIQUE", "LABORATOIRES", "MEDICAMENTS", "TRANSPORTS-VEHICULES")

foreach ($cat in $categories) {
    $folderBody = @{
        name                              = $cat
        folder                            = @{}
        "@microsoft.graph.conflictBehavior" = "rename"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/drives/$driveId/root/children" -Method POST -Headers $headers -Body $folderBody | Out-Null
        Write-Host "  Created: $cat" -ForegroundColor Green
    } catch {
        Write-Host "  Exists: $cat" -ForegroundColor Gray
    }
}

# ---- Output for next scripts ----
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SharePoint Site Ready" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Site ID  : $siteId"
Write-Host "  Drive ID : $driveId"
Write-Host "  Group ID : $groupId"
Write-Host "  URL      : https://$($site.siteCollection.hostname)/sites/$SiteAlias"
Write-Host ""

# Save for use by other scripts
$config = @{
    siteId    = $siteId
    driveId   = $driveId
    groupId   = $groupId
    siteName  = $SiteName
    siteAlias = $SiteAlias
    siteUrl   = "https://$($site.siteCollection.hostname)/sites/$SiteAlias"
} | ConvertTo-Json
$config | Set-Content -Path (Join-Path $PSScriptRoot ".sharepoint-config.json")
Write-Host "Config saved to scripts/.sharepoint-config.json"
