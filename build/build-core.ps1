$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$nasm = Join-Path $root ".tools\nasm\nasm.exe"
$clang = Join-Path $root ".tools\llvm\bin\clang.exe"
$link = Join-Path $root ".tools\llvm\bin\lld-link.exe"
$ld = Join-Path $root ".tools\llvm\bin\ld.lld.exe"
$strip = Join-Path $root ".tools\llvm\bin\llvm-strip.exe"
$dlltool = Join-Path $root ".tools\llvm\bin\llvm-dlltool.exe"
$sqliteDll = Join-Path $root ".tools\sqlite\win-x64-3.53.4\bin\sqlite3.dll"
if (!(Test-Path -LiteralPath $nasm)) { throw "project-local NASM was not found: $nasm" }
if (!(Test-Path -LiteralPath $clang)) { throw "project-local clang was not found: $clang" }
if (!(Test-Path -LiteralPath $link)) { throw "project-local lld-link was not found: $link" }
if (!(Test-Path -LiteralPath $ld)) { throw "project-local ld.lld was not found: $ld" }
if (!(Test-Path -LiteralPath $strip)) { throw "project-local llvm-strip was not found: $strip" }
if (!(Test-Path -LiteralPath $dlltool)) { throw "project-local llvm-dlltool was not found: $dlltool" }
if (!(Test-Path -LiteralPath $sqliteDll)) { throw "portable SQLite runtime was not found: $sqliteDll" }
$sysroot = $env:YUL_AARCH64_SYSROOT
$bootstrapSysroot = [string]::IsNullOrWhiteSpace($sysroot)
if ($bootstrapSysroot) { $sysroot = Join-Path $root ".tools\aarch64-sysroot" }
if ($bootstrapSysroot -and !(Test-Path -LiteralPath (Join-Path $sysroot "lib\aarch64-linux-gnu\libc.so.6"))) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "bootstrap-aarch64-sysroot.ps1") | Out-Null
}
if (!(Test-Path -LiteralPath (Join-Path $sysroot "lib\aarch64-linux-gnu\libc.so.6"))) { throw "AArch64 sysroot was not found: $sysroot" }
$sysrootLib = Join-Path $sysroot "lib\aarch64-linux-gnu"

$windowsOutput = Join-Path $root "build\windows-x64"
$linuxOutput = Join-Path $root "build\linux-aarch64"
New-Item -ItemType Directory -Force -Path $windowsOutput, $linuxOutput | Out-Null

$windowsAmountObject = Join-Path $windowsOutput "amount_parser.obj"
$windowsNameObject = Join-Path $windowsOutput "name_normalizer.obj"
$windowsLedgerObject = Join-Path $windowsOutput "ledger.obj"
$windowsSqliteObject = Join-Path $windowsOutput "sqlite.obj"
$windowsKernelImport = Join-Path $windowsOutput "kernel32.lib"
$windowsCore = Join-Path $windowsOutput "yul-core.dll"
& $nasm -f win64 (Join-Path $root "src\amount_parser_windows_x64.asm") -o $windowsAmountObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for amount_parser_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\name_normalizer_windows_x64.asm") -o $windowsNameObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for name_normalizer_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\ledger_windows_x64.asm") -o $windowsLedgerObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for ledger_windows_x64.asm" }
& $nasm -f win64 (Join-Path $root "src\sqlite_windows_x64.asm") -o $windowsSqliteObject
if ($LASTEXITCODE -ne 0) { throw "NASM failed for sqlite_windows_x64.asm" }
& $dlltool -m i386:x86-64 -d (Join-Path $root "src\kernel32.def") -l $windowsKernelImport
if ($LASTEXITCODE -ne 0) { throw "llvm-dlltool failed for kernel32 import library" }
& $link /dll /noentry "/def:$(Join-Path $root 'src\yul_core_windows_x64.def')" "/out:$windowsCore" $windowsAmountObject $windowsNameObject $windowsLedgerObject $windowsSqliteObject $windowsKernelImport
if ($LASTEXITCODE -ne 0) { throw "LLD failed for yul-core.dll" }
Copy-Item -LiteralPath $sqliteDll -Destination $windowsOutput -Force

$linuxAmountObject = Join-Path $linuxOutput "amount_parser.o"
$linuxNameObject = Join-Path $linuxOutput "name_normalizer.o"
$linuxLedgerObject = Join-Path $linuxOutput "ledger.o"
$linuxSqliteObject = Join-Path $linuxOutput "sqlite.o"
$linuxCore = Join-Path $linuxOutput "yul-core.so"
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\amount_parser_linux_aarch64.S") -o $linuxAmountObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 assembly failed for amount_parser_linux_aarch64.S" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\name_normalizer_linux_aarch64.S") -o $linuxNameObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 assembly failed for name_normalizer_linux_aarch64.S" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\ledger_linux_aarch64.S") -o $linuxLedgerObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 assembly failed for ledger_linux_aarch64.S" }
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\sqlite_linux_aarch64.S") -o $linuxSqliteObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 assembly failed for sqlite_linux_aarch64.S" }
& $ld -m aarch64elf -shared -z relro -z now -z noexecstack -o $linuxCore "-L$sysrootLib" $linuxAmountObject $linuxNameObject $linuxLedgerObject $linuxSqliteObject -l:libc.so.6 -l:libdl.so.2
if ($LASTEXITCODE -ne 0) { throw "AArch64 link failed for yul-core.so" }
& $strip --strip-unneeded $linuxCore
if ($LASTEXITCODE -ne 0) { throw "llvm-strip failed for yul-core.so" }
Write-Output $windowsCore
Write-Output $linuxCore
