<#
.SYNOPSIS
    Generates .sharepoint-config.json from an existing SharePoint site.

.DESCRIPTION
    Use this script instead of 01-create-sharepoint-site.ps1 when you already
    have a SharePoint site with documents. It looks up the site and drive IDs
    via Microsoft Graph and saves them to scripts/.sharepoint-config.json.

.PARAMETER SiteUrl
    The full URL of your existing SharePoint site.
    Example: https://contoso.sharepoint.com/sites/my-procurement-docs

.EXAMPLE
    .\01b-connect-existing-sharepoint.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/my-procurement-docs"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl
)

$ErrorActionPreference = 'Stop'

# ---- Validate URL format ----
if ($SiteUrl -notmatch '^https://[^/]+\.sharepoint\.com/sites/[^/]+') {
    throw "Invalid SharePoint URL. Expected format: https://<tenant>.sharepoint.com/sites/<site-name>"
}

# ---- Parse hostname and site path from URL ----
$uri = [System.Uri]$SiteUrl.TrimEnd('/')
$hostname = $uri.Host
$sitePath = $uri.AbsolutePath.TrimEnd('/')

# ---- Auth via Azure CLI token ----
Write-Host "[1/3] Getting Graph API token..." -ForegroundColor Yellow
$token = az account get-access-token --resource "https://graph.microsoft.com" --query accessToken -o tsv
if (-not $token) { throw "Failed to get Graph token. Run 'az login' first." }
$headers = @{ "Authorization" = "Bearer $token" }

# ---- Look up site by URL ----
Write-Host "[2/3] Looking up SharePoint site..." -ForegroundColor Yellow
Write-Host "  URL: $SiteUrl" -ForegroundColor Gray

try {
    $site = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/sites/${hostname}:${sitePath}" -Headers $headers
} catch {
    throw "Could not find SharePoint site at '$SiteUrl'. Verify the URL and that you have access. Error: $($_.Exception.Message)"
}

$siteId = $site.id
$siteName = $site.displayName
$siteWebUrl = $site.webUrl
Write-Host "  Site found: $siteName" -ForegroundColor Green
Write-Host "  Site ID: $siteId" -ForegroundColor Green

# ---- Get default document library drive ----
Write-Host "[3/3] Getting document library..." -ForegroundColor Yellow
$drives = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/drives" -Headers $headers

if ($drives.value.Count -eq 0) {
    throw "No document libraries found on this site."
}

# Use the default "Documents" library (first drive)
$drive = $drives.value[0]
$driveId = $drive.id
$driveName = $drive.name
Write-Host "  Library: $driveName" -ForegroundColor Green
Write-Host "  Drive ID: $driveId" -ForegroundColor Green

# ---- Try to resolve the M365 group (may not exist for communication sites) ----
$groupId = ""
try {
    # Extract site-name from path for group lookup
    $siteAlias = ($sitePath -split '/')[-1]
    $groupSearch = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=mailNickname eq '$siteAlias'" -Headers $headers
    if ($groupSearch.value.Count -gt 0) {
        $groupId = $groupSearch.value[0].id
        Write-Host "  Group ID: $groupId" -ForegroundColor Green
    } else {
        Write-Host "  No M365 group found (communication site or different alias)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Could not resolve group (non-blocking)" -ForegroundColor Gray
}

# ---- Save config ----
$siteAlias = ($sitePath -split '/')[-1]
$config = @{
    siteId    = $siteId
    driveId   = $driveId
    groupId   = $groupId
    siteName  = $siteName
    siteAlias = $siteAlias
    siteUrl   = $siteWebUrl
} | ConvertTo-Json

$configFile = Join-Path $PSScriptRoot ".sharepoint-config.json"
$config | Set-Content -Path $configFile -Encoding utf8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Existing SharePoint Site Connected" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Site     : $siteName"
Write-Host "  Site ID  : $siteId"
Write-Host "  Drive ID : $driveId"
Write-Host "  Group ID : $(if ($groupId) { $groupId } else { '(none)' })"
Write-Host "  URL      : $siteWebUrl"
Write-Host ""
Write-Host "Config saved to scripts/.sharepoint-config.json" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  .\02-upload-documents.ps1    # Upload PDFs (optional, skip if docs already exist)"
Write-Host "  .\03-configure-ai-search.ps1 # Configure the AI Search index and indexer"
