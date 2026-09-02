$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$nasm = Join-Path $root ".tools\nasm\nasm.exe"
$link = Join-Path $root ".tools\llvm\bin\lld-link.exe"
$dlltool = Join-Path $root ".tools\llvm\bin\llvm-dlltool.exe"
$sqliteDll = Join-Path $root ".tools\sqlite\win-x64-3.53.4\bin\sqlite3.dll"
if (!(Test-Path -LiteralPath $nasm)) { throw "project-local NASM was not found: $nasm" }
if (!(Test-Path -LiteralPath $link)) { throw "project-local lld-link was not found: $link" }
if (!(Test-Path -LiteralPath $dlltool)) { throw "project-local llvm-dlltool was not found: $dlltool" }
if (!(Test-Path -LiteralPath $sqliteDll)) { throw "portable SQLite runtime was not found: $sqliteDll" }
$output = Join-Path $root "build\windows-x64"
New-Item -ItemType Directory -Force -Path $output | Out-Null
$mainSource = Join-Path $root "src\main.asm"
$platformSource = Join-Path $root "src\platform_windows_x64.asm"
$runtimeSource = Join-Path $root "src\native_runtime_windows_x64.asm"
$networkSource = Join-Path $root "src\native_network_windows_x64.asm"
$serviceSource = Join-Path $root "src\native_service_windows_x64.asm"
$mainObject = Join-Path $output "main.obj"
$platformObject = Join-Path $output "platform.obj"
$runtimeObject = Join-Path $output "native_runtime.obj"
$networkObject = Join-Path $output "native_network.obj"
$serviceObject = Join-Path $output "native_service.obj"
$amountObject = Join-Path $output "amount_parser.obj"
$nameObject = Join-Path $output "name_normalizer.obj"
$ledgerObject = Join-Path $output "ledger.obj"
$sqliteObject = Join-Path $output "sqlite.obj"
$executable = Join-Path $output "yul-vending-machine.exe"
$kernel32Import = Join-Path $output "kernel32.lib"
& $nasm -f win64 $mainSource -o $mainObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for main.asm" }
& $nasm -f win64 $platformSource -o $platformObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for platform_windows_x64.asm" }
& $nasm -f win64 $runtimeSource -o $runtimeObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for native_runtime_windows_x64.asm" }
& $nasm -f win64 $networkSource -o $networkObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for native_network_windows_x64.asm" }
& $nasm -f win64 $serviceSource -o $serviceObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for native_service_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\amount_parser_windows_x64.asm") -o $amountObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for amount_parser_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\name_normalizer_windows_x64.asm") -o $nameObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for name_normalizer_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\ledger_windows_x64.asm") -o $ledgerObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for ledger_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\sqlite_windows_x64.asm") -o $sqliteObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for sqlite_windows_x64.asm" }
& $dlltool -m i386:x86-64 -d (Join-Path $root "src\kernel32.def") -l $kernel32Import
if ($LASTEXITCODE -ne 0) { throw "llvm-dlltool failed for kernel32 import library" }
& $link "/subsystem:console" "/entry:yul_vending_machine_native_entry" "/out:$executable" $mainObject $platformObject $runtimeObject $networkObject $serviceObject $amountObject $nameObject $ledgerObject $sqliteObject $kernel32Import
if ($LASTEXITCODE -ne 0) { throw "LLD failed for the Windows native launcher" }
Copy-Item -LiteralPath $sqliteDll -Destination $output -Force
