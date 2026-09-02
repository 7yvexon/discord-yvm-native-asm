$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$nasm = Join-Path $root ".tools\nasm\nasm.exe"
$clang = Join-Path $root ".tools\llvm\bin\clang.exe"
$llvmMc = Join-Path $root ".tools\llvm\bin\llvm-mc.exe"
$llvmReadObj = Join-Path $root ".tools\llvm\bin\llvm-readobj.exe"
$ldLld = Join-Path $root ".tools\llvm\bin\ld.lld.exe"
$llvmDllTool = Join-Path $root ".tools\llvm\bin\llvm-dlltool.exe"
$sqlite = Join-Path $root ".tools\sqlite\win-x64-3.53.4\bin\sqlite3.exe"
foreach ($tool in @($nasm, $clang, $llvmMc, $llvmReadObj, $ldLld, $llvmDllTool, $sqlite)) {
    if (!(Test-Path -LiteralPath $tool)) { throw "missing portable tool: $tool" }
}
& $nasm -v
& $clang --version
& $llvmMc --version
& $llvmReadObj --version
& $sqlite ":memory:" "select sqlite_version();"
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build.ps1")
if ($LASTEXITCODE -ne 0) { throw "Windows native launcher build failed" }
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build-core.ps1")
if ($LASTEXITCODE -ne 0) { throw "native core build failed" }
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build-aarch64.ps1")
if ($LASTEXITCODE -ne 0) { throw "AArch64 native launcher build failed" }
$launcherSources = @(
    Get-Content -LiteralPath (Join-Path $root "src\main.asm") -Raw
    Get-Content -LiteralPath (Join-Path $root "src\main_linux_aarch64.S") -Raw
    Get-Content -LiteralPath (Join-Path $root "src\native_runtime_windows_x64.asm") -Raw
    Get-Content -LiteralPath (Join-Path $root "src\native_runtime_linux_aarch64.S") -Raw
    Get-Content -LiteralPath (Join-Path $root "src\native_network_windows_x64.asm") -Raw
    Get-Content -LiteralPath (Join-Path $root "src\native_network_linux_aarch64.S") -Raw
    Get-Content -LiteralPath (Join-Path $root "build\build.ps1") -Raw
    Get-Content -LiteralPath (Join-Path $root "build\build-aarch64.ps1") -Raw
    Get-Content -LiteralPath (Join-Path $root "build\create-release.ps1") -Raw
)
if (($launcherSources -join "`n") -match "(?i)python|CreateProcessA|execve") { throw "native launcher still contains a managed-process dependency" }
$nativePanel = & (Join-Path $root "build\windows-x64\yul-vending-machine.exe") panel-text
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($nativePanel -join "`n"))) { throw "Windows native launcher smoke test failed" }
if (!(Test-Path -LiteralPath (Join-Path $root "build\windows-x64\sqlite3.dll"))) { throw "Windows SQLite runtime deployment failed" }
$windowsCoreHeaders = & $llvmReadObj --file-headers (Join-Path $root "build\windows-x64\yul-core.dll")
if (-not ($windowsCoreHeaders -match "Format: COFF-x86-64")) { throw "Windows native core verification failed" }
$aarch64Output = Join-Path $root "build\linux-aarch64"
$aarch64Executable = Join-Path $aarch64Output "yul-vending-machine"
$aarch64Core = Join-Path $aarch64Output "yul-core.so"
$platformObject = Join-Path $aarch64Output "platform.o"
& $clang --target=aarch64-linux-gnu -c (Join-Path $root "src\platform_linux_aarch64.S") -o $platformObject
if ($LASTEXITCODE -ne 0) { throw "AArch64 assembly failed" }
$headers = & $llvmReadObj --file-headers $platformObject
if (-not ($headers -match "Format: elf64-littleaarch64")) { throw "AArch64 object verification failed" }
$nativeHeaders = & $llvmReadObj --file-headers $aarch64Executable
if (-not ($nativeHeaders -match "Format: elf64-littleaarch64")) { throw "AArch64 executable verification failed" }
$nativeDynamic = & $llvmReadObj --dynamic-table $aarch64Executable
if (-not ($nativeDynamic -match "libc.so.6")) { throw "AArch64 launcher dynamic libc dependency is missing" }
if (-not ($nativeDynamic -match "libdl.so.2")) { throw "AArch64 launcher dynamic libdl dependency is missing" }
$coreHeaders = & $llvmReadObj --file-headers $aarch64Core
if (-not ($coreHeaders -match "Format: elf64-littleaarch64")) { throw "AArch64 native core verification failed" }
