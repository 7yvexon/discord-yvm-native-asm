param(
    [Parameter(Mandatory = $true)]
    [string]$ReleaseId,
    [ValidateSet("linux-aarch64", "windows-x64")]
    [string]$Architecture = "linux-aarch64",
    [string]$SourceCommit = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$releaseRoot = Join-Path $root "build\releases"
$release = Join-Path $releaseRoot $ReleaseId
if ($ReleaseId -notmatch '^[A-Za-z0-9._-]+$') { throw "invalid release id" }
if (Test-Path -LiteralPath $release) { throw "release already exists: $release" }
$headCommit = (& git -C $root rev-parse --verify HEAD 2>$null).Trim()
if ($LASTEXITCODE -ne 0 -or $headCommit -notmatch '^[0-9a-fA-F]{40}$') { throw "unable to resolve a full source commit" }
$dirty = (& git -C $root status --porcelain --untracked-files=all 2>$null)
if ($LASTEXITCODE -ne 0) { throw "unable to inspect source tree" }
if (-not [string]::IsNullOrWhiteSpace(($dirty -join "`n"))) { throw "release source tree must be clean" }
$resolvedCommit = $headCommit
if (-not [string]::IsNullOrWhiteSpace($SourceCommit)) {
    $resolvedCommit = (& git -C $root rev-parse --verify ("$SourceCommit^{commit}") 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or $resolvedCommit -notmatch '^[0-9a-fA-F]{40}$') { throw "unable to resolve source commit" }
    if ($resolvedCommit -ine $headCommit) { throw "source commit must match the checked-out HEAD" }
}

if ($Architecture -eq "linux-aarch64") {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build-aarch64.ps1") | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "AArch64 launcher build failed" }
    $binary = Join-Path $root "build\linux-aarch64\yul-vending-machine"
    $nativeCore = Join-Path $root "build\linux-aarch64\yul-core.so"
} else {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build.ps1") | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Windows launcher build failed" }
    $binary = Join-Path $root "build\windows-x64\yul-vending-machine.exe"
    $nativeCore = Join-Path $root "build\windows-x64\yul-core.dll"
}
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build-core.ps1") | Out-Null
if ($LASTEXITCODE -ne 0) { throw "native core build failed" }
if (!(Test-Path -LiteralPath $binary)) { throw "native binary was not built: $binary" }
if (!(Test-Path -LiteralPath $nativeCore)) { throw "native core was not built: $nativeCore" }

New-Item -ItemType Directory -Force -Path $release | Out-Null
Copy-Item -LiteralPath $binary -Destination (Join-Path $release (Split-Path $binary -Leaf))
Copy-Item -LiteralPath $nativeCore -Destination (Join-Path $release (Split-Path $nativeCore -Leaf))
Copy-Item -LiteralPath (Join-Path $root "db") -Destination $release -Recurse
Copy-Item -LiteralPath (Join-Path $root "deploy") -Destination $release -Recurse
Copy-Item -LiteralPath (Join-Path $root "config.example.ini") -Destination $release
if ($Architecture -eq "windows-x64") {
    $sqliteDll = Join-Path $root ".tools\sqlite\win-x64-3.53.4\bin\sqlite3.dll"
    if (Test-Path -LiteralPath $sqliteDll) { Copy-Item -LiteralPath $sqliteDll -Destination $release }
}
Get-ChildItem -LiteralPath $release -Directory -Filter "__pycache__" -Recurse | Remove-Item -Recurse -Force
$metadata = [ordered]@{
    schema = 1
    release_id = $ReleaseId
    architecture = $Architecture
    source_commit = $resolvedCommit
    created_utc = (Get-Date).ToUniversalTime().ToString("o")
}
$metadataPath = Join-Path $release "RELEASE.json"
[System.IO.File]::WriteAllText($metadataPath, (($metadata | ConvertTo-Json -Compress) + "`n"), [System.Text.Encoding]::UTF8)
$rootChecksumPath = Join-Path $release "SHA256SUMS"
$checksumLines = Get-ChildItem -LiteralPath $release -File -Recurse |
    Where-Object { $_.FullName -ne $rootChecksumPath } |
    Sort-Object FullName |
    ForEach-Object {
        $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $relative = $_.FullName.Substring($release.Length + 1).Replace("\", "/")
        "{0}  {1}" -f $hash, $relative
    }
$checksumPath = Join-Path $release "SHA256SUMS"
[System.IO.File]::WriteAllText($checksumPath, (($checksumLines -join "`n") + "`n"), [System.Text.Encoding]::ASCII)
$manifestDigest = (Get-FileHash -LiteralPath $checksumPath -Algorithm SHA256).Hash.ToLowerInvariant()
$trustedDigestPath = Join-Path $releaseRoot ("{0}.SHA256SUMS.sha256" -f $ReleaseId)
[System.IO.File]::WriteAllText($trustedDigestPath, ("{0}  SHA256SUMS`n" -f $manifestDigest), [System.Text.Encoding]::ASCII)
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "verify-release.ps1") -ReleasePath $release -Architecture $Architecture -ExpectedSourceCommit $resolvedCommit | Out-Null
if ($LASTEXITCODE -ne 0) { throw "release verification failed" }
Write-Output $release
