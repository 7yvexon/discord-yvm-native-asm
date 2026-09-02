$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $PSScriptRoot "toolchain-manifest.json"
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$tools = Join-Path $root ".tools"
$downloads = Join-Path $tools "downloads"
New-Item -ItemType Directory -Force -Path $downloads | Out-Null

function Get-Or-Download([string]$url, [string]$target, [string]$algorithm, [string]$expected) {
    if (!(Test-Path -LiteralPath $target)) {
        Invoke-WebRequest -Uri $url -OutFile $target -UseBasicParsing
    }
    $actual = (Get-FileHash -LiteralPath $target -Algorithm $algorithm).Hash.ToLowerInvariant()
    if ($actual -ne $expected.ToLowerInvariant()) {
        throw "hash mismatch: $target"
    }
}

function Verify-Sha3([string]$target, [string]$expected) {
    $actual = (& python (Join-Path $PSScriptRoot "hash_sha3.py") $target).Trim()
    if ($actual -ne $expected.ToLowerInvariant()) {
        throw "SHA3-256 mismatch: $target"
    }
}

$nasmArchive = Join-Path $downloads "nasm-3.02-win64.zip"
Get-Or-Download $manifest.nasm.url $nasmArchive "SHA256" $manifest.nasm.archive_sha256
$nasmUnpack = Join-Path $tools "nasm-unpack"
New-Item -ItemType Directory -Force -Path $nasmUnpack | Out-Null
Expand-Archive -LiteralPath $nasmArchive -DestinationPath $nasmUnpack -Force
$nasmSource = Get-ChildItem -LiteralPath $nasmUnpack -Filter "nasm.exe" -Recurse | Select-Object -First 1
$ndisasmSource = Get-ChildItem -LiteralPath $nasmUnpack -Filter "ndisasm.exe" -Recurse | Select-Object -First 1
$nasmDestination = Join-Path $tools "nasm"
New-Item -ItemType Directory -Force -Path $nasmDestination | Out-Null
Copy-Item -LiteralPath $nasmSource.FullName -Destination (Join-Path $nasmDestination "nasm.exe") -Force
Copy-Item -LiteralPath $ndisasmSource.FullName -Destination (Join-Path $nasmDestination "ndisasm.exe") -Force

$llvmArchive = Join-Path $downloads "clang+llvm-22.1.8-x86_64-pc-windows-msvc.tar.xz"
Get-Or-Download $manifest.llvm.url $llvmArchive "SHA256" $manifest.llvm.archive_sha256
$llvmDestination = Join-Path $tools "llvm"
& python (Join-Path $PSScriptRoot "extract_llvm.py") --archive $llvmArchive --destination $llvmDestination --root "clang+llvm-22.1.8-x86_64-pc-windows-msvc"
if ($LASTEXITCODE -ne 0) { throw "LLVM extraction failed" }

$sqliteDllArchive = Join-Path $downloads "sqlite-dll-win-x64-3530400.zip"
$sqliteToolsArchive = Join-Path $downloads "sqlite-tools-win-x64-3530400.zip"
if (!(Test-Path -LiteralPath $sqliteDllArchive)) { Invoke-WebRequest -Uri $manifest.sqlite.dll_url -OutFile $sqliteDllArchive -UseBasicParsing }
if (!(Test-Path -LiteralPath $sqliteToolsArchive)) { Invoke-WebRequest -Uri $manifest.sqlite.tools_url -OutFile $sqliteToolsArchive -UseBasicParsing }
Verify-Sha3 $sqliteDllArchive $manifest.sqlite.dll_archive_sha3_256
Verify-Sha3 $sqliteToolsArchive $manifest.sqlite.tools_archive_sha3_256
$sqliteDllUnpack = Join-Path $tools "sqlite-dll-unpack"
$sqliteToolsUnpack = Join-Path $tools "sqlite-tools-unpack"
New-Item -ItemType Directory -Force -Path $sqliteDllUnpack,$sqliteToolsUnpack | Out-Null
Expand-Archive -LiteralPath $sqliteDllArchive -DestinationPath $sqliteDllUnpack -Force
Expand-Archive -LiteralPath $sqliteToolsArchive -DestinationPath $sqliteToolsUnpack -Force
$sqliteDestination = Join-Path $tools "sqlite\win-x64-3.53.4\bin"
New-Item -ItemType Directory -Force -Path $sqliteDestination | Out-Null
Copy-Item -LiteralPath (Join-Path $sqliteDllUnpack "sqlite3.dll") -Destination $sqliteDestination -Force
Copy-Item -LiteralPath (Join-Path $sqliteDllUnpack "sqlite3.def") -Destination $sqliteDestination -Force
Get-ChildItem -LiteralPath $sqliteToolsUnpack -Filter "*.exe" | Copy-Item -Destination $sqliteDestination -Force

& (Join-Path $tools "nasm\nasm.exe") -v
& (Join-Path $tools "llvm\bin\clang.exe") --version
& (Join-Path $sqliteDestination "sqlite3.exe") ":memory:" "select sqlite_version();"
