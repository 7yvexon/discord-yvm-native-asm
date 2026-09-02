from __future__ import annotations

import ctypes
import os
from pathlib import Path


class NativeCoreError(ValueError):
    pass


class NativeCore:
    def __init__(self, library: ctypes.CDLL):
        self.library = library
        self._parse_amount = library.yul_parse_amount_ascii
        self._parse_amount.argtypes = [ctypes.c_void_p, ctypes.c_uint64, ctypes.POINTER(ctypes.c_uint64)]
        self._parse_amount.restype = ctypes.c_int
        self._normalize_name = library.yul_normalize_name_utf8
        self._normalize_name.argtypes = [
            ctypes.c_void_p,
            ctypes.c_uint64,
            ctypes.c_void_p,
            ctypes.c_uint64,
            ctypes.POINTER(ctypes.c_uint64),
        ]
        self._normalize_name.restype = ctypes.c_int
        self._add_support_total = library.yul_add_support_total
        self._add_support_total.argtypes = [ctypes.c_uint64, ctypes.c_uint64, ctypes.POINTER(ctypes.c_uint64)]
        self._add_support_total.restype = ctypes.c_int

    def parse_amount(self, value: bytes) -> int:
        source = (ctypes.c_ubyte * len(value)).from_buffer_copy(value)
        output = ctypes.c_uint64()
        status = int(self._parse_amount(source, len(value), ctypes.byref(output)))
        if status != 0:
            raise NativeCoreError("native amount parser rejected the value")
        return int(output.value)

    def normalize_name(self, value: bytes) -> bytes:
        source = (ctypes.c_ubyte * len(value)).from_buffer_copy(value)
        output = (ctypes.c_ubyte * 256)()
        output_length = ctypes.c_uint64()
        status = int(self._normalize_name(source, len(value), output, 256, ctypes.byref(output_length)))
        if status != 0:
            raise NativeCoreError("native name normalizer rejected the value")
        length = int(output_length.value)
        if length > 256:
            raise NativeCoreError("native name normalizer returned an invalid length")
        return bytes(output[:length])

    def add_support_total(self, current: int, amount: int) -> int:
        output = ctypes.c_uint64()
        status = int(self._add_support_total(current, amount, ctypes.byref(output)))
        if status != 0:
            raise NativeCoreError("native support total arithmetic rejected the value")
        return int(output.value)


_cached_core: NativeCore | None | bool = None


def _candidate_paths() -> list[Path]:
    root = Path(__file__).resolve().parent.parent
    configured = os.environ.get("YUL_CORE_LIBRARY", "")
    if os.name == "nt":
        names = ["yul-core.dll"]
        build_directory = root / "build" / "windows-x64"
    else:
        names = ["yul-core.so", "libyul-core.so"]
        build_directory = root / "build" / "linux-aarch64"
    paths = [Path(configured)] if configured else []
    paths.extend(root / name for name in names)
    paths.extend(build_directory / name for name in names)
    return paths


def load_native_core() -> NativeCore | None:
    global _cached_core
    if _cached_core is not None:
        return None if _cached_core is False else _cached_core
    if os.environ.get("YUL_DISABLE_NATIVE_CORE", "") in {"1", "true", "TRUE"}:
        _cached_core = False
        return None
    for path in _candidate_paths():
        if not path.is_file():
            continue
        try:
            _cached_core = NativeCore(ctypes.CDLL(str(path)))
            return _cached_core
        except (OSError, AttributeError):
            continue
    _cached_core = False
    return None


def native_core_available() -> bool:
    return load_native_core() is not None
