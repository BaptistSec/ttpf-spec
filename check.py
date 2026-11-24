"""Decodes a .ttpf with the layout in SPEC.md and prints a summary. Self-test: python check.py --selftest"""
import struct, sys

def summary(d):
    assert d[:4] == b"RDS5", "bad magic"
    n, _, _, hp = struct.unpack_from("<IIII", d, 4)
    ents = [struct.unpack_from("<II", d, 0x18 + 8 * i) for i in range(n)]
    ends = [(lo & 0x3FFFFFF) * 0x100 for lo, _ in ents]
    assert ends == sorted(ends) and ends[-1] <= len(d), "chunk ends out of order or past file"
    assert d[hp * 0x100:hp * 0x100 + 4] == b"ETPF", "no ETPF at header_pages*0x100"
    a, b, c = struct.unpack_from("<III", d, hp * 0x100 + 4)
    tex = []
    for i in range(b):
        u0, u1, u2, u3 = struct.unpack_from("<IIII", d, hp * 0x100 + 0x10 + 16 * i)
        tex.append(((u0 & 0x3FFF) + 1, ((u0 >> 14) & 0x3FFF) + 1, (u1 & 0x3FF) >> 3, u0 >> 28, u2 & 0x1FFFFF))
    return {"chunks": n, "A": a, "descriptors": tex}

def selftest():
    # tiny synthetic file built here, independent of any other project
    hp = 1
    etpf = b"ETPF" + struct.pack("<III", 634, 1, 0x4290) + struct.pack("<IIII", 7 | (7 << 14), 7 | (98 << 3) | (1 << 24), 1, 0)
    etpf = etpf.ljust(0x100, b"\0")
    table = struct.pack("<II", 0x200 // 0x100 | (7 << 26), 1) + struct.pack("<II", 0x300 // 0x100, 2)
    head = (b"RDS5" + struct.pack("<IIII", 2, 0, 0, hp)).ljust(0x18, b"\0") + table
    d = head.ljust(0x100, b"\0") + etpf + bytes(range(16)).ljust(0x100, b"\0")
    s = summary(d)
    assert s["chunks"] == 2 and s["A"] == 634 and s["descriptors"] == [(8, 8, 98, 0, 1)], s
    print("selftest ok")

if __name__ == "__main__":
    if sys.argv[1:] == ["--selftest"]: selftest()
    else: print(summary(open(sys.argv[1], "rb").read()))
