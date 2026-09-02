#!/usr/bin/env sh
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
clang="$root/.tools/llvm/bin/clang"
ld="$root/.tools/llvm/bin/ld.lld"
strip="$root/.tools/llvm/bin/llvm-strip"
if [ ! -x "$clang" ]; then
    printf '%s\n' "project-local LLVM clang was not found: $clang" >&2
    exit 1
fi
if [ ! -x "$ld" ]; then
    printf '%s\n' "project-local LLVM lld was not found: $ld" >&2
    exit 1
fi
if [ ! -x "$strip" ]; then
    printf '%s\n' "project-local llvm-strip was not found: $strip" >&2
    exit 1
fi
output="$root/build/linux-aarch64"
mkdir -p "$output"
sysroot="${YUL_AARCH64_SYSROOT:-$root/.tools/aarch64-sysroot}"
if [ ! -f "$sysroot/lib/aarch64-linux-gnu/libc.so.6" ]; then
    printf '%s\n' "AArch64 sysroot was not found: $sysroot" >&2
    printf '%s\n' "Run build/bootstrap-aarch64-sysroot.ps1 on Windows or set YUL_AARCH64_SYSROOT." >&2
    exit 1
fi
sysroot_lib="$sysroot/lib/aarch64-linux-gnu"
"$clang" --target=aarch64-linux-gnu -c "$root/src/main_linux_aarch64.S" -o "$output/main.o"
if [ ! -f "$output/main.o" ]; then
    printf '%s\n' "AArch64 main assembly failed" >&2
    exit 1
fi
"$clang" --target=aarch64-linux-gnu -c "$root/src/native_runtime_linux_aarch64.S" -o "$output/native_runtime.o"
"$clang" --target=aarch64-linux-gnu -c "$root/src/native_network_linux_aarch64.S" -o "$output/native_network.o"
"$clang" --target=aarch64-linux-gnu -c "$root/src/platform_linux_aarch64.S" -o "$output/platform.o"
"$clang" --target=aarch64-linux-gnu -c "$root/src/amount_parser_linux_aarch64.S" -o "$output/amount_parser.o"
"$clang" --target=aarch64-linux-gnu -c "$root/src/name_normalizer_linux_aarch64.S" -o "$output/name_normalizer.o"
"$clang" --target=aarch64-linux-gnu -c "$root/src/ledger_linux_aarch64.S" -o "$output/ledger.o"
"$clang" --target=aarch64-linux-gnu -c "$root/src/sqlite_linux_aarch64.S" -o "$output/sqlite.o"
"$ld" -m aarch64elf -pie -z relro -z now -z noexecstack -dynamic-linker /lib/ld-linux-aarch64.so.1 -e _start -o "$output/yul-vending-machine" "-L$sysroot_lib" "$output/main.o" "$output/native_runtime.o" "$output/native_network.o" "$output/platform.o" "$output/amount_parser.o" "$output/name_normalizer.o" "$output/ledger.o" "$output/sqlite.o" -l:libc.so.6 -l:libdl.so.2
"$ld" -m aarch64elf -shared -z relro -z now -z noexecstack -o "$output/yul-core.so" "-L$sysroot_lib" "$output/amount_parser.o" "$output/name_normalizer.o" "$output/ledger.o" "$output/sqlite.o" -l:libc.so.6 -l:libdl.so.2
"$strip" --strip-unneeded "$output/yul-vending-machine"
"$strip" --strip-unneeded "$output/yul-core.so"
printf '%s\n' "AArch64 native launcher built at $output/yul-vending-machine"
printf '%s\n' "AArch64 native core built at $output/yul-core.so"
