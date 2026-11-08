// Hexagonal diffuser, flat, for laser cutting: just the outline and the centre
// hole (no ribs or rim), plus a "^H" to engrave. Export as DXF.
//
// `layer` picks what to render:
//   "cut"     – hexagon outline and centre hole
//   "engrave" – the ^H, as filled outlines
//   "both"    – preview: the plate with the ^H shown as holes
// `make` builds both and merges them into one DXF with CUT and ENGRAVE layers.

include <params.scad>

/* [Laser] */
layer = "engrave";          // ["cut", "engrave", "both"]

/* [Engraving] */
text_h      = 150;       // height of the H
caret_h     = 100;       // caret size: it's half this tall
hole_gap    = 6;         // clearance between the centre hole and each letter
stroke      = 0.18;      // stroke width of the H, as a fraction of text_h
caret_w     = 0.75;      // caret width, as a fraction of caret_h
caret_stroke = 0.15;     // caret stroke width, as a fraction of caret_h
caret_slant = 15;        // italic slant of the caret, degrees

module cut_outline() {
    difference() {
        circle(r = hex_r, $fn = 6);
        circle(d = disc_hole_d);
    }
}

// A bold sans-serif H, bottom-left at the origin.
module letter_h(h) {
    w = 0.7 * h;
    s = stroke * h;
    square([s, h]);
    translate([w - s, 0]) square([s, h]);
    translate([0, (h - s) / 2]) square([w, s]);
}

// A caret, bottom-left at the origin, slanted so its point leans to the right.
// It's a triangle minus a copy of itself shifted down, which leaves a chevron
// with a sharp point.
module caret(h) {
    w = caret_w * h;
    ch = 0.5 * h;
    t = caret_stroke * h;
    d = t / cos(atan(ch / (w / 2)));   // vertical shift giving stroke t
    multmatrix([[1, tan(caret_slant), 0, -ch * tan(caret_slant) / 2],
                [0, 1, 0, 0],
                [0, 0, 1, 0]])
        difference() {
            polygon([[0, 0], [w / 2, ch], [w, 0]]);
            translate([0, -d]) polygon([[0, 0], [w / 2, ch], [w, 0]]);
        }
}

// The ^H centred on the plate, with the centre hole in the space between the
// caret and the H.
module engraving() {
    clear = disc_hole_d / 2 + hole_gap;
    // The slant pulls the caret's right foot in, so that's its right edge.
    caret_right = caret_w * caret_h - 0.5 * caret_h * tan(caret_slant) / 2;
    // Raised like a superscript, its top level with the top of the H.
    translate([-clear - caret_right, (text_h - caret_h) / 2]) caret(caret_h);
    translate([clear, -text_h / 2]) letter_h(text_h);
}

if (layer == "cut") cut_outline();
else if (layer == "engrave") engraving();
else difference() { cut_outline(); engraving(); }
