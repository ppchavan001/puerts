

$repo = "puerts/backend-nodejs"
# $repo = "puerts/backend-quickjs"
$currentDir = $PSScriptRoot
$tempDir = "$currentDir\temp"
$tempFile = "$tempDir/pts_git_apiResponse.json"

#region functions

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

function ProcessWebRequest {
    param (
        $request
    )
    Print "Processing WebRequest $request" 
    Invoke-WebRequest $request
}

# Deletes  directory
function Delete {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path $Path -PathType Container) {
        Remove-Item $Path -Recurse -Force
    }
}

function DeleteCache {
    PrintWarning("Removing tar temp dir : $tarLoc")
    Delete $tarLoc
    PrintWarning("Removing temp dir : $tempDir")
    Delete $tempDir

}

#endregion

#region Script Start

PrintWarning("Current dir : $currentDir")
Print("tempDir : $tempDir")
Print("tempFile : $tempFile")

Print("Creating temp dir $tempDir")
New-Item -ItemType Directory -Path $tempDir -Force
Print("Created temp dir @ $tempDir")

#region Download latest release

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
    $downloadPath = "$tempDir\$latestTag"

    New-Item -ItemType Directory -Path $downloadPath -Force

    try {
        $ProgressPreference = 'SilentlyContinue'
        $finalFile = "$downloadPath\$assetName";
        
        if (Test-Path -Path $script:finalFile -PathType Leaf) {
            PrintWarning( "Selected file already exists in dir. Proceeding setup with it")
        }
        else {    
            $downloadRequest = "-Uri $downloadUrl -OutFile $finalFile"
            Print "Sending web request $downloadRequest"
            Invoke-WebRequest -Uri $downloadUrl -OutFile $finalFile
            PrintSuccess "Asset '$($latestAsset.name)' downloaded successfully to '$downloadPath'."
        }
        PrintSuccess "Asset file ready at : $finalFile"
    }
    catch {
        PrintError("An error occurred while downloading '$($latestAsset.name)': $($_.Exception.Message)")
    }
}
else {
    PrintError "No assets found in the latest release."
}

#endregion


#region Extract

$downloadedFile = $finalFile
if ($downloadedFile.Length -gt 0) {
    PrintWarning("Downloaded file :$downloadedFile")
}
else {
    PrintError("Download failed or cancelled!")
    DeleteCache
    Start-Sleep -Seconds 30
    return
}

Print("Extracting file to : $tarLoc")

$tarLoc = "$tempDir/tar/"
$extractionScript = "$currentDir/extractFile.ps1"
& $extractionScript "$downloadedFile" $tarLoc

Print("Extracted file to : $tarLoc")

# Check tarLoc and extract all tar files to tarLoc/out
$tarFiles = Get-ChildItem -Path $tarLoc -Filter "*.tar"
foreach ( $tarFile in $tarFiles) {
    $outputDirectory = Join-Path -Path $tarLoc -ChildPath "out/"
    New-Item -ItemType Directory -Path $outputDirectory -Force
    Print("Extracting " + $tarFile.Name + " to $outputDirectory")
    & $extractionScript -Path $tarFile.FullName -DestinationPath $outputDirectory
}

PrintSuccess("Extracted all files.")

$pluginTarget = Join-Path -Path $currentDir -ChildPath "../unreal/Puerts/ThirdParty/"
New-Item -ItemType Directory -Path $pluginTarget -Force
$pluginTarget = Resolve-Path($pluginTarget)
Print("Copying files from $outputDirectory to $pluginTarget")

Copy-Item -Path "$outputDirectory\*" -Destination $pluginTarget -Recurse -Force
PrintSuccess("Finished copying files to $pluginTarget")

PrintSuccess("pts setup successfully.")

DeleteCache
#endregion

#endregion
