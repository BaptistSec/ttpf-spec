# ttpf-spec

A written and machine-readable description of the `.ttpf` texture database layout used by GTA VI: the RDS5 header, the chunk table and the ETPF texture records.

The layout is not official. It is merged from two public community sources, [0x52504639](https://github.com/SentinelInteractive/0x52504639) and [ttpf-viewer](https://github.com/paryzius/ttpf-viewer), and [SPEC.md](SPEC.md) says for every field whether they agree, only one of them says it, they conflict, or nobody knows. Nothing has been checked against a real file by this project, so treat the conflicts as open questions rather than facts.

`ttpf.ksy` is the same layout as a Kaitai Struct definition. `check.py` is a small reader with no dependencies (`python check.py file.ttpf` prints a summary, `--selftest` checks it against a built-in sample). `python tests/test_ksy.py` compiles the `.ksy` with the official compiler (needs Node and `npm install` in `tools/`) and checks the generated parser against `check.py`.

[ttpf-kit](https://github.com/BaptistSec/ttpf-kit) uses this layout to verify, compare and patch files. MIT licence, no game data.
