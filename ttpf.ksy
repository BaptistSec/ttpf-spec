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
  - id: flags_a
    type: u4
  - id: flags_b
    type: u4
  - id: header_pages
    type: u4
  - id: pad_14
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
    instances:
      file_end:
        value: (lo & 0x03ffffff) * 0x100
      next_codec:
        value: (lo >> 26) & 0xf
        doc: codec of the NEXT chunk; 0 RAW, 1..7 BCPack BC1..BC7, 8 ZLIB
      virtual_end:
        value: (hi & 0xfffff) * 0x4000 + ((lo >> 30) & 3) * 0x1000
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
    instances:
      width:
        value: (u0 & 0x3fff) + 1
      height:
        value: ((u0 >> 14) & 0x3fff) + 1
      format_byte:
        value: u1 & 7
      dxgi_format:
        value: (u1 >> 3) & 0x7f
      mip_count:
        value: u1 >> 24
      virtual_page_index:
        value: u2 & 0xfffff
