$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$tools = Join-Path $root ".tools"
$downloads = Join-Path $tools "downloads"
$destination = Join-Path $tools "aarch64-sysroot"
$url = "https://deb.debian.org/debian/pool/main/g/glibc/libc6_2.36-9+deb12u14_arm64.deb"
$expected = "01F4330719FD4F65580E16EA5A0527F372FCA750E8F588D26DEAF09F2D3B1CF4"
$archive = Join-Path $downloads "libc6_2.36-9+deb12u14_arm64.deb"
New-Item -ItemType Directory -Force -Path $downloads,$destination | Out-Null
if (!(Test-Path -LiteralPath $archive)) { Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing }
$actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToUpperInvariant()
if ($actual -ne $expected) { throw "AArch64 sysroot archive hash mismatch" }
$dataArchive = Join-Path $destination "data.tar.xz"
if (!(Test-Path -LiteralPath (Join-Path $destination "lib\aarch64-linux-gnu\libc.so.6"))) {
    tar -xf $archive -C $destination data.tar.xz
    if ($LASTEXITCODE -ne 0) { throw "Unable to extract Debian data archive" }
    $dataTar = Join-Path $destination "data.tar"
    & python -c "import lzma; p=r'$dataArchive'; o=r'$dataTar'; open(o,'wb').write(lzma.open(p,'rb').read())"
    if ($LASTEXITCODE -ne 0) { throw "Unable to decompress Debian data archive" }
    tar -xf $dataTar -C $destination
    if ($LASTEXITCODE -ne 0) { throw "Unable to unpack AArch64 sysroot" }
    Remove-Item -LiteralPath $dataTar,$dataArchive -Force
}
if (!(Test-Path -LiteralPath (Join-Path $destination "lib\aarch64-linux-gnu\ld-linux-aarch64.so.1"))) { throw "AArch64 dynamic loader is missing" }
Write-Output $destination
