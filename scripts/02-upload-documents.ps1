<#
.SYNOPSIS
    Uploads procurement PDFs to SharePoint with metadata.

.DESCRIPTION
    Reads docs/ folder and uploads each PDF to the matching SharePoint category folder.
    Sets custom metadata as description field for AI Search indexing.
#>

[CmdletBinding()]
param(
    [string]$DocsPath = (Join-Path $PSScriptRoot "..\docs")
)

$ErrorActionPreference = 'Stop'

# ---- Load config ----
$configFile = Join-Path $PSScriptRoot ".sharepoint-config.json"
if (-not (Test-Path $configFile)) { throw "Run 01-create-sharepoint-site.ps1 first." }
$config = Get-Content $configFile | ConvertFrom-Json
$driveId = $config.driveId

# ---- Auth ----
Write-Host "[1/2] Getting Graph API token..." -ForegroundColor Yellow
$token = az account get-access-token --resource "https://graph.microsoft.com" --query accessToken -o tsv
$headers = @{ "Authorization" = "Bearer $token" }

# ---- Document metadata catalog ----
$catalog = @(
    @{ file="BIOMEDICAL/AO-2024-BIO-0847-equipements-biomedicaux.pdf"; cat="BIOMEDICAL"; ref="AO-2024-BIO-0847"; annee=2024; type="AO"; attr="MedTech Solutions SAS"; montant=471200; objet="Equipements biomedicaux (moniteurs, pousse-seringues, defibrillateurs)" }
    @{ file="BIOMEDICAL/AO-2024-BIO-0955-sterilisation-autoclaves.pdf"; cat="BIOMEDICAL"; ref="AO-2024-BIO-0955"; annee=2024; type="AO"; attr="Getinge AB"; montant=1365000; objet="Sterilisation centrale - autoclaves et laveurs-desinfecteurs" }
    @{ file="BIOMEDICAL/AO-2024-BIO-1203-imagerie-scanner-irm.pdf"; cat="BIOMEDICAL"; ref="AO-2024-BIO-1203"; annee=2024; type="AO"; attr="Siemens Healthineers"; montant=3690000; objet="Imagerie medicale - scanner 128 coupes et IRM 1.5T" }
    @{ file="DISPOSITIFS-MEDICAUX/AO-2023-DM-0312-rapport-analyse-dispositifs.pdf"; cat="DISPOSITIFS-MEDICAUX"; ref="AO-2023-DM-0312"; annee=2023; type="AO"; attr="MediSupply Corp"; montant=832000; objet="Dispositifs medicaux a usage unique (sondes, catheters, kits)" }
    @{ file="DISPOSITIFS-MEDICAUX/AO-2024-DM-0488-gants-examen-chirurgicaux.pdf"; cat="DISPOSITIFS-MEDICAUX"; ref="AO-2024-DM-0488"; annee=2024; type="AO"; attr="Medline Industries"; montant=498000; objet="Gants d'examen et chirurgicaux (nitrile, latex)" }
    @{ file="DISPOSITIFS-MEDICAUX/AO-2024-DM-0621-pansements-soins-infirmiers.pdf"; cat="DISPOSITIFS-MEDICAUX"; ref="AO-2024-DM-0621"; annee=2024; type="AO"; attr="Molnlycke Health Care"; montant=1185000; objet="Pansements techniques et materiel de soins infirmiers" }
    @{ file="EQUIPEMENTS-GENERAUX/AO-2023-EG-0567-fauteuils-roulants-mobilite.pdf"; cat="EQUIPEMENTS-GENERAUX"; ref="AO-2023-EG-0567"; annee=2023; type="AO"; attr="Invacare France"; montant=255000; objet="Fauteuils roulants et aides a la mobilite" }
    @{ file="EQUIPEMENTS-GENERAUX/AO-2024-EG-0234-mobilier-medical.pdf"; cat="EQUIPEMENTS-GENERAUX"; ref="AO-2024-EG-0234"; annee=2024; type="AO"; attr="Hill-Rom SAS / Linet France"; montant=907500; objet="Mobilier medical et literie hospitaliere" }
    @{ file="EQUIPEMENTS-GENERAUX/AO-2024-EG-0389-vetements-bloc-operatoire.pdf"; cat="EQUIPEMENTS-GENERAUX"; ref="AO-2024-EG-0389"; annee=2024; type="AO"; attr="Molnlycke / Hartmann"; montant=515000; objet="Vetements de bloc operatoire et drapes steriles" }
    @{ file="HOTELLERIE/AO-2023-HOT-0298-blanchisserie-linge.pdf"; cat="HOTELLERIE"; ref="AO-2023-HOT-0298"; annee=2023; type="AO"; attr="Initial Textile Services"; montant=645000; objet="Blanchisserie et fourniture de linge hospitalier" }
    @{ file="HOTELLERIE/AO-2024-HOT-0412-nettoyage-hygiene-locaux.pdf"; cat="HOTELLERIE"; ref="AO-2024-HOT-0412"; annee=2024; type="AO"; attr="Onet Proprete Sante"; montant=1890000; objet="Nettoyage, desinfection et hygiene des locaux" }
    @{ file="HOTELLERIE/PA-2024-HOT-0156-restauration-collective.pdf"; cat="HOTELLERIE"; ref="PA-2024-HOT-0156"; annee=2024; type="PA"; attr="Sodexante Restauration"; montant=2400000; objet="Restauration collective patients et personnel" }
    @{ file="INFORMATIQUE/AO-2023-IT-0156-dossier-patient-informatise.pdf"; cat="INFORMATIQUE"; ref="AO-2023-IT-0156"; annee=2023; type="AO"; attr="Dedalus France"; montant=2850000; objet="Dossier Patient Informatise (DPI) - DxCare" }
    @{ file="INFORMATIQUE/AO-2024-IT-0234-cybersecurite-soc.pdf"; cat="INFORMATIQUE"; ref="AO-2024-IT-0234"; annee=2024; type="AO"; attr="Orange Cyberdefense"; montant=485000; objet="Cybersecurite et SOC manage 24/7" }
    @{ file="INFORMATIQUE/MAPA-2024-IT-0089-infrastructure-reseau.pdf"; cat="INFORMATIQUE"; ref="MAPA-2024-IT-0089"; annee=2024; type="MAPA"; attr="Axians Healthcare IT"; montant=612000; objet="Infrastructure reseau et securite (switches, pare-feu, Wi-Fi)" }
    @{ file="LABORATOIRES/AO-2023-LAB-0891-etude-marche-reactifs.pdf"; cat="LABORATOIRES"; ref="AO-2023-LAB-0891"; annee=2023; type="AO"; attr="N/A (etude de marche)"; montant=3530000; objet="Etude de marche - reactifs et consommables de laboratoire" }
    @{ file="LABORATOIRES/AO-2024-LAB-0112-automates-hematologie.pdf"; cat="LABORATOIRES"; ref="AO-2024-LAB-0112"; annee=2024; type="AO"; attr="Sysmex"; montant=1280000; objet="Automates d'hematologie (NFS, reticulocytes, frottis)" }
    @{ file="LABORATOIRES/AO-2024-LAB-0345-microbiologie-identification.pdf"; cat="LABORATOIRES"; ref="AO-2024-LAB-0345"; annee=2024; type="AO"; attr="bioMerieux"; montant=1450000; objet="Automates microbiologie - identification et antibiogramme" }
    @{ file="MEDICAMENTS/AC-2023-MED-0567-accord-cadre-medicaments.pdf"; cat="MEDICAMENTS"; ref="AC-2023-MED-0567"; annee=2023; type="AC"; attr="Multi-attributaires"; montant=8200000; objet="Accord-cadre medicaments et specialites pharmaceutiques" }
    @{ file="MEDICAMENTS/AO-2023-MED-0892-nutrition-enterale-parenterale.pdf"; cat="MEDICAMENTS"; ref="AO-2023-MED-0892"; annee=2023; type="AO"; attr="Fresenius Kabi / Nutricia"; montant=1100000; objet="Nutrition enterale et parenterale" }
    @{ file="MEDICAMENTS/AO-2024-MED-0723-gaz-medicaux.pdf"; cat="MEDICAMENTS"; ref="AO-2024-MED-0723"; annee=2024; type="AO"; attr="Air Liquide Sante"; montant=515000; objet="Gaz medicaux et maintenance des installations" }
    @{ file="TRANSPORTS-VEHICULES/AO-2023-TR-0145-ambulances-smur.pdf"; cat="TRANSPORTS-VEHICULES"; ref="AO-2023-TR-0145"; annee=2023; type="AO"; attr="Gruau Ambulances"; montant=668000; objet="Ambulances SMUR et vehicules medicalises" }
    @{ file="TRANSPORTS-VEHICULES/AO-2024-TR-0078-transport-vehicules.pdf"; cat="TRANSPORTS-VEHICULES"; ref="AO-2024-TR-0078"; annee=2024; type="AO"; attr="ALD Automotive / Ambulances Contoso Nord"; montant=978000; objet="Transport sanitaire et vehicules de service" }
    @{ file="TRANSPORTS-VEHICULES/PA-2024-TR-0201-navettes-inter-sites.pdf"; cat="TRANSPORTS-VEHICULES"; ref="PA-2024-TR-0201"; annee=2024; type="PA"; attr="Transdev Sante"; montant=295000; objet="Navettes inter-sites et coursiers biologiques" }
    # ---- New documents (2025) ----
    @{ file="BIOMEDICAL/AO-2025-BIO-0134-endoscopie-digestive.pdf"; cat="BIOMEDICAL"; ref="AO-2025-BIO-0134"; annee=2025; type="AO"; attr="Olympus Medical Systems"; montant=1895000; objet="Equipements d'endoscopie digestive (colonnes, endoscopes, IA, laveurs)" }
    @{ file="DISPOSITIFS-MEDICAUX/AO-2025-DM-0245-sutures-chirurgicales.pdf"; cat="DISPOSITIFS-MEDICAUX"; ref="AO-2025-DM-0245"; annee=2025; type="AO"; attr="Ethicon / B. Braun (multi-attributaire)"; montant=420000; objet="Sutures chirurgicales, ligatures et dispositifs de fermeture cutanee" }
    @{ file="EQUIPEMENTS-GENERAUX/AO-2025-EG-0178-lits-matelas-anti-escarres.pdf"; cat="EQUIPEMENTS-GENERAUX"; ref="AO-2025-EG-0178"; annee=2025; type="AO"; attr="Hill-Rom (Baxter)"; montant=1350000; objet="Lits medicalises electriques et matelas anti-escarres" }
    @{ file="LABORATOIRES/AO-2025-LAB-0567-biologie-moleculaire-pcr.pdf"; cat="LABORATOIRES"; ref="AO-2025-LAB-0567"; annee=2025; type="AO"; attr="Roche Diagnostics / bioMerieux (multi-attributaire)"; montant=1170000; objet="Biologie moleculaire - automates PCR et reactifs" }
    @{ file="INFORMATIQUE/AO-2025-IT-0312-telemedecine-plateforme.pdf"; cat="INFORMATIQUE"; ref="AO-2025-IT-0312"; annee=2025; type="AO"; attr="Doctolib Pro / Parsys Telemedecine (multi-attributaire)"; montant=1375000; objet="Plateforme de telemedecine et teleconsultation" }
    @{ file="TRANSPORTS-VEHICULES/AO-2025-TR-0289-transport-sanitaire-urgences.pdf"; cat="TRANSPORTS-VEHICULES"; ref="AO-2025-TR-0289"; annee=2025; type="AO"; attr="Gruau Ambulances / GFA"; montant=1850000; objet="Vehicules sanitaires et d'urgence pre-hospitaliere" }
    @{ file="MEDICAMENTS/AC-2025-MED-0891-antiseptiques-desinfectants.pdf"; cat="MEDICAMENTS"; ref="AC-2025-MED-0891"; annee=2025; type="AC"; attr="Schulke / B. Braun / Anios (multi-attributaire)"; montant=680000; objet="Accord-cadre antiseptiques, desinfectants et produits d'hygiene des mains" }
)

# ---- Upload ----
Write-Host "[2/2] Uploading $($catalog.Count) documents..." -ForegroundColor Yellow

$uploaded = 0
$failed = 0

foreach ($doc in $catalog) {
    $localPath = Join-Path $DocsPath $doc.file
    if (-not (Test-Path $localPath)) {
        Write-Host "  SKIP (not found): $($doc.file)" -ForegroundColor Red
        $failed++
        continue
    }

    $fileName = Split-Path $doc.file -Leaf
    $folder = $doc.cat
    $uploadUrl = "https://graph.microsoft.com/v1.0/drives/$driveId/root:/$folder/${fileName}:/content"

    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($localPath)
        $uploadHeaders = @{
            "Authorization" = "Bearer $token"
            "Content-Type"  = "application/pdf"
        }
        $result = Invoke-RestMethod -Uri $uploadUrl -Method PUT -Headers $uploadHeaders -Body $fileBytes
        $itemId = $result.id

        # Set description with structured metadata (for AI Search)
        $descText = "Categorie: $($doc.cat) | Reference: $($doc.ref) | Annee: $($doc.annee) | Type: $($doc.type) | Attributaire: $($doc.attr) | Montant HT: $($doc.montant) EUR | Objet: $($doc.objet)"
        $updateBody = @{
            description = $descText
        } | ConvertTo-Json
        $updateHeaders = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }
        Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/drives/$driveId/items/$itemId" -Method PATCH -Headers $updateHeaders -Body $updateBody | Out-Null

        $sizeKB = [math]::Round($fileBytes.Length / 1KB, 1)
        Write-Host "  OK: $fileName ($($sizeKB)KB) -> $folder/" -ForegroundColor Green
        $uploaded++
    } catch {
        Write-Host "  FAIL: $fileName - $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "Upload complete: $uploaded OK, $failed failed." -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
