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
// Reduce diameter at end for easier insertion. 1 is no reduction, 0.9 is 10% reduction
screw_start_reduction = 0.9; //[0:0.01:1]
knob_diameter      = 30;
knob_height        = 8;

/* [Ball Joint] */
ball_diameter     = 6;
ball_clearance    = 0.3;
socket_depth      = 3;
// how smoothly rounded or polygonal the rounding is (24 is plenty)
roundedness = 8; //[4:4:64]

/* [Press Pad] */
pad_diameter     = 20;
pad_thickness    = 4;

/* [OpenGrid Snap] */
snap_type = "lite"; // [lite, full]
snap_is_directional = true; // [true, false]

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
    hull() {
        // Base point at the corner
        translate([0, 0, 0])
            cuboid([0.1, clamp_width, 0.1], anchor=BOTTOM);
            
        // Point up the spine
        translate([0, 0, gusset_height])
            cuboid([0.1, clamp_width, 0.1], anchor=BOTTOM);
            
        // Point out along the arm
        translate([gusset_length, 0, 0])
            cuboid([0.1, clamp_width, 0.1], anchor=BOTTOM);
    }
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
                //BOTTOM+RIGHT,TOP+RIGHT,FRONT+BOTTOM,FRONT+TOP,FRONT+RIGHT

            translate([spine_thickness-1, 0, arm_thickness-2])
                corner_gusset();

            // Top jaw
            translate([spine_thickness + (arm_length)/2, 0, arm_thickness + opening_width])
                cuboid([arm_length, clamp_width, arm_thickness], anchor=BOTTOM);

            // Bottom gusset
            // translate([spine_thickness-1, 0, arm_thickness-2])
            //     corner_gusset();

            // Top gusset
            translate([spine_thickness-1, 0,clamp_opening+arm_thickness+2])
                rotate([0, 90, 0])
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
    //   end_len = 2,
      end_len1 = 2,
      d1 = thread_diameter * screw_start_reduction, // Reduce diameter at end for easier insertion
      internal = false,
      bevel = true,
      anchor = BOTTOM
    );

    // Knob
    tex = texture("diamonds");
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

module openGridSnap(lite=false, directional=false, orient, anchor, spin){
	module openGridSnapNub(w, nub_h, nub_w, nub_d, b_y, top_wedge_h, bot_wedge_h, r_x, r_r, r_s){
		move([w/2, 0, 0]) 
		intersection(){
			difference(){
				//bounding box
				zmove(nub_h) cuboid([nub_d,nub_w,2-nub_h], anchor=CENTER+LEFT+BOTTOM) ;
				//top part
				zmove(2) rotate([0,180,90]) wedge([nub_w,nub_d,top_wedge_h], anchor=CENTER+BOTTOM+BACK);
				//bottom part
				zmove(nub_h) rotate([0,0,90]) ymove(b_y) wedge([nub_w,0.4,bot_wedge_h], anchor=CENTER+BOTTOM+BACK);
			};
			//rounding
			xmove(r_x) yscale(r_s) cyl($fn=600, r=r_r, h=2, anchor=BOTTOM);
		};
	}

	w=24.80;
	fulldiff=3.4;
	h=lite ? 3.4 : fulldiff*2;
	attachable(orient=orient, anchor=anchor, spin=spin, size=[w,w,h]){
		zmove(-h/2) difference(){
			core=3 + (lite ? 0 : fulldiff);
			top_h=0.4; 
			top_nub_h=1.1;

			union() {
				//top
				zmove(h-top_h) cuboid([w,w,top_h], rounding=3.262743, edges="Z", $fn=2, anchor=BOTTOM);
				// core
				cuboid([w,w,core], rounding=4.81837, edges="Z", $fn=2, anchor=BOTTOM);
				//top nub
				offs=2.02;
				intersection(){
					zmove(core-top_nub_h) cuboid([w,w,top_nub_h], rounding=3.262743, edges="Z", $fn=2, anchor=BOTTOM);
					zrot_copies(n=4) move([w/2-offs,w/2-offs,core]) rotate([180, 0, 135]) wedge(size=[6.817,top_nub_h,top_nub_h], anchor=CENTER+BOTTOM);
				};
				//bottom nub
				zmove(lite ? 0 : fulldiff) zrot_copies(n=4)
					if (!directional || ($idx==1 || $idx==3))
					openGridSnapNub(
						w=w,
						nub_h=0.2,
						nub_w=11,
						nub_d=0.4,
						top_wedge_h=0.6,
						bot_wedge_h=0.6,
						r_x=-12.36,
						r_s=1.36,
						r_r=13.025,
						b_y=-0
					);
				//directional nubs 
				 if (directional) {
					//front directional nub
					zmove(lite ? 0 : fulldiff) openGridSnapNub(
						w=w,
						nub_h=0,
						nub_w=14,
						nub_d=0.8,
						top_wedge_h=1.0,
						bot_wedge_h=0.4,
						r_x=-11.75,
						r_s=1.26,
						r_r=13.025,
						b_y=-0.4
					);
					 
					//rear directional nub
					zrot(180) zmove(lite ? 0 : fulldiff) openGridSnapNub(
						w=w,
						nub_h=0.65,
						nub_w=10.8,
						nub_d=0.4,
						top_wedge_h=0.6,
						bot_wedge_h=0.6,
						r_x=-12.41,
						r_s=1.37,
						r_r=13.025,
						b_y=0
					);
				};
			};
			//bottom click holes
			zrot_copies(n=4)
				move([w/2-1, 0, 0])
				if (!directional || $idx==1 || $idx==3)
					cuboid([0.6,12.4,2.8 + (lite ? 0 : fulldiff)], rounding=0.3, $fn=100, edges="Z", anchor=BOTTOM);
			//bottom click holes for rear directional
			if (directional) {
				zrot(180) move([w/2-1, 0, 0.599]) cuboid([0.6, 12.4, 2.2 + (lite ? 0 : fulldiff) ], rounding=0.3, $fn=100, edges="Z", anchor=BOTTOM);
				zrot(180) move([w/2-1.2, 0, 0]) prismoid(size1=[0.6, 12.4], size2=[0.6, 12.4], h=0.6, shift=[0.2,0], rounding=0.3, $fn=100);
				zrot(180) move([w/2-0.1, 0, 0]) rotate([0,0,0]) prismoid(size1=[0.2, 20], size2=[0, 20], shift=[0.1,0], h=0.6, anchor=BOTTOM);
			};

			//bottom wall click holes
			zrot_copies(n=4)
				move([w/2, 0, 2.2 + (lite ? 0 : fulldiff)])
				if (!directional || ($idx>0))
					cuboid([1.4,12,0.4], anchor=BOTTOM);

			//directional indicator
			if (directional) move([9.5,0,0]) cylinder(r1=2, r2=1.5, h=0.4, $fn=2);
		};
		children();
	};
};

// OpenGrid Snap with Hole for clamp_screw
module openGridSnapWithHole(lite=false, directional=false, orient, anchor, spin){
    union() {
        difference() {
            // Create the OpenGrid Snap base
            openGridSnap(lite=lite, directional=directional, orient=orient, anchor=anchor, spin=spin);

            // Add a hole for the clamp screw
            // translate([0, 0, -0.1])
            //     threaded_rod(
            //         d = thread_diameter,
            //         l = adj_screw_length,
            //         pitch = thread_pitch,
            //         internal = true,
            //         bevel = true,
            //         anchor = CENTER
            //     );
            translate([0, 0, -5])
                cylinder(d = thread_diameter + .5, h = 20, anchor = BOTTOM);
        }
    }
}

  
 //--- Layout for Printing ---
xdistribute(sizes=[(5),knob_diameter,pad_diameter,30], spacing=10){
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

    // openGridSnap(lite=true, directional=true); 
    openGridSnapWithHole(lite=(snap_type=="lite"), directional=snap_is_directional);
 }