// Shared geometry for the diffuser, in two shapes: "circle" and "hex".
//
// A thin plate with radial ribs on one side for stiffness. The hole lets the
// plug's thread pass through; the plate rests on the plug's collar.
// Print flat side down, ribs up. When hanging, the ribs face up toward the bulbs.
//
// The hexagon's corners sit at 0°, 60°, ... so the ribs run out to its corners.

include <params.scad>

hub_out_d = disc_hole_d + 2 * hub_w;
rib_r_in  = hub_out_d / 2 - 0.5;
pin_z     = disc_t + 2.5;

// Centre-to-farthest-point radius of each shape.
function outer_r(shape) = shape == "hex" ? hex_r : disc_d / 2;

// Where a rib meets the inside of the rim.
function rib_r_out(shape) =
    shape == "hex" ? hex_r - (rim_w > 0 ? rim_w / cos(30) - 0.5 : 0)
                   : disc_d / 2 - (rim_w > 0 ? rim_w - 0.5 : 0);

// Pins go only where the rib is tall enough to surround the hole.
function pin_radii(shape) =
    let (r_out = rib_r_out(shape),
         r_min = rib_r_in + 10,
         r_max = rib_r_in + (r_out - rib_r_in)
               * (spoke_h_inner - (pin_z - disc_t + pin_hole_d / 2 + 1))
               / (spoke_h_inner - spoke_h_outer))
    [for (i = [0 : pin_count - 1])
         r_min + (r_max - r_min) * i / max(pin_count - 1, 1)];

function is_seam(i) = segments > 1 && (i * segments) % spokes == 0;

module outline(shape) {
    if (shape == "hex") circle(r = hex_r, $fn = 6);
    else                circle(d = disc_d, $fn = 360);
}

module rib(w, r_out) {
    hull() {
        translate([rib_r_in, -w / 2, 0])
            cube([0.01, w, disc_t + spoke_h_inner]);
        translate([r_out - 0.01, -w / 2, 0])
            cube([0.01, w, disc_t + spoke_h_outer]);
    }
}

module diffuser(shape = "circle") {
    assert(shape == "circle" || shape == "hex", "shape must be \"circle\" or \"hex\"");
    assert(spokes % segments == 0, "segments must divide evenly into spokes");
    difference() {
        union() {
            linear_extrude(height = disc_t) outline(shape);
            cylinder(d = hub_out_d, h = disc_t + spoke_h_inner);
            if (rim_w > 0)
                linear_extrude(height = disc_t + rim_h)
                    difference() {
                        outline(shape);
                        offset(delta = -rim_w) outline(shape);
                    }
            for (i = [0 : spokes - 1])
                rotate([0, 0, i * 360 / spokes])
                    rib(is_seam(i) ? 2 * spoke_w : spoke_w, rib_r_out(shape));
        }
        translate([0, 0, -1])
            cylinder(d = disc_hole_d, h = disc_t + spoke_h_inner + 2);
        // Alignment pin holes straight through each seam rib.
        for (i = [0 : spokes - 1])
            if (is_seam(i))
                for (r = pin_radii(shape))
                    rotate([0, 0, i * 360 / spokes])
                        translate([r, 0, pin_z])
                            rotate([90, 0, 0])
                                cylinder(d = pin_hole_d, h = 2 * spoke_w + 2,
                                         center = true, $fn = 24);
    }
}

// One wedge, lying between angle 0 and 360/segments.
module diffuser_wedge(shape = "circle") {
    a = 360 / segments;
    big = 2 * outer_r(shape);
    intersection() {
        diffuser(shape);
        translate([0, 0, -1])
            linear_extrude(height = disc_t + spoke_h_inner + 2)
                polygon(concat([[0, 0]],
                               [for (t = [0 : a / 16 : a]) big * [cos(t), sin(t)]]));
    }
}

// A wedge turned to point along +X, with a size report and bed-fit warning.
module printable_wedge(shape = "circle") {
    r = outer_r(shape);
    a = 360 / segments;
    width = 2 * r * sin(min(a, 180) / 2);
    echo(str(shape, ": ", round(2 * r), " mm across; segment about ",
             round(r), " x ", round(width), " mm"));
    if (max(r, width) > bed_size)
        echo(str("WARNING: segment may not fit a ", bed_size,
                 " mm bed — increase segments"));
    rotate([0, 0, -a / 2]) diffuser_wedge(shape);
}
