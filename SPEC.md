# .ttpf layout

A `.ttpf` file is a texture database: RDS5 header, chunk table, ETPF block, chunk payloads. All integers are little-endian. The machine-readable form is `ttpf.ksy`.

## Sources

This spec merges two independent community sources, both MIT:

- **S1** SentinelInteractive/0x52504639, `docs/ttpf-rds5-etpf.md` (notes) and `docs/bcpack-entropy.md`. Written from measurements on a copy the authors own.
- **S2** paryzius/ttpf-viewer, `src/archive.rs` (a working viewer whose header comment documents the layout and whose code reads real files).

Nothing here has been checked against a real file by this project. Each field gets a status:

- **agreed**: S1 and S2 say the same thing
- **S1 only** / **S2 only**: one source
- **conflict**: the sources differ, both readings are given
- **open**: neither explains it

## Header

| Offset | Field | Status |
| --- | --- | --- |
| 0x00 | `RDS5` | agreed |
| 0x04 | chunk count | agreed |
| 0x08 | total unpacked size, low 32 bits | **conflict**: S2 says size, S1 calls 0x08 and 0x0C "flags" |
| 0x0C | bits 0..7 are size bits 32..39, the rest unknown | S2 only |
| 0x10 | ETPF position / 0x100 (a "header page count") | agreed |
| 0x14 | unknown | open |
| 0x18 | chunk table, 8 bytes per chunk, zero padded to 0x100 | agreed |

## Chunk table entry

Read as a 64-bit value `v = lo | hi << 32`.

| Bits | Meaning | Status |
| --- | --- | --- |
| 0..25 | file end of the chunk, times 0x100 | agreed |
| 26..29 | how the **next** chunk is stored: 0 raw, 1 to 7 BCPack BC1 to BC7, 8 zlib | agreed |
| 30..51 | unpacked end, times 0x1000 | agreed (S1 splits it as `hi & 0xFFFFF` times 0x4000 plus bits 30..31 times 0x1000) |
| 52..63 | unknown, S2 suspects a checksum | S2 only |

Chunk 0 starts at the ETPF position, ends at its own file end, and holds the ETPF block, stored as-is. Chunk i starts where chunk i-1 ends. The chunks are consecutive pieces of one unpacked stream.

**Source discrepancy.** S1's `bcpack-entropy.md` says "the codec id is the block format number times four, so BC1 is 0x04, BC3 0x0C, BC5 0x14, BC7 0x1C". That does not match the 1 to 7 numbering in its own layout page or in S2. It may describe a different field width or a different place in the entry. Unresolved, so tools should treat the 4-bit value as authoritative only for raw (0) and zlib (8).

## ETPF block

| Offset | Field | Status |
| --- | --- | --- |
| 0 | `ETPF` | agreed |
| 4 | constant 634 in every database S1 looked at | S1 only; S2 calls it unknown |
| 8 | texture count | agreed |
| 12 | S1: unexplained (0x4290 in the graphics database). S2: section size | **conflict** |
| 16 | one 16-byte record per texture | agreed |
| after the records | a sorted list of 8-byte name hashes | S2 only |

### Texture record

| Word, bits | Meaning | Status |
| --- | --- | --- |
| u0 0..13 | width - 1 | agreed |
| u0 14..27 | height - 1 | agreed |
| u0 28..31 | mip field. For cube maps it is the level count, otherwise count minus one | S2 only |
| u1 0..2 | flags, meaning unknown (S1 calls it the "format byte") | open |
| u1 3..9 | DXGI format | agreed |
| u1 10..19 | array size - 1 | S2 only |
| u1 24..27 | tile mode: 0 means 64 KiB tiles, otherwise 4 KiB | S2 only |
| u1 24..31 | S1 reads this as the mip count | **conflict** with the row above |
| u2 0..19 or 0..20 | start in the unpacked stream, times 0x1000 | **conflict** on width (S1 20 bits, S2 21) |
| u3 | unknown, nonzero on 5 records in S1's data | open |

### Surfaces

Per S2, each texture is a contiguous run of the unpacked stream holding its mip levels smallest first. The top level ends where the next texture starts, and the next level ends where the top level starts. Levels smaller than a tile are padded to a whole tile, and below the top level they may be packed together.

Per S1, surfaces are in Morton order at 4 KiB or 64 KiB granularity, tile shift `12 - log2(bytes per element)`. S2's tile modes agree with the 4 KiB and 64 KiB split.

## Open questions

BCPack decoding (S1 has identified the entropy layer, rANS over fragments with static tables, and has no decoder; S2 treats BCPack textures as unreadable). Unknown header and entry bits. The 5 nonzero u3 records. Which of the conflicting readings above is right.

## What would settle the conflicts

A real `.ttpf` file read with both layouts: the ETPF third word against the actual section size, the mip field against the surface sizes, and the high bits of 0x0C and of the chunk entries. This repository does not include game files, so that check has to be run by someone who holds one.
