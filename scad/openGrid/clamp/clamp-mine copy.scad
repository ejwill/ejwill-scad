include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 100;

/* [Clamp Frame Dimensions] */
clamp_opening       = 25;
opening_clearance   = 0.5;
spine_thickness     = 10;
arm_thickness       = 12;
arm_length          = 10; 
jaw_overhang        = 10;
clamp_width         = 20;

/* [Gusset Parameters] */
gusset_height      = arm_thickness * 0.7;  // Height of the gusset
gusset_length      = arm_thickness * 0.7;  // Length of the gusset base

/* [Threaded Screw Hole] */
thread_diameter = 8;
thread_pitch    = 1.25;
thread_offset   = 0;

/* [Screw] */
screw_length       = 50;
knob_diameter      = 30;
knob_height        = 8;

/* [Ball Joint] */
ball_diameter     = 6;
ball_clearance    = 0.3;
socket_depth      = 3;
roundedness = 8; //[4:4:64] // how smoothly rounded or polygonal the rounding is (24 is plenty)

/* [Press Pad] */
pad_diameter     = 20;
pad_thickness    = 4;

/* [Derived] */
opening_width  = clamp_opening + opening_clearance;
// arm_length     = opening_width + jaw_overhang;
thread_length  = arm_thickness + 2;
adj_screw_length = opening_width + arm_thickness; // Adjusted screw length to account for pad thickness

// Validation: Ensure pad is thick enough for the socket
if (pad_thickness < socket_depth + (ball_diameter + ball_clearance) / 2) {
  echo(str(
    "[WARNING] pad_thickness (", pad_thickness, ") is too thin. ",
    "Increase to at least ",
    socket_depth + (ball_diameter + ball_clearance) / 2, "mm to avoid through-hole."
  ));
}

module corner_gusset() {
    prismoid(
        size1=[clamp_width, gusset_length],
        size2=[clamp_width, 0],
        h=gusset_height,
        anchor=BOTTOM
    );
}

module clamp_body() {
    difference() {
        union() {
            // Spine
            translate([spine_thickness/2, 0, 0])
                cuboid([spine_thickness, clamp_width, opening_width + 2 * arm_thickness], anchor=BOTTOM);

            // Bottom jaw
            translate([spine_thickness + (arm_length)/2, 0, 0])
                cuboid([arm_length, clamp_width, arm_thickness], anchor=BOTTOM);

            // Top jaw
            translate([spine_thickness + (arm_length)/2, 0, arm_thickness + opening_width])
                cuboid([arm_length, clamp_width, arm_thickness], anchor=BOTTOM);


            // Bottom gusset
            translate([spine_thickness, 0, 0])
                corner_gusset();

            // Top gusset
            translate([spine_thickness, 0, arm_thickness + opening_width])
                corner_gusset();
        }

        // Internal thread hole
        translate([
            arm_length / 2 + thread_offset + spine_thickness,
            0,
            arm_thickness + opening_width + arm_thickness / 2
        ])
            threaded_rod(
                d = thread_diameter,
                l = thread_length,
                pitch = thread_pitch,
                internal = true,
                bevel = true,
                anchor = CENTER,
                teardrop = true
            );
    }
}

module clamp_screw() {
  union() {
    // Threaded shaft
    threaded_rod(
      d = thread_diameter,
      l = screw_length,
      pitch = thread_pitch,
      end_len1 = 2,
      d1 = thread_diameter * 0.8, // Reduce diameter at end for easier insertion
      internal = false,
      bevel = true,
      anchor = BOTTOM
    );

    // Knob
    tex = texture("pyramids");
    translate([0, 0, screw_length])
      cyl(d = knob_diameter, h = knob_height, texture = tex, anchor = BOTTOM);

    // Neck + Ball (attached directly below screw)
    translate([0, 0, 0])
      union() {
        // Neck at base of screw
        cyl(d = ball_diameter * 0.6, h = ball_diameter * 0.4, anchor = BOTTOM);

        // Ball below neck
        translate([0, 0, (-ball_diameter+0.5) / 2])
          sphere(d = ball_diameter);
      }
  }
}

module press_pad_socket() {
  difference() {
    // Main pad body
    // cyl(d = pad_diameter, h = pad_thickness, anchor = BOTTOM);
    cyl(d = pad_diameter, h = 5, anchor = BOTTOM);

    // Ball socket cavity — upper hemisphere only
    translate([0, 0, pad_thickness - socket_depth])
      intersection() {
        sphere(d = ball_diameter + ball_clearance);
        cube([2 * (ball_diameter + ball_clearance), 2 * (ball_diameter + ball_clearance), (ball_diameter + ball_clearance) / 2], center = true);
      }

    // Snap-fit ring to retain ball
    translate([0, 0, pad_thickness - 0.6])
      cyl(d = ball_diameter - 0.2, h = 0.6, anchor = BOTTOM);
  }
}

module press() {
    $fn = 32;
    difference() {
        union() {
            //cyl(h=pad_thickness, d=pad_diameter, rounding=1, $fn=64);
            rounded(h = pad_thickness, d = pad_diameter, r = 1);
            //cyl(h=10, d=14, rounding=1, $fn=64);
            rounded(h = 10, d = 14, r = 1);
        }
        translate([0, 0, 10 - 2]) sphere(d = ball_diameter + ball_clearance);
        for (i = [0, 120, 240])
            translate([0, 0, 6.5]) rotate([90, 0, 90 + i]) hull() {
                cylinder(d = 3, h = 10);
                translate([0, 5, 0]) cylinder(d = 3, h = 10);
            }
    }
}

module rounded(h = 5, d = 20, r = 2) {
    translate([0, 0, r])
        minkowski() {
            cylinder(d = d - r * 2, h = h - r * 2, $fn = 64);
            sphere(r = r, $fn = roundedness);
        }
}

//--- Layout for Printing ---
/*translate([0, 0, 0])
  rotate([0, 0, 0])
    clamp_body();

translate([arm_length + 20, 0, screw_length+knob_height])
  rotate([180, 0, 0])
    clamp_screw();

translate([arm_length + 50, 0, 0])
  press_pad_socket(); */
  
 //--- Layout for Printing ---
xdistribute(sizes=[(arm_length+spine_thickness),knob_diameter,pad_diameter,30], spacing=10){
translate([0, (opening_width + 2 * arm_thickness)/2, clamp_width/2])
    rotate([90, 180, 0])
        clamp_body();

//translate([arm_length + 20, 0, screw_length+knob_height])
translate([0, 0, screw_length+knob_height])
  rotate([180, 0, 0])
    clamp_screw();

// //translate([arm_length + 50, 0, 0])
// translate([0, 0, 0])
//   press_pad_socket();

translate([0, 0, 0])
    press();
 }