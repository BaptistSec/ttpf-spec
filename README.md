# ttpf-spec

The `.ttpf` texture database layout (RDS5 header, chunk table, ETPF descriptors) as a structured spec and a Kaitai Struct definition.

- `SPEC.md`: every field with a status (documented, inferred, open)
- `ttpf.ksy`: machine-readable layout, usable with Kaitai Struct to generate parsers
- `check.py`: dependency-free reference reader with a built-in self-test (`python check.py --selftest`)
- `tests/test_ksy.py`: compiles `ttpf.ksy` with the official Kaitai compiler and checks the generated parser against `check.py`

The layout merges two MIT community sources (SentinelInteractive/0x52504639 and paryzius/ttpf-viewer), and SPEC.md marks every field as agreed, one-source, conflict or open. Where they conflict, both readings are listed. Nothing is checked against real files. No game data is included.

Companion tool: [ttpf-kit](https://github.com/BaptistSec/ttpf-kit) (inspect, verify, patch).

MIT licence.
