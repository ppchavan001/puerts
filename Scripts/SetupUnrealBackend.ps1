

$repo = "puerts/backend-nodejs"
# $repo = "puerts/backend-quickjs"
$currentDir = $PSScriptRoot
$tempDir = "$currentDir\temp"
$tempFile = "$tempDir/pts_git_apiResponse.json"

#region log file setup
$logFile = "$currentDir\setup.log"
if (Test-Path $logFile) {
    Remove-Item $logFile -Force
}

Start-Transcript -Path $logFile
#endregion

#region functions

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
    Write-Warning("Removing tar temp dir : $tarLoc")
    Delete $tarLoc
    Write-Warning("Removing temp dir : $tempDir")
    Delete $tempDir

}

#endregion

#region Script Start
try {
   
    Write-Warning("Current dir : $currentDir")
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
                Write-Warning( "Selected file already exists in dir. Proceeding setup with it")
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
            Write-Error("An error occurred while downloading '$($latestAsset.name)': $($_.Exception.Message)")
        }
    }
    else {
        Write-Error "No assets found in the latest release."
    }

    #endregion


    #region Extract

    $downloadedFile = $finalFile
    if ($downloadedFile.Length -gt 0) {
        Write-Warning("Downloaded file :$downloadedFile")
    }
    else {
        throw ("Download failed or cancelled!")
    }

    Print("Extracting file to : $tarLoc")
    $pluginTarget = Join-Path -Path $currentDir -ChildPath "../unreal/Puerts/ThirdParty/"
    New-Item -ItemType Directory -Path $pluginTarget -Force
    $pluginTarget = Resolve-Path($pluginTarget)
    
    # Extract using 7zip
    if ($false) {
        $tarLoc = "$tempDir/tar/"
        $extractionScript = "$currentDir/extractFileUsing7zip.ps1"
        & $extractionScript "$downloadedFile" $tarLoc

        Print("Extracted file to : $tarLoc")

        # Check tarLoc and extract all tar files to tarLoc/out
        $tarFiles = Get-ChildItem -Path $tarLoc -Filter "*.tar"
        foreach ( $tarFile in $tarFiles) {
            $outputDirectory = Join-Path -Path $tarLoc -ChildPath "out/"
            New-Item -ItemType Directory -Path $outputDirectory -Force
            Print("Extracting " + $tarFile.Name + " to $outputDirectory")
            & $extractionScript -Path $tarFile.FullName -DestinationPath "$outputDirectory"
        }

        PrintSuccess("Extracted all files.")

    
        Print("Copying files from $outputDirectory to $pluginTarget")

        Copy-Item -Path "$outputDirectory\*" -Destination "$pluginTarget" -Recurse -Force
        PrintSuccess("Finished copying files to $pluginTarget")
    }

    # Extract using system lib
    if ($true) {
        $extractionScript = "$currentDir/extractFile.ps1"
        & $extractionScript "$downloadedFile" "$pluginTarget"
    }

    PrintSuccess("pts setup successfully.")
 
}
catch {
    Write-Error "Failed to extract file. Error: $($_.Exception.Message)"
}

DeleteCache
#endregion

#endregion
