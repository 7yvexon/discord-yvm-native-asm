from __future__ import annotations

import ctypes
import os
from pathlib import Path


_dll_directory_handles = []


def prepare_sqlite_runtime() -> None:
    if os.name != "nt":
        return
    candidates = []
    configured = os.environ.get("YUL_SQLITE_DLL", "")
    if configured:
        candidates.append(Path(configured))
    candidates.append(Path(__file__).resolve().parent.parent / "sqlite3.dll")
    for candidate in candidates:
        if not candidate.is_file():
            continue
        try:
            _dll_directory_handles.append(os.add_dll_directory(str(candidate.parent)))
            ctypes.CDLL(str(candidate))
            return
        except (OSError, AttributeError):
            continue
