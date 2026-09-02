from __future__ import annotations

import argparse
import tarfile
from pathlib import Path


def extract(archive: Path, destination: Path, root: str) -> int:
    executables = {
        "clang.exe",
        "clang++.exe",
        "clang-cl.exe",
        "lld-link.exe",
        "ld.lld.exe",
        "lld.exe",
        "llvm-addr2line.exe",
        "llvm-ar.exe",
        "llvm-as.exe",
        "llvm-config.exe",
        "llvm-cxxfilt.exe",
        "llvm-dlltool.exe",
        "llvm-lib.exe",
        "llvm-mc.exe",
        "llvm-nm.exe",
        "llvm-objcopy.exe",
        "llvm-objdump.exe",
        "llvm-ranlib.exe",
        "llvm-readelf.exe",
        "llvm-readobj.exe",
        "llvm-rc.exe",
        "llvm-size.exe",
        "llvm-strip.exe",
        "obj2yaml.exe",
        "yaml2obj.exe",
    }
    written = 0
    with tarfile.open(archive, "r:xz") as container:
        for member in container:
            name = member.name.replace("\\", "/")
            prefix = root + "/"
            if not name.startswith(prefix):
                continue
            relative = name[len(prefix):]
            relative_path = Path(relative)
            include = relative in {"LICENSE.TXT", "NOTICE.TXT"}
            include = include or relative.startswith("lib/clang/")
            include = include or relative == "include/llvm/Support/LICENSE.TXT"
            include = include or (relative.startswith("bin/") and relative_path.name in executables)
            if not include:
                continue
            if relative_path.is_absolute() or ".." in relative_path.parts:
                raise ValueError(f"unsafe archive path: {member.name}")
            target = destination / "LICENSE.TXT" if relative == "include/llvm/Support/LICENSE.TXT" else destination / relative_path
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
                continue
            if not member.isfile():
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            source = container.extractfile(member)
            if source is None:
                raise OSError(f"unable to read archive member: {member.name}")
            with source, target.open("wb") as output:
                while True:
                    chunk = source.read(1024 * 1024)
                    if not chunk:
                        break
                    output.write(chunk)
            written += 1
    return written


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--archive", type=Path, required=True)
    parser.add_argument("--destination", type=Path, required=True)
    parser.add_argument("--root", required=True)
    args = parser.parse_args()
    count = extract(args.archive, args.destination, args.root)
    print(f"llvm_files={count}")
    return 0


raise SystemExit(main())
