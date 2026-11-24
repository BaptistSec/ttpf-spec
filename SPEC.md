# .ttpf layout (community notes, structured)

A `.ttpf` file is a texture database: RDS5 header, chunk table, ETPF descriptor block, chunk payloads. All integers little-endian. Machine-readable form: `ttpf.ksy`.

Every field below carries a status: **documented** (stated in the source notes), **inferred** (follows from documented fields), **open** (unknown). Nothing here has been independently checked against real files.

| Offset | Field | Status | Notes |
| --- | --- | --- | --- |
| 0x00 | magic `RDS5` | documented | |
| 0x04 | chunk table entry count | documented | |
| 0x08, 0x0C | flags | documented | meaning open |
| 0x10 | header page count | documented | ETPF starts at count * 0x100. Not a texture count. |
| 0x18 | chunk table, 8 bytes each | documented | padded with zeros to 0x100 |

## Chunk table entry (lo, hi: u32)

- file end = (lo & 0x03FFFFFF) * 0x100
- virtual end = (hi & 0xFFFFF) * 0x4000 + ((lo >> 30) & 3) * 0x1000
- codec of the **next** chunk = (lo >> 26) & 0xF: 0 RAW, 1 to 7 BCPack BC1 to BC7, 8 ZLIB
- chunk i spans from the end of chunk i-1 to its own end. Chunk 0 starts at the 0x100-aligned end of the table and is the ETPF block (never zlib).

## ETPF block

`ETPF`, A (634 in every database examined), B (descriptor count), C (open), then B descriptors of 16 bytes:

| Word | Bits | Meaning | Status |
| --- | --- | --- | --- |
| u0 | 0..13 | width - 1 | documented |
| u0 | 14..27 | height - 1 | documented |
| u1 | 0..2 | format byte | documented |
| u1 | 3..9 | DXGI_FORMAT | documented |
| u1 | 24..31 | mip count | documented |
| u2 | 0..19 | virtual page index, address = page * 0x1000 | documented |
| u3 | all | nonzero on 5 records | open |

## Open questions (from the source notes)

ETPF field C. The mip chain rule. The 5 nonzero u3 records. BCPack decoding. The deswizzle rule is documented as Morton order with tile shift 12 - log2(bytes per element), also unverified here.

## Source

SentinelInteractive/0x52504639, `docs/ttpf-rds5-etpf.md` (MIT). This repository restates that layout in a machine-readable form and does not add measurements of its own.
