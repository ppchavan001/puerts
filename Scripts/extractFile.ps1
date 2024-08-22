param(
    [string]$Path,
    [string]$DestinationPath
)

# Check if the file exists
if (-not (Test-Path $Path -PathType Leaf)) {
    Write-Error "File not found: $Path"
    exit
}

# Check if the output location exists, if not, create it
if (-not (Test-Path $DestinationPath -PathType Container)) {
    New-Item -Path $DestinationPath -ItemType Directory -Force
}

# Temporary path for the decompressed .tar file
$tarPath = [System.IO.Path]::ChangeExtension($Path, ".tar")

try {
    # Decompress the .tgz (which is a .tar.gz) to a .tar file
    Write-Host "Decompressing $Path to $tarPath..."
    $inputFile = [System.IO.File]::OpenRead($Path)
    $outputFile = [System.IO.File]::Create($tarPath)
    $gzipStream = New-Object System.IO.Compression.GzipStream($inputFile, [System.IO.Compression.CompressionMode]::Decompress)
    $gzipStream.CopyTo($outputFile)
    $gzipStream.Close()
    $inputFile.Close()
    $outputFile.Close()
    
    # Extract the .tar file to the destination directory
    Write-Host "Extracting $tarPath to $DestinationPath..."
    $tarFile = [System.IO.File]::OpenRead($tarPath)
    [System.IO.Compression.TarArchive]::ExtractToDirectory($tarFile, $DestinationPath)
    $tarFile.Close()

    # Clean up the temporary .tar file
    Remove-Item -Path $tarPath -Force
    
    Write-Host "File extracted successfully to: $DestinationPath"
}
catch {
    Write-Error "Failed to extract file. Error: $($_.Exception.Message)"
}
