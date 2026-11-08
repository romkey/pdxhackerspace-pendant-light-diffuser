# Merge OpenSCAD DXF exports into one DXF, putting each input on its own layer
# so laser software can cut one and engrave the other.
#
#   awk -f merge_dxf.awk -v layers="CUT:1,ENGRAVE:5" cut.dxf engrave.dxf > out.dxf
#
# `layers` gives a NAME:ACI-colour for each input file, in order
# (1 = red, 5 = blue). Only the ENTITIES section of each input is kept.

BEGIN {
    n = split(layers, spec, ",")
    for (i = 1; i <= n; i++) {
        split(spec[i], kv, ":")
        name[i] = kv[1]; color[i] = kv[2]
    }
    print "999\nDXF merged from OpenSCAD exports"
    print "  0\nSECTION\n  2\nHEADER\n  9\n$ACADVER\n  1\nAC1006\n  0\nENDSEC"
    print "  0\nSECTION\n  2\nTABLES"
    print "  0\nTABLE\n  2\nLTYPE\n 70\n1"
    print "  0\nLTYPE\n  2\nCONTINUOUS\n 70\n64\n  3\nSolid line\n 72\n65\n 73\n0\n 40\n0.000000"
    print "  0\nENDTAB"
    print "  0\nTABLE\n  2\nLAYER\n 70\n" n
    for (i = 1; i <= n; i++)
        print "  0\nLAYER\n  2\n" name[i] "\n 70\n0\n 62\n" color[i] "\n  6\nCONTINUOUS"
    print "  0\nENDTAB\n  0\nENDSEC"
    print "  0\nSECTION\n  2\nENTITIES"
}

FNR == 1 { file++; in_ents = 0; odd = 1 }

# DXF is pairs of lines: a group code, then its value.
{
    if (odd) { code = $0 + 0; odd = 0; next }
    odd = 1
    value = $0
    if (!in_ents) {
        if (code == 2 && value == "ENTITIES") in_ents = 1
        next
    }
    if (code == 0 && value == "ENDSEC") { in_ents = 0; next }
    if (code == 8) value = name[file]
    printf "%3d\n%s\n", code, value
}

END { print "  0\nENDSEC\n  0\nEOF" }
