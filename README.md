# ttpf-spec

The `.ttpf` texture database layout (RDS5 header, chunk table, ETPF descriptors) as a structured spec and a Kaitai Struct definition.

- `SPEC.md`: every field with a status (documented, inferred, open)
- `ttpf.ksy`: machine-readable layout, usable with Kaitai Struct to generate parsers
- `check.py`: dependency-free reference reader. `python check.py file.ttpf` prints a summary, `python check.py --selftest` runs a built-in synthetic check.

The layout comes from the MIT-licensed notes in SentinelInteractive/0x52504639 (`docs/ttpf-rds5-etpf.md`). This repo restates it in a form tools can use, and has not been checked against real files. No game data is included.

Companion tool: [ttpf-kit](https://github.com/BaptistSec/ttpf-kit) (inspect, verify, patch).

MIT licence.
