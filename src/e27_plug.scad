// E27 threaded plug — part 1 of the pendant diffuser.
//
// Modelled in print orientation, which is also the hanging orientation:
//   z = 0          grip (prints on the bed, hangs at the bottom)
//   above that     collar — the ledge the diffuser disc rests on
//   above that     E27 thread
//   top            flat end that goes into the socket first
//
// Print with no supports: the collar's underside is a 45° chamfer.

include <params.scad>

collar_chamfer_h = (collar_d - grip_d) / 2;   // 45°
collar_top_z     = grip_h + collar_chamfer_h + collar_h;
plug_top_z       = collar_top_z + thread_length;

// Edison threads have a round profile. Twisting an off-centre circle gives a
// near-sinusoidal round thread with depth 2*e, which is a close match.
module e27_thread(length) {
    e = (e27_major_d - e27_minor_d) / 4;
    r = (e27_major_d + e27_minor_d) / 4 - thread_clearance / 2;
    turns = length / e27_pitch;
    // Negative twist = right-hand thread in OpenSCAD.
    linear_extrude(height = length, twist = -360 * turns,
                   slices = ceil(turns * 72), convexity = 6)
        translate([e, 0]) circle(r = r);
}

// Cone that chamfers the thread crests at the flat end.
module lead_in_trim(length) {
    big = e27_major_d + 2;
    cylinder(d = big, h = length - lead_in);
    translate([0, 0, length - lead_in - 0.001])
        cylinder(d1 = big, d2 = e27_minor_d - 2 * thread_clearance - 0.4,
                 h = lead_in + (big - e27_minor_d) / 2);
}

module grip() {
    difference() {
        cylinder(d = grip_d, h = grip_h);
        for (i = [0 : grip_flutes - 1])
            rotate([0, 0, i * 360 / grip_flutes])
                translate([grip_d / 2 + grip_flute_d / 4, 0, -1])
                    cylinder(d = grip_flute_d, h = grip_h + 2, $fn = 48);
    }
}

module collar() {
    translate([0, 0, grip_h])
        cylinder(d1 = grip_d, d2 = collar_d, h = collar_chamfer_h);
    translate([0, 0, grip_h + collar_chamfer_h])
        cylinder(d = collar_d, h = collar_h);
}

module e27_plug() {
    difference() {
        union() {
            grip();
            collar();
            translate([0, 0, collar_top_z - 0.01])
                intersection() {
                    e27_thread(thread_length + 0.01);
                    lead_in_trim(thread_length + 0.01);
                }
        }
        if (hollow)
            translate([0, 0, -1])
                cylinder(d = e27_minor_d - thread_clearance - 2 * wall,
                         h = plug_top_z - end_cap + 1);
    }
}

e27_plug();
