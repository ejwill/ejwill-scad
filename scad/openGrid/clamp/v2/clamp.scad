include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 100;

/* [Clamp Frame Dimensions] */
clamp_opening       = 25;
opening_clearance   = 0.5;
spine_thickness     = 10;
jaw_thickness       = 12;
jaw_overhang        = 10;
clamp_depth         = 20;

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

/* [Press Pad] */
pad_diameter     = 20;
pad_thickness    = 4;

/* [Derived] */
opening_width  = clamp_opening + opening_clearance;
arm_length     = opening_width + jaw_overhang;
thread_length  = jaw_thickness + 2;

// Validation: Ensure pad is thick enough for the socket
if (pad_thickness < socket_depth + (ball_diameter + ball_clearance) / 2) {
  echo(str(
    "[WARNING] pad_thickness (", pad_thickness, ") is too thin. ",
    "Increase to at least ",
    socket_depth + (ball_diameter + ball_clearance) / 2, "mm to avoid through-hole."
  ));
}

module clamp_body() {
  difference() {
    union() {
      // Spine
      translate([-spine_thickness, 0, 0])
        cuboid([spine_thickness, clamp_depth, opening_width + 2 * jaw_thickness], anchor=BOTTOM);

      // Bottom jaw
      translate([spine_thickness, 0, 0])
        cuboid([arm_length, clamp_depth, jaw_thickness], anchor=BOTTOM);

      // Top jaw
      translate([spine_thickness, 0, jaw_thickness + opening_width])
        cuboid([arm_length, clamp_depth, jaw_thickness], anchor=BOTTOM);
    }

    // Internal thread hole
    translate([
      arm_length / 2 + thread_offset,
      0,
      jaw_thickness + opening_width + jaw_thickness / 2
    ])
      threaded_rod(
        d = thread_diameter,
        l = thread_length,
        pitch = thread_pitch,
        internal = true,
        bevel = true,
        anchor = CENTER
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
      internal = false,
      bevel = true,
      anchor = BOTTOM
    );

    // Knob
    translate([0, 0, screw_length])
      cyl(d = knob_diameter, h = knob_height, anchor = BOTTOM);

    // Neck + Ball (attached directly below screw)
    translate([0, 0, 0])
      union() {
        // Neck at base of screw
        cyl(d = ball_diameter * 0.6, h = ball_diameter * 0.4, anchor = BOTTOM);

        // Ball below neck
        translate([0, 0, -ball_diameter / 2])
          sphere(d = ball_diameter);
      }
  }
}

module press_pad_socket() {
  difference() {
    // Main pad body
    cyl(d = pad_diameter, h = pad_thickness, anchor = BOTTOM);

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

//--- Layout for Printing ---
translate([0, 0, 0])
  rotate([0, 0, 0])
    clamp_body();

translate([arm_length + 20, 0, 0])
  rotate([180, 0, 0])
    clamp_screw();

translate([arm_length + 50, 0, 0])
  press_pad_socket();
