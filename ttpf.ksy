meta:
  id: ttpf
  title: GTA VI .ttpf texture database (RDS5 + ETPF), community layout
  endian: le
  license: MIT
doc: |
  Layout as documented by SentinelInteractive/0x52504639 (MIT). Not official.
  Chunk 0 is the ETPF block at header_pages * 0x100.
seq:
  - id: magic
    contents: "RDS5"
  - id: chunk_count
    type: u4
  - id: size_low
    type: u4
    doc: total unpacked size, low 32 bits (ttpf-viewer). 0x52504639 notes call this "flags".
  - id: size_high_and_unknown
    type: u4
    doc: bits 0..7 are bits 32..39 of the total size (ttpf-viewer); the rest is unknown
  - id: header_pages
    type: u4
  - id: unknown_14
    size: 4
  - id: chunk_table
    type: chunk_entry
    repeat: expr
    repeat-expr: chunk_count
instances:
  etpf:
    pos: header_pages * 0x100
    type: etpf
types:
  chunk_entry:
    seq:
      - id: lo
        type: u4
      - id: hi
        type: u4
        doc: bits 20..31 unknown (ttpf-viewer suspects a checksum)
    instances:
      file_end:
        value: (lo & 0x03ffffff) * 0x100
      next_codec:
        value: (lo >> 26) & 0xf
        doc: codec of the NEXT chunk; 0 RAW, 1..7 BCPack BC1..BC7, 8 ZLIB
      virtual_end:
        value: (hi & 0xfffff) * 0x4000 + ((lo >> 30) & 3) * 0x1000
        doc: same value as ((u64 >> 30) & 0x3fffff) << 12 in ttpf-viewer
  etpf:
    seq:
      - id: magic
        contents: "ETPF"
      - id: const_a
        type: u4
        doc: 634 in every database examined
      - id: descriptor_count
        type: u4
      - id: field_c
        type: u4
        doc: unexplained
      - id: descriptors
        type: descriptor
        repeat: expr
        repeat-expr: descriptor_count
  descriptor:
    seq:
      - id: u0
        type: u4
      - id: u1
        type: u4
      - id: u2
        type: u4
      - id: u3
        type: u4
        doc: unknown
    instances:
      width:
        value: (u0 & 0x3fff) + 1
      height:
        value: ((u0 >> 14) & 0x3fff) + 1
      dxgi_format:
        value: (u1 & 0x3ff) >> 3
        doc: agreed by both sources (0x52504639 masks 7 bits, ttpf-viewer 10 bits minus the 3 low flag bits)
      flags_low:
        value: u1 & 7
        doc: low three bits of u1, meaning unknown ("format byte" in 0x52504639)
      array_size:
        value: ((u1 >> 10) & 0x3ff) + 1
        doc: ttpf-viewer only
      tile_mode:
        value: (u1 >> 24) & 0xf
        doc: ttpf-viewer; 0 = 64 KiB tiles, otherwise 4 KiB. 0x52504639 reads bits 24..31 as the mip count instead (conflict).
      mip_field:
        value: u0 >> 28
        doc: ttpf-viewer; for cube maps this is the level count itself, otherwise count minus one
      start_page:
        value: u2 & 0x1fffff
        doc: unpacked-stream offset = start_page * 0x1000. 0x52504639 masks 20 bits, ttpf-viewer 21.
