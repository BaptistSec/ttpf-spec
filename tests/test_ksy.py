"""Compile ttpf.ksy with the official Kaitai compiler (npm kaitai-struct-compiler) and compare the
generated parser with check.py on a synthetic file. Run: python tests/test_ksy.py
Needs: node, `npm i kaitai-struct-compiler js-yaml` in tools/, `pip install kaitaistruct`."""
import os, subprocess, sys, tempfile, importlib.util
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, root)
import check
from kaitaistruct import KaitaiStream
import io

def build_sample():
    import struct
    etpf = b"ETPF" + struct.pack("<III", 634, 2, 0x4290)
    etpf += struct.pack("<IIII", 7 | (7 << 14), 7 | (98 << 3) | (1 << 24), 1, 0)
    etpf += struct.pack("<IIII", 15 | (31 << 14), 1 | (71 << 3) | (5 << 24), 0x12345, 9)
    etpf = etpf.ljust(0x100, b"\0")
    table = struct.pack("<II", 0x200 // 0x100 | (7 << 26) | (2 << 30), 3) + struct.pack("<II", 0x300 // 0x100 | (8 << 26), 5)
    head = (b"RDS5" + struct.pack("<IIII", 2, 1, 2, 1)).ljust(0x18, b"\0") + table
    return head.ljust(0x100, b"\0") + etpf + bytes(range(16)).ljust(0x100, b"\0")

def main():
    out = tempfile.mkdtemp()
    subprocess.check_call(["node", os.path.join(root, "tools", "compile_ksy.js"), os.path.join(root, "ttpf.ksy"), out],
                          cwd=os.path.join(root, "tools"))
    spec = importlib.util.spec_from_file_location("ttpf", os.path.join(out, "ttpf.py"))
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    data = build_sample()
    t = m.Ttpf(KaitaiStream(io.BytesIO(data)))
    ref = check.summary(data)
    assert t.chunk_count == ref["chunks"] == 2
    assert t.etpf.const_a == ref["A"] == 634
    got = [(d.width, d.height, d.dxgi_format, d.mip_field, d.start_page) for d in t.etpf.descriptors]
    assert [g[:3] + g[4:] for g in got] == [r[:3] + r[4:] for r in ref["descriptors"]], (got, ref)
    e0, e1 = t.chunk_table
    assert (e0.file_end, e0.next_codec, e0.virtual_end) == (0x200, 7, 3 * 0x4000 + 2 * 0x1000)
    assert (e1.file_end, e1.next_codec, e1.virtual_end) == (0x300, 8, 5 * 0x4000)
    assert t.etpf.field_c == 0x4290
    print("ksy compiled and agrees with check.py: ok")

if __name__ == "__main__":
    main()
