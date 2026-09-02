from __future__ import annotations

import hashlib
import sys
from pathlib import Path


if len(sys.argv) != 2:
    raise SystemExit("one file path is required")
print(hashlib.sha3_256(Path(sys.argv[1]).read_bytes()).hexdigest())
