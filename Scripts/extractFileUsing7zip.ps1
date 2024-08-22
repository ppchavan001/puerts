
param(
    [string]$Path,
    [string]$DestinationPath
)

$7zipPath = "C:\Program Files\7-Zip\7z.exe"

if (-not (Test-Path $7zipPath)) {
    Write-Error "Error: 7zip not found at: $7zipPath"
    exit
}
# Check if the file exists
if (-not (Test-Path $Path -PathType Leaf)) {
    Write-Error "Error: File not found: $Path"
    exit
}

# Check if the output location exists, if not, create it
if (-not (Test-Path $DestinationPath -PathType Container)) {
    New-Item -Path $DestinationPath -ItemType Directory -Force
}

# Extract the file to the output location using 7z
try {
    &  $7zipPath x "$Path" -o"$DestinationPath" -y
    Write-Information "File extracted successfully to: $DestinationPath"
}
catch {
    Write-Error "Failed to extract file. Error: $($_.Exception.Message)"
}
