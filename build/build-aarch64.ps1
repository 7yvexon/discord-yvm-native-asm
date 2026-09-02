$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$clang = Join-Path $root ".tools\llvm\bin\clang.exe"
$ld = Join-Path $root ".tools\llvm\bin\ld.lld.exe"
$strip = Join-Path $root ".tools\llvm\bin\llvm-strip.exe"
if (!(Test-Path -LiteralPath $clang)) { throw "project-local clang was not found: $clang" }
if (!(Test-Path -LiteralPath $ld)) { throw "project-local lld was not found: $ld" }
if (!(Test-Path -LiteralPath $strip)) { throw "project-local llvm-strip was not found: $strip" }
$sysroot = $env:YUL_AARCH64_SYSROOT
$bootstrapSysroot = [string]::IsNullOrWhiteSpace($sysroot)
if ($bootstrapSysroot) { $sysroot = Join-Path $root ".tools\aarch64-sysroot" }
if ($bootstrapSysroot -and !(Test-Path -LiteralPath (Join-Path $sysroot "lib\aarch64-linux-gnu\libc.so.6"))) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "bootstrap-aarch64-sysroot.ps1") | Out-Null
}
if (!(Test-Path -LiteralPath (Join-Path $sysroot "lib\aarch64-linux-gnu\libc.so.6"))) { throw "AArch64 sysroot was not found: $sysroot" }
$sysrootLib = Join-Path $sysroot "lib\aarch64-linux-gnu"
$output = Join-Path $root "build\linux-aarch64"
New-Item -ItemType Directory -Force -Path $output | Out-Null
$mainObject = Join-Path $output "main.o"
$runtimeObject = Join-Path $output "native_runtime.o"
$networkObject = Join-Path $output "native_network.o"
$platformObject = Join-Path $output "platform.o"
$executable = Join-Path $output "yul-vending-machine"
$amountObject = Join-Path $output "amount_parser.o"
$nameObject = Join-Path $output "name_normalizer.o"
$ledgerObject = Join-Path $output "ledger.o"
$sqliteObject = Join-Path $output "sqlite.o"
$nativeCore = Join-Path $output "yul-core.so"
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\main_linux_aarch64.S") -o $mainObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 main assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\native_runtime_linux_aarch64.S") -o $runtimeObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 native runtime assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\native_network_linux_aarch64.S") -o $networkObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 native network assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\platform_linux_aarch64.S") -o $platformObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 platform assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\amount_parser_linux_aarch64.S") -o $amountObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 amount parser assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\name_normalizer_linux_aarch64.S") -o $nameObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 name normalizer assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\ledger_linux_aarch64.S") -o $ledgerObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 ledger assembly failed" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\sqlite_linux_aarch64.S") -o $sqliteObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 SQLite assembly failed" }
& $ld -m aarch64elf -pie -z relro -z now -z noexecstack -dynamic-linker /lib/ld-linux-aarch64.so.1 -e _start -o $executable "-L$sysrootLib" $mainObject $runtimeObject $networkObject $platformObject $amountObject $nameObject $ledgerObject $sqliteObject -l:libc.so.6 -l:libdl.so.2
if ($LASTEXITCODE -ne 0) { throw "AArch64 link failed" }
& $ld -m aarch64elf -shared -z relro -z now -z noexecstack -o $nativeCore "-L$sysrootLib" $amountObject $nameObject $ledgerObject $sqliteObject -l:libc.so.6 -l:libdl.so.2
if ($LASTEXITCODE -ne 0) { throw "AArch64 native core link failed" }
& $strip --strip-unneeded $executable
if ($LASTEXITCODE -ne 0) { throw "AArch64 launcher strip failed" }
& $strip --strip-unneeded $nativeCore
if ($LASTEXITCODE -ne 0) { throw "AArch64 native core strip failed" }
Write-Output $executable
Write-Output $nativeCore
