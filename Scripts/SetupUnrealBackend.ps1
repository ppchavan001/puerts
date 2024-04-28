Add-Type -AssemblyName System.Windows.Forms


$repo = "puerts/backend-nodejs"
$currentDir = Get-Location
$tempDir = "$currentDir/temp"
$tempFile = "$tempDir/pts_git_apiResponse.json"

function PrintError {
    param (
        $Message
    )
    Write-Host "[Error]: $Message " -ForegroundColor Red
        
}

function PrintWarning {
    param (
        $Message
    )
    Write-Host "[Warning]: $Message " -ForegroundColor Yellow
        
}

function PrintSuccess {
    param (
        $Message
    )
    Write-Host "[Ok]: $Message " -ForegroundColor Green
        
}

function Print {
    param (
        $Message
    )
    Write-Host "[Log]: $Message " 
        
}

PrintWarning("Current dir : $currentDir")
Print("tempDir : $tempDir")
Print("tempFile : $tempFile")

Print("Creating temp dir $tempDir")
New-Item -ItemType Directory -Path $tempDir -Force
Print("Created temp dir @ $tempDir")

$repoUrl = "https://api.github.com/repos/$repo/releases/latest"
# Send a request to GitHub API to get information about the latest release
$response = Invoke-RestMethod -Uri $repoUrl -Method Get

# Check if the response contains assets
if ($response.assets.Count -gt 0) {
    # Get the latest asset
    $latestAsset = $response.assets[0]
    $latestTag = $response.tag_name
    $assetName = $latestAsset.name
    # Define the download URL of the latest asset
    $downloadUrl = $latestAsset.browser_download_url

    # Define the path where the asset will be downloaded
    $downloadPath = "$tempDir"

    New-Item -ItemType Directory -Path $downloadPath -Force

    try {
        $ProgressPreference = 'SilentlyContinue'
        Print "Downloadig to $downloadPath"
        Invoke-WebRequest -Uri $downloadUrl -OutFile "$downloadPath"
        PrintSuccess "Asset '$($latestAsset.name)' downloaded successfully to '$downloadPath'."
    }
    catch {
        PrintError("An error occurred while downloading '$($latestAsset.name)': $($_.Exception.Message)")
    }
}
else {
    PrintError "No assets found in the latest release."
}

exit


if ($downloadedFile.Length -gt 0) {
    PrintWarning("Downloaded file :$downloadedFile")
}
else {
    PrintError("Download failed or cancelled!")
    return
}


Print("Extracting file to : $tarLoc")

$tarLoc = "$tempDir/tar/"
& "./extractFile.ps1" "$downloadedFile" $tarLoc

Print("Extracted file to : $tarLoc")

# Check tarLoc and extract all tar files to tarLoc/out
$tarFiles = Get-ChildItem -Path $tarLoc -Filter "*.tar"
foreach ($tarFile in $tarFiles) {
    $outputDirectory = Join-Path -Path $tarLoc -ChildPath "out/"
    New-Item -ItemType Directory -Path $outputDirectory -Force
    Print("Extracting " + $tarFile.Name + " to $outputDirectory")
    & "./extractFile.ps1" -Path $tarFile.FullName -DestinationPath $outputDirectory
}

PrintSuccess("Extracted all files.")

$pluginTarget = Join-Path -Path $currentDir -ChildPath "..\puerTS"
New-Item -ItemType Directory -Path $pluginTarget -Force
$pluginTarget = Resolve-Path($pluginTarget)
Print("Copying files from $outputDirectory to $pluginTarget")

Copy-Item -Path "$outputDirectory\*" -Destination $pluginTarget -Recurse -Force
PrintSuccess("Finished copying files to $pluginTarget")

PrintSuccess("pts setup successfully.")

if ($delcheckbox.Checked) {
    PrintWarning("Removing temp dir : $tempDir")
    Remove-Item $tempDir -Recurse
}
else {
    PrintWarning("Removing tar temp dir : $tarLoc")
    Remove-Item $tarLoc -Recurse
}
