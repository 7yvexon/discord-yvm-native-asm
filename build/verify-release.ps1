param(
    [Parameter(Mandatory = $true)]
    [string]$ReleasePath,
    [ValidateSet("linux-aarch64", "windows-x64")]
    [string]$Architecture = "linux-aarch64",
    [string]$ExpectedSourceCommit = "",
    [string]$TrustedManifestDigest = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$release = (Resolve-Path -LiteralPath $ReleasePath).Path
$rootManifest = Join-Path $release "SHA256SUMS"
if (!(Test-Path -LiteralPath $rootManifest)) { throw "release checksum manifest is missing" }
if (!(Test-Path -LiteralPath (Join-Path $release "RELEASE.json"))) { throw "release metadata is missing" }
$links = Get-ChildItem -LiteralPath $release -Recurse -Force -Attributes ReparsePoint
if ($links.Count -gt 0) { throw "release must not contain symbolic links or reparse points" }
if (-not [string]::IsNullOrWhiteSpace($TrustedManifestDigest)) {
    $manifestHash = (Get-FileHash -LiteralPath $rootManifest -Algorithm SHA256).Hash
    if ($manifestHash -ine $TrustedManifestDigest.Trim()) { throw "release checksum manifest is not trusted" }
}

$metadata = Get-Content -LiteralPath (Join-Path $release "RELEASE.json") -Raw | ConvertFrom-Json
if ($metadata.schema -ne 1) { throw "unsupported release metadata schema" }
if ($metadata.architecture -ne $Architecture) { throw "release architecture does not match requested architecture" }
if (-not [string]::IsNullOrWhiteSpace($ExpectedSourceCommit) -and $metadata.source_commit -ne $ExpectedSourceCommit) { throw "release source commit does not match expected commit" }

$manifestEntries = Get-Content -LiteralPath (Join-Path $release "SHA256SUMS") |
    Where-Object { $_.Trim().Length -gt 0 }
foreach ($entry in $manifestEntries) {
    $parts = $entry -split "\s{2}", 2
    if ($parts.Count -ne 2 -or $parts[0] -notmatch '^[0-9a-fA-F]{64}$') { throw "invalid checksum manifest entry" }
    $relative = $parts[1].Trim()
    if ([IO.Path]::IsPathRooted($relative) -or $relative -notmatch '^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$' -or $relative -eq "SHA256SUMS") { throw "unsafe checksum path: $relative" }
    $file = Join-Path $release ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "checksum target is missing: $relative" }
    $actual = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
    if ($actual -ine $parts[0]) { throw "checksum mismatch: $relative" }
}

$manifestPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($entry in $manifestEntries) {
    $relative = ($entry -split "\s{2}", 2)[1].Trim()
    if (-not $manifestPaths.Add($relative)) { throw "duplicate checksum path: $relative" }
}
$releaseFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($file in (Get-ChildItem -LiteralPath $release -File -Recurse -Force)) {
    if ($file.FullName -eq $rootManifest) { continue }
    $relative = $file.FullName.Substring($release.Length + 1).Replace("\", "/")
    if (-not $releaseFiles.Add($relative)) { throw "duplicate release path: $relative" }
}
if ($releaseFiles.Count -ne $manifestPaths.Count) { throw "checksum manifest does not cover exactly the release files" }
foreach ($relative in $releaseFiles) {
    if (-not $manifestPaths.Contains($relative)) { throw "checksum manifest is missing: $relative" }
}

$required = if ($Architecture -eq "linux-aarch64") {
    @("yul-vending-machine", "yul-core.so", "config.example.ini", "deploy/install.sh", "deploy/install-trusted.sh", "deploy/verify-release.sh", "deploy/verify-trusted-release.sh", "deploy/healthcheck.sh", "deploy/backup.sh", "deploy/restore.sh", "deploy/rollback.sh", "deploy/rollback-trusted.sh", "deploy/sqlite-maintenance.sh", "deploy/yul-vending-machine.service")
} else {
    @("yul-vending-machine.exe", "yul-core.dll", "config.example.ini")
}
foreach ($relative in $required) {
    if (!(Test-Path -LiteralPath (Join-Path $release $relative) -PathType Leaf)) { throw "required release file is missing: $relative" }
}

if ($Architecture -eq "linux-aarch64") {
    $readelf = Join-Path $root ".tools\llvm\bin\llvm-readelf.exe"
    if (!(Test-Path -LiteralPath $readelf)) { throw "project-local llvm-readelf was not found: $readelf" }
    $launcher = Join-Path $release "yul-vending-machine"
    $core = Join-Path $release "yul-core.so"
    $elf = (& $readelf -h -l -d $launcher | Out-String)
    $coreElf = (& $readelf -h -l -d $core | Out-String)
    if ($elf -notmatch "Type:\s+DYN|Elf file type is DYN") { throw "native launcher must be a position-independent executable" }
    if ($elf -notmatch "GNU_RELRO") { throw "native launcher is missing GNU_RELRO" }
    $stack = ($elf -split "`r?`n" | Where-Object { $_ -match "GNU_STACK" } | Select-Object -First 1)
    if ([string]::IsNullOrWhiteSpace($stack) -or $stack -match "RWE|RWX") { throw "native launcher has an executable GNU_STACK" }
    if ($elf -notmatch "BIND_NOW|FLAGS_1.*NOW") { throw "native launcher is missing immediate symbol binding" }
    if ($coreElf -notmatch "Type:\s+DYN|Elf file type is DYN") { throw "native core must be a shared ELF object" }
    if ($coreElf -notmatch "GNU_RELRO") { throw "native core is missing GNU_RELRO" }
    $coreStack = ($coreElf -split "`r?`n" | Where-Object { $_ -match "GNU_STACK" } | Select-Object -First 1)
    if ([string]::IsNullOrWhiteSpace($coreStack) -or $coreStack -match "RWE|RWX") { throw "native core has an executable GNU_STACK" }
    if ($coreElf -notmatch "BIND_NOW|FLAGS_1.*NOW") { throw "native core is missing immediate symbol binding" }
    $sections = (& $readelf -S $launcher | Out-String)
    if ($sections -match "\.symtab|\.debug_") { throw "native launcher must not contain local symbol or debug sections" }
    $coreSections = (& $readelf -S $core | Out-String)
    if ($coreSections -match "\.symtab|\.debug_") { throw "native core must not contain local symbol or debug sections" }
}

Write-Output "release verified: $($metadata.release_id) [$Architecture]"
