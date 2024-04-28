Add-Type -AssemblyName System.Windows.Forms

param(
    [string]$Path,
    [string]$DestinationPath
)

$7zipPath = "C:\Program Files\7-Zip\7z.exe"

if (-not (Test-Path $7zipPath)) {
    Write-Host "Error: 7zip not found at: $7zipPath"
    [System.Windows.Forms.MessageBox]::Show("Error 7zip not found.", "Error", "OK", "Error")
    exit
}
# Check if the file exists
if (-not (Test-Path $Path -PathType Leaf)) {
    Write-Host "Error: File not found: $Path"
    exit
}

# Check if the output location exists, if not, create it
if (-not (Test-Path $DestinationPath -PathType Container)) {
    New-Item -Path $DestinationPath -ItemType Directory -Force
}

# Extract the file to the output location using 7z
try {
    &  $7zipPath x "$Path" -o"$DestinationPath" -y
    Write-Host "File extracted successfully to: $DestinationPath"
}
catch {
    Write-Host "Failed to extract file. Error: $_"
    [System.Windows.Forms.MessageBox]::Show("Error extracing downloaded file. Make sure 7Zip is installed at C:\Program Files\7-Zip\7z.exe \n $($_.Exception.Message)", "Error", "OK", "Error")
}
