// Shared dimensions for the E27 pendant light diffuser.
// Both parts include this file so the disc's hole always matches the plug.
// All units are millimetres.

/* [E27 thread] */
// E27 (Edison) thread: IEC 60061-1 nominal male dimensions.
e27_major_d = 26.45;     // outside diameter of thread crests
e27_minor_d = 24.26;     // diameter at thread roots
e27_pitch   = 25.4 / 7;  // 7 threads per inch = 3.629 mm
// Shrink the thread slightly so a printed part turns freely in a metal shell.
thread_clearance = 0.3;  // subtracted from the diameter
thread_length    = 20;   // length of threaded section
lead_in          = 1.5;  // chamfer at the flat end to help start the thread

/* [Plug body] */
hollow        = true;    // hollow out the plug to save material
wall          = 2.4;     // wall thickness when hollow
end_cap       = 2.0;     // solid thickness of the flat end

/* [Collar (the ledge the disc sits on)] */
collar_d      = 36;      // must be larger than disc_hole_d
collar_h      = 3;       // flat part of the collar
collar_chamfer = 3;      // 45° underside chamfer so it prints without supports

/* [Grip] */
grip_d        = 32;
grip_h        = 14;
grip_flutes   = 12;      // number of finger scallops
grip_flute_d  = 6;

/* [Splitter and bulbs] */
// Designed for a DiCUNO 7-in-1 splitter: the plug screws into the centre
// socket (pointing down), and the six gooseneck arms are bent so their BR30
// bulbs point up above the disc. The arms bend, so measure your setup.
br30_d          = 95.25; // BR30 = 30/8" = 3.75" across the face
bulb_ring_r     = 110;   // distance from the splitter's axis to each bulb's centre
                         // (six BR30s touch at 95.25; leave a little air)
cover_margin    = 15;    // extra disc beyond the bulbs' outer edge, so they stay
                         // hidden when seen from an angle below

/* [Disc] */
disc_d          = 2 * (bulb_ring_r + br30_d / 2 + cover_margin);
disc_t          = 1.2;   // very thin so light passes through
disc_hole_clearance = 1.0;
disc_hole_d     = e27_major_d + disc_hole_clearance;
spokes          = 6;
spoke_w         = 2.4;   // a seam rib is two of these, one on each segment
spoke_h_inner   = 8;     // rib height at the hub (above the disc)
spoke_h_outer   = 3;     // rib height at the rim
hub_w           = 4;     // width of the reinforcing ring around the hole
rim_w           = 2.4;   // width of the reinforcing ring at the edge (0 = none)
rim_h           = 3;

/* [Hexagon] */
// The hexagon's corners point at the bulbs, so it needs less area than a
// circle to hide them. Size it so each bulb (plus margin) fits inside the
// two edges beside its corner.
hex_apothem     = bulb_ring_r * cos(30) + br30_d / 2 + cover_margin;
hex_r           = hex_apothem / cos(30);   // centre-to-corner radius

/* [Segmenting] */
// The disc is too big for most printers, so it's printed as identical wedges
// joined along the ribs. Segments must divide evenly into spokes.
segments        = 6;
pin_d           = 1.75;  // 1.75 mm filament works as alignment pins
pin_hole_d      = 1.95;
pin_count       = 3;     // pins per seam
bed_size        = 220;   // warn if a segment won't fit a square bed this size

$fn = 128;
