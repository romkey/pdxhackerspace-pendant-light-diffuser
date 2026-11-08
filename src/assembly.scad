// Preview of the assembled diffuser in hanging orientation, with ghosted
// BR30 bulbs showing what the plate has to hide. The DiCUNO splitter itself
// would sit just above the plug. For viewing only — print the individual parts.

include <params.scad>
use <e27_plug.scad>
use <diffuser_lib.scad>

shape = "circle"; // [circle, hex]

collar_top_z = grip_h + (collar_d - grip_d) / 2 + collar_h;

color("white") e27_plug();
color("ivory", 0.8) translate([0, 0, collar_top_z]) diffuser(shape);

// BR30 bulbs pointing up (approximate shape), lined up with the hexagon's corners.
br30_h = 135;
%for (i = [0 : 5])
    rotate([0, 0, i * 60])
        translate([bulb_ring_r, 0, collar_top_z + 60]) {
            cylinder(d1 = 27, d2 = br30_d, h = br30_h - 20);
            translate([0, 0, br30_h - 20]) scale([1, 1, 0.25]) sphere(d = br30_d);
        }
